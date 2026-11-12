import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import 'ships_rules.dart';

/// Colours of the sea (the app's tokens have no blue but player 2's).
abstract final class ShipsColors {
  static const sea = Color(0xFFB9D4E2);
  static const seaLine = Color(0xFF8FB3C7);
  static const seaDeep = Color(0xFF2E5E7E);
  static const water = Color(0xFFD9E7EE);
  static const fire = Color(0xFFE0562A);
  static const wreck = Color(0xFF4A3A30);
}

/// What one cell shows.
enum ShipsLook {
  /// Unknown or empty sea.
  sea,

  /// A shot that fell in the water.
  miss,

  /// Water known from a sunk ship next to it.
  water,

  /// A hit on a ship not (yet) known as sunk.
  hit,
}

/// Which piece of a ship lies on a cell: its place along the ship and the
/// direction, so the ends are drawn as bow and stern.
@immutable
class ShipPiece {
  const ShipPiece({required this.index, required this.length, required this.horizontal, this.sunk = false});

  final int index;
  final int length;
  final bool horizontal;
  final bool sunk;
}

/// The ship pieces of [ships] by cell; [sunk] marks ships drawn as wrecks.
Map<int, ShipPiece> shipPieces(int size, List<Ship> ships, {Set<int> sunk = const {}}) => {
  for (final (s, ship) in ships.indexed)
    for (final (i, cell) in ship.cells(size).indexed)
      cell: ShipPiece(index: i, length: ship.length, horizontal: ship.horizontal, sunk: sunk.contains(s)),
};

/// Paints one cell of the sea: water, then a ship piece, then a shot mark.
void paintShipsCell(Canvas canvas, Rect r, ShipsLook look, ShipPiece? piece, {bool shot = false}) {
  final side = r.shortestSide;
  canvas.drawRect(r, Paint()..color = look == ShipsLook.water ? ShipsColors.water : ShipsColors.sea);
  canvas.drawRect(
    r.deflate(0.5),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.5, side * 0.02)
      ..color = ShipsColors.seaLine,
  );
  if (piece != null) _paintPiece(canvas, r, piece);
  switch (look) {
    case ShipsLook.sea:
      break;
    case ShipsLook.water:
      canvas.drawCircle(r.center, side * 0.06, Paint()..color = ShipsColors.seaLine);
    case ShipsLook.miss:
      canvas.drawCircle(
        r.center,
        side * 0.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.08
          ..color = ShipsColors.seaDeep,
      );
    case ShipsLook.hit:
      _cross(canvas, r, ShipsColors.fire);
  }
  if (shot && look == ShipsLook.sea && piece != null) _cross(canvas, r, ShipsColors.fire);
}

void _cross(Canvas canvas, Rect r, Color colour) {
  final d = r.shortestSide * 0.28;
  final p = Paint()
    ..color = colour
    ..strokeWidth = r.shortestSide * 0.12
    ..strokeCap = StrokeCap.round;
  canvas
    ..drawLine(r.center.translate(-d, -d), r.center.translate(d, d), p)
    ..drawLine(r.center.translate(d, -d), r.center.translate(-d, d), p);
}

/// A wooden hull piece: rounded at the bow and the stern, one plank line.
void _paintPiece(Canvas canvas, Rect r, ShipPiece piece) {
  final side = r.shortestSide;
  final inset = side * 0.14;
  final first = piece.index == 0, last = piece.index == piece.length - 1;
  final round = Radius.circular(side * 0.4);
  final body = piece.horizontal
      ? Rect.fromLTRB(first ? r.left + inset : r.left, r.top + inset, last ? r.right - inset : r.right, r.bottom - inset)
      : Rect.fromLTRB(r.left + inset, first ? r.top + inset : r.top, r.right - inset, last ? r.bottom - inset : r.bottom);
  final rrect = piece.horizontal
      ? RRect.fromRectAndCorners(body, topLeft: first ? round : Radius.zero, bottomLeft: first ? round : Radius.zero, topRight: last ? round : Radius.zero, bottomRight: last ? round : Radius.zero)
      : RRect.fromRectAndCorners(body, topLeft: first ? round : Radius.zero, topRight: first ? round : Radius.zero, bottomLeft: last ? round : Radius.zero, bottomRight: last ? round : Radius.zero);
  canvas.drawRRect(rrect, Paint()..color = piece.sunk ? ShipsColors.wreck : AppColors.wood);
  final plank = Paint()
    ..color = (piece.sunk ? Colors.black : AppColors.woodLight).withValues(alpha: 0.6)
    ..strokeWidth = max(1, side * 0.05);
  if (piece.horizontal) {
    canvas.drawLine(Offset(body.left + (first ? side * 0.2 : 0), body.center.dy), Offset(body.right - (last ? side * 0.2 : 0), body.center.dy), plank);
  } else {
    canvas.drawLine(Offset(body.center.dx, body.top + (first ? side * 0.2 : 0)), Offset(body.center.dx, body.bottom - (last ? side * 0.2 : 0)), plank);
  }
}

/// One cell as a widget, for `BoardGrid`.
class ShipsCell extends StatelessWidget {
  const ShipsCell({super.key, required this.look, this.piece, this.shot = false, this.selected = false});

  final ShipsLook look;
  final ShipPiece? piece;

  /// The other seat has shot this cell of an own ship (drawn as a hit).
  final bool shot;
  final bool selected;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _CellPainter(look, piece, shot, selected),
    child: const SizedBox.expand(),
  );
}

class _CellPainter extends CustomPainter {
  _CellPainter(this.look, this.piece, this.shot, this.selected);

  final ShipsLook look;
  final ShipPiece? piece;
  final bool shot;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    paintShipsCell(canvas, r, look, piece, shot: shot);
    if (selected) {
      canvas.drawRect(
        r.deflate(1.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.gold,
      );
    }
  }

  @override
  bool shouldRepaint(_CellPainter old) =>
      old.look != look || old.piece != piece || old.shot != shot || old.selected != selected;
}

/// A whole sea in one picture (the small "own fleet" map, the icon, the
/// rule steps): [looks] and [pieces] by cell, [shotShips] the ship cells hit.
class ShipsSea extends StatelessWidget {
  const ShipsSea({super.key, required this.size, this.looks = const {}, this.pieces = const {}, this.shotShips = const {}, this.mark});

  final int size;
  final Map<int, ShipsLook> looks;
  final Map<int, ShipPiece> pieces;
  final Set<int> shotShips;

  /// A cell framed in gold, e.g. the last shot.
  final int? mark;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: CustomPaint(painter: _SeaPainter(size, looks, pieces, shotShips, mark)),
  );
}

class _SeaPainter extends CustomPainter {
  _SeaPainter(this.n, this.looks, this.pieces, this.shotShips, this.mark);

  final int n;
  final Map<int, ShipsLook> looks;
  final Map<int, ShipPiece> pieces;
  final Set<int> shotShips;
  final int? mark;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.shortestSide / n;
    for (var c = 0; c < n * n; c++) {
      final r = Rect.fromLTWH((c % n) * cell, (c ~/ n) * cell, cell, cell);
      paintShipsCell(canvas, r, looks[c] ?? ShipsLook.sea, pieces[c], shot: shotShips.contains(c));
    }
    final m = mark;
    if (m != null) {
      canvas.drawRect(
        Rect.fromLTWH((m % n) * cell, (m ~/ n) * cell, cell, cell).deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(2, cell * 0.12)
          ..color = AppColors.gold,
      );
    }
    canvas.drawRect(
      Offset.zero & Size.square(cell * n),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ShipsColors.seaDeep,
    );
  }

  @override
  bool shouldRepaint(_SeaPainter old) => true;
}
