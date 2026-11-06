import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'matches_painters.dart';

/// The illustrated rule steps (design §8): the 3-5-7 layout, taking from one
/// row, and the last match burning.
enum MatchesRuleStepKind { layout, take, last }

/// One rule step: a little felt table drawn in code, and a caption.
class MatchesRuleStep extends StatelessWidget {
  const MatchesRuleStep({super.key, required this.kind, required this.text});

  final MatchesRuleStepKind kind;
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
            color: AppColors.felt,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.wood, width: 2),
          ),
          padding: const EdgeInsets.all(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _MiniTablePainter(kind)),
              if (kind == MatchesRuleStepKind.take)
                Align(
                  alignment: const Alignment(0.95, 0.95),
                  child: Icon(Icons.touch_app, size: 26, color: AppColors.paper.withValues(alpha: 0.9)),
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

class _MiniTablePainter extends CustomPainter {
  const _MiniTablePainter(this.kind);

  final MatchesRuleStepKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final slot = size.width / 7;
    final rowH = size.height / 3;
    void match(int row, int i, int of, {Color? glow, double lift = 0, double burn = 0}) {
      final left = (size.width - of * slot) / 2 + i * slot;
      MatchArt.paint(canvas, Rect.fromLTWH(left, row * rowH + 2 - lift, slot, rowH - 4), glow: glow, burn: burn);
    }

    switch (kind) {
      case MatchesRuleStepKind.layout:
        for (final (row, n) in const [(0, 3), (1, 5), (2, 7)]) {
          for (var i = 0; i < n; i++) {
            match(row, i, n);
          }
        }
      case MatchesRuleStepKind.take:
        for (var i = 0; i < 3; i++) {
          match(0, i, 3);
        }
        for (var i = 0; i < 5; i++) {
          final picked = i >= 3;
          match(1, i, 5, glow: picked ? AppColors.players[0] : null, lift: picked ? rowH * 0.15 : 0);
        }
        for (var i = 0; i < 4; i++) {
          match(2, i, 7);
        }
      case MatchesRuleStepKind.last:
        final box = Rect.fromCenter(center: size.center(Offset(0, size.height * 0.12)), width: size.width * 0.3, height: size.height * 0.62);
        MatchArt.paint(canvas, box, burn: 0.45);
    }
  }

  @override
  bool shouldRepaint(_MiniTablePainter old) => old.kind != kind;
}
