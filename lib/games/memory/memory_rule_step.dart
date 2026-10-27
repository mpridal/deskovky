import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'memory_card_art.dart';

/// One illustrated rule step (spec 13.4): two small cards and a sign.
/// [left]/[right] are motifs of the animal set, or null for a card back.
class MemoryRuleStep extends StatelessWidget {
  const MemoryRuleStep({super.key, required this.left, required this.right, required this.icon, required this.text});

  final int? left;
  final int? right;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 96,
        height: 64,
        child: Stack(
          children: [
            for (final (i, motif) in [left, right].indexed)
              Positioned(
                left: i * 42.0,
                top: 4,
                width: 50,
                height: 50,
                child: Transform.rotate(
                  angle: i == 0 ? -0.12 : 0.12,
                  child: motif == null
                      ? const MemoryCardBack()
                      : MemoryCardFace(set: 'animals', motif: motif, frame: AppColors.players[1]),
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(icon, size: 28, color: AppColors.players[0]),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.caption(color: AppColors.ink),
      ),
    ],
  );
}
