import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/game/game_config.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Gold "Pokračovat" bar (spec 5.1, mockup `.continue`): resumes the game in
/// progress, otherwise starts the last played game with the same setup.
class ContinueBar extends ConsumerWidget {
  const ContinueBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final saved = ref.watch(lastSavedProvider).value;
    final config = saved?.config ?? ref.watch(lastPlayedProvider).value;
    final module = config == null ? null : moduleById(config.gameId);
    // Without anybody to play there is nothing to continue (spec 5.7).
    final hasPlayer = ref.watch(activePlayerProvider).value != null;
    if (config == null || module == null || !hasPlayer) return const SizedBox.shrink();

    final subtitle = saved != null
        ? l10n.continueSaved
        : l10n.continueSummary(_seats(l10n, config), difficultyLabel(l10n, config.difficulty));
    final Object extra = saved ?? config;

    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: () => context.push('/play/${config.gameId}', extra: extra),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFC98A1A)]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0xFF9B6A12), offset: Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.continueTitle(gameText(l10n, module.titleKey)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.button(color: AppColors.ink),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(color: AppColors.ink.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  l10n.continuePlay,
                  style: AppTypography.button(color: AppColors.paper).copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _seats(AppLocalizations l10n, GameConfig c) => c.robots == 0
      ? l10n.playersCount(c.seats.length)
      : l10n.seatSummary(l10n.playersCount(c.seats.length), c.humans, c.robots);
}
