import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Round paper icon button, 44–48 dp (spec 6.3), always with a label for
/// screen readers.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 48,
  }) : assert(size >= 44 && size <= 48);

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: tooltip,
      // excludeSemantics drops the detector's tap action, so screen readers
      // need it here explicitly.
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onPressed,
          behavior: HitTestBehavior.opaque,
          child: SizedBox.square(
            dimension: 48,
            child: Center(
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: AppColors.paper,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.paper2, offset: Offset(0, 3)),
                    BoxShadow(color: Color(0x4D000000), offset: Offset(0, 5), blurRadius: 10),
                  ],
                ),
                child: Icon(icon, color: AppColors.ink, size: size * 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
