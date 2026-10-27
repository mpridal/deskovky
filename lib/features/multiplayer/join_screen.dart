import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/multiplayer_providers.dart';
import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../../core/avatar/avatar_spec.dart';
import '../../core/multiplayer/protocol.dart';
import '../../core/multiplayer/room_info.dart';
import '../../core/players/player_profile.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/thinking_dots.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'room_widgets.dart';

/// "Připojit se ke hře" (spec 14.2 step 3–4): who plays on this device, the
/// rooms found on the Wi-Fi, or a room code (and IP:port under Pokročilé).
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key});

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  late final Stream<List<RoomInfo>> _rooms = ref.read(networkEnvProvider).rooms();
  final _code = TextEditingController();
  final _address = TextEditingController();
  Set<int>? _who;
  var _advanced = false;
  var _joining = false;
  List<RoomInfo> _found = const [];

  @override
  void dispose() {
    _code.dispose();
    _address.dispose();
    super.dispose();
  }

  Set<int> _picked(List<PlayerProfile> profiles) {
    final active = ref.read(activePlayerProvider).value;
    return _who ??= {if (active != null) active.id else if (profiles.isNotEmpty) profiles.first.id};
  }

  Future<void> _join(JoinTicket ticket, List<PlayerProfile> profiles) async {
    final l10n = AppLocalizations.of(context);
    final who = [
      for (final p in profiles)
        if (_picked(profiles).contains(p.id)) p,
    ];
    if (who.isEmpty) {
      showAppToast(context, l10n.joinPickSomeone);
      return;
    }
    setState(() => _joining = true);
    try {
      final version = await ref.read(appVersionProvider.future).catchError((Object _) => '?');
      await ref
          .read(networkRoomsProvider)
          .join(
            ticket: ticket,
            profiles: [for (final p in who) ProfileCard(name: p.name, avatar: p.avatar.toJson())],
            profileIds: [for (final p in who) p.id],
            appVersion: version,
          );
      if (mounted) await context.push('/join/lobby');
    } on Object {
      if (mounted) showAppToast(context, l10n.joinFailed);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  void _joinByCode(List<PlayerProfile> profiles) {
    final l10n = AppLocalizations.of(context);
    final code = _code.text.trim();
    final address = _address.text.trim();
    if (address.isNotEmpty) {
      final parts = address.split(':');
      final port = parts.length == 2 ? int.tryParse(parts[1]) : null;
      if (port == null || parts[0].isEmpty) {
        showAppToast(context, l10n.joinFailed);
        return;
      }
      _join(JoinTicket(ip: parts[0], port: port, code: code), profiles);
      return;
    }
    final room = _found.where((r) => r.code == code).firstOrNull;
    if (room == null) {
      showAppToast(context, l10n.joinCodeNotFound);
      return;
    }
    _join(room.ticket, profiles);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(playersProvider).value ?? const <PlayerProfile>[];
    final who = _picked(profiles);
    return RoomPage(
      title: l10n.homeJoin,
      onBack: () => context.pop(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          roomLabel(l10n.joinWho),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in profiles)
                Semantics(
                  button: true,
                  selected: who.contains(p.id),
                  child: GestureDetector(
                    key: ValueKey('who${p.id}'),
                    onTap: () => setState(() => who.contains(p.id) ? who.remove(p.id) : who.add(p.id)),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                      decoration: BoxDecoration(
                        color: who.contains(p.id) ? AppColors.gold : AppColors.paper,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarView(spec: p.avatar, size: 32),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              p.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.body(color: AppColors.ink),
                            ),
                          ),
                          if (who.contains(p.id)) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check, size: 18, color: AppColors.ink),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          roomLabel(l10n.joinRooms),
          StreamBuilder<List<RoomInfo>>(
            stream: _rooms,
            builder: (context, snapshot) {
              _found = snapshot.data ?? const [];
              if (_found.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      const ThinkingDots(color: AppColors.paper),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.joinSearching, style: AppTypography.body(color: AppColors.paper))),
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  for (final room in _found)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PaperCard(
                        key: ValueKey('room${room.code}'),
                        onTap: _joining ? null : () => _join(room.ticket, profiles),
                        child: Row(
                          children: [
                            AvatarView(spec: AvatarSpec.fromJson(room.hostAvatar), size: 44, semanticLabel: room.hostName),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${room.hostName} · ${_gameTitle(l10n, room.gameId)}',
                                    style: AppTypography.body(color: AppColors.ink).copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${l10n.roomCode} ${room.code} · ${l10n.joinFree(room.free)}',
                                    style: AppTypography.caption(color: AppColors.wood),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.wood),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          roomLabel(l10n.joinByCode),
          _field(const ValueKey('joinCode'), _code, l10n.roomCode, TextInputType.number),
          TextButton.icon(
            key: const ValueKey('joinAdvancedToggle'),
            onPressed: () => setState(() => _advanced = !_advanced),
            icon: Icon(_advanced ? Icons.expand_less : Icons.expand_more, color: AppColors.paper),
            label: Text(l10n.joinAdvanced, style: AppTypography.body(color: AppColors.paper)),
          ),
          if (_advanced) ...[
            _field(const ValueKey('joinAddress'), _address, l10n.joinAddress, TextInputType.url),
            const SizedBox(height: 12),
          ],
          PrimaryButton(
            key: const ValueKey('joinConnect'),
            label: l10n.joinConnect,
            icon: Icons.wifi,
            onPressed: _joining ? null : () => _joinByCode(profiles),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _field(Key key, TextEditingController controller, String label, TextInputType type) => TextField(
    key: key,
    controller: controller,
    keyboardType: type,
    style: AppTypography.body(color: AppColors.ink),
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.paper,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  String _gameTitle(AppLocalizations l10n, String gameId) {
    final module = moduleById(gameId);
    return module == null ? gameId : gameText(l10n, module.titleKey);
  }
}
