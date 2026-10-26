import 'dart:ui';

import 'ludo_rules.dart';

/// Where things lie on the 11 × 11 cross board, in cell units (column, row).
/// Corner 0 starts on the left arm and the ring runs clockwise.
abstract final class LudoGeometry {
  static const size = 11;

  /// The 40 ring fields, clockwise from corner 0's start field.
  static final List<(int, int)> ring = () {
    final cells = <(int, int)>[];
    void line(int c, int r, int dc, int dr, int n) {
      for (var k = 0; k < n; k++) {
        cells.add((c + dc * k, r + dr * k));
      }
    }

    line(0, 4, 1, 0, 5); // left arm, top edge → centre
    line(4, 3, 0, -1, 4); // up the top arm
    line(5, 0, 1, 0, 2); // across its end
    line(6, 1, 0, 1, 4); // down
    line(7, 4, 1, 0, 4); // right arm, top edge
    line(10, 5, 0, 1, 2); // its end
    line(9, 6, -1, 0, 4); // back to the centre
    line(6, 7, 0, 1, 4); // down the bottom arm
    line(5, 10, -1, 0, 2); // its end
    line(4, 9, 0, -1, 4); // up
    line(3, 6, -1, 0, 4); // left arm, bottom edge
    line(0, 5, 0, -1, 1); // its end, the last field before corner 0's home
    return List<(int, int)>.unmodifiable(cells);
  }();

  /// Unit step from a corner's arm end towards the centre.
  static const _inward = [(1, 0), (0, 1), (-1, 0), (0, -1)];
  static const _armEnd = [(0, 5), (5, 0), (10, 5), (5, 10)];
  static const _quadrant = [(0, 0), (7, 0), (7, 7), (0, 7)];

  /// Home field 0–3 of [corner], from the entrance inwards.
  static (int, int) home(int corner, int k) {
    final (c, r) = _armEnd[corner];
    final (dc, dr) = _inward[corner];
    return (c + dc * (k + 1), r + dr * (k + 1));
  }

  /// Waiting spot [i] (0–3) in the corner.
  static (int, int) base(int corner, int i) {
    final (c, r) = _quadrant[corner];
    return (c + 1 + i % 2, r + 1 + i ~/ 2);
  }

  /// The quadrant of a corner (cell units), for its tinted area.
  static Rect quadrant(int corner) {
    final (c, r) = _quadrant[corner];
    return Rect.fromLTWH(c.toDouble(), r.toDouble(), 4, 4);
  }

  static (int, int) start(int corner) => ring[corner * 10];

  /// The cell of piece [i] of [seat] standing at [pos].
  static (int, int) cellOf(LudoState s, int seat, int i, int pos) {
    final corner = s.corner(seat);
    if (pos == LudoPos.base) return base(corner, i);
    if (LudoPos.inHome(pos)) return home(corner, pos - LudoPos.ringLength);
    return ring[LudoRules.ringField(s, seat, pos)!];
  }

  /// Cells a piece passes moving from [from] to [to] (both included).
  static List<(int, int)> walk(LudoState s, int seat, int i, int from, int to) => [
    if (from == LudoPos.base) ...[base(s.corner(seat), i), cellOf(s, seat, i, 0)],
    if (from != LudoPos.base)
      for (var p = from; p <= to; p++) cellOf(s, seat, i, p),
  ];
}
