import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'minesweeper_art.dart';

/// One illustrated rule step (spec 13.4): a 3×3 piece of the board drawn
/// with the game's own squares and a caption.
class MinesweeperRuleStep extends StatelessWidget {
  const MinesweeperRuleStep({super.key, required this.cells, required this.text, this.puff = false});

  /// Nine squares, row by row: look and number.
  final List<(CellLook, int)> cells;
  final String text;

  /// A smoke cloud over the middle square.
  final bool puff;

  /// Tap: the first tap opens an empty area.
  static const open = [
    (CellLook.hidden, 0), (CellLook.hidden, 0), (CellLook.hidden, 0),
    (CellLook.open, 1), (CellLook.open, 1), (CellLook.open, 2),
    (CellLook.open, 0), (CellLook.open, 0), (CellLook.open, 0),
  ];

  /// A number counts the mines around it.
  static const number = [
    (CellLook.flag, 0), (CellLook.open, 1), (CellLook.flag, 0),
    (CellLook.open, 1), (CellLook.open, 2), (CellLook.open, 1),
    (CellLook.open, 0), (CellLook.open, 0), (CellLook.open, 0),
  ];

  /// A flag where a mine must be.
  static const flag = [
    (CellLook.hidden, 0), (CellLook.hidden, 0), (CellLook.hidden, 0),
    (CellLook.open, 1), (CellLook.flag, 0), (CellLook.open, 1),
    (CellLook.open, 1), (CellLook.open, 1), (CellLook.open, 1),
  ];

  /// Střídačka: a mine is a puff and that player is out.
  static const out = [
    (CellLook.open, 1), (CellLook.open, 1), (CellLook.open, 1),
    (CellLook.open, 1), (CellLook.exploded, 0), (CellLook.open, 1),
    (CellLook.open, 1), (CellLook.open, 1), (CellLook.open, 1),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.wood, borderRadius: BorderRadius.circular(10)),
        child: CustomPaint(painter: _StepPainter(cells, puff)),
      ),
      const SizedBox(height: 6),
      Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
    ],
  );
}

class _StepPainter extends CustomPainter {
  _StepPainter(this.cells, this.puff);

  final List<(CellLook, int)> cells;
  final bool puff;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 3;
    for (var i = 0; i < 9; i++) {
      final (look, number) = cells[i];
      canvas
        ..save()
        ..translate((i % 3) * s, (i ~/ 3) * s);
      CellPainter(look: look, number: number, tint: look == CellLook.exploded ? AppColors.players[1] : null)
          .paint(canvas, Size.square(s));
      canvas.restore();
    }
    if (puff) paintPuff(canvas, size.center(Offset.zero), s * 1.8, 0.35);
  }

  @override
  bool shouldRepaint(_StepPainter old) => false;
}
