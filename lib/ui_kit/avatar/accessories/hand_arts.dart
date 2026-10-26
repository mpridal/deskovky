import 'dart:ui';

import 'accessory_art.dart';

/// "Do ruky" (spec 5.6): held by a hand at the bottom right.
const Map<String, AccessoryArt> handArts = {
  'magic_wand': AccessoryArt(AccessorySlot.hand, _magicWand, animated: true),
  'phone': AccessoryArt(AccessorySlot.hand, _phone, animated: true),
};

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

void _phone(Canvas c, AccessoryContext ctx) {
  c.drawRRect(RRect.fromLTRBR(76, 62, 92, 88, const Radius.circular(3.5)), Art.fill(Art.ink));
  // The display blinks gently.
  final screen = Color.lerp(Art.blue, const Color(0xFF7FB0F0), Art.pulse(ctx.t))!;
  c.drawRRect(RRect.fromLTRBR(78, 65, 90, 83, const Radius.circular(1.5)), Art.fill(screen));
  c.drawCircle(const Offset(84, 85.5), 1.1, Art.fill(const Color(0xFF888888)));
  Art.hand(c, ctx.skin, at: const Offset(80, 90));
}
