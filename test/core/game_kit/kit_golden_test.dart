import 'package:deskovky/core/game_kit/board_grid.dart';
import 'package:deskovky/core/game_kit/dice.dart';
import 'package:deskovky/core/game_kit/flip_card.dart';
import 'package:deskovky/core/game_kit/piece_token.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('game kit pieces', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 300);
    addTearDown(tester.view.reset);
    Widget card(Color color) => DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: const SizedBox(width: 56, height: 72),
    );
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: AppColors.felt,
          child: RepaintBoundary(
            child: Row(
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: BoardGrid(
                    columns: 5,
                    rows: 5,
                    highlighted: const {(2, 2)},
                    cellBuilder: (_, c, r) => Container(
                      margin: const EdgeInsets.all(1),
                      color: (c + r).isEven ? AppColors.paper : AppColors.paper2,
                      child: c == r && c < 4 ? Center(child: PieceToken(seat: c, size: 32)) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [for (final v in [1, 2, 3]) Padding(padding: const EdgeInsets.all(4), child: Dice(value: v, rolling: false, label: 'd', size: 48))]),
                    Row(children: [for (final v in [4, 5, 6]) Padding(padding: const EdgeInsets.all(4), child: Dice(value: v, rolling: false, label: 'd', size: 48))]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FlipCard(faceUp: false, front: card(AppColors.gold), back: card(AppColors.wood)),
                        const SizedBox(width: 8),
                        FlipCard(faceUp: true, front: card(AppColors.gold), back: card(AppColors.wood)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('goldens/kit.png'));
  });
}
