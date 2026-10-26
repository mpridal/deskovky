import 'dart:ui';

import 'accessory_art.dart';

/// "Na obličej" (spec 5.6): over the eyes at y ≈ 51.
const Map<String, AccessoryArt> faceArts = {
  'glasses': AccessoryArt(AccessorySlot.face, _glasses),
  'sunglasses': AccessoryArt(AccessorySlot.face, _sunglasses),
  'hero_mask': AccessoryArt(AccessorySlot.face, _heroMask),
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
