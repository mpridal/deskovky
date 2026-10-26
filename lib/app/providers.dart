import 'dart:async';
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
import '../core/points/points_repository.dart';
import '../core/points/rewards_config.dart';
import '../core/settings/settings_repository.dart';
import '../core/stats/leaderboard.dart';
import '../core/stats/match_record.dart';
import '../core/stats/player_stats.dart';
import '../core/stats/stats_repository.dart';
import 'stats_service.dart';

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

final statsRepositoryProvider = Provider<StatsRepository>((ref) => StatsRepository(ref.watch(databaseProvider)));

final pointsRepositoryProvider = Provider<PointsRepository>((ref) => PointsRepository(ref.watch(databaseProvider)));

/// Point values from `rewards.json`; `main()` overrides it with the file
/// read at start, tests use the defaults.
final rewardsConfigProvider = Provider<RewardsConfig>((ref) => RewardsConfig.defaults);

final statsServiceProvider = Provider<StatsService>(
  (ref) => StatsService(
    ref.watch(statsRepositoryProvider),
    points: ref.watch(pointsRepositoryProvider),
    rewards: ref.watch(rewardsConfigProvider),
  ),
);

/// Every finished game, refreshed after each new one.
final allMatchesProvider = StreamProvider<List<MatchRecord>>((ref) => ref.watch(statsRepositoryProvider).watchAllMatches());

final earnedBadgesProvider = StreamProvider.family<Map<String, DateTime>, int>(
  (ref, playerId) => ref.watch(statsRepositoryProvider).watchEarnedBadges(playerId),
);

/// The latest badge earned on this device (tablet "Poslední odměna").
final lastBadgeProvider = StreamProvider<(int, String)?>((ref) => ref.watch(statsRepositoryProvider).watchLastBadge());

/// The active player's best stars per game (home cards, spec 5.1).
final activeBestStarsProvider = Provider<Map<String, int>>((ref) {
  final player = ref.watch(activePlayerProvider).value;
  if (player == null) return const {};
  final stats = computePlayerStats(player.id, ref.watch(allMatchesProvider).value ?? const []);
  return {for (final MapEntry(:key, :value) in stats.byGame.entries) key: value.bestStars};
});

/// "Now" for week and month views; emits again at each period boundary so a
/// device left on overnight rolls over to the new week by itself.
final statsNowProvider = StreamProvider<DateTime>((ref) {
  final repo = ref.watch(statsRepositoryProvider);
  final controller = StreamController<DateTime>();
  Timer? timer;
  void tick() {
    final now = repo.now();
    controller.add(now);
    timer = Timer(nextPeriodBoundary(now).difference(now) + const Duration(seconds: 1), tick);
  }

  tick();
  ref.onDispose(() {
    timer?.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Every points movement of every player (leaderboards, balances).
final pointsLedgerProvider = StreamProvider<List<PointsEntry>>((ref) => ref.watch(pointsRepositoryProvider).watchAll());

/// Balance and total earned per player, from the ledger (spec 5.6).
final pointsSummaryProvider = Provider<Map<int, ({int balance, int earned})>>((ref) {
  final totals = <int, ({int balance, int earned})>{};
  for (final e in ref.watch(pointsLedgerProvider).value ?? const <PointsEntry>[]) {
    final t = totals[e.playerId] ?? (balance: 0, earned: 0);
    totals[e.playerId] = (balance: t.balance + e.amount, earned: t.earned + (e.amount > 0 ? e.amount : 0));
  }
  return totals;
});
