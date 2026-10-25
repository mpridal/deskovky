import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/app_database.dart';
import '../core/players/active_player.dart';
import '../core/players/player_profile.dart';
import '../core/players/player_repository.dart';
import '../core/settings/settings_repository.dart';

/// The app database. Overridden in `main()` with [AppDatabase.open] and in
/// tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override databaseProvider'));

final playerRepositoryProvider = Provider<PlayerRepository>((ref) => PlayerRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(databaseProvider)));

final playersProvider = StreamProvider<List<PlayerProfile>>((ref) => ref.watch(playerRepositoryProvider).watchAll());

final activePlayerProvider = StreamProvider<PlayerProfile?>(
  (ref) => watchActivePlayer(ref.watch(playerRepositoryProvider), ref.watch(settingsRepositoryProvider)),
);

/// Language chosen in Settings; null follows the system.
final localeSettingProvider = StreamProvider<Locale?>((ref) => ref.watch(settingsRepositoryProvider).watchLocale());
