import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/avatar/avatar_spec.dart';
import 'accessories/accessory_art.dart';
import 'avatar_painter.dart';

/// A human avatar drawn from [spec] at [size] dp (28–160), optionally with a
/// ring in the player's color.
class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.spec, required this.size, this.ringColor, this.semanticLabel})
      : assert(size >= 28 && size <= 160);

  final AvatarSpec spec;
  final double size;
  final Color? ringColor;
  final String? semanticLabel;

  /// Animated upgrades move only from this size up (spec 5.6).
  static const animationSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final animate = size >= animationSize &&
        !MediaQuery.disableAnimationsOf(context) &&
        spec.equipped.values.any((e) => accessoryArts[e.id]?.animated ?? false);
    Widget avatar = animate
        ? _AnimatedAccessories(spec: spec, size: size)
        : CustomPaint(size: Size.square(size), painter: AvatarPainter(spec, logicalSize: size));
    if (ringColor != null) {
      avatar = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringColor!, width: max(2, size * 0.06)),
        ),
        child: avatar,
      );
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      child: SizedBox.square(dimension: size, child: avatar),
    );
  }
}

/// [AvatarView] that bounces (200 ms) whenever [spec] changes, unless the
/// system asks to reduce motion.
class AnimatedAvatarView extends StatefulWidget {
  const AnimatedAvatarView({super.key, required this.spec, required this.size, this.ringColor, this.semanticLabel});

  final AvatarSpec spec;
  final double size;
  final Color? ringColor;
  final String? semanticLabel;

  @override
  State<AnimatedAvatarView> createState() => _AnimatedAvatarViewState();
}

class _AnimatedAvatarViewState extends State<AnimatedAvatarView> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void didUpdateWidget(AnimatedAvatarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spec != widget.spec && !MediaQuery.disableAnimationsOf(context)) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        final t = Curves.easeOut.transform(_bounce.value);
        final scale = _bounce.isAnimating ? 1 + 0.08 * sin(pi * t) : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: AvatarView(
        spec: widget.spec,
        size: widget.size,
        ringColor: widget.ringColor,
        semanticLabel: widget.semanticLabel,
      ),
    );
  }
}

/// Repaints the avatar for upgrades that move (glowing halo, sparks, …).
class _AnimatedAccessories extends StatefulWidget {
  const _AnimatedAccessories({required this.spec, required this.size});

  final AvatarSpec spec;
  final double size;

  @override
  State<_AnimatedAccessories> createState() => _AnimatedAccessoriesState();
}

class _AnimatedAccessoriesState extends State<_AnimatedAccessories> with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(vsync: this, duration: const Duration(seconds: 2))
    ..repeat();

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _cycle,
    builder: (context, _) => CustomPaint(
      size: Size.square(widget.size),
      painter: AvatarPainter(widget.spec, logicalSize: widget.size, t: _cycle.value),
    ),
  );
}
