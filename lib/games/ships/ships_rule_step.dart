import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'ships_art.dart';

/// The illustrated rule steps: placing ships apart, firing (water or hit)
/// and a sunk ship with its water around it.
enum ShipsRuleStepKind { place, fire, sink }

/// One rule step: a little 4 × 4 sea and a caption.
class ShipsRuleStep extends StatelessWidget {
  const ShipsRuleStep({super.key, required this.kind, required this.text});

  final ShipsRuleStepKind kind;
  final String text;

  static const _h3 = [
    ShipPiece(index: 0, length: 3, horizontal: true),
    ShipPiece(index: 1, length: 3, horizontal: true),
    ShipPiece(index: 2, length: 3, horizontal: true),
  ];

  @override
  Widget build(BuildContext context) {
    final sea = switch (kind) {
      ShipsRuleStepKind.place => ShipsSea(
        size: 4,
        pieces: {
          0: _h3[0],
          1: _h3[1],
          2: _h3[2],
          11: const ShipPiece(index: 0, length: 2, horizontal: false),
          15: const ShipPiece(index: 1, length: 2, horizontal: false),
        },
      ),
      ShipsRuleStepKind.fire => const ShipsSea(
        size: 4,
        looks: {5: ShipsLook.miss, 10: ShipsLook.hit},
        mark: 10,
      ),
      ShipsRuleStepKind.sink => ShipsSea(
        size: 4,
        pieces: {
          for (final (i, p) in _h3.indexed)
            5 + i: ShipPiece(index: p.index, length: 3, horizontal: true, sunk: true),
        },
        shotShips: const {5, 6, 7},
        looks: const {0: ShipsLook.water, 1: ShipsLook.water, 2: ShipsLook.water, 3: ShipsLook.water, 4: ShipsLook.water, 8: ShipsLook.water, 9: ShipsLook.water, 10: ShipsLook.water, 11: ShipsLook.water},
      ),
    };
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.wood,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                sea,
                if (kind == ShipsRuleStepKind.fire)
                  Align(
                    alignment: const Alignment(0.95, 0.95),
                    child: Icon(Icons.touch_app, size: 24, color: AppColors.ink.withValues(alpha: 0.8)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
        ],
      ),
    );
  }
}
