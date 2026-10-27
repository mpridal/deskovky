import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/tictactoe/tictactoe_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

GameScreenState _screen(WidgetTester tester) => tester.state<GameScreenState>(find.byType(GameScreen));

/// Lets real database I/O started inside fake time finish, then settles.
Future<void> _settleIo(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }
}

/// The person takes the first free cell of the middle rows outward.
Future<void> _humanMove(WidgetTester tester, TictactoeState s) async {
  final middle = s.size ~/ 2;
  final order = [for (var i = 0; i < s.cells.length; i++) i]
    ..sort((a, b) => ((a ~/ s.size - middle).abs() + (a % s.size - middle).abs()).compareTo(
      (b ~/ s.size - middle).abs() + (b % s.size - middle).abs(),
    ));
  final cell = order.firstWhere((i) => s.cells[i] < 0);
  final finder = find.byKey(ValueKey('cell${cell % s.size},${cell ~/ s.size}'));
  await tester.tapAt(tester.getCenter(finder));
  await tester.pump();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('home → setup → a 3×3 game against the robot → results with stars; the setup is remembered', (tester) async {
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);

    await tester.tap(find.text('Piškvorky'));
    await tester.pumpAndSettle();
    expect(find.byType(GameSetupScreen), findsOneWidget);
    for (final label in ['Rychle', 'vždy hráč 1']) {
      await tester.scrollUntilVisible(find.text(label), 120, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Hrát!'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Tereza, polož ✕'), findsOneWidget);

    GameSession<Object?>? finished;
    for (var guard = 0; guard < 60; guard++) {
      if (find.byType(GameScreen).evaluate().isEmpty) break;
      final session = _screen(tester).debugSession!;
      if (session.rules.isOver(session.state)) {
        finished = session;
        break;
      }
      final s = session.state as TictactoeState;
      if (s.current == 0) await _humanMove(tester, s);
      await tester.pump(const Duration(milliseconds: 300));
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
    final match = (await tester.runAsync(() => StatsRepository(db).allMatches()))!.single;
    expect(match.gameId, 'tictactoe');
    expect(match.difficulty, Difficulty.medium);
    final result = finished.rules.result(finished.state);
    expect(match.participants.first.stars, result.stars.first);

    // The setup opens with the last choices.
    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/play/tictactoe/setup');
    await _settleIo(tester);
    // At the end of the setup list, below "Kde se hraje".
    await tester.scrollUntilVisible(
      find.textContaining('Nastavení načteno z minulé hry'),
      120,
      scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
    );
    expect(find.textContaining('Nastavení načteno z minulé hry'), findsOneWidget);
  });

  testWidgets('a 10×10 game is saved on exit and continues the same after a restart', (tester) async {
    final tereza = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!.id;
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(
      '/play/tictactoe',
      extra: GameConfig(
        gameId: 'tictactoe',
        seats: [HumanSeat(tereza), const RobotSeat()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {'board': 10, 'start': 'first', 'confirm': false},
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _humanMove(tester, _screen(tester).debugSession!.state as TictactoeState);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
    }
    final session = _screen(tester).debugSession!;
    expect(session.moves, hasLength(4), reason: 'two stones each');
    final hash = session.hash;

    await tester.tap(find.bySemanticsLabel(RegExp('^Konec')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit'));
    await _settleIo(tester);
    expect(await tester.runAsync(() => GameStore(db).savedSession('tictactoe')), isNotNull);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _settleIo(tester);
    await tester.tap(find.text('Pokračovat: Piškvorky'));
    await _settleIo(tester);
    final restored = _screen(tester).debugSession!;
    expect(restored.hash, hash);
    expect((restored.state as TictactoeState).size, 10);
  });
}
