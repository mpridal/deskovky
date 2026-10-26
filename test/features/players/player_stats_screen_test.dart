import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/players/player_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<int> _seed(WidgetTester tester, AppDatabase db) async => (await tester.runAsync(() async {
  final t = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  final stats = StatsRepository(db);
  for (final (place, seconds) in [(1, 75), (1, 62), (2, 30)]) {
    await stats.recordMatch(
      MatchRecord(
        gameId: 'sample',
        playedAt: DateTime.now(),
        duration: Duration(seconds: seconds),
        difficulty: null,
        participants: [
          MatchParticipant(seat: 0, playerId: t, place: place, score: place == 1 ? 7 : 2, stars: place == 1 ? 3 : 1),
          MatchParticipant(seat: 1, playerId: null, place: 3 - place, score: 1, stars: 0),
        ],
      ),
    );
  }
  await stats.awardBadge(t, 'first_win');
  return t;
}))!;

Future<void> _open(WidgetTester tester, AppDatabase db, int id, {Locale locale = const Locale('cs'), double textScale = 1}) async {
  await pumpApp(tester, size: const Size(360, 740), db: db, locale: locale, textScale: textScale);
  GoRouter.of(tester.element(find.byType(Navigator).first)).push('/players/$id/stats');
  await tester.pumpAndSettle();
  expect(find.byType(PlayerStatsScreen), findsOneWidget);
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('shows totals, the game records and badges earned and still locked', (tester) async {
    final id = await _seed(tester, db);
    await _open(tester, db, id);
    expect(find.text('Statistiky: Tereza'), findsOneWidget);
    Finder tile(String key) => find.byKey(ValueKey(key));
    expect(find.descendant(of: tile('statPlayed'), matching: find.text('3')), findsOneWidget);
    expect(find.descendant(of: tile('statWins'), matching: find.text('2')), findsOneWidget);
    expect(find.descendant(of: tile('statWinRate'), matching: find.text('67 %')), findsOneWidget);
    expect(find.descendant(of: tile('statBestStreak'), matching: find.text('2')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Nejrychlejší výhra: 1:02'), 200);
    expect(find.text('Nejlepší skóre: 7'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('badge_first_win')), 200);
    expect(find.byKey(const ValueKey('badge_first_win_earned')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('badge_streak5')), 200);
    expect(find.byKey(const ValueKey('badge_streak5_earned')), findsNothing);
  });

  testWidgets('players list leads to statistics', (tester) async {
    await _seed(tester, db);
    await pumpApp(tester, size: const Size(360, 740), db: db);
    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Statistiky: Tereza'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerStatsScreen), findsOneWidget);
  });

  testWidgets('a player without games sees a friendly note', (tester) async {
    final id = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Babi', avatar: AvatarSpec.defaults)))!.id;
    await _open(tester, db, id);
    expect(find.text('Zatím žádná dohraná hra.'), findsOneWidget);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('statistics fit 360 dp at 130 % in $code', (tester) async {
        final id = await _seed(tester, db);
        await _open(tester, db, id, locale: Locale(code), textScale: 1.3);
        final list = find.byType(Scrollable).first;
        for (var i = 0; i < 12; i++) {
          expect(tester.takeException(), isNull);
          await tester.drag(list, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
