import 'package:flutter/material.dart';

import '../../ui_kit/components/thinking_dots.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'seat_identity.dart';

/// A player in the HUD strip (mockup `.pchip`): avatar, name, score; the
/// player to move sits on paper and gently pulses, a thinking robot shows
/// animated dots.
class PlayerChip extends StatefulWidget {
  const PlayerChip({
    super.key,
    required this.identity,
    required this.score,
    required this.active,
    required this.thinking,
    this.compact = false,
  });

  final SeatIdentity identity;
  final int score;
  final bool active;
  final bool thinking;

  /// Avatar and score only (phones); the bubble says whose turn it is.
  final bool compact;

  @override
  State<PlayerChip> createState() => _PlayerChipState();
}

class _PlayerChipState extends State<PlayerChip> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PlayerChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final animate = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!animate && _pulse.isAnimating) {
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
  Widget build(BuildContext context) {
    final id = widget.identity;
    final fg = widget.active ? AppColors.ink : AppColors.paper;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.04).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: widget.active ? AppColors.paper : const Color(0x40000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: id.color, width: 3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            id.avatar(widget.compact ? 32 : 40, thinking: widget.thinking),
            const SizedBox(width: 8),
            if (!widget.compact) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  id.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button(color: fg).copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 6),
              if (widget.thinking) ...[ThinkingDots(color: fg), const SizedBox(width: 6)],
            ],
            Text('${widget.score}', style: AppTypography.h2(color: fg).copyWith(fontSize: 20, height: 1)),
          ],
        ),
      ),
    );
  }
}
