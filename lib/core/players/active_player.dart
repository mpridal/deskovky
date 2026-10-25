import 'dart:async';

import '../settings/settings_repository.dart';
import 'player_profile.dart';
import 'player_repository.dart';

/// The player currently playing on this device: the remembered one if it
/// still exists, otherwise the oldest profile (which then becomes the
/// remembered one), or null when there are no profiles.
Stream<PlayerProfile?> watchActivePlayer(PlayerRepository players, SettingsRepository settings) {
  late final StreamController<PlayerProfile?> controller;
  StreamSubscription<List<PlayerProfile>>? playersSub;
  StreamSubscription<int?>? idSub;
  List<PlayerProfile>? profiles;
  int? activeId;
  var idLoaded = false;

  void emit() {
    final list = profiles;
    if (list == null || !idLoaded) return;
    if (list.isEmpty) {
      controller.add(null);
      return;
    }
    final remembered = list.where((p) => p.id == activeId).firstOrNull;
    if (remembered != null) {
      controller.add(remembered);
    } else {
      controller.add(list.first);
      unawaited(settings.setActivePlayerId(list.first.id));
    }
  }

  controller = StreamController<PlayerProfile?>(
    onListen: () {
      playersSub = players.watchAll().listen((list) {
        profiles = list;
        emit();
      }, onError: controller.addError);
      idSub = settings.watchActivePlayerId().listen((id) {
        activeId = id;
        idLoaded = true;
        emit();
      }, onError: controller.addError);
    },
    onCancel: () async {
      await playersSub?.cancel();
      await idSub?.cancel();
    },
  );
  return controller.stream.distinct();
}
