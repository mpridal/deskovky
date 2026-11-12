import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import 'ships_art.dart';

/// Game icon: a little 5 × 5 sea with a ship, a hit and a miss.
class ShipsIcon extends StatelessWidget {
  const ShipsIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(
        child: Container(
          width: side,
          height: side,
          padding: EdgeInsets.all(side * 0.06),
          decoration: BoxDecoration(
            color: AppColors.wood,
            borderRadius: BorderRadius.circular(side * 0.18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(side * 0.1),
            child: const ShipsSea(
              size: 5,
              pieces: {
                6: ShipPiece(index: 0, length: 3, horizontal: true),
                7: ShipPiece(index: 1, length: 3, horizontal: true),
                8: ShipPiece(index: 2, length: 3, horizontal: true),
                19: ShipPiece(index: 0, length: 2, horizontal: false),
                24: ShipPiece(index: 1, length: 2, horizontal: false),
              },
              shotShips: {7},
              looks: {15: ShipsLook.miss},
            ),
          ),
        ),
      );
    },
  );
}
