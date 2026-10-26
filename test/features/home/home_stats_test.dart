import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/shop/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<(int, int)> _seed(WidgetTester tester, AppDatabase db) async => (await tester.runAsync(() async {
  final t = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  final k = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
  final stats = StatsRepository(db);
  for (final (tStars, kStars, tPlace) in [(2, 1, 1), (1, 3, 2), (2, 0, 1)]) {
    await stats.recordMatch(
      MatchRecord(
        gameId: 'sample',
        playedAt: DateTime.now(),
        duration: Duration.zero,
        difficulty: null,
        participants: [
          MatchParticipant(seat: 0, playerId: t, place: tPlace, score: 1, stars: tStars),
          MatchParticipant(seat: 1, playerId: k, place: 3 - tPlace, score: 1, stars: kStars),
        ],
      ),
    );
  }
  await stats.awardBadge(k, 'first_win');
  return (t, k);
}))!;

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets("the game card shows the active player's best stars", (tester) async {
    final (t, k) = await _seed(tester, db);
    await tester.runAsync(() => SettingsRepository(db).setActivePlayerId(t));
    await pumpApp(tester, size: const Size(412, 915), db: db);
    final card = find.byKey(const ValueKey('gameCard0'));
    expect(find.descendant(of: card, matching: find.text('★★☆')), findsOneWidget);
    await tester.runAsync(() => SettingsRepository(db).setActivePlayerId(k));
    await tester.pumpAndSettle();
    expect(find.descendant(of: card, matching: find.text('★★★')), findsOneWidget);
  });

  testWidgets('a game never played shows no stars', (tester) async {
    await tester.runAsync(() async {
      final p = await PlayerRepository(db).create(name: 'Babi', avatar: AvatarSpec.defaults);
      await SettingsRepository(db).setActivePlayerId(p.id);
    });
    await pumpApp(tester, size: const Size(412, 915), db: db);
    expect(find.descendant(of: find.byKey(const ValueKey('gameCard0')), matching: find.textContaining('★')), findsNothing);
  });

  testWidgets("tablet panel: this week's leaderboard and the last reward", (tester) async {
    await _seed(tester, db);
    await pumpApp(tester, size: const Size(1280, 800), db: db);
    final panel = find.byKey(const Key('rightPanel'));
    final rows = find.byWidgetPredicate((w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('weekRow'));
    expect(find.descendant(of: panel, matching: rows), findsNWidgets(2));
    expect(find.descendant(of: panel, matching: find.text('První výhra')), findsOneWidget);
    expect(find.descendant(of: panel, matching: find.textContaining('Kuba')), findsWidgets);
  });

  testWidgets("the top bar shows the active player's points and level", (tester) async {
    final (t, _) = await _seed(tester, db);
    await tester.runAsync(() async {
      await SettingsRepository(db).setActivePlayerId(t);
      await PointsRepository(db).gift(t, 74);
    });
    await pumpApp(tester, size: const Size(412, 915), db: db);
    expect(find.text('● 74'), findsOneWidget);
    expect(find.text('Úr. 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Body: 74'), findsOneWidget);
  });

  testWidgets("the coin pill opens the active player's shop", (tester) async {
    final (t, _) = await _seed(tester, db);
    await tester.runAsync(() => SettingsRepository(db).setActivePlayerId(t));
    await pumpApp(tester, size: const Size(412, 915), db: db);
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Body: ')));
    await tester.pumpAndSettle();
    expect(find.byType(ShopScreen), findsOneWidget);
    expect(tester.widget<ShopScreen>(find.byType(ShopScreen)).playerId, t);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    testWidgets('the top bar with points fits 360 dp at 130 % with a long name in es', (tester) async {
      await tester.runAsync(() async {
        final p = await PlayerRepository(db).create(name: 'Maximiliánek123', avatar: AvatarSpec.defaults);
        await SettingsRepository(db).setActivePlayerId(p.id);
        await PointsRepository(db).gift(p.id, 12345);
      });
      await pumpApp(tester, size: const Size(360, 740), db: db, locale: const Locale('es'), textScale: 1.3);
      expect(tester.takeException(), isNull);
      expect(find.text('● 12345'), findsOneWidget);
    });
  });
}
