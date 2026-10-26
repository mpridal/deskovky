import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Game icon (spec 6.5): wooden tiles, a number, a red flag and a mine.
class MinesweeperIcon extends StatelessWidget {
  const MinesweeperIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(
        child: SizedBox.square(
          dimension: side,
          child: CustomPaint(painter: _MinesweeperIconPainter()),
        ),
      );
    },
  );
}

class _MinesweeperIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final card = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.18));
    canvas
      ..drawRRect(card, Paint()..color = AppColors.paper)
      ..drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.wood,
      );
    final tile = s * 0.36;
    for (var r = 0; r < 2; r++) {
      for (var c = 0; c < 2; c++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(s * 0.12 + c * (tile + s * 0.04), s * 0.12 + r * (tile + s * 0.04), tile, tile),
          Radius.circular(s * 0.05),
        );
        canvas.drawRRect(rect, Paint()..color = r == 1 && c == 0 ? AppColors.paper2 : AppColors.woodLight);
      }
    }
    final number = TextPainter(
      text: TextSpan(
        text: '1',
        style: TextStyle(color: AppColors.players[1], fontSize: s * 0.26, fontWeight: FontWeight.w800),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    number.paint(canvas, Offset(s * 0.3, s * 0.68) - Offset(number.width / 2, number.height / 2));
    final pole = Offset(s * 0.68, s * 0.2);
    canvas
      ..drawLine(
        pole,
        pole + Offset(0, s * 0.26),
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = s * 0.03,
      )
      ..drawPath(
        Path()
          ..moveTo(pole.dx, pole.dy)
          ..lineTo(pole.dx + s * 0.16, pole.dy + s * 0.06)
          ..lineTo(pole.dx, pole.dy + s * 0.12)
          ..close(),
        Paint()..color = AppColors.players[0],
      )
      ..drawCircle(Offset(s * 0.7, s * 0.7), s * 0.09, Paint()..color = AppColors.ink);
    for (var i = 0; i < 8; i++) {
      final a = i * pi / 4;
      canvas.drawLine(
        Offset(s * 0.7, s * 0.7),
        Offset(s * 0.7 + cos(a) * s * 0.14, s * 0.7 + sin(a) * s * 0.14),
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = s * 0.025,
      );
    }
  }

  @override
  bool shouldRepaint(_MinesweeperIconPainter oldDelegate) => false;
}
