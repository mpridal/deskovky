import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/players/player_profile.dart';
import '../../core/points/levels.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'player_switcher_sheet.dart';

/// Top bar of the home screen (spec 5.1, mockup `.bar`): who is playing;
/// tap to switch. Without profiles it offers to create the first one.
/// The coin pill shows the balance and opens the player's shop (spec 5.6).
class ActivePlayerBar extends ConsumerWidget {
  const ActivePlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider);
    final active = ref.watch(activePlayerProvider).value;

    if (!players.hasValue) return const SizedBox(height: 56);
    final points = active == null ? null : ref.watch(pointsSummaryProvider)[active.id];
    if (active == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: PrimaryButton(
          label: l10n.homeCreatePlayer,
          icon: Icons.person_add,
          onPressed: () => context.push('/players/new'),
        ),
      );
    }
    final balance = points?.balance ?? 0;
    final level = levelFor(points?.earned ?? 0);
    return Row(
      children: [
        Expanded(child: _switcher(context, l10n, active, level)),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: l10n.homePointsBalance(balance),
          excludeSemantics: true,
          onTap: () => context.push('/players/${active.id}/shop'),
          child: InkWell(
            onTap: () => context.push('/players/${active.id}/shop'),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x40000000),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: Text('● $balance', style: AppTypography.button(color: AppColors.gold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switcher(BuildContext context, AppLocalizations l10n, PlayerProfile active, int level) {
    return Semantics(
      button: true,
      label: '${l10n.homeSwitchPlayer}: ${active.name}, ${l10n.levelLabel(level)}',
      excludeSemantics: true,
      onTap: () => showPlayerSwitcher(context),
      child: InkWell(
        onTap: () => showPlayerSwitcher(context),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AvatarView(spec: active.avatar, size: 44, ringColor: AppColors.paper),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Narrow phones with large text: both shrink rather than overflow.
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.homeHello,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(color: AppColors.woodLight),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.levelShort(level),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption(color: AppColors.gold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      active.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.h2(color: AppColors.paper).copyWith(fontSize: 20, height: 1.1),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.expand_more, color: AppColors.woodLight),
            ],
          ),
        ),
      ),
    );
  }
}
