import 'package:deskovky/core/game_kit/board_grid.dart';
import 'package:deskovky/core/game_kit/dice.dart';
import 'package:deskovky/core/game_kit/flip_card.dart';
import 'package:deskovky/core/game_kit/piece_token.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {Size size = const Size(400, 400), bool reduceMotion = false}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
}

Widget _cell(BuildContext _, int col, int row) => ColoredBox(key: ValueKey('cell$col,$row'), color: AppColors.paper);

void main() {
  group('BoardGrid', () {
    testWidgets('a tap reports the column and row under the finger', (tester) async {
      final taps = <(int, int)>[];
      await _pump(tester, BoardGrid(columns: 3, rows: 3, cellBuilder: _cell, onTap: taps.add));
      await tester.tap(find.byKey(const ValueKey('cell2,0')));
      await tester.tap(find.byKey(const ValueKey('cell1,2')));
      expect(taps, [(2, 0), (1, 2)]);
    });

    testWidgets('fits the space when cells stay at least 48 dp, without zoom', (tester) async {
      await _pump(tester, BoardGrid(columns: 3, rows: 3, cellBuilder: _cell));
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(tester.getSize(find.byKey(const ValueKey('cell0,0'))).width, closeTo(400 / 3, 0.5));
    });

    testWidgets('a 15×15 board on a 360 dp phone keeps 48 dp cells and zooms', (tester) async {
      await _pump(tester, BoardGrid(columns: 15, rows: 15, cellBuilder: _cell), size: const Size(360, 600));
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(tester.getSize(find.byKey(const ValueKey('cell0,0'))).width, 48);
    });

    testWidgets('a zoomable board starts centred and "centre" brings it back after panning', (tester) async {
      final controller = BoardGridController();
      addTearDown(controller.dispose);
      await _pump(tester, BoardGrid(columns: 15, rows: 15, cellBuilder: _cell, controller: controller), size: const Size(360, 600));
      await tester.pump();
      final middle = find.byKey(const ValueKey('cell7,7'));
      expect(tester.getCenter(middle).dx, closeTo(180, 30));
      expect(tester.getCenter(middle).dy, closeTo(300, 30));
      await tester.drag(find.byType(InteractiveViewer), const Offset(200, 150));
      await tester.pumpAndSettle();
      expect(tester.getCenter(middle).dx, greaterThan(250));
      controller.reset();
      await tester.pumpAndSettle();
      expect(tester.getCenter(middle).dx, closeTo(180, 30));
    });

    testWidgets('highlighted cells get a gold frame', (tester) async {
      await _pump(tester, BoardGrid(columns: 3, rows: 3, cellBuilder: _cell, highlighted: const {(1, 1)}));
      expect(find.byKey(const ValueKey('highlight1,1')), findsOneWidget);
      expect(find.byKey(const ValueKey('highlight0,0')), findsNothing);
    });
  });

  group('PieceToken', () {
    testWidgets('has the player colour and a shape mark for colour-blind players', (tester) async {
      await _pump(tester, const Center(child: PieceToken(seat: 2, size: 40)));
      final token = tester.widget<PieceToken>(find.byType(PieceToken));
      expect(token.color, AppColors.players[2]);
      expect(find.byKey(const ValueKey('mark2')), findsOneWidget);
    });

    testWidgets('a pulsing token stands still with reduced motion', (tester) async {
      await _pump(tester, const Center(child: PieceToken(seat: 0, pulse: true)), reduceMotion: true);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a hopping piece ends on the last field of its path', (tester) async {
      var done = false;
      await _pump(
        tester,
        Stack(
          children: [
            HoppingPiece(
              path: const [Offset(0, 0), Offset(50, 0), Offset(100, 50)],
              onDone: () => done = true,
              child: const PieceToken(key: ValueKey('hop'), seat: 1, size: 20),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byKey(const ValueKey('hop'))), const Offset(100, 50));
      expect(done, isTrue);
    });
  });

  testWidgets('the same hopping piece hops again when it gets a new path', (tester) async {
    var done = 0;
    Widget piece(List<Offset> path) => Stack(
      children: [
        HoppingPiece(
          key: const ValueKey('piece'),
          path: path,
          onDone: () => done++,
          child: const PieceToken(key: ValueKey('hop'), seat: 1, size: 20),
        ),
      ],
    );
    await _pump(tester, piece(const [Offset(0, 0), Offset(50, 0)]));
    await tester.pumpAndSettle();
    await _pump(tester, piece(const [Offset(50, 0), Offset(100, 0), Offset(150, 20)]));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(find.byKey(const ValueKey('hop'))).dx, lessThan(150), reason: 'it moves, it does not jump');
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('hop'))), const Offset(150, 20));
    expect(done, 2);
  });

  group('FlipCard', () {
    testWidgets('shows the side that is up and turns over', (tester) async {
      Widget card(bool up) => Center(
        child: SizedBox(
          width: 80,
          height: 100,
          child: FlipCard(faceUp: up, front: const Text('front'), back: const Text('back')),
        ),
      );
      await _pump(tester, card(false));
      expect(find.text('back'), findsOneWidget);
      expect(find.text('front'), findsNothing);
      await _pump(tester, card(true));
      await tester.pumpAndSettle();
      expect(find.text('front'), findsOneWidget);
      expect(find.text('back'), findsNothing);
    });
  });

  group('Dice', () {
    testWidgets('shows the value from the game state and tells screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      var tapped = 0;
      await _pump(tester, Center(child: Dice(value: 4, rolling: false, label: 'Kostka', onTap: () => tapped++)));
      expect(find.bySemanticsLabel('Kostka: 4'), findsOneWidget);
      await tester.tap(find.byType(Dice));
      expect(tapped, 1);
      handle.dispose();
    });

    testWidgets('rolling shakes, but not with reduced motion', (tester) async {
      await _pump(tester, const Center(child: Dice(value: null, rolling: true, label: 'Kostka')));
      expect(tester.hasRunningAnimations, isTrue);
      await _pump(tester, const Center(child: Dice(value: null, rolling: true, label: 'Kostka')), reduceMotion: true);
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
