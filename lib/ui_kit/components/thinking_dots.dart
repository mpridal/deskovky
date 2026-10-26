import 'package:flutter/material.dart';

/// "Přemýšlím…" – three dots lighting up in turn (spec 5.7.1); all lit and
/// still when the system asks to reduce motion.
class ThinkingDots extends StatefulWidget {
  const ThinkingDots({super.key, required this.color, this.size = 6});

  final Color color;
  final double size;

  @override
  State<ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<ThinkingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _cycle = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _cycle.stop();
    } else if (!_cycle.isAnimating) {
      _cycle.repeat();
    }
  }

  @override
  void dispose() {
    _cycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _cycle,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.size * 0.25),
                child: Opacity(
                  opacity: _cycle.isAnimating ? ((_cycle.value * 3).floor() == i ? 1.0 : 0.3) : 1.0,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
