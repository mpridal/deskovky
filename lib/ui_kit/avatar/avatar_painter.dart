import 'dart:math';

import 'package:flutter/rendering.dart';

import '../../core/avatar/avatar_spec.dart';

const _ink = Color(0xFF2B211B);
const _mouthColor = Color(0xFF7A2F2A);
const _shirt = Color(0xFFF4EADB);
const _cheek = Color(0x59E58A7A);
const _capColor = Color(0xFFD9534F);
const _capShade = Color(0xFFB8403C);

/// Paints a human avatar in a 100×100 coordinate system (same as the SVG
/// mockup), scaled to the canvas. Layers back to front: background, back
/// hair, shoulders, neck, face, cheeks, eyes, mouth, front hair.
class AvatarPainter extends CustomPainter {
  AvatarPainter(this.spec);

  final AvatarSpec spec;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 100, 100)));

    final skin = AvatarPalette.skin[spec.skin];
    final hair = Paint()..color = AvatarPalette.hair[spec.hairColor];

    canvas.drawCircle(const Offset(50, 50), 50, Paint()..color = AvatarPalette.background[spec.background]);
    _backHair(canvas, hair);
    canvas.drawPath(
      Path()
        ..moveTo(22, 100)
        ..quadraticBezierTo(24, 78, 50, 78)
        ..quadraticBezierTo(76, 78, 78, 100)
        ..close(),
      Paint()..color = _shirt,
    );
    canvas.drawRRect(RRect.fromLTRBR(43, 70, 57, 82, const Radius.circular(4)), Paint()..color = skin);
    _face(canvas, Paint()..color = skin);
    final cheek = Paint()..color = _cheek;
    canvas.drawCircle(const Offset(35, 60), 4, cheek);
    canvas.drawCircle(const Offset(65, 60), 4, cheek);
    _eyes(canvas);
    _mouth(canvas);
    _frontHair(canvas, hair);
    canvas.restore();
  }

  void _face(Canvas canvas, Paint paint) {
    switch (spec.face) {
      case FaceShape.oval:
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 50), width: 48, height: 56), paint);
      case FaceShape.round:
        canvas.drawCircle(const Offset(50, 50), 27, paint);
      case FaceShape.wide:
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 50), width: 56, height: 50), paint);
      case FaceShape.square:
        canvas.drawRRect(RRect.fromLTRBR(24, 23, 76, 77, const Radius.circular(14)), paint);
    }
  }

  void _eyes(Canvas canvas) {
    final fill = Paint()..color = _ink;
    final white = Paint()..color = const Color(0xFFFFFFFF);
    final stroke = _stroke(_ink, 3);

    void roundEye(double x) {
      canvas.drawCircle(Offset(x, 51), 3.6, fill);
      canvas.drawCircle(Offset(x + 1.2, 49.8), 1.1, white);
    }

    void arcUp(double x) => canvas.drawPath(
          Path()
            ..moveTo(x - 4, 52)
            ..quadraticBezierTo(x, 47, x + 4, 52),
          stroke,
        );

    switch (spec.eyes) {
      case EyeStyle.round:
        roundEye(42);
        roundEye(58);
      case EyeStyle.happy:
        arcUp(42);
        arcUp(58);
      case EyeStyle.wink:
        roundEye(42);
        arcUp(58);
      case EyeStyle.sleepy:
        for (final x in [42.0, 58.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(x - 5, 50)
              ..quadraticBezierTo(x, 55, x + 5, 50),
            stroke,
          );
        }
      case EyeStyle.wide:
        for (final x in [42.0, 58.0]) {
          canvas.drawCircle(Offset(x, 51), 5.5, white);
          canvas.drawCircle(Offset(x, 51), 5.5, _stroke(_ink, 1.2));
          canvas.drawCircle(Offset(x, 51.5), 3, fill);
          canvas.drawCircle(Offset(x + 1, 50.3), 1, white);
        }
      case EyeStyle.lashes:
        roundEye(42);
        roundEye(58);
        final lash = _stroke(_ink, 1.5);
        for (final (x, dir) in [(42.0, -1.0), (58.0, 1.0)]) {
          canvas.drawLine(Offset(x + 3 * dir, 48.6), Offset(x + 5.2 * dir, 46.8), lash);
          canvas.drawLine(Offset(x + 1.2 * dir, 47.5), Offset(x + 2.4 * dir, 45.2), lash);
        }
    }
  }

  void _mouth(Canvas canvas) {
    final fill = Paint()..color = _mouthColor;
    final smile = Path()
      ..moveTo(42, 61)
      ..quadraticBezierTo(50, 69, 58, 61);

    switch (spec.mouth) {
      case MouthStyle.smile:
        canvas.drawPath(smile, _stroke(_mouthColor, 3));
      case MouthStyle.open:
        canvas.drawOval(Rect.fromCenter(center: const Offset(50, 64), width: 12, height: 9), fill);
      case MouthStyle.flat:
        canvas.drawLine(const Offset(44, 64), const Offset(56, 64), _stroke(_mouthColor, 3));
      case MouthStyle.grin:
        final grin = Path()
          ..moveTo(41, 61)
          ..quadraticBezierTo(50, 73, 59, 61)
          ..close();
        canvas.drawPath(grin, fill);
        canvas.save();
        canvas.clipPath(grin);
        canvas.drawRect(const Rect.fromLTWH(40, 60, 20, 3.4), Paint()..color = const Color(0xFFFFFFFF));
        canvas.restore();
      case MouthStyle.tongue:
        canvas.drawOval(Rect.fromCenter(center: const Offset(52, 66.5), width: 7, height: 6), Paint()..color = const Color(0xFFE06C75));
        canvas.drawPath(smile, _stroke(_mouthColor, 3));
      case MouthStyle.surprised:
        canvas.drawCircle(const Offset(50, 65), 3.6, fill);
    }
  }

  void _backHair(Canvas canvas, Paint hair) {
    switch (spec.hair) {
      case HairStyle.long:
        canvas.drawPath(
          Path()
            ..moveTo(23, 48)
            ..quadraticBezierTo(20, 16, 50, 16)
            ..quadraticBezierTo(80, 16, 77, 48)
            ..lineTo(80, 86)
            ..lineTo(64, 86)
            ..lineTo(66, 52)
            ..lineTo(34, 52)
            ..lineTo(36, 86)
            ..lineTo(20, 86)
            ..close(),
          hair,
        );
      case HairStyle.bob:
        canvas.drawPath(
          Path()
            ..moveTo(23, 50)
            ..quadraticBezierTo(20, 16, 50, 16)
            ..quadraticBezierTo(80, 16, 77, 50)
            ..lineTo(78, 70)
            ..quadraticBezierTo(70, 74, 64, 70)
            ..lineTo(36, 70)
            ..quadraticBezierTo(30, 74, 22, 70)
            ..close(),
          hair,
        );
      case HairStyle.pigtails:
        for (final x in [17.0, 83.0]) {
          canvas.drawOval(Rect.fromCenter(center: Offset(x, 56), width: 15, height: 24), hair);
        }
        final tie = Paint()..color = const Color(0xFFE0A82E);
        canvas.drawCircle(const Offset(22, 44), 3.2, tie);
        canvas.drawCircle(const Offset(78, 44), 3.2, tie);
      case HairStyle.short:
      case HairStyle.braids:
      case HairStyle.curly:
      case HairStyle.bun:
      case HairStyle.spiky:
      case HairStyle.cap:
      case HairStyle.bald:
        break;
    }
  }

  void _frontHair(Canvas canvas, Paint hair) {
    Path cap(double top, double fringeY) => Path()
      ..moveTo(25, 46)
      ..quadraticBezierTo(24, top, 50, top)
      ..quadraticBezierTo(76, top, 75, 46)
      ..quadraticBezierTo(68, fringeY, 50, fringeY)
      ..quadraticBezierTo(32, fringeY, 25, 46)
      ..close();

    switch (spec.hair) {
      case HairStyle.short:
      case HairStyle.pigtails:
        canvas.drawPath(
          Path()
            ..moveTo(25, 46)
            ..quadraticBezierTo(24, 17, 50, 17)
            ..quadraticBezierTo(76, 17, 75, 46)
            ..quadraticBezierTo(70, 30, 52, 29)
            ..quadraticBezierTo(34, 29, 25, 46)
            ..close(),
          hair,
        );
      case HairStyle.braids:
        // Braids hang in front of the shoulders, so they read at 28 dp too.
        final band = Paint()..color = const Color(0xFFE0A82E);
        for (final x in [26.0, 74.0]) {
          for (var y = 50.0; y <= 82; y += 8) {
            canvas.drawCircle(Offset(x, y), 5, hair);
          }
          canvas.drawRect(Rect.fromCenter(center: Offset(x, 88), width: 7, height: 3), band);
        }
        continue longFront;
      longFront:
      case HairStyle.long:
        canvas.drawPath(
          Path()
            ..moveTo(25, 46)
            ..quadraticBezierTo(27, 18, 50, 18)
            ..quadraticBezierTo(73, 18, 75, 46)
            ..quadraticBezierTo(62, 32, 46, 33)
            ..quadraticBezierTo(34, 35, 25, 46)
            ..close(),
          hair,
        );
      case HairStyle.curly:
        for (var i = 0; i < 9; i++) {
          final a = pi * (1 + i / 8);
          canvas.drawCircle(Offset(50 + 27 * cos(a), 44 + 25 * sin(a)), 9, hair);
        }
        canvas.drawCircle(const Offset(50, 22), 10, hair);
      case HairStyle.bun:
        canvas.drawCircle(const Offset(50, 13), 9, hair);
        canvas.drawPath(cap(19, 31), hair);
      case HairStyle.spiky:
        canvas.drawPath(
          Path()
            ..addPolygon(const [
              Offset(25, 46),
              Offset(26, 26),
              Offset(33, 30),
              Offset(36, 16),
              Offset(44, 26),
              Offset(50, 12),
              Offset(56, 26),
              Offset(64, 16),
              Offset(67, 30),
              Offset(74, 26),
              Offset(75, 46),
            ], false)
            ..quadraticBezierTo(64, 32, 50, 32)
            ..quadraticBezierTo(36, 32, 25, 46)
            ..close(),
          hair,
        );
      case HairStyle.bob:
        canvas.drawPath(
          Path()
            ..moveTo(24, 46)
            ..quadraticBezierTo(23, 17, 50, 17)
            ..quadraticBezierTo(77, 17, 76, 46)
            ..lineTo(76, 38)
            ..quadraticBezierTo(50, 34, 24, 38)
            ..close(),
          hair,
        );
      case HairStyle.cap:
        canvas.drawRect(const Rect.fromLTWH(23, 36, 6, 12), hair);
        canvas.drawRect(const Rect.fromLTWH(71, 36, 6, 12), hair);
        canvas.drawPath(
          Path()
            ..moveTo(23, 40)
            ..quadraticBezierTo(23, 13, 50, 13)
            ..quadraticBezierTo(77, 13, 77, 40)
            ..close(),
          Paint()..color = _capColor,
        );
        canvas.drawPath(
          Path()
            ..moveTo(48, 37)
            ..quadraticBezierTo(78, 32, 92, 41)
            ..quadraticBezierTo(74, 45, 48, 42)
            ..close(),
          Paint()..color = _capShade,
        );
        canvas.drawCircle(const Offset(50, 14), 2.5, Paint()..color = _capShade);
      case HairStyle.bald:
        break;
    }
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  @override
  bool shouldRepaint(AvatarPainter oldDelegate) => oldDelegate.spec != spec;
}
