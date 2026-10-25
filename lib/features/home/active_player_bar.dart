import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'player_switcher_sheet.dart';

/// Top bar of the home screen (spec 5.1, mockup `.bar`): who is playing;
/// tap to switch. Without profiles it offers to create the first one.
/// Points and the sound button join this row in milestones 5 and 7.
class ActivePlayerBar extends ConsumerWidget {
  const ActivePlayerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider);
    final active = ref.watch(activePlayerProvider).value;

    if (!players.hasValue) return const SizedBox(height: 56);
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
    return Semantics(
      button: true,
      label: '${l10n.homeSwitchPlayer}: ${active.name}',
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
                    Text(l10n.homeHello, maxLines: 1, style: AppTypography.caption(color: AppColors.woodLight)),
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
