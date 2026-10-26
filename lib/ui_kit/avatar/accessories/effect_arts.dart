import 'dart:ui';

import 'accessory_art.dart';

/// "Efekt" (spec 5.6): particles around the avatar; still below 64 dp.
const Map<String, AccessoryArt> effectArts = {
  'sparkles': AccessoryArt(AccessorySlot.effect, _sparkles, animated: true),
  'bubbles': AccessoryArt(AccessorySlot.effect, _bubbles, animated: true),
  'snow': AccessoryArt(AccessorySlot.effect, _snow, animated: true),
};

const _sparkleSpots = [Offset(18, 30), Offset(82, 26), Offset(14, 62), Offset(86, 58), Offset(30, 12), Offset(70, 88)];

void _sparkles(Canvas c, AccessoryContext ctx) {
  for (var i = 0; i < _sparkleSpots.length; i++) {
    final glow = Art.pulse((ctx.t + i / _sparkleSpots.length) % 1);
    final size = 2 + 2.2 * glow;
    c.drawPath(Art.star(_sparkleSpots[i], size, size * 0.35), Art.fill(Art.goldLight.withValues(alpha: 0.5 + 0.5 * glow)));
  }
}

void _bubbles(Canvas c, AccessoryContext ctx) {
  const columns = [14.0, 26.0, 74.0, 86.0, 20.0, 80.0];
  for (var i = 0; i < columns.length; i++) {
    final phase = (ctx.t + i / columns.length) % 1;
    final y = 92 - 70 * phase;
    final r = 2.2 + (i % 3);
    c.drawCircle(Offset(columns[i], y), r, Art.fill(Art.white.withValues(alpha: 0.18)));
    c.drawCircle(Offset(columns[i], y), r, Art.stroke(Art.white.withValues(alpha: 0.7), 0.8));
  }
}

void _snow(Canvas c, AccessoryContext ctx) {
  const columns = [12.0, 24.0, 38.0, 62.0, 76.0, 88.0, 30.0, 70.0];
  for (var i = 0; i < columns.length; i++) {
    final phase = (ctx.t + i * 0.13) % 1;
    final y = 6 + 88 * phase;
    final x = columns[i] + 2 * Art.pulse((phase * 2) % 1);
    final flake = Art.stroke(Art.white.withValues(alpha: 0.9), 0.8);
    for (final d in const [Offset(1.8, 0), Offset(0.9, 1.6), Offset(-0.9, 1.6)]) {
      c.drawLine(Offset(x, y) - d, Offset(x, y) + d, flake);
    }
  }
}
