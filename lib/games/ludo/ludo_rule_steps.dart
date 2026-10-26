import 'package:flutter/material.dart';

import '../../core/game_kit/dice.dart';
import '../../core/game_kit/piece_token.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

enum LudoRuleStepKind { enter, capture, home }

/// One illustrated rule step (spec 13.4): a little scene of fields, pieces
/// and the die drawn with the game kit, and a caption.
class LudoRuleStep extends StatelessWidget {
  const LudoRuleStep({super.key, required this.kind, required this.text});

  final LudoRuleStepKind kind;
  final String text;

  static const _field = 26.0;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 120,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 112,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.felt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.wood, width: 2),
          ),
          child: switch (kind) {
            LudoRuleStepKind.enter => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Dice(value: 6, rolling: false, label: '6', size: 30),
                const Icon(Icons.arrow_forward, color: AppColors.paper, size: 18),
                _fieldWith(AppColors.players[0], const PieceToken(seat: 0, size: 20)),
              ],
            ),
            LudoRuleStepKind.capture => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const PieceToken(seat: 0, size: 20),
                const Icon(Icons.arrow_forward, color: AppColors.paper, size: 18),
                _fieldWith(AppColors.woodLight, const PieceToken(seat: 1, size: 20)),
                const Icon(Icons.undo, color: AppColors.gold, size: 20),
              ],
            ),
            LudoRuleStepKind.home => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Dice(value: 2, rolling: false, label: '2', size: 26),
                for (var k = 0; k < 3; k++)
                  _fieldWith(
                    Color.lerp(AppColors.woodLight, AppColors.players[0], 0.6)!,
                    k == 1 ? const PieceToken(seat: 0, size: 18) : null,
                    size: 22,
                  ),
              ],
            ),
          },
        ),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.ink)),
      ],
    ),
  );

  static Widget _fieldWith(Color color, Widget? piece, {double size = _field}) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.wood, width: 2),
    ),
    child: piece,
  );
}
