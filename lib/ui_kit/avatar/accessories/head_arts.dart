import 'dart:ui';

import 'accessory_art.dart';

/// "Na hlavu" (spec 5.6). Coordinates follow the mockup's SVG avatar.
const Map<String, AccessoryArt> headArts = {
  'crown': AccessoryArt(AccessorySlot.head, _crown),
  'halo': AccessoryArt(AccessorySlot.head, _halo, animated: true),
  'top_hat': AccessoryArt(AccessorySlot.head, _topHat, hairLine: 24),
  'wizard_hat': AccessoryArt(AccessorySlot.head, _wizardHat, hairLine: 27),
};

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

void _topHat(Canvas c, AccessoryContext ctx) {
  c.drawOval(Rect.fromCenter(center: const Offset(50, 25), width: 60, height: 12), Art.fill(Art.ink));
  c.drawRRect(RRect.fromLTRBR(34, 1, 66, 25, const Radius.circular(3)), Art.fill(Art.ink));
  c.drawRect(const Rect.fromLTWH(34, 17, 32, 5), Art.fill(Art.red));
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
