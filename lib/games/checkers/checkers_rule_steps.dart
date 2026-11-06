import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'checkers_pieces.dart';

/// The illustrated rule steps (spec 13.4): a move, a capture, a multiple
/// capture and crowning.
enum CheckersRuleStepKind { move, capture, multi, crown }

/// One rule step: a corner of the board drawn in code, and a caption.
class CheckersRuleStep extends StatelessWidget {
  const CheckersRuleStep({super.key, required this.kind, required this.text});

  final CheckersRuleStepKind kind;
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppColors.wood,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.walnut, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(painter: _StepPainter(kind)),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.caption(color: AppColors.ink),
        ),
      ],
    ),
  );
}

class _StepPainter extends CustomPainter {
  const _StepPainter(this.kind);

  final CheckersRuleStepKind kind;

  static const _n = 5;

  @override
  void paint(Canvas canvas, Size size) {
    const CheckersSquaresPainter(size: _n).paint(canvas, size);
    final cell = size.width / _n;
    Offset at(int c, int r) => Offset((c + 0.5) * cell, (r + 0.5) * cell);

    // (column, row, seat, king) and the arrows of the move.
    final (pieces, arrows, ghosts) = switch (kind) {
      CheckersRuleStepKind.move => (
        const [(1, 4, 0, false), (3, 0, 1, false)],
        const [((1, 4), (2, 3)), ((1, 4), (0, 3))],
        const <(int, int)>[],
      ),
      CheckersRuleStepKind.capture => (
        const [(1, 4, 0, false), (2, 3, 1, false), (4, 1, 1, false)],
        const [((1, 4), (3, 2))],
        const <(int, int)>[],
      ),
      CheckersRuleStepKind.multi => (
        const [(0, 4, 0, false), (1, 3, 1, false), (3, 1, 1, false)],
        const [((0, 4), (2, 2)), ((2, 2), (4, 0))],
        const <(int, int)>[],
      ),
      CheckersRuleStepKind.crown => (
        const [(3, 0, 0, true), (0, 1, 1, false)],
        const [((2, 1), (3, 0))],
        const [(2, 1)],
      ),
    };
    for (final (c, r) in ghosts) {
      canvas.drawCircle(at(c, r), cell * 0.36, Paint()..color = AppColors.players[0].withValues(alpha: 0.3));
    }
    for (final (c, r, seat, king) in pieces) {
      _piece(canvas, at(c, r), cell * 0.38, seat, king);
    }
    final pen = Paint()
      ..color = AppColors.gold
      ..strokeWidth = cell * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final ((c0, r0), (c1, r1)) in arrows) {
      final a = at(c0, r0), b = at(c1, r1);
      final dir = (b - a) / (b - a).distance;
      final start = a + dir * cell * 0.3, end = b - dir * cell * 0.1;
      if (kind == CheckersRuleStepKind.move) {
        canvas.drawLine(start, end, pen);
      } else {
        // A jump arcs over the taken piece.
        final mid = (start + end) / 2 + Offset(dir.dy, -dir.dx) * cell * 0.35;
        canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy),
          pen,
        );
      }
      final angle = atan2(dir.dy, dir.dx);
      final head = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - cos(angle - 0.5) * cell * 0.28, end.dy - sin(angle - 0.5) * cell * 0.28)
        ..lineTo(end.dx - cos(angle + 0.5) * cell * 0.28, end.dy - sin(angle + 0.5) * cell * 0.28)
        ..close();
      canvas.drawPath(head, Paint()..color = AppColors.gold);
    }
    if (kind == CheckersRuleStepKind.capture || kind == CheckersRuleStepKind.multi) {
      // The taken pieces are crossed out.
      final cross = Paint()
        ..color = AppColors.paper
        ..strokeWidth = cell * 0.1
        ..strokeCap = StrokeCap.round;
      for (final (c, r) in kind == CheckersRuleStepKind.capture ? const [(2, 3)] : const [(1, 3), (3, 1)]) {
        final o = at(c, r);
        final d = cell * 0.2;
        canvas
          ..drawLine(o - Offset(d, d), o + Offset(d, d), cross)
          ..drawLine(o + Offset(-d, d), o + Offset(d, -d), cross);
      }
    }
  }

  static void _piece(Canvas canvas, Offset centre, double radius, int seat, bool king) {
    final color = AppColors.players[seat];
    canvas
      ..drawCircle(centre + Offset(0, radius * 0.1), radius, Paint()..color = const Color(0x55000000))
      ..drawCircle(centre, radius, Paint()..color = color)
      ..drawCircle(
        centre,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.14
          ..color = Color.lerp(color, AppColors.ink, 0.35)!,
      );
    if (king) {
      final s = radius * 1.2;
      canvas.save();
      canvas.translate(centre.dx - s / 2, centre.dy - s / 2);
      CrownPainter(seat).paint(canvas, Size.square(s));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_StepPainter old) => old.kind != kind;
}
