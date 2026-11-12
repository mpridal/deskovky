import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import 'war_card_art.dart';
import 'war_rules.dart';

/// Game icon: an ace and a king crossed on a felt card.
class WarIcon extends StatelessWidget {
  const WarIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      final cardH = side * 0.62;
      Widget card(int c, double angle, Offset at) => Positioned(
        left: at.dx,
        top: at.dy,
        child: Transform.rotate(
          angle: angle,
          child: SizedBox(width: cardH * warCardAspect, height: cardH, child: WarCardFace(card: c)),
        ),
      );
      return Center(
        child: Container(
          width: side,
          height: side,
          decoration: BoxDecoration(
            color: AppColors.felt,
            borderRadius: BorderRadius.circular(side * 0.18),
            border: Border.all(color: AppColors.wood, width: 2),
          ),
          child: Stack(
            children: [
              card(WarCard.of(13, 0), -0.3, Offset(side * 0.14, side * 0.2)),
              card(WarCard.of(14, 1), 0.3, Offset(side * 0.42, side * 0.16)),
            ],
          ),
        ),
      );
    },
  );
}
