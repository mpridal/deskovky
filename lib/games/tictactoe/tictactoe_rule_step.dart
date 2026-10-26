import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'tictactoe_marks.dart';

/// The illustrated rule steps (spec 13.4).
enum TictactoeRuleStepKind { tap, three, five, draw }

/// One rule step: a little squared-paper board drawn in code, and a caption.
class TictactoeRuleStep extends StatelessWidget {
  const TictactoeRuleStep({super.key, required this.kind, required this.text});

  final TictactoeRuleStepKind kind;
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
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.wood, width: 2),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MiniBoardPainter(kind)),
              if (kind == TictactoeRuleStepKind.tap)
                Align(
                  alignment: const Alignment(0.75, 0.85),
                  child: Icon(Icons.touch_app, size: 30, color: AppColors.ink.withValues(alpha: 0.8)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
      ],
    ),
  );
}

class _MiniBoardPainter extends CustomPainter {
  const _MiniBoardPainter(this.kind);

  final TictactoeRuleStepKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final n = kind == TictactoeRuleStepKind.five ? 6 : 3;
    final cell = size.width / n;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        canvas.save();
        canvas.translate(c * cell, r * cell);
        PaperCellPainter(right: c == n - 1, bottom: r == n - 1).paint(canvas, Size.square(cell));
        canvas.restore();
      }
    }
    // (column, row, seat) per kind, and the crossed-out row if any.
    final (marks, strike) = switch (kind) {
      TictactoeRuleStepKind.tap => (const [(0, 0, 0), (1, 1, 1)], null),
      TictactoeRuleStepKind.three => (const [(0, 0, 0), (1, 1, 0), (2, 2, 0), (2, 0, 1), (1, 0, 1)], ((0, 0), (2, 2))),
      TictactoeRuleStepKind.five => (
        const [(0, 5, 0), (1, 4, 0), (2, 3, 0), (3, 2, 0), (4, 1, 0), (1, 1, 1), (2, 1, 1), (3, 1, 1), (5, 1, 1)],
        ((0, 5), (4, 1)),
      ),
      TictactoeRuleStepKind.draw => (
        const [(0, 0, 0), (1, 0, 1), (2, 0, 0), (0, 1, 0), (1, 1, 1), (2, 1, 1), (0, 2, 1), (1, 2, 0), (2, 2, 0)],
        null,
      ),
    };
    for (final (c, r, seat) in marks) {
      canvas.save();
      canvas.translate(c * cell, r * cell);
      MarkPainter(seat: seat).paint(canvas, Size.square(cell));
      canvas.restore();
    }
    if (strike != null) {
      final ((c0, r0), (c1, r1)) = strike;
      canvas.drawLine(
        Offset((c0 + 0.3) * cell, (r0 + (r1 > r0 ? 0.3 : 0.7)) * cell),
        Offset((c1 + 0.7) * cell, (r1 + (r1 > r0 ? 0.7 : 0.3)) * cell),
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = cell * 0.14
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniBoardPainter old) => old.kind != kind;
}
