import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Game icon (spec 6.5): a paper card with a big "?" and number dots in the
/// player colours, on the card's pastel background.
class SampleIcon extends StatelessWidget {
  const SampleIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide * 0.7;
        return Center(
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(side * 0.18),
              border: Border.all(color: AppColors.wood, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '?',
                  style: AppTypography.h1(color: AppColors.ink).copyWith(fontSize: side * 0.6, height: 1),
                ),
                for (final (i, align) in const [
                  Alignment(-0.7, -0.7),
                  Alignment(0.7, -0.7),
                  Alignment(-0.7, 0.7),
                  Alignment(0.7, 0.7),
                ].indexed)
                  Align(
                    alignment: align,
                    child: Container(
                      width: side * 0.14,
                      height: side * 0.14,
                      decoration: BoxDecoration(color: AppColors.players[i], shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
