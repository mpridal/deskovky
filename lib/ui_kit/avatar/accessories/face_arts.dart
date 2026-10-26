import 'dart:ui';

import 'accessory_art.dart';

/// "Na obličej" (spec 5.6): over the eyes at y ≈ 51.
const Map<String, AccessoryArt> faceArts = {
  'glasses': AccessoryArt(AccessorySlot.face, _glasses),
  'mustache': AccessoryArt(AccessorySlot.face, _mustache),
  'face_paint_star': AccessoryArt(AccessorySlot.face, _facePaintStar),
  'sunglasses': AccessoryArt(AccessorySlot.face, _sunglasses),
  'hero_mask': AccessoryArt(AccessorySlot.face, _heroMask),
  'monocle': AccessoryArt(AccessorySlot.face, _monocle),
  'carnival_mask': AccessoryArt(AccessorySlot.face, _carnivalMask),
};

void _glasses(Canvas c, AccessoryContext ctx) {
  final frame = Art.variant(ctx.variant, Art.ink);
  for (final x in [41.0, 59.0]) {
    c.drawCircle(Offset(x, 51), 7.5, Art.fill(Art.white.withValues(alpha: 0.25)));
    c.drawCircle(Offset(x, 51), 7.5, Art.stroke(frame, 2.4));
  }
  final bars = Art.stroke(frame, 2.4);
  c.drawLine(const Offset(48.5, 51), const Offset(51.5, 51), bars);
  c.drawLine(const Offset(26, 48), const Offset(33.5, 50), bars);
  c.drawLine(const Offset(74, 48), const Offset(66.5, 50), bars);
}

void _mustache(Canvas c, AccessoryContext ctx) {
  const hair = Color(0xFF5A3825);
  for (final dir in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(50, 58.5)
        ..quadraticBezierTo(50 + 6 * dir, 55, 50 + 11 * dir, 58)
        ..quadraticBezierTo(50 + 14 * dir, 60, 50 + 15 * dir, 56.5)
        ..quadraticBezierTo(50 + 14 * dir, 63, 50 + 8 * dir, 61.5)
        ..quadraticBezierTo(50 + 4 * dir, 61, 50, 60.5)
        ..close(),
      Art.fill(hair),
    );
  }
}

void _facePaintStar(Canvas c, AccessoryContext ctx) {
  final star = Art.star(const Offset(64, 59), 5.5, 2.4);
  c.drawPath(star, Art.fill(Art.yellow));
  c.drawPath(star, Art.stroke(Art.gold, 0.8));
  c.drawCircle(const Offset(35, 59), 1.6, Art.fill(Art.blue));
  c.drawCircle(const Offset(32, 62), 1.1, Art.fill(Art.red));
}

void _sunglasses(Canvas c, AccessoryContext ctx) {
  for (final x in [31.0, 52.0]) {
    c.drawRRect(RRect.fromLTRBR(x, 45, x + 17, 56, const Radius.circular(5)), Art.fill(Art.ink));
  }
  final bars = Art.stroke(Art.ink, 2.4);
  c.drawLine(const Offset(48, 49), const Offset(52, 49), bars);
  c.drawLine(const Offset(26, 47), const Offset(31, 48), bars);
  c.drawLine(const Offset(74, 47), const Offset(69, 48), bars);
  c.drawLine(const Offset(34, 48), const Offset(39, 48), Art.stroke(Art.white.withValues(alpha: 0.6), 1.5));
}

void _heroMask(Canvas c, AccessoryContext ctx) {
  c.drawPath(
    Path()
      ..moveTo(24, 45)
      ..quadraticBezierTo(50, 38, 76, 45)
      ..quadraticBezierTo(77, 59, 63, 58)
      ..quadraticBezierTo(54, 57, 50, 53)
      ..quadraticBezierTo(46, 57, 37, 58)
      ..quadraticBezierTo(23, 59, 24, 45)
      ..close(),
    Art.fill(Art.blue),
  );
  for (final x in [42.0, 58.0]) {
    c.drawOval(Rect.fromCenter(center: Offset(x, 51), width: 12, height: 9), Art.fill(Art.white));
  }
}

void _monocle(Canvas c, AccessoryContext ctx) {
  c.drawCircle(const Offset(58, 51), 7.5, Art.fill(Art.white.withValues(alpha: 0.3)));
  c.drawCircle(const Offset(58, 51), 7.5, Art.stroke(Art.gold, 2.2));
  c.drawPath(
    Path()
      ..moveTo(64, 56)
      ..quadraticBezierTo(70, 66, 64, 76),
    Art.stroke(Art.goldDark, 1),
  );
}

void _carnivalMask(Canvas c, AccessoryContext ctx) {
  final mask = Path()
    ..moveTo(26, 46)
    ..quadraticBezierTo(38, 40, 50, 46)
    ..quadraticBezierTo(62, 40, 74, 46)
    ..quadraticBezierTo(73, 57, 61, 57)
    ..quadraticBezierTo(54, 56, 50, 52)
    ..quadraticBezierTo(46, 56, 39, 57)
    ..quadraticBezierTo(27, 57, 26, 46)
    ..close();
  c.drawPath(mask, Art.fill(Art.purple));
  c.drawPath(mask, Art.stroke(Art.gold, 1.4));
  for (final x in [41.0, 59.0]) {
    c.drawOval(Rect.fromCenter(center: Offset(x, 50.5), width: 10, height: 6), Art.fill(Art.ink));
  }
  // Feathers on the right.
  for (final (dx, colour) in [(0.0, Art.gold), (5.0, Art.red), (10.0, Art.green)]) {
    c.drawPath(
      Path()
        ..moveTo(72, 45)
        ..quadraticBezierTo(76 + dx, 34 - dx, 82 + dx, 30 - dx * 0.5)
        ..quadraticBezierTo(80 + dx, 40, 74, 47)
        ..close(),
      Art.fill(colour),
    );
  }
}
