import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import 'tag_pill.dart';

/// One seat at the table: stripe in the seat's player color, avatar, name
/// and a tag such as "Člověk" or "🤖 Robot".
class PlayerSlot extends StatelessWidget {
  const PlayerSlot({
    super.key,
    required this.seat,
    required this.avatar,
    required this.name,
    required this.tag,
    this.trailing,
  }) : assert(seat >= 0 && seat < 4);

  final int seat;
  final Widget avatar;
  final String name;
  final String tag;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: AppColors.paper,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ColoredBox(key: const Key('playerSlotStripe'), color: AppColors.players[seat], child: const SizedBox(width: 8)),
              Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 8), child: Center(child: avatar)),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.button(color: AppColors.ink),
                  ),
                ),
              ),
              Center(child: TagPill(label: tag, background: AppColors.paper2, foreground: AppColors.ink)),
              ?trailing,
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
