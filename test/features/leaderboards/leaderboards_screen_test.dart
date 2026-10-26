import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/players/player_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _seed(WidgetTester tester, AppDatabase db) => tester.runAsync(() async {
  final players = PlayerRepository(db);
  final t = (await players.create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  final k = (await players.create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
  final stats = StatsRepository(db);
  final now = DateTime.now();
  final points = PointsRepository(db);
  Future<void> game(List<(int?, int)> seats, {DateTime? at, Difficulty? difficulty}) async {
    final id = await stats.recordMatch(
    MatchRecord(
      gameId: 'sample',
      playedAt: at ?? now,
      duration: const Duration(seconds: 30),
      difficulty: difficulty,
      participants: [
        for (var i = 0; i < seats.length; i++)
          MatchParticipant(seat: i, playerId: seats[i].$1, place: seats[i].$2, score: 3, stars: 2),
      ],
    ),
    );
    for (final (player, place) in seats) {
      if (player != null) {
        await points.addGameLines(player, [PointsLine(PointsReason.win, place == 1 ? 20 : 3)], matchId: id);
      }
    }
  }
  await game([(t, 1), (k, 2)]);
  await game([(t, 1), (null, 2)], difficulty: Difficulty.hard);
  await game([(k, 1), (t, 2)], at: now.subtract(const Duration(days: 40)));
});

Future<void> _open(WidgetTester tester, AppDatabase db, {Locale locale = const Locale('cs'), double textScale = 1}) async {
  await pumpApp(tester, size: const Size(360, 740), db: db, locale: locale, textScale: textScale);
  await tester.tap(find.byIcon(Icons.emoji_events_outlined));
  await tester.pumpAndSettle();
}

Finder _row(String name) => find.ancestor(of: find.text(name), matching: find.byKey(const ValueKey('leaderboardRow')));

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('empty leaderboard invites to play', (tester) async {
    await _open(tester, db);
    expect(find.text('Zatím tu nikdo není. Dohrajte hru!'), findsOneWidget);
  });

  testWidgets('all time: people ranked by wins, robots never listed', (tester) async {
    await _seed(tester, db);
    await _open(tester, db);
    expect(find.byKey(const ValueKey('leaderboardRow')), findsNWidgets(2));
    expect(find.descendant(of: _row('Tereza'), matching: find.text('● 43')), findsOneWidget);
    expect(find.descendant(of: _row('Kuba'), matching: find.text('● 23')), findsOneWidget);
    expect(find.descendant(of: _row('Tereza'), matching: find.text('2 výhry · 3 hry · 67 %')), findsOneWidget);
    expect(find.descendant(of: _row('Kuba'), matching: find.text('1 výhra · 2 hry · 50 %')), findsOneWidget);
    expect(tester.getTopLeft(_row('Tereza')).dy, lessThan(tester.getTopLeft(_row('Kuba')).dy));
    expect(find.textContaining('Čipík'), findsNothing);
  });

  testWidgets('this week leaves out the old game; hard difficulty only the robot game', (tester) async {
    await _seed(tester, db);
    await _open(tester, db);
    await tester.tap(find.text('Týden'));
    await tester.pumpAndSettle();
    expect(find.descendant(of: _row('Kuba'), matching: find.text('● 3')), findsOneWidget);
    await tester.tap(find.text('Vše'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Těžká'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('leaderboardRow')), findsOneWidget);
    expect(_row('Tereza'), findsOneWidget);
  });

  testWidgets('tapping a row opens the player statistics', (tester) async {
    await _seed(tester, db);
    await _open(tester, db);
    await tester.tap(_row('Kuba'));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerStatsScreen), findsOneWidget);
    expect(find.text('Statistiky: Kuba'), findsOneWidget);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('leaderboard fits 360 dp at 130 % in $code', (tester) async {
        await _seed(tester, db);
        await _open(tester, db, locale: Locale(code), textScale: 1.3);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
