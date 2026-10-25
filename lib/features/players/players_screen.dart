import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/players/player_profile.dart';
import '../../core/players/player_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'player_tile.dart';

/// Players tab (spec 5.2): profiles on this device, choose who plays,
/// create, edit and delete.
class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, PlayerProfile player) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteTitle(player.name),
      message: l10n.deleteMessage,
      confirmLabel: l10n.deleteConfirm,
      cancelLabel: l10n.cancel,
    );
    if (confirmed) await ref.read(playerRepositoryProvider).delete(player.id);
  }

  Future<void> _select(BuildContext context, WidgetRef ref, PlayerProfile player) async {
    final message = AppLocalizations.of(context).playersNowPlaying(player.name);
    await ref.read(settingsRepositoryProvider).setActivePlayerId(player.id);
    if (context.mounted) showAppToast(context, message);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider).value ?? const [];
    final activeId = ref.watch(activePlayerProvider).value?.id;
    final full = players.length >= PlayerRepository.maxProfiles;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.navPlayers, style: AppTypography.h1(color: AppColors.paper)),
          const SizedBox(height: 16),
          if (players.isEmpty) ...[
            const Center(child: _EmptyCircle()),
            const SizedBox(height: 12),
            Text(l10n.playersEmpty, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.paper)),
            const SizedBox(height: 16),
          ],
          for (final player in players)
            Padding(
              key: ValueKey('player${player.id}'),
              padding: const EdgeInsets.only(bottom: 12),
              child: PlayerTile(
                player: player,
                active: player.id == activeId,
                onSelect: () => _select(context, ref, player),
                onEdit: () => context.push('/players/${player.id}/edit'),
                onDelete: () => _delete(context, ref, player),
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: PrimaryButton(
              label: l10n.playersNew,
              icon: Icons.person_add,
              onPressed: full ? null : () => context.push('/players/new'),
            ),
          ),
          if (full) ...[
            const SizedBox(height: 8),
            Text(l10n.playersLimit, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.woodLight)),
          ],
        ],
      ),
    );
  }
}

class _EmptyCircle extends StatelessWidget {
  const _EmptyCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.woodLight, width: 3),
      ),
      child: const Icon(Icons.add, size: 48, color: AppColors.woodLight),
    );
  }
}
