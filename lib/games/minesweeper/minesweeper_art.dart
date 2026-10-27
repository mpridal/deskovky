import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// What one square shows.
enum CellLook {
  /// Wooden tile.
  hidden,
  flag,
  question,

  /// Paper with a number (or empty for 0).
  open,

  /// A mine shown at the end of a lost game.
  mine,

  /// A mine somebody uncovered: soot on paper and a ring in their color.
  exploded,

  /// A flag on a square without a mine, shown at the end.
  wrongFlag,
}

/// Number colors from the tokens (spec 6.1, 13.7); the digit's weight and
/// the dots under it grow with the number, so they differ by shape too.
final numberColors = [
  AppColors.ink,
  AppColors.players[1], // 1 blue
  Color.lerp(AppColors.players[3], AppColors.ink, 0.3)!, // 2 green, darkened for paper
  AppColors.players[0], // 3 red
  AppColors.feltDark, // 4
  AppColors.wood, // 5
  AppColors.felt, // 6
  AppColors.walnut, // 7
  AppColors.ink, // 8
];

final _woodHigh = Color.lerp(AppColors.woodLight, AppColors.paper, 0.25)!;
final _woodLow = Color.lerp(AppColors.woodLight, AppColors.wood, 0.35)!;

/// Paints one square of the board in a [size]×[size] box.
class CellPainter extends CustomPainter {
  const CellPainter({required this.look, this.number = 0, this.tint, this.pressed = false});

  final CellLook look;
  final int number;

  /// Player color: who uncovered the square (Střídačka) or found the mine.
  final Color? tint;
  final bool pressed;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;
    switch (look) {
      case CellLook.hidden || CellLook.flag || CellLook.question || CellLook.wrongFlag:
        paintWoodTile(canvas, rect.deflate(s * 0.04), s);
        if (look == CellLook.flag || look == CellLook.wrongFlag) paintFlag(canvas, rect, s);
        if (look == CellLook.wrongFlag) _cross(canvas, rect, s);
        if (look == CellLook.question) _text(canvas, rect, '?', AppColors.walnut, FontWeight.w800, s * 0.6);
      case CellLook.open || CellLook.mine || CellLook.exploded:
        _paper(canvas, rect, s);
        if (look == CellLook.open && number > 0) _number(canvas, rect, s);
        if (look == CellLook.mine || look == CellLook.exploded) {
          if (look == CellLook.exploded) {
            canvas.drawCircle(rect.center, s * 0.44, Paint()..color = const Color(0x33000000));
            if (tint != null) {
              canvas.drawCircle(
                rect.center,
                s * 0.42,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = s * 0.07
                  ..color = tint!,
              );
            }
          }
          paintMine(canvas, rect.center, s * 0.3);
        }
    }
  }

  void _paper(Canvas canvas, Rect rect, double s) {
    canvas.drawRect(rect, Paint()..color = AppColors.paper);
    if (look == CellLook.open && tint != null) canvas.drawRect(rect, Paint()..color = tint!.withValues(alpha: 0.12));
    canvas.drawRect(
      rect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.paper2,
    );
  }

  void _number(Canvas canvas, Rect rect, double s) {
    final color = numberColors[number.clamp(0, 8)];
    final weight = FontWeight.values[(4 + number).clamp(4, 8)]; // w500 … w900
    _text(canvas, rect.translate(0, -s * 0.06), '$number', color, weight, s * (0.5 + number * 0.015));
    // Dots under the digit: one for 1, two for 2… (max four, then a bar).
    final dots = number.clamp(1, 4);
    final r = s * 0.035;
    final y = rect.bottom - s * 0.14;
    final paint = Paint()..color = color;
    if (number > 4) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(rect.center.dx, y), width: s * 0.4, height: r * 2),
          Radius.circular(r),
        ),
        paint,
      );
    } else {
      for (var i = 0; i < dots; i++) {
        canvas.drawCircle(Offset(rect.center.dx + (i - (dots - 1) / 2) * r * 3, y), r, paint);
      }
    }
  }

  void _cross(Canvas canvas, Rect rect, double s) {
    final paint = Paint()
      ..color = AppColors.players[0]
      ..strokeWidth = s * 0.08
      ..strokeCap = StrokeCap.round;
    final r = rect.deflate(s * 0.22);
    canvas
      ..drawLine(r.topLeft, r.bottomRight, paint)
      ..drawLine(r.topRight, r.bottomLeft, paint);
  }

  static void _text(Canvas canvas, Rect rect, String text, Color color, FontWeight weight, double fontSize) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: AppTypography.headingFamily,
          color: color,
          fontWeight: weight,
          fontSize: fontSize,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, rect.center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(CellPainter old) =>
      old.look != look || old.number != number || old.tint != tint || old.pressed != pressed;
}

/// A wooden tile with grain and a bevel (spec 6.1: wood).
void paintWoodTile(Canvas canvas, Rect rect, double s) {
  final r = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.14));
  canvas
    ..drawRRect(r.shift(Offset(0, s * 0.04)), Paint()..color = AppColors.wood)
    ..drawRRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_woodHigh, AppColors.woodLight, _woodLow],
        ).createShader(rect),
    );
  final grain = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = max(1, s * 0.02)
    ..color = const Color(0x22000000);
  for (var i = 1; i <= 2; i++) {
    final y = rect.top + rect.height * i / 3;
    canvas.drawPath(
      Path()
        ..moveTo(rect.left + s * 0.15, y)
        ..quadraticBezierTo(rect.center.dx, y - s * 0.08 * (i.isOdd ? 1 : -1), rect.right - s * 0.15, y),
      grain,
    );
  }
}

/// A red flag on a little pole.
void paintFlag(Canvas canvas, Rect rect, double s) {
  final pole = Offset(rect.left + s * 0.4, rect.top + s * 0.22);
  canvas
    ..drawLine(
      pole,
      pole + Offset(0, s * 0.56),
      Paint()
        ..color = AppColors.ink
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round,
    )
    ..drawLine(
      Offset(rect.left + s * 0.28, rect.top + s * 0.78),
      Offset(rect.left + s * 0.6, rect.top + s * 0.78),
      Paint()
        ..color = AppColors.ink
        ..strokeWidth = s * 0.07
        ..strokeCap = StrokeCap.round,
    )
    ..drawPath(
      Path()
        ..moveTo(pole.dx, pole.dy)
        ..lineTo(pole.dx + s * 0.34, pole.dy + s * 0.13)
        ..lineTo(pole.dx, pole.dy + s * 0.27)
        ..close(),
      Paint()..color = AppColors.players[0],
    );
}

/// A friendly cartoon mine (spec 13.7: not scary): a round dark ball with
/// short studs, a shine and a little fuse.
void paintMine(Canvas canvas, Offset centre, double radius) {
  final ink = Paint()..color = AppColors.walnut;
  final studs = Paint()
    ..color = AppColors.walnut
    ..strokeWidth = radius * 0.28
    ..strokeCap = StrokeCap.round;
  for (var i = 0; i < 8; i++) {
    final a = i * pi / 4;
    canvas.drawLine(centre, centre + Offset(cos(a), sin(a)) * radius * 1.3, studs);
  }
  canvas
    ..drawCircle(centre, radius, ink)
    ..drawCircle(
      centre - Offset(radius * 0.35, radius * 0.35),
      radius * 0.28,
      Paint()..color = const Color(0xCCFFFFFF),
    );
}

/// A smoke cloud "puf" (spec 13.7: the explosion is a puff of smoke), [t]
/// from 0 to 1: the cloud swells and fades.
void paintPuff(Canvas canvas, Offset centre, double s, double t) {
  final grow = Curves.easeOut.transform(t.clamp(0, 1));
  final alpha = (1 - Curves.easeIn.transform(t.clamp(0, 1))) * 0.9;
  final paint = Paint()..color = Color.lerp(AppColors.paper2, AppColors.walnut, 0.25)!.withValues(alpha: alpha);
  final light = Paint()..color = AppColors.paper.withValues(alpha: alpha);
  for (var i = 0; i < 7; i++) {
    final a = i * 2 * pi / 7 + 0.4;
    final d = s * (0.12 + 0.28 * grow);
    final r = s * (0.14 + 0.16 * grow) * (i.isEven ? 1 : 0.8);
    canvas.drawCircle(centre + Offset(cos(a), sin(a)) * d, r, paint);
  }
  canvas.drawCircle(centre, s * (0.16 + 0.18 * grow), light);
}
