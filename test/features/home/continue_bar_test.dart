import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

const _config = GameConfig(
  gameId: 'sample',
  seats: [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'range': 20},
);

GoRouterState _routerState(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Navigator).last)).state;

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('hidden without history', (tester) async {
    await pumpApp(tester, size: const Size(360, 740), db: db, disableAnimations: true);
    expect(find.textContaining('Pokračovat'), findsNothing);
  });

  testWidgets('with a remembered setup it shows a summary and starts the game', (tester) async {
    await tester.runAsync(() => GameStore(db).saveLastConfig(_config));
    await pumpApp(tester, size: const Size(360, 740), db: db, disableAnimations: true);
    expect(find.text('Pokračovat: Hádej číslo'), findsOneWidget);
    expect(find.text('2 hráči (1 + 1 🤖) · Střední'), findsOneWidget);
    await tester.tap(find.text('Pokračovat: Hádej číslo'));
    await tester.pumpAndSettle();
    expect(_routerState(tester).uri.path, '/play/sample');
    expect(_routerState(tester).extra, _config);
  });

  testWidgets('with a saved game it offers to resume it', (tester) async {
    const save = SavedGame(config: _config, seed: 3, moves: [Move(seat: 0, type: 'guess', data: {'value': 10})]);
    await tester.runAsync(() async {
      // The saved game's human (profile 1) must exist, or it cannot be resumed.
      await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults);
      await GameStore(db).saveLastConfig(_config);
      await GameStore(db).saveSession(save);
    });
    await pumpApp(tester, size: const Size(360, 740), db: db, disableAnimations: true);
    expect(find.text('Rozehraná hra'), findsOneWidget);
    await tester.tap(find.text('Pokračovat: Hádej číslo'));
    await tester.pumpAndSettle();
    expect(_routerState(tester).uri.path, '/play/sample');
    expect(_routerState(tester).extra, save);
  });
}
