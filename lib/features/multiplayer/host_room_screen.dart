import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/multiplayer_providers.dart';
import '../../app/providers.dart';
import '../../core/multiplayer/host_room.dart';
import '../../core/multiplayer/protocol.dart';
import '../../core/players/player_profile.dart';
import '../../games/game_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'room_widgets.dart';

/// The host's open room (spec 14.2 step 2, 14.6): QR code and room code for
/// the others, the places, the settings and "Spustit hru" once all are ready.
class HostRoomScreen extends ConsumerWidget {
  const HostRoomScreen({super.key});

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    await ref.read(networkRoomsProvider).leave();
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final rooms = ref.watch(networkRoomsProvider);
    final room = rooms.host;
    final ticket = rooms.ticket;
    if (room == null || ticket == null) {
      return RoomPage(title: l10n.roomTitle, onBack: () => context.pop(), body: const SizedBox.shrink());
    }
    final profiles = ref.watch(playersProvider).value ?? const <PlayerProfile>[];
    return ListenableBuilder(
      listenable: room,
      builder: (context, _) {
        final lobby = room.lobbyState;
        return RoomPage(
          title: '${l10n.roomTitle} · ${gameText(l10n, room.module.titleKey)}',
          onBack: () => _leave(context, ref),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 12),
              PaperCard(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    QrImageView(
                      data: ticket.toUri().toString(),
                      size: 140,
                      backgroundColor: AppColors.paper,
                      semanticsLabel: l10n.roomCode,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.roomCode, style: AppTypography.caption(color: AppColors.wood)),
                        Text(
                          room.roomCode,
                          key: const ValueKey('roomCode'),
                          style: AppTypography.h1(color: AppColors.ink).copyWith(fontSize: 40, letterSpacing: 6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(l10n.roomJoinHint, style: AppTypography.caption(color: AppColors.paper)),
              ),
              roomLabel(l10n.navPlayers),
              for (final (i, slot) in room.slots.indexed)
                RoomSlotTile(
                  seat: i,
                  slot: lobby.slots[i],
                  connected: slot is! RemoteSlot || slot.connected,
                  onTap: room.started ? null : () => _editSlot(context, room, i, profiles),
                ),
              roomLabel(l10n.lobbySettings),
              RoomSettingsSummary(
                module: room.module,
                difficulty: room.difficulty,
                options: room.options,
                hasRobots: room.slots.any((s) => s is RobotSlot),
              ),
              if (!room.canStart && !room.started)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(l10n.roomWaitReady, style: AppTypography.caption(color: AppColors.woodLight)),
                ),
              const SizedBox(height: 16),
            ],
          ),
          bottom: SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              key: const ValueKey('roomStart'),
              label: l10n.roomStart,
              icon: Icons.play_arrow,
              onPressed: room.canStart
                  ? () {
                      room.start();
                      context.pushReplacement('/play/${room.module.id}/net');
                    }
                  : null,
            ),
          ),
        );
      },
    );
  }

  /// A free or robot place gets a robot, a person of this device or stays
  /// free; a remote person can be removed.
  Future<void> _editSlot(BuildContext context, HostRoom room, int index, List<PlayerProfile> profiles) async {
    final l10n = AppLocalizations.of(context);
    final slot = room.slots[index];
    final seated = {
      for (final s in room.slots)
        if (s is LocalSlot) s.profileId,
    };
    final choice = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: AppColors.paper,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        Widget tile(Widget leading, String label, Object value) => ListTile(
          leading: leading,
          title: Text(label, style: AppTypography.body(color: AppColors.ink)),
          onTap: () => Navigator.of(context).pop(value),
        );
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (slot is RemoteSlot)
                  tile(const Icon(Icons.person_remove, color: AppColors.ink), l10n.roomRemove, 'kick')
                else ...[
                  if (slot is! RobotSlot)
                    tile(RobotAvatar(color: AppColors.players[index % 4], size: 36), l10n.slotMakeRobot, 'robot'),
                  if (profiles.any((p) => !seated.contains(p.id)))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.slotAddLocal, style: AppTypography.caption(color: AppColors.wood)),
                      ),
                    ),
                  for (final p in profiles)
                    if (!seated.contains(p.id)) tile(AvatarView(spec: p.avatar, size: 36), p.name, p),
                  if (slot is! OpenSlot) tile(const Icon(Icons.person_add_alt, color: AppColors.ink), l10n.slotLeaveOpen, 'open'),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    switch (choice) {
      case 'kick' when slot is RemoteSlot:
        room.kick(slot.clientId);
      case 'robot':
        room.setSlot(index, const RobotSlot());
      case 'open':
        room.setSlot(index, const OpenSlot());
      case PlayerProfile p:
        room.setSlot(index, LocalSlot(profileId: p.id, card: ProfileCard(name: p.name, avatar: p.avatar.toJson())));
    }
  }
}
