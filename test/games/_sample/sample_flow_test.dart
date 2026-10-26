import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

void main() {
  testWidgets('home → setup (4 seats, 2 people) → game with robots → results → play again → continue', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() async {
      await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults);
      await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults);
    });
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);

    // Setup: 4 seats, Kuba on seat 2, robots fill seats 3–4, fast robots, range 1–20.
    await tester.tap(find.text('Hádej číslo'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(SegmentedControl<int>).first, matching: find.text('4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('seat1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kuba').last);
    await tester.pumpAndSettle();
    expect(find.text('Hráči · 2 lidé + 2 roboti'), findsOneWidget);
    for (final label in ['Rychle', '1–20']) {
      await tester.scrollUntilVisible(find.text(label), 120, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Hrát!'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);

    // Play: humans always take the lowest possible number, robots play themselves.
    GameSession<Object?>? finished;
    for (var guard = 0; guard < 200; guard++) {
      final screen = find.byType(GameScreen);
      if (screen.evaluate().isEmpty) break;
      final session = tester.state<GameScreenState>(screen).debugSession!;
      if (session.rules.isOver(session.state)) {
        finished = session;
        break;
      }
      final seat = session.rules.currentSeat(session.state)!;
      if (seat < 2) {
        final tile = find.byKey(ValueKey('number${(session.state as SampleState).low}'));
        await tester.ensureVisible(tile);
        await tester.tap(tile);
      }
      await tester.pump(const Duration(milliseconds: 260));
    }
    expect(finished, isNotNull, reason: 'the game ended');

    // Replay contract: every action went through Move/LocalTransport.
    final replay = GameSession.restore(finished!.rules, finished.toSave())!;
    expect(replay.hash, finished.hash);

    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.byType(RobotAvatar), findsWidgets);

    await tester.tap(find.text('Hrát znovu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(GameScreen), findsOneWidget);

    // Back home through the pause → exit; the game is saved and can be continued.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konec').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit'));
    await tester.pumpAndSettle();
    expect(find.text('Pokračovat: Hádej číslo'), findsOneWidget);

    // Opening the setup again restores the last setup.
    await tester.tap(find.text('Hádej číslo').last);
    await tester.pumpAndSettle();
    expect(find.byType(GameSetupScreen), findsOneWidget);
    expect(find.textContaining('Nastavení načteno z minulé hry'), findsOneWidget);
    expect(find.text('Hráči · 2 lidé + 2 roboti'), findsOneWidget);
  });
}
