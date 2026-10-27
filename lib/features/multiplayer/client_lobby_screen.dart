import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/multiplayer_providers.dart';
import '../../core/multiplayer/protocol.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/thinking_dots.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'room_widgets.dart';

/// A joined room on the client (spec 14.2 step 4–6): everybody's places, the
/// host's settings read-only and "Jsem připraven".
class ClientLobbyScreen extends ConsumerStatefulWidget {
  const ClientLobbyScreen({super.key});

  @override
  ConsumerState<ClientLobbyScreen> createState() => _ClientLobbyScreenState();
}

class _ClientLobbyScreenState extends ConsumerState<ClientLobbyScreen> {
  var _ready = false;

  Future<void> _leave() async {
    await ref.read(networkRoomsProvider).leave();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(networkRoomsProvider).client;
    if (room == null) return RoomPage(title: l10n.roomTitle, onBack: () => context.pop(), body: const SizedBox.shrink());
    return ListenableBuilder(
      listenable: room,
      builder: (context, _) {
        final lobby = room.lobby;
        final module = lobby == null ? null : moduleById(lobby.gameId);
        final closed = room.closedReason;
        Widget body;
        if (closed != null) {
          body = Padding(
            padding: const EdgeInsets.all(16),
            child: PaperCard(
              child: Text(byeText(l10n, closed), style: AppTypography.body(color: AppColors.ink)),
            ),
          );
        } else if (lobby == null || module == null) {
          body = const Center(child: ThinkingDots(color: AppColors.paper));
        } else {
          body = ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              roomLabel(l10n.navPlayers),
              for (final (i, slot) in lobby.slots.indexed) RoomSlotTile(seat: i, slot: slot),
              roomLabel(l10n.lobbySettings),
              RoomSettingsSummary(
                module: module,
                difficulty: lobby.difficulty,
                options: lobby.options,
                hasRobots: lobby.slots.any((s) => s.kind == SlotKind.robot),
              ),
              if (_ready)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(l10n.lobbyWaitStart, style: AppTypography.caption(color: AppColors.woodLight)),
                ),
              const SizedBox(height: 16),
            ],
          );
        }
        return RoomPage(
          title: module == null ? l10n.roomTitle : '${l10n.roomTitle} · ${gameText(l10n, module.titleKey)}',
          onBack: _leave,
          body: body,
          bottom: SizedBox(
            width: double.infinity,
            child: closed != null
                ? PrimaryButton(key: const ValueKey('lobbyLeave'), label: l10n.leaveRoom, secondary: true, onPressed: _leave)
                : PrimaryButton(
                    key: const ValueKey('lobbyReady'),
                    label: _ready ? l10n.lobbyNotReady : l10n.lobbyReady,
                    icon: _ready ? Icons.pause : Icons.check,
                    secondary: _ready,
                    onPressed: lobby == null
                        ? null
                        : () {
                            setState(() => _ready = !_ready);
                            room.setReady(_ready);
                          },
                  ),
          ),
        );
      },
    );
  }
}
