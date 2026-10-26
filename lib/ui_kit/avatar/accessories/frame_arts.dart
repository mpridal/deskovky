import 'dart:math';
import 'dart:ui';

import 'accessory_art.dart';

/// "Rámeček" (spec 5.6): a ring around the circle, between radius 43.5 and 49.5
/// (painted outside the circle clip, so nothing may reach radius 50).
const Map<String, AccessoryArt> frameArts = {
  'wood_frame': AccessoryArt(AccessorySlot.frame, _woodFrame),
  'gold_frame': AccessoryArt(AccessorySlot.frame, _goldFrame),
  'rainbow_frame': AccessoryArt(AccessorySlot.frame, _rainbowFrame),
  'flame_frame': AccessoryArt(AccessorySlot.frame, _flameFrame, animated: true),
  'star_frame': AccessoryArt(AccessorySlot.frame, _starFrame),
};

const _centre = Offset(50, 50);
const _radius = 46.5;

void _ring(Canvas c, Paint paint) => c.drawCircle(_centre, _radius, paint..style = PaintingStyle.stroke);

void _woodFrame(Canvas c, AccessoryContext ctx) {
  _ring(c, Paint()..color = const Color(0xFFA0703F)..strokeWidth = 6);
  for (var i = 0; i < 12; i++) {
    final a = i * pi / 6;
    c.drawArc(Rect.fromCircle(center: _centre, radius: _radius + (i.isEven ? 1.4 : -1.4)), a, 0.35, false,
        Art.stroke(const Color(0xFF7A522B), 0.9));
  }
}

void _goldFrame(Canvas c, AccessoryContext ctx) {
  _ring(c, Paint()..color = Art.gold..strokeWidth = 6);
  _ring(c, Paint()..color = Art.goldDark..strokeWidth = 1);
  for (final a in [-2.4, -0.8, 0.8, 2.4]) {
    c.drawCircle(_centre + Offset(_radius * cos(a), _radius * sin(a)), 1.8, Art.fill(Art.goldLight));
  }
}

void _rainbowFrame(Canvas c, AccessoryContext ctx) {
  const colours = [Art.red, Color(0xFFE88A2E), Art.yellow, Art.green, Art.blue, Art.purple, Art.red];
  c.drawCircle(
    _centre,
    _radius,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..shader = Gradient.sweep(_centre, colours, [for (var i = 0; i < colours.length; i++) i / (colours.length - 1)]),
  );
}

void _flameFrame(Canvas c, AccessoryContext ctx) {
  _ring(c, Paint()..color = const Color(0xFFD9534F)..strokeWidth = 5);
  // Flames flicker around the ring, staying inside the 100×100 box.
  for (var i = 0; i < 14; i++) {
    final a = i * 2 * pi / 14;
    final flicker = 0.7 + 0.3 * Art.pulse((ctx.t + i / 7) % 1);
    final base = _centre + Offset((_radius - 2) * cos(a), (_radius - 2) * sin(a));
    final tip = _centre + Offset((_radius + 2.8 * flicker) * cos(a + 0.12), (_radius + 2.8 * flicker) * sin(a + 0.12));
    final side = Offset(-sin(a), cos(a)) * 2.6;
    c.drawPath(
      Path()
        ..moveTo((base + side).dx, (base + side).dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo((base - side).dx, (base - side).dy)
        ..close(),
      Art.fill(i.isEven ? const Color(0xFFE8B931) : const Color(0xFFE88A2E)),
    );
  }
}

void _starFrame(Canvas c, AccessoryContext ctx) {
  _ring(c, Paint()..color = const Color(0xFF3A4FA0)..strokeWidth = 6);
  for (var i = 0; i < 8; i++) {
    final a = i * pi / 4 - pi / 2;
    c.drawPath(Art.star(_centre + Offset(_radius * cos(a), _radius * sin(a)), 3.0, 1.3), Art.fill(Art.goldLight));
  }
}
