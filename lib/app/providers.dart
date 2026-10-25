import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/audio_catalog.dart';
import '../core/audio/audio_service.dart';
import '../core/audio/just_audio_backend.dart';
import '../core/db/app_database.dart';
import '../core/game/ai_player.dart';
import '../core/game/game_config.dart';
import '../core/game/game_store.dart';
import '../core/players/active_player.dart';
import '../core/players/player_profile.dart';
import '../core/players/player_repository.dart';
import '../core/settings/settings_repository.dart';

/// The app database. Overridden in `main()` with [AppDatabase.open] and in
/// tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError('override databaseProvider'));

final playerRepositoryProvider = Provider<PlayerRepository>((ref) => PlayerRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final playersProvider = StreamProvider<List<PlayerProfile>>((ref) => ref.watch(playerRepositoryProvider).watchAll());

final activePlayerProvider = StreamProvider<PlayerProfile?>(
  (ref) => watchActivePlayer(ref.watch(playerRepositoryProvider), ref.watch(settingsRepositoryProvider)),
);

/// Language chosen in Settings; null follows the system.
final localeSettingProvider = StreamProvider<Locale?>((ref) => ref.watch(settingsRepositoryProvider).watchLocale());

final gameStoreProvider = Provider<GameStore>((ref) => GameStore(ref.watch(databaseProvider)));

/// Setup of the most recently played game (home "Pokračovat").
final lastPlayedProvider = StreamProvider<GameConfig?>((ref) => ref.watch(gameStoreProvider).watchLastPlayed());

/// The most recently saved game in progress.
final lastSavedProvider = StreamProvider<SavedGame?>((ref) => ref.watch(gameStoreProvider).watchLastSaved());

/// Runs robots' AI off the UI thread; tests override it with [InlineAiRunner].
final aiRunnerProvider = Provider<AiRunner>((ref) => const IsolateAiRunner());

final musicOnProvider = StreamProvider<bool>((ref) => ref.watch(settingsRepositoryProvider).watchMusicOn());

final sfxOnProvider = StreamProvider<bool>((ref) => ref.watch(settingsRepositoryProvider).watchSfxOn());

final musicVolumeProvider = StreamProvider<double>((ref) => ref.watch(settingsRepositoryProvider).watchMusicVolume());

final sfxVolumeProvider = StreamProvider<double>((ref) => ref.watch(settingsRepositoryProvider).watchSfxVolume());

final vibrationOnProvider = StreamProvider<bool>((ref) => ref.watch(settingsRepositoryProvider).watchVibrationOn());

/// Music and effects; tests override it with a fake backend.
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService(backend: JustAudioBackend(), catalog: AudioCatalog.standard);
  ref.onDispose(service.dispose);
  return service;
});
