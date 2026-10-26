import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/minesweeper/minesweeper_state.dart';
import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

GameSession<Object?> _session(WidgetTester tester) =>
    tester.state<GameScreenState>(find.byType(GameScreen)).debugSession!;

Future<void> _openEasyGame(WidgetTester tester) async {
  await tester.tap(find.text('Miny'));
  await tester.pumpAndSettle();
  // One player: the classic game.
  await tester.tap(find.descendant(of: find.byType(SegmentedControl<int>).first, matching: find.text('1')));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(find.text('Lehká'), 120, scrollable: find.byType(Scrollable).first);
  await tester.tap(find.text('Lehká'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Hrát!'));
  await tester.pumpAndSettle();
  expect(find.byType(GameScreen), findsOneWidget);
}

Future<void> _tapCell(WidgetTester tester, int cell, int columns) async {
  await tester.tap(find.byKey(ValueKey('cell${cell % columns},${cell ~/ columns}')));
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('one player clears an easy board: results, the win counted and "Bez vlajek" earned', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    late int tereza;
    await tester.runAsync(() async {
      tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
    });
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _openEasyGame(tester);

    await _tapCell(tester, 40, 9);
    for (var guard = 0; guard < 100; guard++) {
      if (find.byType(GameScreen).evaluate().isEmpty) break;
      final s = _session(tester).state as MinesweeperState;
      if (s.over) break;
      final safe = [
        for (var i = 0; i < s.cellCount; i++)
          if (!s.isRevealed(i) && !s.mineSet.contains(i)) i,
      ];
      await _tapCell(tester, safe.first, s.columns);
    }

    for (var i = 0; i < 30 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);

    late Map<String, int> counters;
    late Set<String> badges;
    await tester.runAsync(() async {
      final stats = StatsRepository(db);
      counters = await stats.counters(tereza);
      badges = (await stats.earnedBadges(tereza)).keys.toSet();
    });
    expect(counters['minesweeper.win'], 1);
    expect(badges, contains('minesweeper.noflag'));
    expect(badges, isNot(contains('minesweeper.defuser')));
  });

  testWidgets('a game left in the middle is saved and continues the same', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _openEasyGame(tester);
    await _tapCell(tester, 40, 9);
    final s = _session(tester).state as MinesweeperState;
    await tester.longPress(find.byKey(ValueKey('cell${s.mines.first % 9},${s.mines.first ~/ 9}')));
    await tester.pump();
    final hash = _session(tester).hash;

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konec').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10 && find.text('Pokračovat: Miny').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Pokračovat: Miny'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    expect(_session(tester).hash, hash);
    expect((_session(tester).state as MinesweeperState).flagsCount(), 1);
  });
}
