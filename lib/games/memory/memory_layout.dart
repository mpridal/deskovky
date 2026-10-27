import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Where the cards go: [columns] × [rows] square cards of [side] with [gap]
/// between them, centred in the area (spec 13.6: the grid makes the cards as
/// big as the screen's shape allows, in any orientation).
@immutable
class MemoryGrid {
  const MemoryGrid({
    required this.columns,
    required this.rows,
    required this.side,
    required this.gap,
    required this.size,
  });

  final int columns;
  final int rows;
  final double side;
  final double gap;

  /// Size of the whole grid; larger than the area only when cards would be
  /// smaller than [minSide] (then the board scrolls).
  final Size size;

  /// Cards are never smaller than a comfortable touch target (spec 13.4).
  static const minSide = 48.0;

  /// Top left corner of card [index] (reading order); the last row is centred.
  Offset cardAt(int index, int cards) {
    final row = index ~/ columns;
    final col = index % columns;
    final inRow = row == rows - 1 ? cards - row * columns : columns;
    final shift = (columns - inRow) * (side + gap) / 2;
    return Offset(shift + col * (side + gap), row * (side + gap));
  }

  static MemoryGrid fit(Size area, int cards) {
    final gap = area.shortestSide < 500 ? 6.0 : 10.0;
    var best = (columns: cards, rows: 1, side: 0.0);
    for (var columns = 1; columns <= cards; columns++) {
      final rows = (cards / columns).ceil();
      final side = min((area.width - gap * (columns - 1)) / columns, (area.height - gap * (rows - 1)) / rows);
      // Bigger cards first; with equal size, fewer empty places.
      if (side > best.side + 0.01 || ((side - best.side).abs() <= 0.01 && columns * rows < best.columns * best.rows)) {
        best = (columns: columns, rows: rows, side: side);
      }
    }
    final side = max(best.side, minSide).floorToDouble();
    return MemoryGrid(
      columns: best.columns,
      rows: best.rows,
      side: side,
      gap: gap,
      size: Size(best.columns * side + (best.columns - 1) * gap, best.rows * side + (best.rows - 1) * gap),
    );
  }
}
