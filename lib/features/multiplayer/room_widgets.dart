import 'package:flutter/material.dart';

import '../../core/avatar/avatar_spec.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/multiplayer/protocol.dart';
import '../../games/game_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/components/player_slot.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../game_play/seat_identity.dart';

/// A full-screen page of network play: felt, back button and title.
class RoomPage extends StatelessWidget {
  const RoomPage({super.key, required this.title, required this.onBack, required this.body, this.bottom});

  final String title;
  final VoidCallback onBack;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        body: FeltBackground(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      RoundIconButton(icon: Icons.arrow_back, tooltip: l10n.back, sound: UiSound.back, onPressed: onBack),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.h2(color: AppColors.paper),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: body),
                if (bottom case final bottom?) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget roomLabel(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
  child: Text(text, style: AppTypography.caption(color: AppColors.woodLight)),
);

/// One place in a room (spec 14.6): 🏠 on the host's device, 📱 on their own,
/// 🤖 a robot, or free; a dot shows whether a remote device is connected.
class RoomSlotTile extends StatelessWidget {
  const RoomSlotTile({super.key, required this.seat, required this.slot, this.connected = true, this.onTap});

  final int seat;
  final LobbySlot slot;
  final bool connected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = AppColors.players[seat % AppColors.players.length];
    final (Widget avatar, String name, String tag) = switch (slot.kind) {
      SlotKind.robot => (RobotAvatar(color: color, size: 40), robotName(l10n, seat), l10n.seatRobot),
      SlotKind.open => (
        CircleAvatar(radius: 20, backgroundColor: AppColors.paper2, child: Icon(Icons.add, color: color)),
        l10n.slotOpen,
        l10n.slotWaiting,
      ),
      SlotKind.host => (
        AvatarView(spec: AvatarSpec.fromJson(slot.avatar), size: 40, semanticLabel: slot.name),
        slot.name,
        l10n.slotHere,
      ),
      SlotKind.remote => (
        AvatarView(spec: AvatarSpec.fromJson(slot.avatar), size: 40, semanticLabel: slot.name),
        slot.name,
        l10n.slotOwnDevice,
      ),
    };
    final status = slot.kind == SlotKind.remote
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: ValueKey(connected ? 'dotConnected' : 'dotLost'),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: connected ? const Color(0xFF3FA34D) : const Color(0xFFC8473B),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  !connected ? l10n.slotDisconnected : (slot.ready ? l10n.slotReady : l10n.slotWaiting),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(color: AppColors.ink),
                ),
              ),
            ],
          )
        : null;
    return Padding(
      key: ValueKey('roomSlot$seat'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: onTap != null,
        child: GestureDetector(
          onTap: onTap,
          child: PlayerSlot(seat: seat % 4, avatar: avatar, name: name, tag: tag, detail: status),
        ),
      ),
    );
  }
}

/// The game's settings as text, for everyone to read (spec 14.2 step 5).
class RoomSettingsSummary extends StatelessWidget {
  const RoomSettingsSummary({
    super.key,
    required this.module,
    required this.difficulty,
    required this.options,
    required this.hasRobots,
  });

  final GameModule<Object?> module;
  final Difficulty difficulty;
  final Map<String, Object?> options;
  final bool hasRobots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <(String, String)>[
      if (hasRobots || module.difficultyWithoutRobots) (l10n.setupDifficulty, difficultyLabel(l10n, difficulty)),
      for (final option in module.options)
        if (option case ChoiceOption(:final choices))
          (
            gameText(l10n, option.labelKey),
            [
              for (final (value, label) in choices)
                if (value == (options[option.id] ?? option.defaultValue)) gameText(l10n, label),
            ].firstOrNull ?? '',
          ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
            child: Wrap(
              spacing: 8,
              children: [
                Text('$label:', style: AppTypography.body(color: AppColors.woodLight)),
                Text(value, style: AppTypography.body(color: AppColors.paper)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Why the host hung up, for the person on this device.
String byeText(AppLocalizations l10n, String reason) => switch (reason) {
  'version' => l10n.byeVersion,
  'code' => l10n.byeCode,
  'full' => l10n.byeFull,
  'started' => l10n.byeStarted,
  'kicked' => l10n.byeKicked,
  'ended' => l10n.byeEnded,
  _ => l10n.byeLost,
};
