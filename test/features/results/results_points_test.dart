import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/features/game_play/game_outcome.dart';
import 'package:deskovky/features/game_play/seat_identity.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

const _lines = [
  PointsLine(PointsReason.win, 20),
  PointsLine(PointsReason.stars, 6, count: 3),
  PointsLine(PointsReason.streak, 5, count: 3),
  PointsLine(PointsReason.firstToday, 5),
  PointsLine(PointsReason.record, 5),
  PointsLine(PointsReason.badge, 15, badgeId: 'first_win'),
];

GameOutcomeView _outcome() => GameOutcomeView(
  config: const GameConfig(
    gameId: 'sample',
    seats: [HumanSeat(1), HumanSeat(2), HumanSeat(3), HumanSeat(4)],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: {'range': 20},
  ),
  result: const GameResult(places: [1, 2, 3, 4], scores: [4, 3, 2, 1], stars: [3, 2, 1, 0]),
  seats: [
    for (final (i, n) in ['Tereza', 'Maximilián', 'Babička', 'Kuba'].indexed)
      SeatIdentity(seat: i, name: n, profile: null, difficulty: null),
  ],
  rewards: MatchRewards(
    points: {
      1: const PlayerPoints(lines: _lines, levelBefore: 0, levelAfter: 1),
      2: const PlayerPoints(lines: [PointsLine(PointsReason.second, 8)], levelBefore: 2, levelAfter: 2),
      3: const PlayerPoints(lines: [PointsLine(PointsReason.participation, 3)], levelBefore: 0, levelAfter: 0),
      4: const PlayerPoints(lines: [PointsLine(PointsReason.participation, 3)], levelBefore: 0, levelAfter: 0),
    },
  ),
);

Future<void> _show(WidgetTester tester, {Locale locale = const Locale('cs'), double textScale = 1}) async {
  await pumpApp(tester, size: const Size(360, 740), locale: locale, textScale: textScale, disableAnimations: true);
  GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample/results', extra: _outcome());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('every person gets a points breakdown with a total; a level-up is announced', (tester) async {
    await _show(tester);
    final card = find.byKey(const ValueKey('points1'));
    await tester.scrollUntilVisible(card, 200);
    for (final text in ['Výhra', 'Hodnocení 3 ★', 'Série 3 výher', 'První hra dne', 'Nový osobní rekord', 'Odznak: První výhra', 'Celkem +56 ●', 'Nová úroveň 1!']) {
      expect(find.descendant(of: card, matching: find.text(text)), findsOneWidget, reason: text);
    }
    await tester.scrollUntilVisible(find.byKey(const ValueKey('points4')), 200);
    expect(find.descendant(of: find.byKey(const ValueKey('points2')), matching: find.text('2. místo')), findsOneWidget);
  });

  testWidgets('a tried item that is affordable now is announced', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    final kuba = (await tester.runAsync(() async {
      final id = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
      await SettingsRepository(db).addTriedItem(id, 'wizard_hat');
      return id;
    }))!;
    final outcome = GameOutcomeView(
      config: GameConfig(
        gameId: 'sample',
        seats: [HumanSeat(kuba), const RobotSeat()],
        difficulty: Difficulty.medium,
        robotSpeed: RobotSpeed.fast,
        options: const {'range': 20},
      ),
      result: const GameResult(places: [1, 2], scores: [4, 3], stars: [3, 0]),
      seats: [
        const SeatIdentity(seat: 0, name: 'Kuba', profile: null, difficulty: null),
        const SeatIdentity(seat: 1, name: 'Robot', profile: null, difficulty: Difficulty.medium),
      ],
      rewards: MatchRewards(
        points: {kuba: const PlayerPoints(lines: [PointsLine(PointsReason.win, 30)], levelBefore: 2, levelAfter: 2, balanceBefore: 380)},
      ),
    );
    await pumpApp(tester, size: const Size(360, 740), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample/results', extra: outcome);
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pumpAndSettle();
    }
    final notice = find.text('Kuba, teď si můžeš koupit: Čarodějnický klobouk!');
    await tester.scrollUntilVisible(notice, 200);
    expect(notice, findsOneWidget);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('4 breakdowns fit 360 dp at 130 % in $code', (tester) async {
        await _show(tester, locale: Locale(code), textScale: 1.3);
        final list = find.byType(Scrollable).first;
        for (var i = 0; i < 15; i++) {
          expect(tester.takeException(), isNull);
          await tester.drag(list, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
