import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Squared paper of one cell: paper with a thin blue line on its top and
/// left edge (the board draws the closing edges).
class PaperCellPainter extends CustomPainter {
  const PaperCellPainter({this.right = false, this.bottom = false});

  /// Also draw the right / bottom edge (last column / row).
  final bool right;
  final bool bottom;

  static final _line = AppColors.players[1].withValues(alpha: 0.28);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.paper);
    final line = Paint()
      ..color = _line
      ..strokeWidth = max(1, size.width / 40);
    canvas
      ..drawLine(Offset.zero, Offset(size.width, 0), line)
      ..drawLine(Offset.zero, Offset(0, size.height), line);
    if (right) canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), line);
    if (bottom) canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), line);
  }

  @override
  bool shouldRepaint(PaperCellPainter old) => old.right != right || old.bottom != bottom;
}

/// A hand-drawn ✕ (seat 0) or ◯ (seat 1) in the seat's colour; [progress]
/// 0→1 draws it stroke by stroke.
class MarkPainter extends CustomPainter {
  const MarkPainter({required this.seat, this.progress = 1, this.opacity = 1});

  final int seat;
  final double progress;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final s = size.shortestSide;
    final pen = Paint()
      ..color = AppColors.players[seat].withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round;
    final o = Offset((size.width - s) / 2, (size.height - s) / 2);
    if (seat == 0) {
      final first = (progress * 2).clamp(0.0, 1.0), second = (progress * 2 - 1).clamp(0.0, 1.0);
      final a = o + Offset(s * 0.26, s * 0.26), b = o + Offset(s * 0.74, s * 0.74);
      canvas.drawLine(a, Offset.lerp(a, b, first)!, pen);
      if (second > 0) {
        final c = o + Offset(s * 0.74, s * 0.26), d = o + Offset(s * 0.26, s * 0.74);
        canvas.drawLine(c, Offset.lerp(c, d, second)!, pen);
      }
    } else {
      final rect = Rect.fromCircle(center: o + Offset(s / 2, s / 2), radius: s * 0.27);
      canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, pen);
    }
  }

  @override
  bool shouldRepaint(MarkPainter old) => old.seat != seat || old.progress != progress || old.opacity != opacity;
}

/// One cell's piece of the stroke that crosses out the winning row.
/// The row runs through the cell centres in direction ([dc], [dr]); cell
/// [index] of [count] covers the row's stretch `index…index+1` and draws
/// the part of `0.25…count-0.25` that [progress] (0→1) has reached.
class StrikePainter extends CustomPainter {
  const StrikePainter({
    required this.index,
    required this.count,
    required this.dc,
    required this.dr,
    required this.progress,
  });

  final int index;
  final int count;
  final int dc;
  final int dr;
  final double progress;

  static const _inset = 0.25;

  @override
  void paint(Canvas canvas, Size size) {
    final end = _inset + (count - 2 * _inset) * progress;
    final from = max(_inset, index.toDouble()), to = min(end, index + 1.0);
    if (to <= from) return;
    Offset at(double t) {
      final u = t - index;
      return Offset((0.5 + (u - 0.5) * dc) * size.width, (0.5 + (u - 0.5) * dr) * size.height);
    }

    canvas.drawLine(
      at(from),
      at(to),
      Paint()
        ..color = AppColors.ink
        ..strokeWidth = size.shortestSide * 0.12
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(StrikePainter old) => old.progress != progress || old.index != index || old.count != count;
}
