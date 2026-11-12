import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/family_controller.dart';
import '../../app/multiplayer_providers.dart';
import '../../app/providers.dart';
import '../../app/update_controller.dart';
import '../../core/multiplayer/protocol.dart';
import '../../core/players/player_profile.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// How long an invitation waits for an answer (spec 5.4).
const inviteTimeout = Duration(seconds: 60);

/// "Táta tě zve do hry Pexeso – hrát?" (spec "Rodinná synchronizace" 5.4):
/// Hrát joins the room as the invited child, already ready; Teď ne or 60 s
/// without an answer lets it go.
Future<void> showFamilyInvite(BuildContext context, WidgetRef ref, FamilyInvite invite) async {
  final l10n = AppLocalizations.of(context);
  final players = await ref.read(playerRepositoryProvider).all();
  final child = players.where((p) => p.uid == invite.profileUid).firstOrNull;
  if (child == null || !context.mounted) return;
  final module = moduleById(invite.gameId);
  final game = module == null ? invite.gameId : gameText(l10n, module.titleKey);
  // One timer for the whole invitation (the builder may run many times).
  final navigator = Navigator.of(context);
  var open = true;
  final expiry = Timer(inviteTimeout, () {
    if (open) navigator.pop(false);
  });
  final play = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.inviteTitle(invite.hostName, game), textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 16),
              PrimaryButton(
                key: const ValueKey('invitePlay'),
                label: l10n.invitePlay,
                icon: Icons.play_arrow,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text(l10n.inviteLater, style: AppTypography.button(color: AppColors.ink)),
              ),
            ],
          ),
        ),
      );
    },
  );
  open = false;
  expiry.cancel();
  if (play != true || !context.mounted) return;
  await _join(context, ref, invite, child);
}

Future<void> _join(BuildContext context, WidgetRef ref, FamilyInvite invite, PlayerProfile child) async {
  final l10n = AppLocalizations.of(context);
  final router = GoRouter.of(context);
  try {
    final version = await ref.read(appVersionProvider.future).catchError((Object _) => '?');
    final room = await ref
        .read(networkRoomsProvider)
        .join(
          ticket: invite.room,
          profiles: [ProfileCard(name: child.name, avatar: child.avatar.toJson(), uid: child.uid)],
          profileIds: [child.id],
          appVersion: version,
        );
    // Invited to play: ready at once.
    room.setReady(true);
    await router.push('/lobby');
  } on Object {
    if (context.mounted) showAppToast(context, l10n.joinFailed);
  }
}
