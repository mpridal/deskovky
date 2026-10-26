import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Computer player avatar (spec 5.7.1): grey square head, antenna and LED
/// eyes in the slot [color]. Below 64 dp an "AI" badge marks it as a robot
/// even without colors.
class RobotAvatar extends StatefulWidget {
  const RobotAvatar({super.key, required this.color, required this.size, this.semanticLabel, this.blinking = false})
      : assert(size >= 28 && size <= 160);

  final Color color;
  final double size;
  final String? semanticLabel;

  /// The robot is thinking: its LED eyes blink (spec 5.7.1), unless the
  /// system asks to reduce motion.
  final bool blinking;

  @override
  State<RobotAvatar> createState() => _RobotAvatarState();
}

class _RobotAvatarState extends State<RobotAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(RobotAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final animate = widget.blinking && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_blink.isAnimating) {
      _blink.repeat(reverse: true);
    } else if (!animate && _blink.isAnimating) {
      _blink.stop();
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final color = widget.color;
    final semanticLabel = widget.semanticLabel;
    final badge = size * 0.38;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _blink,
                builder: (context, _) => CustomPaint(
                  painter: RobotPainter(color, eyeLevel: _blink.isAnimating ? 0.25 + 0.75 * _blink.value : 1),
                ),
              ),
            ),
            if (size < 64)
              Positioned(
                right: 0,
                bottom: 0,
                width: badge,
                height: badge,
                child: ExcludeSemantics(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: badge * 0.1),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(badge * 0.18),
                      child: FittedBox(
                        child: Text('AI', style: AppTypography.button(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paints the robot; [eyeLevel] 0–1 dims the LED eyes for blinking.
class RobotPainter extends CustomPainter {
  RobotPainter(this.color, {this.eyeLevel = 1});

  final Color color;
  final double eyeLevel;

  static const _metal = Color(0xFFC9D1D8);
  static const _metalDark = Color(0xFF7C8791);
  static const _outline = Color(0xFF5B6670);
  static const _body = Color(0xFF9AA4AD);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);
    canvas.clipPath(Path()..addOval(const Rect.fromLTWH(0, 0, 100, 100)));

    final slot = Paint()..color = color;
    final outline = Paint()
      ..color = _outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(const Offset(50, 50), 50, slot);
    // Antenna.
    canvas.drawLine(const Offset(50, 22), const Offset(50, 10), outline..strokeWidth = 3);
    canvas.drawCircle(const Offset(50, 9), 5, slot);
    canvas.drawCircle(
      const Offset(50, 9),
      5,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Body and neck.
    canvas.drawPath(
      Path()
        ..moveTo(22, 100)
        ..quadraticBezierTo(24, 82, 50, 82)
        ..quadraticBezierTo(76, 82, 78, 100)
        ..close(),
      Paint()..color = _body,
    );
    canvas.drawRect(const Rect.fromLTWH(42, 72, 16, 12), Paint()..color = _metalDark);
    // Head with ears.
    final head = RRect.fromLTRBR(22, 22, 78, 74, const Radius.circular(14));
    canvas.drawRRect(head, Paint()..color = _metal);
    canvas.drawRRect(head, outline..strokeWidth = 2.5);
    final ear = Paint()..color = _metalDark;
    canvas.drawRRect(RRect.fromLTRBR(17, 40, 23, 56, const Radius.circular(3)), ear);
    canvas.drawRRect(RRect.fromLTRBR(77, 40, 83, 56, const Radius.circular(3)), ear);
    // Display with LED eyes.
    canvas.drawRRect(RRect.fromLTRBR(30, 33, 70, 53, const Radius.circular(8)), Paint()..color = AppColors.ink);
    final glint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final eye = Paint()..color = Color.lerp(AppColors.ink, color, eyeLevel)!;
    for (final x in [41.0, 59.0]) {
      canvas.drawCircle(Offset(x, 43), 5, eye);
      if (eyeLevel > 0.6) canvas.drawCircle(Offset(x, 43), 2, glint);
    }
    // Mouth grille.
    canvas.drawRRect(RRect.fromLTRBR(36, 59, 64, 67, const Radius.circular(3)), Paint()..color = _metalDark);
    final grille = Paint()
      ..color = _metal
      ..strokeWidth = 1.5;
    for (final x in [43.0, 50.0, 57.0]) {
      canvas.drawLine(Offset(x, 59), Offset(x, 67), grille);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RobotPainter oldDelegate) => oldDelegate.color != color || oldDelegate.eyeLevel != eyeLevel;
}
