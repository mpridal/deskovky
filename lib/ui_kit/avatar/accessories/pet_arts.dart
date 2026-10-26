import 'dart:math';
import 'dart:ui';

import 'accessory_art.dart';

/// "Mazlíček" (spec 5.6): sits on the left shoulder at the bottom left.
const Map<String, AccessoryArt> petArts = {
  'kitten': AccessoryArt(AccessorySlot.pet, _kitten),
  'chick': AccessoryArt(AccessorySlot.pet, _chick),
  'puppy': AccessoryArt(AccessorySlot.pet, _puppy),
  'parrot': AccessoryArt(AccessorySlot.pet, _parrot),
  'dragon': AccessoryArt(AccessorySlot.pet, _dragon),
};

const _seat = Offset(25, 76);

/// Pets are drawn small around [_seat] and enlarged here, so they read on
/// the shoulder instead of hiding at the circle's edge.
void _onShoulder(Canvas c, void Function() draw) {
  c.save();
  c.translate(_seat.dx, _seat.dy);
  c.scale(1.45);
  c.translate(-_seat.dx, -_seat.dy);
  draw();
  c.restore();
}

void _eyes(Canvas c, Offset centre, {double gap = 3.4, double y = -1}) {
  for (final dx in [-gap / 2, gap / 2]) {
    c.drawCircle(centre + Offset(dx, y), 1.1, Art.fill(Art.ink));
  }
}

void _kitten(Canvas c, AccessoryContext ctx) => _onShoulder(c, () => _kittenBody(c));

void _kittenBody(Canvas c) {
  const fur = Color(0xFFE8A35A);
  for (final dir in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(_seat.dx + 3 * dir, _seat.dy - 6)
        ..lineTo(_seat.dx + 7 * dir, _seat.dy - 13)
        ..lineTo(_seat.dx + 8 * dir, _seat.dy - 3)
        ..close(),
      Art.fill(fur),
    );
  }
  c.drawCircle(_seat, 8, Art.fill(fur));
  c.drawCircle(_seat + const Offset(0, 2.5), 3, Art.fill(const Color(0xFFF4EADB)));
  _eyes(c, _seat);
  c.drawCircle(_seat + const Offset(0, 1.6), 0.9, Art.fill(const Color(0xFFE06C75)));
  for (final dir in [-1.0, 1.0]) {
    c.drawLine(_seat + Offset(3 * dir, 2), _seat + Offset(9 * dir, 1), Art.stroke(Art.ink, 0.5));
  }
}

void _chick(Canvas c, AccessoryContext ctx) => _onShoulder(c, () => _chickBody(c));

void _chickBody(Canvas c) {
  c.drawCircle(_seat + const Offset(0, 1), 8, Art.fill(Art.yellow));
  c.drawOval(Rect.fromCenter(center: _seat + const Offset(-6, 3), width: 5, height: 7), Art.fill(const Color(0xFFD9A62A)));
  _eyes(c, _seat, y: -1.5);
  c.drawPath(
    Path()
      ..moveTo(_seat.dx - 1.6, _seat.dy + 1)
      ..lineTo(_seat.dx + 1.6, _seat.dy + 1)
      ..lineTo(_seat.dx, _seat.dy + 3.5)
      ..close(),
    Art.fill(const Color(0xFFE88A2E)),
  );
  c.drawLine(_seat + const Offset(0, -7), _seat + const Offset(1.5, -10.5), Art.stroke(const Color(0xFFD9A62A), 1.2));
}

void _puppy(Canvas c, AccessoryContext ctx) => _onShoulder(c, () => _puppyBody(c));

void _puppyBody(Canvas c) {
  const fur = Color(0xFFC89B6D);
  const ear = Color(0xFF6B4A2E);
  c.drawCircle(_seat, 8, Art.fill(fur));
  for (final dir in [-1.0, 1.0]) {
    c.drawOval(Rect.fromCenter(center: _seat + Offset(7.5 * dir, 1), width: 5, height: 10), Art.fill(ear));
  }
  c.drawOval(Rect.fromCenter(center: _seat + const Offset(0, 3), width: 7, height: 5), Art.fill(const Color(0xFFF4EADB)));
  _eyes(c, _seat, y: -2);
  c.drawCircle(_seat + const Offset(0, 1.8), 1.3, Art.fill(Art.ink));
}

void _parrot(Canvas c, AccessoryContext ctx) => _onShoulder(c, () => _parrotBody(c));

void _parrotBody(Canvas c) {
  c.drawPath(
    Path()
      ..moveTo(_seat.dx - 2, _seat.dy + 6)
      ..lineTo(_seat.dx - 6, _seat.dy + 16)
      ..lineTo(_seat.dx + 1, _seat.dy + 7)
      ..close(),
    Art.fill(Art.blue),
  );
  c.drawOval(Rect.fromCenter(center: _seat + const Offset(0, 2), width: 13, height: 16), Art.fill(Art.green));
  c.drawCircle(_seat + const Offset(0, -5), 5.5, Art.fill(Art.red));
  c.drawPath(
    Path()
      ..moveTo(_seat.dx + 4, _seat.dy - 6)
      ..quadraticBezierTo(_seat.dx + 9, _seat.dy - 5, _seat.dx + 6, _seat.dy - 1)
      ..quadraticBezierTo(_seat.dx + 5, _seat.dy - 3, _seat.dx + 3, _seat.dy - 3)
      ..close(),
    Art.fill(Art.gold),
  );
  c.drawCircle(_seat + const Offset(1.5, -6), 1.1, Art.fill(Art.ink));
  c.drawOval(Rect.fromCenter(center: _seat + const Offset(-3.5, 3), width: 5, height: 9), Art.fill(Art.yellow));
}

void _dragon(Canvas c, AccessoryContext ctx) => _onShoulder(c, () => _dragonBody(c));

void _dragonBody(Canvas c) {
  const scales = Color(0xFF4CAF6A);
  const belly = Color(0xFFE8D28A);
  // Wings behind.
  for (final dir in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(_seat.dx + 2 * dir, _seat.dy)
        ..lineTo(_seat.dx + 11 * dir, _seat.dy - 10)
        ..lineTo(_seat.dx + 9 * dir, _seat.dy - 2)
        ..lineTo(_seat.dx + 12 * dir, _seat.dy + 1)
        ..close(),
      Art.fill(const Color(0xFF8E5BC8)),
    );
  }
  c.drawCircle(_seat, 8, Art.fill(scales));
  c.drawOval(Rect.fromCenter(center: _seat + const Offset(0, 3), width: 8, height: 6), Art.fill(belly));
  for (final dir in [-1.0, 1.0]) {
    c.drawPath(
      Path()
        ..moveTo(_seat.dx + 2.5 * dir, _seat.dy - 7)
        ..lineTo(_seat.dx + 4 * dir, _seat.dy - 12)
        ..lineTo(_seat.dx + 5.5 * dir, _seat.dy - 6)
        ..close(),
      Art.fill(Art.gold),
    );
  }
  _eyes(c, _seat, gap: 4, y: -2);
  // A little smoke puff.
  for (var i = 0; i < 3; i++) {
    final a = -pi / 3 + i * 0.3;
    c.drawCircle(_seat + Offset(10 + 2.0 * i, -2 - 2.0 * i) + Offset(cos(a), sin(a)), 1.4 - 0.3 * i, Art.fill(const Color(0xCCFFFFFF)));
  }
}
