import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'war_card_art.dart';
import 'war_rules.dart';

/// The illustrated rule steps: turning the top card, the higher card
/// winning, and a war.
enum WarRuleStepKind { flip, higher, war }

/// One rule step: a little felt table with cards, and a caption.
class WarRuleStep extends StatelessWidget {
  const WarRuleStep({super.key, required this.kind, required this.text});

  final WarRuleStepKind kind;
  final String text;

  static const _h = 48.0;

  static Widget _card(Widget child) => SizedBox(width: _h * warCardAspect, height: _h, child: child);

  @override
  Widget build(BuildContext context) {
    final cards = switch (kind) {
      WarRuleStepKind.flip => [
        _card(const WarCardBack()),
        _card(WarCardFace(card: WarCard.of(9, 1))),
      ],
      WarRuleStepKind.higher => [
        _card(WarCardFace(card: WarCard.of(13, 0), glow: AppColors.players[0])),
        _card(WarCardFace(card: WarCard.of(8, 2))),
      ],
      WarRuleStepKind.war => [
        _card(WarCardFace(card: WarCard.of(10, 3))),
        _card(const WarCardBack()),
        _card(WarCardFace(card: WarCard.of(13, 1), glow: AppColors.players[0])),
      ],
    };
    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppColors.felt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.wood, width: 2),
            ),
            padding: const EdgeInsets.all(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Overlapping, so three cards fit as well as two.
                Center(
                  child: SizedBox(
                    width: _h * warCardAspect + (cards.length - 1) * _h * 0.45,
                    height: _h,
                    child: Stack(
                      children: [
                        for (final (i, card) in cards.indexed) Positioned(left: i * _h * 0.45, top: 0, child: card),
                      ],
                    ),
                  ),
                ),
                if (kind == WarRuleStepKind.flip)
                  Align(
                    alignment: const Alignment(0.95, 0.95),
                    child: Icon(Icons.touch_app, size: 24, color: AppColors.paper.withValues(alpha: 0.9)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
        ],
      ),
    );
  }
}
