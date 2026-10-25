import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Gold pill button with a 5 dp bottom edge that sinks 3 dp while pressed
/// (spec 6.3). The `tap` sound is added with the AudioService (milestone 5).
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.secondary = false});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Paper instead of gold, for the second choice next to a primary button.
  final bool secondary;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  static const _edge = Color(0xFF9B6A12);
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed != null && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final depth = _pressed ? 2.0 : 5.0;
    return Semantics(
      button: true,
      enabled: enabled,
      // Own node, so a dialog does not merge the button into its text and
      // screen readers can press it.
      container: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Transform.translate(
              offset: Offset(0, _pressed ? 3 : 0),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.secondary ? AppColors.paper : AppColors.gold,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [BoxShadow(color: widget.secondary ? AppColors.paper2 : _edge, offset: Offset(0, depth))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[Icon(widget.icon, color: AppColors.ink), const SizedBox(width: 8)],
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: AppTypography.h2(color: AppColors.ink).copyWith(fontSize: 20, height: 1.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
