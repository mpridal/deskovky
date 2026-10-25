import 'package:flutter/material.dart';

import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/tag_pill.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// One profile in the Players list: tap to play as them, edit, delete.
class PlayerTile extends StatelessWidget {
  const PlayerTile({
    super.key,
    required this.player,
    required this.active,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final PlayerProfile player;
  final bool active;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seat = player.favoriteSeat;
    return PaperCard(
      key: const ValueKey('playerTile'),
      onTap: onSelect,
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          AvatarView(
            spec: player.avatar,
            size: 56,
            ringColor: seat == null ? null : AppColors.players[seat],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h2(color: AppColors.ink),
                ),
                if (active)
                  TagPill(label: l10n.playerActiveTag, background: AppColors.gold, foreground: AppColors.ink),
              ],
            ),
          ),
          RoundIconButton(icon: Icons.edit, tooltip: l10n.playerEdit(player.name), onPressed: onEdit, size: 44),
          RoundIconButton(
            icon: Icons.delete_outline,
            tooltip: l10n.playerDelete(player.name),
            onPressed: onDelete,
            size: 44,
          ),
        ],
      ),
    );
  }
}
