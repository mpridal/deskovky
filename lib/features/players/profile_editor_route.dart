import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/avatar/avatar_spec.dart';
import '../../core/players/player_profile.dart';
import '../avatar_editor/avatar_editor_screen.dart';

/// Opens the avatar editor with a name field for a new profile ([playerId]
/// null) or an existing one, and saves through [PlayerRepository].
class ProfileEditorRoute extends ConsumerWidget {
  const ProfileEditorRoute({super.key, this.playerId});

  final int? playerId;

  Future<ProfileError?> _guard(Future<Object?> Function() action) async {
    try {
      await action();
      return null;
    } on ProfileException catch (e) {
      return e.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(playerRepositoryProvider);
    final id = playerId;
    if (id == null) {
      return AvatarEditorScreen(
        showName: true,
        initial: AvatarSpec.defaults,
        onSave: (r) => _guard(() => repo.create(name: r.name, avatar: r.avatar)),
      );
    }
    final players = ref.watch(playersProvider);
    final player = players.value?.where((p) => p.id == id).firstOrNull;
    if (player == null) return const Scaffold(body: SizedBox.shrink());
    final catalog = ref.watch(shopCatalogProvider);
    final owned = ref.watch(ownedItemsProvider(id)).value ?? const <String>{};
    return AvatarEditorScreen(
      key: ValueKey('edit$id'),
      showName: true,
      initial: player.avatar,
      initialName: player.name,
      ownedItems: [for (final item in catalog.items) if (owned.contains(item.id)) item],
      onSave: (r) => _guard(() => repo.update(id, name: r.name, avatar: r.avatar)),
    );
  }
}
