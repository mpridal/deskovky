import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Game icon (spec 6.5): two cards turned up with a matching star and one face down.
class MemoryIcon extends StatelessWidget {
  const MemoryIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(child: SizedBox.square(dimension: side, child: CustomPaint(painter: _MemoryIconPainter())));
    },
  );
}

class _MemoryIconPainter extends CustomPainter {
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
    void drawCard(Offset at, double angle, {required bool up}) {
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(angle);
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: s * 0.34, height: s * 0.46),
        Radius.circular(s * 0.05),
      );
      canvas
        ..drawRRect(r, Paint()..color = up ? AppColors.paper2 : AppColors.wood)
        ..drawRRect(r, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = AppColors.walnut);
      if (up) {
        final star = Path();
        for (var i = 0; i < 10; i++) {
          final rad = i.isEven ? s * 0.1 : s * 0.045;
          final a = -pi / 2 + i * pi / 5;
          final p = Offset(cos(a) * rad, sin(a) * rad);
          i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(star..close(), Paint()..color = AppColors.gold);
      }
      canvas.restore();
    }

    drawCard(Offset(s * 0.3, s * 0.42), -0.2, up: true);
    drawCard(Offset(s * 0.7, s * 0.42), 0.2, up: true);
    drawCard(Offset(s * 0.5, s * 0.66), 0, up: false);
  }

  @override
  bool shouldRepaint(_MemoryIconPainter oldDelegate) => false;
}
