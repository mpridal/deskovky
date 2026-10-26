import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// One illustrated rule step (spec 13.4): a number tile with a sign and a caption.
class SampleRuleStep extends StatelessWidget {
  const SampleRuleStep({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.paper2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.wood, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('7', style: AppTypography.h1(color: AppColors.ink)),
            Align(alignment: const Alignment(0.9, 0.9), child: Icon(icon, size: 26, color: AppColors.players[1])),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
    ],
  );
}
