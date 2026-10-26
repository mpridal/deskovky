import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/seeded_random.dart';
import '../../ui_kit/tokens/app_colors.dart';

/// Paper confetti in the winner's colour (plus gold) falling for 1.5 s
/// (spec 5.9). Callers leave it out when the system asks to reduce motion.
class Confetti extends StatefulWidget {
  const Confetti({super.key, required this.color});

  final Color color;

  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController _fall = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
    ..forward();

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _fall,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(progress: _fall.value, color: widget.color),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final random = SeededRandom(0);
    final fade = 1 - Curves.easeIn.transform(progress);
    for (var i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -random.nextDouble() * size.height * 0.3;
      final speed = 0.6 + random.nextDouble() * 0.6;
      final y = startY + progress * speed * size.height * 1.2;
      final angle = random.nextDouble() * pi + progress * 6 * (i.isEven ? 1 : -1);
      final paint = Paint()..color = (i % 3 == 0 ? AppColors.gold : color).withValues(alpha: fade);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(angle)
        ..drawRect(const Rect.fromLTWH(-4, -2, 8, 4), paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
