import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Game icon (spec 6.5): a cross of fields with the four coloured home corners.
class LudoIcon extends StatelessWidget {
  const LudoIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(child: SizedBox.square(dimension: side, child: CustomPaint(painter: _LudoIconPainter())));
    },
  );
}

class _LudoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final card = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.18));
    canvas
      ..drawRRect(card, Paint()..color = AppColors.paper)
      ..drawRRect(card, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.wood);
    final f = s / 11;
    for (final (i, corner) in const [Offset(0, 0), Offset(7, 0), Offset(7, 7), Offset(0, 7)].indexed) {
      final home = RRect.fromRectAndRadius(
        Rect.fromLTWH((corner.dx + 0.6) * f, (corner.dy + 0.6) * f, 3.2 * f, 3.2 * f),
        Radius.circular(f),
      );
      canvas
        ..drawRRect(home, Paint()..color = AppColors.players[i].withValues(alpha: 0.35))
        ..drawCircle(home.center, f * 0.9, Paint()..color = AppColors.players[i]);
    }
    final field = Paint()..color = AppColors.woodLight;
    for (var k = 0; k < 11; k++) {
      for (final p in [Offset(k.toDouble(), 5), Offset(5, k.toDouble())]) {
        if (p.dx == 5 && p.dy == 5) continue;
        canvas.drawCircle(Offset((p.dx + 0.5) * f, (p.dy + 0.5) * f), f * 0.38, field);
      }
    }
  }

  @override
  bool shouldRepaint(_LudoIconPainter oldDelegate) => false;
}
