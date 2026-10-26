import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// A die (game kit, spec 8, Člověče). The game state decides the [value]; the
/// widget only shows it, shakes while [rolling] (not with reduced motion) and
/// reports taps. [label] is read out with the value, e.g. "Kostka: 4".
class Dice extends StatefulWidget {
  const Dice({super.key, required this.value, required this.rolling, required this.label, this.onTap, this.size = 64});

  final int? value;
  final bool rolling;
  final String label;
  final VoidCallback? onTap;
  final double size;

  @override
  State<Dice> createState() => _DiceState();
}

class _DiceState extends State<Dice> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
  var _face = 1;

  @override
  void initState() {
    super.initState();
    _shake.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) setState(() => _face = _face % 6 + 1);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Dice oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.rolling && !MediaQuery.disableAnimationsOf(context)) {
      if (!_shake.isAnimating) _shake.repeat(reverse: true);
    } else {
      _shake
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.rolling && _shake.isAnimating ? _face : widget.value;
    return Semantics(
      label: widget.value == null || widget.rolling ? widget.label : '${widget.label}: ${widget.value}',
      button: widget.onTap != null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.rotate(angle: (_shake.value - 0.5) * 0.4 * (_shake.isAnimating ? 1 : 0), child: child),
          child: SizedBox.square(dimension: widget.size, child: CustomPaint(painter: _DicePainter(shown))),
        ),
      ),
    );
  }
}

class _DicePainter extends CustomPainter {
  _DicePainter(this.value);

  final int? value;

  static const _pips = {
    1: [(0, 0)],
    2: [(-1, -1), (1, 1)],
    3: [(-1, -1), (0, 0), (1, 1)],
    4: [(-1, -1), (1, -1), (-1, 1), (1, 1)],
    5: [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
    6: [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final body = RRect.fromRectAndRadius(Offset.zero & Size.square(s), Radius.circular(s * 0.2));
    canvas
      ..drawRRect(body.shift(Offset(0, s * 0.05)), Paint()..color = const Color(0x55000000))
      ..drawRRect(body, Paint()..color = AppColors.paper)
      ..drawRRect(body, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.04
        ..color = AppColors.wood);
    final c = Offset(s / 2, s / 2), step = s * 0.26, r = s * 0.085;
    for (final (x, y) in _pips[value] ?? const <(int, int)>[]) {
      canvas.drawCircle(c + Offset(x * step, y * step), r, Paint()..color = AppColors.ink);
    }
    if (value == null) {
      canvas.drawCircle(c, max(r, 2), Paint()..color = AppColors.paper2);
    }
  }

  @override
  bool shouldRepaint(_DicePainter old) => old.value != value;
}
