import 'dart:math';
import 'dart:ui';

import 'accessory_art.dart';

/// "Na hlavu" (spec 5.6). Coordinates follow the mockup's SVG avatar.
const Map<String, AccessoryArt> headArts = {
  'cap': AccessoryArt(AccessorySlot.head, _cap, hairLine: 30),
  'ears_headband': AccessoryArt(AccessorySlot.head, _earsHeadband),
  'flower_wreath': AccessoryArt(AccessorySlot.head, _flowerWreath),
  'top_hat': AccessoryArt(AccessorySlot.head, _topHat, hairLine: 24),
  'viking_helmet': AccessoryArt(AccessorySlot.head, _vikingHelmet, hairLine: 30),
  'pirate_bandana': AccessoryArt(AccessorySlot.head, _pirateBandana, hairLine: 31),
  'wizard_hat': AccessoryArt(AccessorySlot.head, _wizardHat, hairLine: 27),
  'crown': AccessoryArt(AccessorySlot.head, _crown),
  'halo': AccessoryArt(AccessorySlot.head, _halo, animated: true),
};

void _cap(Canvas c, AccessoryContext ctx) {
  final colour = Art.variant(ctx.variant, Art.red);
  final shade = Color.lerp(colour, Art.ink, 0.25)!;
  c.drawPath(
    Path()
      ..moveTo(24, 34)
      ..quadraticBezierTo(24, 10, 50, 10)
      ..quadraticBezierTo(76, 10, 76, 34)
      ..close(),
    Art.fill(colour),
  );
  // The peak points forward-right, like the free cap hairstyle.
  c.drawPath(
    Path()
      ..moveTo(46, 31)
      ..quadraticBezierTo(76, 26, 90, 35)
      ..quadraticBezierTo(72, 39, 46, 36)
      ..close(),
    Art.fill(shade),
  );
  c.drawCircle(const Offset(50, 11), 2.5, Art.fill(shade));
  c.drawLine(const Offset(50, 12), const Offset(50, 33), Art.stroke(shade.withValues(alpha: 0.6), 1.2));
}

void _earsHeadband(Canvas c, AccessoryContext ctx) {
  const band = Color(0xFFE88FB4);
  const inner = Color(0xFFF7C6DA);
  for (final x in [30.0, 70.0]) {
    final tip = x < 50 ? -4.0 : 4.0;
    c.drawPath(
      Path()
        ..moveTo(x - 9, 24)
        ..lineTo(x + tip, 4)
        ..lineTo(x + 9, 22)
        ..close(),
      Art.fill(band),
    );
    c.drawPath(
      Path()
        ..moveTo(x - 5, 22)
        ..lineTo(x + tip * 0.75, 9)
        ..lineTo(x + 5, 21)
        ..close(),
      Art.fill(inner),
    );
  }
  c.drawArc(const Rect.fromLTWH(24, 16, 52, 30), pi, pi, false, Art.stroke(band, 4.5));
}

void _flowerWreath(Canvas c, AccessoryContext ctx) {
  c.drawArc(const Rect.fromLTWH(25, 15, 50, 26), pi * 1.05, pi * 0.9, false, Art.stroke(const Color(0xFF4C8F5A), 2.4));
  const colours = [Color(0xFFE88FB4), Art.white, Art.yellow, Color(0xFFE88FB4), Art.white];
  for (var i = 0; i < colours.length; i++) {
    final a = pi * (1.12 + i * 0.19);
    final centre = Offset(50 + 25 * cos(a), 28 + 13 * sin(a));
    for (var p = 0; p < 5; p++) {
      final pa = p * 2 * pi / 5;
      c.drawCircle(centre + Offset(3 * cos(pa), 3 * sin(pa)), 2.4, Art.fill(colours[i]));
    }
    c.drawCircle(centre, 1.8, Art.fill(Art.gold));
  }
}

void _topHat(Canvas c, AccessoryContext ctx) {
  c.drawOval(Rect.fromCenter(center: const Offset(50, 25), width: 60, height: 12), Art.fill(Art.ink));
  c.drawRRect(RRect.fromLTRBR(34, 1, 66, 25, const Radius.circular(3)), Art.fill(Art.ink));
  c.drawRect(const Rect.fromLTWH(34, 17, 32, 5), Art.fill(Art.red));
}

void _vikingHelmet(Canvas c, AccessoryContext ctx) {
  const horn = Color(0xFFF4EADB);
  const hornShade = Color(0xFFC9B79C);
  for (final dir in [-1.0, 1.0]) {
    final h = Path()
      ..moveTo(50 + 20 * dir, 24)
      ..quadraticBezierTo(50 + 34 * dir, 20, 50 + 33 * dir, 4)
      ..quadraticBezierTo(50 + 27 * dir, 16, 50 + 17 * dir, 17)
      ..close();
    c.drawPath(h, Art.fill(horn));
    c.drawPath(h, Art.stroke(hornShade, 1));
  }
  c.drawPath(
    Path()
      ..moveTo(25, 33)
      ..quadraticBezierTo(25, 8, 50, 8)
      ..quadraticBezierTo(75, 8, 75, 33)
      ..close(),
    Art.fill(Art.silver),
  );
  c.drawRect(const Rect.fromLTWH(24, 29, 52, 5), Art.fill(Art.silverDark));
  c.drawRect(const Rect.fromLTWH(48, 9, 4, 22), Art.fill(Art.silverDark));
  for (final x in [30.0, 40.0, 60.0, 70.0]) {
    c.drawCircle(Offset(x, 31.5), 1, Art.fill(Art.silver));
  }
}

void _pirateBandana(Canvas c, AccessoryContext ctx) {
  c.drawPath(
    Path()
      ..moveTo(24, 35)
      ..quadraticBezierTo(24, 12, 50, 12)
      ..quadraticBezierTo(76, 12, 76, 35)
      ..quadraticBezierTo(50, 29, 24, 35)
      ..close(),
    Art.fill(Art.red),
  );
  for (final (x, y) in [(36.0, 22.0), (50.0, 18.0), (64.0, 22.0), (43.0, 28.0), (58.0, 28.0)]) {
    c.drawCircle(Offset(x, y), 1.6, Art.fill(Art.white));
  }
  // Knot and tails on the left side.
  c.drawCircle(const Offset(23, 33), 3.5, Art.fill(Art.red));
  c.drawPath(
    Path()
      ..moveTo(22, 34)
      ..lineTo(13, 44)
      ..lineTo(18, 46)
      ..lineTo(24, 37)
      ..close(),
    Art.fill(const Color(0xFFB8403C)),
  );
}

void _wizardHat(Canvas c, AccessoryContext ctx) {
  c.drawPath(
    Path()
      ..moveTo(24, 28)
      ..quadraticBezierTo(50, 20, 76, 28)
      ..lineTo(56, -2)
      ..quadraticBezierTo(50, -6, 44, 4)
      ..close(),
    Art.fill(const Color(0xFF5B3FA0)),
  );
  c.drawOval(Rect.fromCenter(center: const Offset(50, 28), width: 56, height: 10), Art.fill(const Color(0xFF4A3285)));
  c.drawCircle(const Offset(46, 14), 2, Art.fill(Art.goldLight));
  c.drawCircle(const Offset(55, 21), 1.5, Art.fill(Art.goldLight));
}

void _crown(Canvas c, AccessoryContext ctx) {
  final metal = Art.variant(ctx.variant, Art.gold);
  final dark = metal == Art.silver ? Art.silverDark : Art.goldDark;
  final body = Path()
    ..moveTo(31, 24)
    ..lineTo(34, 6)
    ..lineTo(43, 16)
    ..lineTo(50, 3)
    ..lineTo(57, 16)
    ..lineTo(66, 6)
    ..lineTo(69, 24)
    ..close();
  c.drawPath(body, Art.fill(metal));
  c.drawPath(body, Art.stroke(dark, 1.6));
  c.drawRRect(RRect.fromLTRBR(31, 21, 69, 26, const Radius.circular(2)), Art.fill(dark));
  c.drawCircle(const Offset(50, 15), 2.6, Art.fill(Art.red));
  c.drawCircle(const Offset(40, 19), 1.8, Art.fill(Art.blue));
  c.drawCircle(const Offset(60, 19), 1.8, Art.fill(Art.green));
}

void _halo(Canvas c, AccessoryContext ctx) {
  final ring = Rect.fromCenter(center: const Offset(50, 9), width: 38, height: 10);
  final glow = 0.35 + 0.3 * Art.pulse(ctx.t);
  c.drawOval(ring, Art.stroke(Art.goldLight.withValues(alpha: glow), 6));
  c.drawOval(ring, Art.stroke(Art.gold, 3));
}
