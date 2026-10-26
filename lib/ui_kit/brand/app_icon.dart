import 'dart:math';

import 'package:flutter/widgets.dart';

import '../tokens/app_colors.dart';

/// The launcher icon (chosen by Miloš, 2026-10-26): a family of four around a
/// game table with two dice, on a green felt circle. Drawn in a 128×128
/// space; `tool/app_icon/generate_app_icon_test.dart` renders the Android
/// PNGs from it.
class AppIconPainter extends CustomPainter {
  const AppIconPainter();

  static const _design = 128.0;
  static const _skin = Color(0xFFF4EADB);
  static const _pip = AppColors.ink;

  /// Player colours: two adults (big) and two children (small).
  static final _players = [
    (const Offset(38, 38), 10.0, AppColors.players[1]),
    (const Offset(90, 38), 10.0, AppColors.players[0]),
    (const Offset(90, 90), 7.5, AppColors.players[3]),
    (const Offset(38, 90), 7.5, AppColors.players[2]),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = min(size.width, size.height) / _design;
    canvas
      ..save()
      ..translate((size.width - _design * scale) / 2, (size.height - _design * scale) / 2)
      ..scale(scale);
    const centre = Offset(64, 64);
    canvas.drawCircle(centre, 64, Paint()..color = AppColors.felt);
    canvas.drawCircle(centre, 24, Paint()..color = AppColors.wood);
    canvas.drawCircle(centre, 19, Paint()..color = AppColors.woodLight);
    _die(canvas, const Offset(57, 60), -14, const [Offset(-3.5, -3.5), Offset.zero, Offset(3.5, 3.5)]);
    _die(canvas, const Offset(70, 68), 18, const [Offset(-3.5, -3.5), Offset(3.5, -3.5), Offset(-3.5, 3.5), Offset(3.5, 3.5)]);
    for (final (at, radius, colour) in _players) {
      canvas.drawCircle(at, radius, Paint()..color = colour);
    }
    canvas.restore();
  }

  void _die(Canvas canvas, Offset centre, double degrees, List<Offset> pips) {
    canvas
      ..save()
      ..translate(centre.dx, centre.dy)
      ..rotate(degrees * pi / 180);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 14, height: 14), const Radius.circular(3)),
      Paint()..color = _skin,
    );
    for (final p in pips) {
      canvas.drawCircle(p, 1.6, Paint()..color = _pip);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(AppIconPainter oldDelegate) => false;
}
