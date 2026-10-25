import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Small rounded label ("Brzy", "Člověk", "🤖 Robot"). Shrinks rather than
/// being clipped when space runs out.
class TagPill extends StatelessWidget {
  const TagPill({
    super.key,
    required this.label,
    this.background = AppColors.walnut,
    this.foreground = AppColors.paper,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
        child: Text(label, maxLines: 1, style: AppTypography.caption(color: foreground).copyWith(fontSize: 11)),
      ),
    );
  }
}
