import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Game icon (spec 6.5): a paper grid with red crosses and a blue nought.
class TictactoeIcon extends StatelessWidget {
  const TictactoeIcon({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = constraints.biggest.shortestSide * 0.7;
      return Center(child: SizedBox.square(dimension: side, child: CustomPaint(painter: _TictactoeIconPainter())));
    },
  );
}

class _TictactoeIconPainter extends CustomPainter {
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
    final line = Paint()
      ..color = AppColors.woodLight
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round;
    for (final f in [1 / 3, 2 / 3]) {
      canvas
        ..drawLine(Offset(s * f, s * 0.12), Offset(s * f, s * 0.88), line)
        ..drawLine(Offset(s * 0.12, s * f), Offset(s * 0.88, s * f), line);
    }
    final cross = Paint()
      ..color = AppColors.players[0]
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(s * 0.2, s * 0.2), Offset(s * 0.4, s * 0.4), cross)
      ..drawLine(Offset(s * 0.4, s * 0.2), Offset(s * 0.2, s * 0.4), cross)
      ..drawLine(Offset(s * 0.6, s * 0.6), Offset(s * 0.8, s * 0.8), cross)
      ..drawLine(Offset(s * 0.8, s * 0.6), Offset(s * 0.6, s * 0.8), cross)
      ..drawCircle(Offset(s * 0.5, s * 0.5), s * 0.1, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.07
        ..color = AppColors.players[1]);
  }

  @override
  bool shouldRepaint(_TictactoeIconPainter oldDelegate) => false;
}
