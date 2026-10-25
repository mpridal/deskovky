import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/avatar/avatar_spec.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/layout/empty_screen.dart';

/// Players tab. Until profiles exist (milestone 3) it only lets you try the
/// avatar editor; the result lives in memory.
class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  AvatarSpec _avatar = AvatarSpec.defaults;

  Future<void> _edit() async {
    final edited = await context.push<AvatarSpec>('/players/avatar', extra: _avatar);
    if (edited != null && mounted) setState(() => _avatar = edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyScreen(
      title: l10n.navPlayers,
      children: [
        const SizedBox(height: 24),
        Center(child: AvatarView(spec: _avatar, size: 150)),
        const SizedBox(height: 24),
        Center(child: PrimaryButton(label: l10n.avatarEdit, icon: Icons.edit, onPressed: _edit)),
      ],
    );
  }
}
