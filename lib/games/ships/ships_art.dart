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
      _waves(canvas, r);
    case ShipsLook.hit:
      _cross(canvas, r, ShipsColors.fire);
  }
  if (shot && look == ShipsLook.sea && piece != null) _cross(canvas, r, ShipsColors.fire);
}

/// A shot into the water: two little waves, the lower one shifted.
void _waves(Canvas canvas, Rect r) {
  final side = r.shortestSide;
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = side * 0.08
    ..strokeCap = StrokeCap.round
    ..color = ShipsColors.seaDeep;
  final width = side * 0.56, crest = side * 0.07;
  for (final (dy, dx) in [(-0.12, -0.04), (0.12, 0.04)]) {
    final start = r.center.translate(-width / 2 + side * dx, side * dy);
    final path = Path()..moveTo(start.dx, start.dy);
    // Two humps: up, down, up, down.
    for (var i = 0; i < 4; i++) {
      final x = start.dx + width * (i + 1) / 4;
      path.quadraticBezierTo(x - width / 8, start.dy + (i.isEven ? -crest : crest), x, start.dy);
    }
    canvas.drawPath(path, paint);
  }
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

/// The slice of a whole ship that lies on cell [r]: the ship is drawn in
/// one piece and clipped to the cell, so it reads as one vessel across cells.
void _paintPiece(Canvas canvas, Rect r, ShipPiece piece) {
  final side = r.shortestSide;
  canvas
    ..save()
    ..clipRect(r);
  if (piece.horizontal) {
    canvas.translate(r.left - piece.index * side, r.top);
  } else {
    // Bow down: the ship's length runs along the screen's y axis.
    canvas
      ..translate(r.left + side, r.top - piece.index * side)
      ..rotate(pi / 2);
  }
  paintShip(canvas, piece.length, side, sunk: piece.sunk);
  canvas.restore();
}

/// A grey warship seen from above, [length] cells long and one cell
/// ([side]) wide, bow to the right: a hull with a pointed bow, a deck, a
/// white bridge and gun turrets. A sunk one is dark and burnt.
void paintShip(Canvas canvas, int length, double side, {bool sunk = false}) {
  final h = side, l = length * side;
  final m = h * 0.16;
  final top = m, bottom = h - m, mid = h / 2;
  final stern = m * 0.8, bowTip = l - m * 0.5, bowStart = l - h * 0.95;
  final c = h * 0.14;
  Path hull(double inset) {
    final t = top + inset, b = bottom - inset, s = stern + inset, tip = bowTip - inset * 1.8;
    return Path()
      ..moveTo(s + c, t)
      ..lineTo(bowStart, t)
      ..quadraticBezierTo(tip - h * 0.2, t, tip, mid)
      ..quadraticBezierTo(tip - h * 0.2, b, bowStart, b)
      ..lineTo(s + c, b)
      ..quadraticBezierTo(s, b, s, b - c)
      ..lineTo(s, t + c)
      ..quadraticBezierTo(s, t, s + c, t)
      ..close();
  }

  final hullColour = sunk ? const Color(0xFF3A3F45) : const Color(0xFF6E7B88);
  final outline = sunk ? const Color(0xFF1F2226) : const Color(0xFF39434D);
  final deckColour = sunk ? const Color(0xFF50565D) : const Color(0xFFA7B2BC);
  final cabinColour = sunk ? const Color(0xFF6A6F75) : const Color(0xFFF1F2F3);
  final gunColour = sunk ? const Color(0xFF2A2D31) : const Color(0xFF46515C);

  // A soft shadow on the water, then the hull, then the deck.
  if (!sunk) {
    canvas.drawPath(hull(0).shift(Offset(h * 0.03, h * 0.05)), Paint()..color = ShipsColors.seaDeep.withValues(alpha: 0.25));
  }
  canvas.drawPath(hull(0), Paint()..color = hullColour);
  canvas.drawPath(
    hull(0),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1, h * 0.04)
      ..color = outline,
  );
  canvas.drawPath(hull(h * 0.08), Paint()..color = deckColour);

  final stroke = max(1.0, h * 0.06);
  void turret(double u, {bool backwards = false}) {
    final barrel = Paint()
      ..color = gunColour
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(Offset(u, mid), Offset(u + (backwards ? -1 : 1) * h * 0.32, mid), barrel)
      ..drawCircle(Offset(u, mid), h * 0.13, Paint()..color = gunColour);
  }

  // The bridge a little behind the middle; turrets in front and behind
  // where there is room.
  final cabinU = l * 0.42;
  final cabin = Rect.fromCenter(center: Offset(cabinU, mid), width: h * 0.5, height: h * 0.34);
  for (var u = l - h * 0.95; u > cabinU + h * 0.6; u -= h * 0.62) {
    turret(u);
  }
  if (cabinU - h * 0.65 >= h * 0.6) turret(h * 0.6, backwards: true);
  canvas.drawRRect(RRect.fromRectAndRadius(cabin, Radius.circular(h * 0.06)), Paint()..color = cabinColour);
  canvas.drawRRect(
    RRect.fromRectAndRadius(cabin, Radius.circular(h * 0.06)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.75, h * 0.025)
      ..color = outline,
  );
  // Bridge windows facing the bow.
  canvas.drawLine(
    Offset(cabin.right - h * 0.07, cabin.top + h * 0.07),
    Offset(cabin.right - h * 0.07, cabin.bottom - h * 0.07),
    Paint()
      ..color = sunk ? outline : const Color(0xFF2E5E7E)
      ..strokeWidth = stroke * 0.8
      ..strokeCap = StrokeCap.round,
  );
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
