import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import 'memory_cards.dart';

/// Back of a card (spec 13.6): wood with the app logo – a felt disc with the
/// four player dots and a wooden ring holding two dice.
class MemoryCardBack extends StatelessWidget {
  const MemoryCardBack({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BackPainter(), child: const SizedBox.expand());
}

class _BackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;
    final card = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.14));
    canvas
      ..drawRRect(card.shift(Offset(0, s * 0.04)), Paint()..color = AppColors.walnut)
      ..drawRRect(
        card,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.woodLight, AppColors.wood],
          ).createShader(rect),
      );
    // Wood grain.
    final grain = Paint()
      ..color = AppColors.walnut.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012;
    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      final path = Path()
        ..moveTo(s * 0.06, y)
        ..quadraticBezierTo(size.width / 2, y + (i.isEven ? 1 : -1) * s * 0.05, size.width - s * 0.06, y);
      canvas.drawPath(path, grain);
    }
    canvas.drawRRect(
      card.deflate(s * 0.05),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025
        ..color = AppColors.walnut.withValues(alpha: 0.45),
    );

    // The logo.
    final c = size.center(Offset.zero);
    final r = s * 0.32;
    canvas.drawCircle(c, r, Paint()..color = AppColors.felt);
    for (final (i, a) in const [Alignment(-1, -1), Alignment(1, -1), Alignment(-1, 1), Alignment(1, 1)].indexed) {
      final order = const [1, 0, 2, 3][i];
      canvas.drawCircle(c + Offset(a.x, a.y) * r * 0.55, r * 0.13, Paint()..color = AppColors.players[order]);
    }
    canvas
      ..drawCircle(c, r * 0.46, Paint()..color = AppColors.wood)
      ..drawCircle(c, r * 0.36, Paint()..color = AppColors.woodLight);
    void die(Offset at, double angle, List<Offset> pips) {
      final d = r * 0.26;
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(angle)
        ..drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: d, height: d), Radius.circular(d * 0.2)),
          Paint()..color = AppColors.paper,
        );
      for (final p in pips) {
        canvas.drawCircle(p * d * 0.28, d * 0.09, Paint()..color = AppColors.ink);
      }
      canvas.restore();
    }

    die(c + Offset(-r * 0.12, -r * 0.08), -0.35, const [Offset(-1, -1), Offset(0, 0), Offset(1, 1)]);
    die(c + Offset(r * 0.14, r * 0.12), 0.3, const [Offset(-1, -1), Offset(1, -1), Offset(-1, 1), Offset(1, 1)]);
  }

  @override
  bool shouldRepaint(_BackPainter oldDelegate) => false;
}

/// Face of a card: the picture on paper, with a frame in the colour of the
/// player who turned it (or found it).
class MemoryCardFace extends StatelessWidget {
  const MemoryCardFace({super.key, required this.set, required this.motif, this.frame});

  final String set;
  final int motif;
  final Color? frame;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final s = constraints.biggest.shortestSide;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(s * 0.14),
          border: Border.all(color: frame ?? AppColors.paper2, width: frame == null ? s * 0.03 : s * 0.06),
          boxShadow: [BoxShadow(color: const Color(0x66000000), offset: Offset(0, s * 0.04))],
        ),
        child: Padding(
          padding: EdgeInsets.all(s * 0.13),
          child: Image.asset(
            memoryCardAsset(set, motif),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
            errorBuilder: (context, error, stack) => const SizedBox.shrink(),
          ),
        ),
      );
    },
  );
}
