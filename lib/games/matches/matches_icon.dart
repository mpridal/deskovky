import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import 'matches_painters.dart';

/// Game icon: three matches on a felt card, the middle one lit.
class MatchesIcon extends StatelessWidget {
  const MatchesIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(child: SizedBox.square(dimension: side, child: const CustomPaint(painter: _MatchesIconPainter())));
    },
  );
}

class _MatchesIconPainter extends CustomPainter {
  const _MatchesIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final card = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.18));
    canvas
      ..drawRRect(card, Paint()..color = AppColors.felt)
      ..drawRRect(card, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.wood);
    for (final (x, angle, burn) in const [(0.3, -0.25, 0.0), (0.5, 0.0, 0.45), (0.7, 0.25, 0.0)]) {
      canvas
        ..save()
        ..translate(s * x, s * 0.58)
        ..rotate(angle);
      MatchArt.paint(canvas, Rect.fromCenter(center: Offset.zero, width: s * 0.2, height: s * 0.62), burn: burn);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MatchesIconPainter oldDelegate) => false;
}
