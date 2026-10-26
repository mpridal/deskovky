import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// A game piece in the colour of player 1–4 (game kit, spec 8), with a small
/// white shape per seat so colour-blind players can tell pieces apart:
/// circle, square, triangle, diamond. [pulse] makes a movable piece throb.
class PieceToken extends StatefulWidget {
  const PieceToken({super.key, required this.seat, this.size = 36, this.pulse = false, this.showMark = true});

  final int seat;
  final double size;
  final bool pulse;
  final bool showMark;

  Color get color => AppColors.players[seat % AppColors.players.length];

  @override
  State<PieceToken> createState() => _PieceTokenState();
}

class _PieceTokenState extends State<PieceToken> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PieceToken oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.pulse && !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 1.0, end: 1.12).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
    child: SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(
        painter: _TokenPainter(widget.color),
        child: widget.showMark
            ? Center(
                child: SizedBox.square(
                  key: ValueKey('mark${widget.seat}'),
                  dimension: widget.size * 0.34,
                  child: CustomPaint(painter: _MarkPainter(widget.seat % 4)),
                ),
              )
            : null,
      ),
    ),
  );
}

class _TokenPainter extends CustomPainter {
  _TokenPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide / 2;
    canvas
      ..drawCircle(c + Offset(0, r * 0.08), r * 0.96, Paint()..color = const Color(0x55000000))
      ..drawCircle(c, r * 0.92, Paint()..color = color)
      ..drawCircle(c, r * 0.92, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1
        ..color = Color.lerp(color, AppColors.ink, 0.35)!)
      ..drawCircle(c - Offset(r * 0.3, r * 0.3), r * 0.18, Paint()..color = const Color(0x66FFFFFF));
  }

  @override
  bool shouldRepaint(_TokenPainter old) => old.color != color;
}

class _MarkPainter extends CustomPainter {
  _MarkPainter(this.shape);

  final int shape;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xE6FFFFFF);
    final w = size.width, h = size.height;
    switch (shape) {
      case 0:
        canvas.drawCircle(size.center(Offset.zero), w / 2, paint);
      case 1:
        canvas.drawRect(Offset.zero & size, paint);
      case 2:
        canvas.drawPath(Path()..moveTo(w / 2, 0)..lineTo(w, h)..lineTo(0, h)..close(), paint);
      default:
        canvas.drawPath(Path()..moveTo(w / 2, 0)..lineTo(w, h / 2)..lineTo(w / 2, h)..lineTo(0, h / 2)..close(), paint);
    }
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.shape != shape;
}

/// Moves [child] field by field along [path] (top-left positions inside a
/// [Stack]) with a little hop per field (spec 13.8 "hopsá"); jumps straight
/// to the end with reduced motion. [onDone] runs when it has arrived.
class HoppingPiece extends StatefulWidget {
  const HoppingPiece({
    super.key,
    required this.path,
    required this.child,
    this.perStep = const Duration(milliseconds: 220),
    this.hopHeight = 14,
    this.onDone,
  }) : assert(path.length > 0);

  final List<Offset> path;
  final Widget child;
  final Duration perStep;
  final double hopHeight;
  final VoidCallback? onDone;

  @override
  State<HoppingPiece> createState() => _HoppingPieceState();
}

class _HoppingPieceState extends State<HoppingPiece> with SingleTickerProviderStateMixin {
  late final AnimationController _move = AnimationController(vsync: this);

  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _start();
  }

  @override
  void didUpdateWidget(HoppingPiece oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The same piece moving again (e.g. keyed by its id) hops its new path.
    if (!listEquals(oldWidget.path, widget.path)) _start();
  }

  void _start() {
    final steps = widget.path.length - 1;
    if (steps == 0 || MediaQuery.disableAnimationsOf(context)) {
      _move.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone?.call());
      return;
    }
    _move.duration = widget.perStep * steps;
    _move.forward(from: 0).whenCompleteOrCancel(() {
      if (mounted && _move.isCompleted) widget.onDone?.call();
    });
  }

  @override
  void dispose() {
    _move.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _move,
    child: widget.child,
    builder: (context, child) {
      final path = widget.path, steps = path.length - 1;
      final at = _move.value * steps;
      final i = min(at.floor(), max(0, steps - 1));
      final t = steps == 0 ? 0.0 : at - i;
      final from = path[i], to = path[min(i + 1, steps)];
      final position = Offset.lerp(from, to, t)! - Offset(0, sin(pi * t) * widget.hopHeight);
      return Positioned(left: position.dx, top: position.dy, child: child!);
    },
  );
}
