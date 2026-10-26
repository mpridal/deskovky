import 'dart:math';
import 'dart:ui';

import 'accessory_art.dart';

/// "Do ruky" (spec 5.6): held by a hand at the bottom right.
const Map<String, AccessoryArt> handArts = {
  'lollipop': AccessoryArt(AccessorySlot.hand, _lollipop),
  'balloon': AccessoryArt(AccessorySlot.hand, _balloon),
  'ice_cream': AccessoryArt(AccessorySlot.hand, _iceCream),
  'phone': AccessoryArt(AccessorySlot.hand, _phone, animated: true),
  'microphone': AccessoryArt(AccessorySlot.hand, _microphone),
  'magic_wand': AccessoryArt(AccessorySlot.hand, _magicWand, animated: true),
  'trophy': AccessoryArt(AccessorySlot.hand, _trophy),
};

void _lollipop(Canvas c, AccessoryContext ctx) {
  c.drawLine(const Offset(80, 88), const Offset(87, 68), Art.stroke(Art.white, 2.2));
  c.drawCircle(const Offset(88, 63), 8, Art.fill(const Color(0xFFE88FB4)));
  c.drawArc(Rect.fromCircle(center: const Offset(88, 63), radius: 5), 0, pi * 1.5, false, Art.stroke(Art.white, 1.6));
  c.drawCircle(const Offset(88, 63), 1.6, Art.fill(Art.white));
  Art.hand(c, ctx.skin);
}

void _balloon(Canvas c, AccessoryContext ctx) {
  final colour = Art.variant(ctx.variant, Art.red);
  c.drawPath(
    Path()
      ..moveTo(80, 86)
      ..quadraticBezierTo(86, 72, 84, 60),
    Art.stroke(Art.ink, 0.9),
  );
  c.drawOval(Rect.fromCenter(center: const Offset(85, 48), width: 18, height: 22), Art.fill(colour));
  c.drawPath(
    Path()
      ..moveTo(83, 59)
      ..lineTo(87, 59)
      ..lineTo(85, 61.5)
      ..close(),
    Art.fill(colour),
  );
  c.drawOval(Rect.fromCenter(center: const Offset(81, 43), width: 4, height: 6), Art.fill(Art.white.withValues(alpha: 0.5)));
  Art.hand(c, ctx.skin);
}

void _iceCream(Canvas c, AccessoryContext ctx) {
  c.drawPath(
    Path()
      ..moveTo(81, 66)
      ..lineTo(93, 66)
      ..lineTo(85, 86)
      ..close(),
    Art.fill(const Color(0xFFD8A657)),
  );
  c.drawLine(const Offset(83, 70), const Offset(90, 70), Art.stroke(const Color(0xFFB8843A), 0.8));
  c.drawCircle(const Offset(84, 63), 5, Art.fill(const Color(0xFFF7C6DA)));
  c.drawCircle(const Offset(90, 63), 5, Art.fill(const Color(0xFFF4EADB)));
  c.drawCircle(const Offset(87, 57), 5, Art.fill(const Color(0xFF8B5A3C)));
  c.drawCircle(const Offset(87, 52), 1.5, Art.fill(Art.red));
  Art.hand(c, ctx.skin);
}

void _phone(Canvas c, AccessoryContext ctx) {
  c.drawRRect(RRect.fromLTRBR(76, 62, 92, 88, const Radius.circular(3.5)), Art.fill(Art.ink));
  // The display blinks gently.
  final screen = Color.lerp(Art.blue, const Color(0xFF7FB0F0), Art.pulse(ctx.t))!;
  c.drawRRect(RRect.fromLTRBR(78, 65, 90, 83, const Radius.circular(1.5)), Art.fill(screen));
  c.drawCircle(const Offset(84, 85.5), 1.1, Art.fill(const Color(0xFF888888)));
  Art.hand(c, ctx.skin, at: const Offset(80, 90));
}

void _microphone(Canvas c, AccessoryContext ctx) {
  c.drawLine(const Offset(80, 88), const Offset(86, 70), Art.stroke(Art.ink, 4));
  c.drawCircle(const Offset(88, 64), 7, Art.fill(Art.silver));
  for (final y in [61.0, 64.0, 67.0]) {
    c.drawLine(Offset(83, y), Offset(93, y), Art.stroke(Art.silverDark, 0.9));
  }
  Art.hand(c, ctx.skin);
}

void _magicWand(Canvas c, AccessoryContext ctx) {
  Art.hand(c, ctx.skin);
  c.drawLine(const Offset(79, 88), const Offset(91, 65), Art.stroke(Art.ink, 3.2));
  final star = Art.star(const Offset(92, 61), 6, 2.6);
  c.drawPath(star, Art.fill(Art.gold));
  c.drawPath(star, Art.stroke(Art.goldDark, 1));
  // Sparks twinkle in turn.
  final a = Art.pulse(ctx.t), b = Art.pulse((ctx.t + 0.5) % 1);
  c.drawCircle(const Offset(85, 56), 1.3 + 0.8 * a, Art.fill(Art.goldLight));
  c.drawCircle(const Offset(96, 70), 1.1 + 0.8 * b, Art.fill(Art.goldLight));
}

void _trophy(Canvas c, AccessoryContext ctx) {
  c.drawRect(const Rect.fromLTWH(81, 79, 12, 4), Art.fill(Art.goldDark));
  c.drawRect(const Rect.fromLTWH(85, 72, 4, 7), Art.fill(Art.gold));
  c.drawPath(
    Path()
      ..moveTo(78, 56)
      ..lineTo(96, 56)
      ..quadraticBezierTo(96, 72, 87, 72)
      ..quadraticBezierTo(78, 72, 78, 56)
      ..close(),
    Art.fill(Art.gold),
  );
  for (final dir in [-1.0, 1.0]) {
    c.drawArc(
      Rect.fromCenter(center: Offset(87 + 10 * dir, 61), width: 7, height: 8),
      dir < 0 ? pi / 2 : -pi / 2,
      pi,
      false,
      Art.stroke(Art.gold, 1.6),
    );
  }
  c.drawPath(Art.star(const Offset(87, 63), 3, 1.3), Art.fill(Art.white));
  Art.hand(c, ctx.skin, at: const Offset(78, 82));
}
