import 'package:flutter/foundation.dart';

import '../core/badges/badge.dart';
import '../core/badges/framework_badges.dart';
import '../core/game/game_config.dart';
import '../core/game/game_module.dart';
import '../core/game/game_result.dart';
import '../core/stats/match_record.dart';
import '../core/stats/player_stats.dart';
import '../core/stats/stats_repository.dart';
import '../games/registry.dart';

/// A badge someone has just earned.
@immutable
class EarnedBadge {
  const EarnedBadge({required this.playerId, required this.badge});

  final int playerId;
  final BadgeDef badge;
}

/// Writes a finished game into statistics and awards badges (spec 5.4, 5.5).
class StatsService {
  StatsService(this._repo, {this._modules = gameModules});

  final StatsRepository _repo;
  final List<GameModule<Object?>> _modules;

  /// Framework badges plus the badges of game [gameId].
  List<BadgeDef> badgesFor(String gameId) => [
    ...frameworkBadges,
    ..._modules.where((m) => m.id == gameId).expand((m) => m.badges),
  ];

  /// Every badge, framework first, then by game.
  List<BadgeDef> get allBadges => [...frameworkBadges, for (final m in _modules) ...m.badges];

  /// Stores the game and returns the badges people earned with it. Robots
  /// and profiles deleted meanwhile get nothing (spec 5.7.1).
  Future<List<EarnedBadge>> recordFinished({
    required GameConfig config,
    required GameResult result,
    required List<GameEvent> events,
    required Duration duration,
  }) async {
    final humanIds = {
      for (final s in config.seats)
        if (s is HumanSeat) s.profileId,
    };
    final existing = await _repo.existingPlayerIds(humanIds);
    final match = MatchRecord(
      gameId: config.gameId,
      playedAt: _repo.now(),
      duration: duration,
      difficulty: config.robots > 0 ? config.difficulty : null,
      participants: [
        for (var seat = 0; seat < config.seats.length; seat++)
          switch (config.seats[seat]) {
            HumanSeat(:final profileId) => MatchParticipant(
              seat: seat,
              playerId: existing.contains(profileId) ? profileId : null,
              robot: false,
              place: result.places[seat],
              score: result.scores[seat],
              stars: result.stars[seat],
            ),
            RobotSeat() => MatchParticipant(
              seat: seat,
              playerId: null,
              robot: true,
              place: result.places[seat],
              score: result.scores[seat],
              stars: result.stars[seat],
            ),
          },
      ],
    );
    await _repo.recordMatch(match, events: events);
    final history = await _repo.allMatches();
    final defs = badgesFor(config.gameId);
    final available = {for (final m in _modules) if (m.available) m.id};
    final earned = <EarnedBadge>[];
    for (final me in match.participants) {
      final playerId = me.playerId;
      if (playerId == null) continue;
      final context = BadgeContext(
        playerId: playerId,
        stats: computePlayerStats(playerId, history),
        counters: await _repo.counters(playerId),
        match: match,
        me: me,
        events: events,
        availableGames: available,
      );
      final already = (await _repo.earnedBadges(playerId)).keys.toSet();
      for (final badge in evaluateBadges(defs, context, already)) {
        if (await _repo.awardBadge(playerId, badge.id)) earned.add(EarnedBadge(playerId: playerId, badge: badge));
      }
    }
    return earned;
  }
}
