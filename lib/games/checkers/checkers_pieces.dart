import 'package:flutter/material.dart';

import '../../core/game_kit/piece_token.dart';
import '../../ui_kit/tokens/app_colors.dart';

/// A piece of Dáma: a [PieceToken] in the seat's colour; a king wears a gold
/// crown whose jewel keeps the seat's shape (circle, square) for colour-blind
/// players.
class CheckersPieceView extends StatelessWidget {
  const CheckersPieceView({super.key, required this.seat, required this.king, required this.size, this.pulse = false});

  final int seat;
  final bool king;
  final double size;
  final bool pulse;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        PieceToken(seat: seat, size: size, pulse: pulse, showMark: !king),
        if (king)
          IgnorePointer(
            child: SizedBox.square(
              dimension: size * 0.62,
              child: CustomPaint(key: ValueKey('crown$seat'), painter: CrownPainter(seat)),
            ),
          ),
      ],
    ),
  );
}

/// A small gold crown with a jewel in the seat's mark shape.
class CrownPainter extends CustomPainter {
  const CrownPainter(this.seat);

  final int seat;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final crown = Path()
      ..moveTo(w * 0.08, h * 0.78)
      ..lineTo(w * 0.04, h * 0.28)
      ..lineTo(w * 0.3, h * 0.52)
      ..lineTo(w * 0.5, h * 0.16)
      ..lineTo(w * 0.7, h * 0.52)
      ..lineTo(w * 0.96, h * 0.28)
      ..lineTo(w * 0.92, h * 0.78)
      ..close();
    canvas
      ..drawPath(crown, Paint()..color = AppColors.gold)
      ..drawPath(
        crown,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.06
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.walnut,
      );
    final jewel = Paint()..color = Colors.white;
    final centre = Offset(w * 0.5, h * 0.6);
    if (seat == 0) {
      canvas.drawCircle(centre, w * 0.1, jewel);
    } else {
      canvas.drawRect(Rect.fromCenter(center: centre, width: w * 0.18, height: w * 0.18), jewel);
    }
  }

  @override
  bool shouldRepaint(CrownPainter old) => old.seat != seat;
}

/// The squares of a board: light paper-wood and dark wood (spec 13.9).
class CheckersSquaresPainter extends CustomPainter {
  const CheckersSquaresPainter({required this.size, this.marked = const {}, this.markColor = const Color(0x55E0A82E)});

  /// Squares per side.
  final int size;

  /// Display squares (column, row) tinted, e.g. the last move.
  final Set<(int, int)> marked;
  final Color markColor;

  static const light = Color(0xFFE8CFA5);
  static const dark = Color(0xFF8B5A3C);

  @override
  void paint(Canvas canvas, Size box) {
    final cell = box.width / size;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
        canvas.drawRect(rect, Paint()..color = (r + c).isOdd ? dark : light);
        if (marked.contains((c, r))) canvas.drawRect(rect, Paint()..color = markColor);
      }
    }
    // A fine grain on the dark squares.
    final grain = Paint()
      ..color = const Color(0x14000000)
      ..strokeWidth = 1;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if ((r + c).isEven) continue;
        for (var k = 1; k < 4; k++) {
          final y = (r + k / 4) * cell;
          canvas.drawLine(Offset(c * cell + cell * 0.1, y), Offset(c * cell + cell * 0.9, y + cell * 0.04), grain);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CheckersSquaresPainter old) =>
      old.size != size || old.marked.length != marked.length || !old.marked.containsAll(marked);
}
