import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Game icon (spec 6.5): a board corner with a red and two dark pieces.
class CheckersIcon extends StatelessWidget {
  const CheckersIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(child: SizedBox.square(dimension: side, child: CustomPaint(painter: _CheckersIconPainter())));
    },
  );
}

class _CheckersIconPainter extends CustomPainter {
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
    final f = s * 0.76 / 4;
    final origin = Offset(s * 0.12, s * 0.12);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 4; c++) {
        canvas.drawRect(
          Rect.fromLTWH(origin.dx + c * f, origin.dy + r * f, f, f),
          Paint()..color = (r + c).isOdd ? AppColors.wood : AppColors.paper2,
        );
      }
    }
    void piece(int c, int r, Color color) {
      final at = origin + Offset((c + 0.5) * f, (r + 0.5) * f);
      canvas
        ..drawCircle(at, f * 0.4, Paint()..color = color)
        ..drawCircle(at, f * 0.26, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white54);
    }

    piece(1, 0, AppColors.players[0]);
    piece(2, 3, AppColors.walnut);
    piece(0, 3, AppColors.walnut);
  }

  @override
  bool shouldRepaint(_CheckersIconPainter oldDelegate) => false;
}
