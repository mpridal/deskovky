import 'package:deskovky/app/providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:deskovky/ui_kit/components/player_slot.dart';
import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<List<int>> _players(WidgetTester tester, AppDatabase db, List<String> names) async =>
    (await tester.runAsync(() async {
      final ids = <int>[];
      for (final n in names) {
        ids.add((await PlayerRepository(db).create(name: n, avatar: AvatarSpec.defaults)).id);
      }
      return ids;
    }))!;

Future<void> _openSetup(WidgetTester tester, AppDatabase db) async {
  await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
  await tester.tap(find.text('Hádej číslo'));
  await tester.pumpAndSettle();
  expect(find.byType(GameSetupScreen), findsOneWidget);
}

Finder _slot(int seat) => find.byKey(ValueKey('seat$seat'));

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 120, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('a solo game whose difficulty is not about robots still offers it (Miny: board size)', (tester) async {
    final ids = await _players(tester, db, ['Kuba']);
    await tester.runAsync(
      () => GameStore(db).saveLastConfig(
        GameConfig(
          gameId: 'minesweeper',
          seats: [HumanSeat(ids.first)],
          difficulty: Difficulty.hard,
          robotSpeed: RobotSpeed.normal,
          options: const {},
        ),
      ),
    );
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [startGameProvider.overrideWithValue('minesweeper')]);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Obtížnost'));
    expect(find.text('Obtížnost'), findsOneWidget);
    expect(find.text('Rychlost robotů'), findsNothing, reason: 'no robots, no robot speed');
  });

  testWidgets('defaults: the active player and robot Čipík', (tester) async {
    await _players(tester, db, ['Tereza']);
    await _openSetup(tester, db);
    expect(find.descendant(of: _slot(0), matching: find.text('Tereza')), findsOneWidget);
    expect(find.descendant(of: _slot(1), matching: find.text('Čipík')), findsOneWidget);
    expect(find.text('Hráči · 1 člověk + 1 robot'), findsOneWidget);
  });

  testWidgets('4 seats with 2 people: seats 3 and 4 are robots in their seat colours', (tester) async {
    await _players(tester, db, ['Tereza', 'Kuba']);
    await _openSetup(tester, db);
    await tester.tap(find.descendant(of: find.byType(SegmentedControl<int>).first, matching: find.text('4')));
    await tester.pumpAndSettle();
    await tester.tap(_slot(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuba').last);
    await tester.pumpAndSettle();

    expect(find.text('Hráči · 2 lidé + 2 roboti'), findsOneWidget);
    for (final seat in [2, 3]) {
      await _scrollTo(tester, _slot(seat));
      final robot = tester.widget<RobotAvatar>(find.descendant(of: _slot(seat), matching: find.byType(RobotAvatar)));
      expect(robot.color, AppColors.players[seat]);
    }
    expect(find.descendant(of: _slot(3), matching: find.text('Bzučák')), findsOneWidget);
  });

  testWidgets('a robot cannot become human when everybody already sits', (tester) async {
    await _players(tester, db, ['Tereza']);
    await _openSetup(tester, db);
    await tester.tap(_slot(1));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Všichni hráči už sedí u stolu.'), findsOneWidget);
  });

  testWidgets('arrow moves a player down the table', (tester) async {
    await _players(tester, db, ['Tereza']);
    await _openSetup(tester, db);
    await tester.tap(find.descendant(of: _slot(0), matching: find.bySemanticsLabel('Posunout níž')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: _slot(1), matching: find.text('Tereza')), findsOneWidget);
    expect(find.descendant(of: _slot(0), matching: find.text('Robík')), findsOneWidget);
  });

  testWidgets('difficulty and speed only show with a robot at the table', (tester) async {
    await _players(tester, db, ['Tereza', 'Kuba']);
    await _openSetup(tester, db);
    expect(find.text('Obtížnost robotů'), findsOneWidget);
    await tester.tap(_slot(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuba').last);
    await tester.pumpAndSettle();
    expect(find.text('Obtížnost robotů'), findsNothing);
    expect(find.text('Rychlost robotů'), findsNothing);
  });

  testWidgets('remembered setup is restored with a note; a deleted profile becomes a robot', (tester) async {
    final ids = await _players(tester, db, ['Tereza', 'Kuba']);
    await tester.runAsync(() async {
      await GameStore(db).saveLastConfig(GameConfig(
        gameId: 'sample',
        seats: [HumanSeat(ids[0]), HumanSeat(ids[1]), const RobotSeat()],
        difficulty: Difficulty.hard,
        robotSpeed: RobotSpeed.slow,
        options: const {'range': 100},
      ));
      await PlayerRepository(db).delete(ids[1]);
    });
    await _openSetup(tester, db);
    expect(find.textContaining('Nastavení načteno z minulé hry'), findsOneWidget);
    expect(find.textContaining('volné sloty doplněny roboty'), findsOneWidget);
    expect(find.text('Hráči · 1 člověk + 2 roboti'), findsOneWidget);
    expect(find.descendant(of: _slot(1), matching: find.text('Čipík')), findsOneWidget);
  });

  testWidgets('Play saves the setup and opens the game', (tester) async {
    await _players(tester, db, ['Tereza']);
    await _openSetup(tester, db);
    await _scrollTo(tester, find.text('1–100'));
    await tester.tap(find.text('1–100'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hrát!'));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(Navigator).last));
    expect(router.state.uri.path, '/play/sample');
    final saved = await tester.runAsync(() => GameStore(db).lastConfig('sample'));
    expect(saved!.options['range'], 100);
    expect(saved.seats.length, 2);
  });

  testWidgets('every slot shows its seat colour stripe', (tester) async {
    await _players(tester, db, ['Tereza']);
    await _openSetup(tester, db);
    final slots = tester.widgetList<PlayerSlot>(find.byType(PlayerSlot)).toList();
    expect([for (final s in slots) s.seat], [0, 1]);
  });

  testWidgets('leaving the setup before it has loaded does not crash', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db);
    final router = GoRouter.of(tester.element(find.byType(Navigator).first));
    router.push('/play/sample/setup');
    await tester.pump();
    router.go('/games');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
