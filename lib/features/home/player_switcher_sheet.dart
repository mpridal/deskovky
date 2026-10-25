import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/players/player_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

Future<void> showPlayerSwitcher(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: AppColors.paper,
  showDragHandle: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
  builder: (_) => const PlayerSwitcherSheet(),
);

/// Grid of all profiles; tapping one makes them the active player.
class PlayerSwitcherSheet extends ConsumerWidget {
  const PlayerSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider).value ?? const [];
    final activeId = ref.watch(activePlayerProvider).value?.id;

    Widget tile({required Widget picture, required String label, required VoidCallback onTap, bool active = false}) =>
        Semantics(
          button: true,
          selected: active,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 88,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  children: [
                    picture,
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in players)
              tile(
                picture: AvatarView(spec: p.avatar, size: 64, ringColor: p.id == activeId ? AppColors.gold : null),
                label: p.name,
                active: p.id == activeId,
                onTap: () async {
                  await ref.read(settingsRepositoryProvider).setActivePlayerId(p.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            if (players.length < PlayerRepository.maxProfiles)
              tile(
                picture: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.wood, width: 3),
                  ),
                  child: const Icon(Icons.add, color: AppColors.wood, size: 32),
                ),
                label: l10n.playersNew,
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/players/new');
                },
              ),
          ],
        ),
      ),
    );
  }
}
