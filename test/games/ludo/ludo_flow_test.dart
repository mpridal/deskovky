import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game_kit/dice.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

const _config = GameConfig(
  gameId: 'ludo',
  seats: [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: {'length': 'short'},
);

GameSession<Object?>? _session(WidgetTester tester) {
  final screen = find.byType(GameScreen);
  return screen.evaluate().isEmpty ? null : tester.state<GameScreenState>(screen).debugSession;
}

/// The person on seat 0 rolls and moves the first movable piece; robots
/// play by themselves.
Future<void> _playTurn(WidgetTester tester, GameSession<Object?> session) async {
  final s = session.state as LudoState;
  if (session.rules.currentSeat(s) == 0) {
    if (s.phase == LudoPhase.roll) {
      await tester.tap(find.byType(Dice));
    } else {
      final piece = LudoRules.currentSteps(s).first.piece;
      await tester.tap(find.byKey(ValueKey('piece0-$piece')), warnIfMissed: false);
    }
  }
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('a game against a robot ends in the results and is recorded with stars', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/play/ludo', extra: _config);
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));

    GameSession<Object?>? finished;
    for (var guard = 0; guard < 4000; guard++) {
      final session = _session(tester);
      if (session == null) break;
      if (session.rules.isOver(session.state)) {
        finished = session;
        break;
      }
      await _playTurn(tester, session);
    }
    expect(finished, isNotNull, reason: 'the game ended');
    final replay = GameSession.restore(finished!.rules, finished.toSave())!;
    expect(replay.hash, finished.hash);

    for (var i = 0; i < 30 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);

    final matches = (await tester.runAsync(() => StatsRepository(db).allMatches()))!;
    expect(matches, hasLength(1));
    expect(matches.single.gameId, 'ludo');
    final person = matches.single.participants.firstWhere((p) => !p.robot);
    expect(person.stars, person.place == 1 ? 3 : 2);
  });

  testWidgets('a game left in the middle continues where it was', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/play/ludo', extra: _config);
    await tester.pumpAndSettle();
    for (var i = 0; i < 40; i++) {
      await _playTurn(tester, _session(tester)!);
    }
    final before = _session(tester)!;
    final hash = before.hash;
    expect(before.moves.length, greaterThan(5));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konec').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(find.text('Pokračovat: Člověče, nezlob se'), findsOneWidget);

    await tester.tap(find.text('Pokračovat: Člověče, nezlob se'));
    for (var i = 0; i < 10 && _session(tester) == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(_session(tester)!.hash, hash);
    // Leave without letting the robot move on.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  });
}
