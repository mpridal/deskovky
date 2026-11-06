import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Drawing of a match (design §8): a wooden stick with a red head, drawn in
/// code. Shared by the board, the rule steps and the icon.
abstract final class MatchArt {
  static const wood = Color(0xFFE9C793);
  static const woodDark = Color(0xFFC79B5E);
  static const head = Color(0xFFC8372D);
  static const headDark = Color(0xFF8E2219);
  static const charred = Color(0xFF2B211B);

  /// The stick's thickness for an upright match in a [size] box.
  static double thickness(Size size) => min(size.width * 0.3, size.height * 0.085);

  /// Paints an upright match filling the height of [box], centred across it.
  /// [glow] lights it in a player's colour (selected); [burn] 0 → 1 lights
  /// the head, flames and leaves it charred; [opacity] fades it.
  static void paint(Canvas canvas, Rect box, {Color? glow, double burn = 0, double opacity = 1}) {
    final w = thickness(box.size);
    final headW = w * 1.7, headH = w * 2.3;
    final cx = box.center.dx;
    final top = box.top + (burn > 0 ? headH * 0.9 : headH * 0.25);
    final stick = Rect.fromLTRB(cx - w / 2, top + headH * 0.5, cx + w / 2, box.bottom - w * 0.3);
    final headRect = Rect.fromCenter(center: Offset(cx, top + headH * 0.5), width: headW, height: headH);
    Color a(Color c) => c.withValues(alpha: c.a * opacity);

    if (glow != null) {
      final halo = RRect.fromRectAndRadius(
        Rect.fromLTRB(headRect.left - w, headRect.top - w, headRect.right + w, stick.bottom + w),
        Radius.circular(headW),
      );
      canvas.drawRRect(
        halo,
        Paint()
          ..color = a(glow.withValues(alpha: 0.55))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.9),
      );
    }

    final stickPaint = Paint()
      ..shader = LinearGradient(colors: [a(wood), a(woodDark)]).createShader(stick);
    canvas.drawRRect(RRect.fromRectAndRadius(stick, Radius.circular(w * 0.3)), stickPaint);
    if (burn > 0) {
      // The wood under the head chars as it burns.
      final charredLength = stick.height * 0.18 * burn;
      canvas.drawRect(
        Rect.fromLTWH(stick.left, stick.top, stick.width, charredLength),
        Paint()..color = a(charred.withValues(alpha: 0.85)),
      );
    }
    final headColor = Color.lerp(head, charred, (burn * 1.6).clamp(0, 1))!;
    canvas.drawOval(
      headRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [a(headColor), a(Color.lerp(headDark, charred, burn.clamp(0, 1))!)],
        ).createShader(headRect),
    );
    if (burn > 0 && burn < 1) flame(canvas, Offset(cx, headRect.top), headW * 1.3 * sin(pi * burn).clamp(0.25, 1), opacity);
  }

  /// A small flame standing on [base], [size] wide.
  static void flame(Canvas canvas, Offset base, double size, [double opacity = 1]) {
    Path drop(double scale) {
      final s = size * scale;
      return Path()
        ..moveTo(base.dx, base.dy - s * 1.9)
        ..quadraticBezierTo(base.dx + s * 0.75, base.dy - s * 0.7, base.dx + s * 0.4, base.dy + s * 0.15)
        ..quadraticBezierTo(base.dx, base.dy + s * 0.45, base.dx - s * 0.4, base.dy + s * 0.15)
        ..quadraticBezierTo(base.dx - s * 0.75, base.dy - s * 0.7, base.dx, base.dy - s * 1.9)
        ..close();
    }

    canvas
      ..drawPath(drop(1), Paint()..color = const Color(0xFFF08A24).withValues(alpha: 0.9 * opacity))
      ..drawPath(drop(0.6), Paint()..color = const Color(0xFFFFD45A).withValues(alpha: opacity));
  }

  /// The faint outline left where a match was taken in the last move.
  static void gap(Canvas canvas, Rect box, double opacity) {
    final w = thickness(box.size);
    final shape = RRect.fromRectAndRadius(
      Rect.fromLTRB(box.center.dx - w * 0.85, box.top + w * 0.6, box.center.dx + w * 0.85, box.bottom - w * 0.3),
      Radius.circular(w),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(1.5, w * 0.25)
        ..color = AppColors.paper.withValues(alpha: opacity),
    );
  }

  /// Paints [count] matches lying in a little heap around [centre]; the last
  /// [burnt] of them are charred. Each match is [length] long.
  static void heap(Canvas canvas, Offset centre, double length, int count, {int burnt = 0}) {
    for (var i = 0; i < count; i++) {
      // A fixed, scattered look: angle and offset from the index.
      final angle = pi / 2 + ((i * 47) % 31 - 15) / 15 * 0.5;
      final dx = ((i * 29) % 13 - 6) / 6 * length * 0.25;
      final dy = ((i * 17) % 9 - 4) / 4 * length * 0.12;
      canvas
        ..save()
        ..translate(centre.dx + dx, centre.dy + dy)
        ..rotate(angle);
      paint(canvas, Rect.fromCenter(center: Offset.zero, width: length * 0.3, height: length), burn: i >= count - burnt ? 1 : 0);
      canvas.restore();
    }
  }
}

/// One upright match (see [MatchArt.paint]).
class MatchPainter extends CustomPainter {
  const MatchPainter({this.glow, this.burn = 0, this.opacity = 1});

  final Color? glow;
  final double burn;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) =>
      MatchArt.paint(canvas, Offset.zero & size, glow: glow, burn: burn, opacity: opacity);

  @override
  bool shouldRepaint(MatchPainter old) => old.glow != glow || old.burn != burn || old.opacity != opacity;
}

/// The outline of a match taken in the last move.
class GapPainter extends CustomPainter {
  const GapPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) => MatchArt.gap(canvas, Offset.zero & size, opacity);

  @override
  bool shouldRepaint(GapPainter old) => old.opacity != opacity;
}

/// A player's pile of taken matches.
class HeapPainter extends CustomPainter {
  const HeapPainter({required this.count, this.burnt = 0});

  final int count;
  final int burnt;

  @override
  void paint(Canvas canvas, Size size) {
    final length = min(size.height * 0.95, size.width * 0.5);
    MatchArt.heap(canvas, size.center(Offset.zero), length, count, burnt: burnt);
  }

  @override
  bool shouldRepaint(HeapPainter old) => old.count != count || old.burnt != burnt;
}
