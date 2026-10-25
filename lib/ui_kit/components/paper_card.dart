import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Cream paper card with a "physical" 5 dp bottom edge (spec 6.3).
class PaperCard extends StatelessWidget {
  const PaperCard({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.onTap});

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  static const radius = BorderRadius.all(Radius.circular(18));

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(color: AppColors.paper2, offset: Offset(0, 5)),
          BoxShadow(color: Color(0x59000000), offset: Offset(0, 8), blurRadius: 16),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
  }
}
