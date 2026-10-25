import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../games/game_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/tag_pill.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Home-grid card (spec 5.1): icon, title, players and a "Brzy" tag for games
/// that are not available yet. [module] null = an unnamed placeholder.
class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.module, required this.tint, this.onTap});

  final GameModule<Object?>? module;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final game = module;
    final playable = game != null && game.available;
    return Semantics(
      button: playable,
      child: PaperCard(
        onTap: playable ? onTap : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(tint.withValues(alpha: 0.25), AppColors.paper),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: game?.icon(context),
                    ),
                  ),
                  if (!playable)
                    // The badge may use the whole card width; TagPill scales
                    // down rather than being clipped.
                    Positioned(
                      top: 6,
                      left: 6,
                      right: 6,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: TagPill(label: l10n.comingSoon),
                      ),
                    ),
                ],
              ),
            ),
            if (game != null) ...[
              const SizedBox(height: 6),
              Text(
                gameText(l10n, game.titleKey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.h2(color: AppColors.ink).copyWith(fontSize: 18, height: 1.1),
              ),
              Text(
                game.minPlayers == game.maxPlayers
                    ? l10n.playersCount(game.maxPlayers)
                    : l10n.gamePlayersRange(game.minPlayers, game.maxPlayers),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption(color: AppColors.wood),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
