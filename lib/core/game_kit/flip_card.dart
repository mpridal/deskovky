import 'dart:math';

import 'package:flutter/material.dart';

/// A card that turns over in 3D when [faceUp] changes (game kit, spec 8,
/// Pexeso). With reduced motion it simply shows the other side.
class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.faceUp,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 320),
  });

  final bool faceUp;
  final Widget front;
  final Widget back;
  final Duration duration;

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.faceUp ? 1 : 0,
  );

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.faceUp == widget.faceUp) return;
    final target = widget.faceUp ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _turn.value = target;
    } else {
      _turn.animateTo(target, curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _turn,
    builder: (context, _) {
      final angle = _turn.value * pi;
      final showFront = _turn.value >= 0.5;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(angle),
        child: showFront
            ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(pi), child: widget.front)
            : widget.back,
      );
    },
  );
}
