import 'dart:math';

import 'package:flutter/widgets.dart';

import '../tokens/app_colors.dart';

/// Green felt playing surface (spec 6.1): base color, soft light from the
/// top and a fine deterministic speckle – all painted, no bitmap.
class FeltBackground extends StatelessWidget {
  const FeltBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: const _FeltPainter(),
        isComplex: true,
        willChange: false,
        child: child,
      ),
    );
  }
}

class _FeltPainter extends CustomPainter {
  const _FeltPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.felt);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.4),
          radius: 0.9,
          colors: [const Color(0x14FFFFFF), const Color(0x00FFFFFF)],
        ).createShader(rect),
    );
    final speck = Paint()..color = AppColors.feltDark.withValues(alpha: 0.25);
    final rnd = Random(42);
    for (var i = 0; i < 600; i++) {
      canvas.drawCircle(
        Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
        0.6 + rnd.nextDouble() * 0.6,
        speck,
      );
    }
  }

  @override
  bool shouldRepaint(_FeltPainter oldDelegate) => false;
}
