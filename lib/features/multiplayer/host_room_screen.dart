import 'package:flutter/material.dart';

import '../../ui_kit/components/app_toast.dart';
import '../../app/family_providers.dart';

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
        if (room.startWhenInvitedJoin && room.canStart && !room.waitingForInvited) {
          // Everyone invited from the setup is here and ready: off we go.
          room.startWhenInvitedJoin = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted || !room.canStart) return;
            room.start();
            context.pushReplacement('/play/${room.module.id}/net');
          });
        }
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
                  onTap: room.started ? null : () => _editSlot(context, ref, room, i, profiles),
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
  Future<void> _editSlot(
    BuildContext context,
    WidgetRef ref,
    HostRoom room,
    int index,
    List<PlayerProfile> profiles,
  ) async {
    final l10n = AppLocalizations.of(context);
    final slot = room.slots[index];
    final seated = {
      for (final s in room.slots)
        if (s is LocalSlot) s.profileId,
    };
    // Family people may play on their own device: invite them (spec 5.4).
    final family = ref.read(familyControllerProvider);
    final seatedUids = {
      for (final s in room.slots)
        if (s case LocalSlot(card: ProfileCard(:final uid?)) || RemoteSlot(card: ProfileCard(:final uid?))) uid,
    };
    // Who plays now on another device first, the others after (their
    // invitation goes to every family device on the Wi-Fi).
    final elsewhere = family.inFamily ? family.playingElsewhere : const <String, Object>{};
    final invitable = [
      if (family.inFamily && slot is OpenSlot)
        for (final p in profiles)
          if (p.uid != null && !seatedUids.contains(p.uid) && slot.invited?.uid != p.uid) p,
    ]..sort((a, b) => (elsewhere.containsKey(a.uid) ? 0 : 1).compareTo(elsewhere.containsKey(b.uid) ? 0 : 1));
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
                  if (invitable.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.inviteFamily, style: AppTypography.caption(color: AppColors.wood)),
                      ),
                    ),
                  for (final p in invitable)
                    ListTile(
                      key: ValueKey('invite_${p.id}'),
                      leading: AvatarView(spec: p.avatar, size: 36),
                      title: Text(p.name, style: AppTypography.body(color: AppColors.ink)),
                      subtitle: Text(
                        elsewhere.containsKey(p.uid) ? l10n.playerActiveTag : l10n.inviteNotHere,
                        style: AppTypography.caption(
                          color: elsewhere.containsKey(p.uid) ? AppColors.felt : AppColors.woodLight,
                        ),
                      ),
                      trailing: const Icon(Icons.send_to_mobile, color: AppColors.wood),
                      onTap: () => Navigator.of(context).pop(('invite', p)),
                    ),
                  if (slot is! OpenSlot)
                    tile(const Icon(Icons.person_add_alt, color: AppColors.ink), l10n.slotLeaveOpen, 'open'),
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
        room.setSlot(
          index,
          LocalSlot(
            profileId: p.id,
            card: ProfileCard(name: p.name, avatar: p.avatar.toJson(), uid: p.uid),
          ),
        );
      case ('invite', PlayerProfile p):
        final ticket = ref.read(networkRoomsProvider).ticket;
        final hostName =
            [
              for (final s in room.slots)
                if (s is LocalSlot) s.card.name,
            ].firstOrNull ??
            '';
        final sent =
            ticket != null &&
            await family.invite(profileUid: p.uid!, room: ticket, gameId: room.module.id, hostName: hostName);
        // Their place waits for them (a stranger takes it only when nothing else is free).
        if (sent && room.slots[index] is OpenSlot) {
          room.setSlot(
            index,
            OpenSlot(
              invited: ProfileCard(name: p.name, avatar: p.avatar.toJson(), uid: p.uid),
            ),
          );
        }
        if (context.mounted) showAppToast(context, sent ? l10n.inviteSent : l10n.inviteNoDevice);
    }
  }
}
