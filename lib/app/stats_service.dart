import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/badges/badge.dart';
import '../core/badges/framework_badges.dart';
import '../core/game/difficulty.dart';
import '../core/game/game_config.dart';
import '../core/game/game_module.dart';
import '../core/game/game_result.dart';
import '../core/points/levels.dart';
import '../core/points/points_math.dart';
import '../core/points/points_repository.dart';
import '../core/points/rewards_config.dart';
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

/// A framework or game badge by id.
BadgeDef? badgeById(String id) =>
    [...frameworkBadges, for (final m in gameModules) ...m.badges].where((b) => b.id == id).firstOrNull;

/// One person's points from a game (spec 5.6 "Výsledky partie").
@immutable
class PlayerPoints {
  const PlayerPoints({required this.lines, required this.levelBefore, required this.levelAfter, this.balanceBefore = 0});

  final List<PointsLine> lines;
  final int levelBefore;
  final int levelAfter;

  /// The spendable points before this game.
  final int balanceBefore;

  int get total => lines.fold(0, (s, l) => s + l.amount);
}

/// What people got from a finished game.
@immutable
class MatchRewards {
  const MatchRewards({this.badges = const [], this.points = const {}});

  static const none = MatchRewards();

  final List<EarnedBadge> badges;

  /// By player id; people only.
  final Map<int, PlayerPoints> points;
}

/// Writes a finished game into statistics, awards badges and points
/// (spec 5.4–5.6).
class StatsService {
  StatsService(this._repo, {required this._points, this._rewards = RewardsConfig.defaults, this._modules = gameModules});

  final StatsRepository _repo;
  final PointsRepository _points;
  final RewardsConfig _rewards;
  final List<GameModule<Object?>> _modules;

  /// Reads `rewards.json` once at app start; defaults if it is broken.
  static Future<RewardsConfig> loadRewards(AssetBundle bundle) async {
    try {
      return RewardsConfig.parse(await bundle.loadString(RewardsConfig.asset));
    } catch (e) {
      debugPrint('StatsService: cannot read ${RewardsConfig.asset}, using defaults: $e');
      return RewardsConfig.defaults;
    }
  }

  /// Framework badges plus the badges of game [gameId].
  List<BadgeDef> badgesFor(String gameId) => [
    ...frameworkBadges,
    ..._modules.where((m) => m.id == gameId).expand((m) => m.badges),
  ];

  /// Every badge, framework first, then by game.
  List<BadgeDef> get allBadges => [...frameworkBadges, for (final m in _modules) ...m.badges];

  /// Stores the game and returns the badges and points people earned, all in
  /// one transaction, so a killed app never keeps the game without its
  /// badges. Robots and profiles deleted meanwhile get nothing (spec 5.7.1).
  Future<MatchRewards> recordFinished({
    required GameConfig config,
    required GameResult result,
    required List<GameEvent> events,
    required Duration duration,
  }) async {
    // Spec 5.6: a game ended early (e.g. Člověče "Ukončit a seřadit") earns
    // nothing – like leaving a game, it is not recorded at all.
    if (result.stats['endedEarly'] == true) return MatchRewards.none;
    return _record(config: config, result: result, events: events, duration: duration);
  }

  Future<MatchRewards> _record({
    required GameConfig config,
    required GameResult result,
    required List<GameEvent> events,
    required Duration duration,
  }) => _repo.transaction(() async {
    final humanIds = {
      for (final s in config.seats)
        if (s is HumanSeat) s.profileId,
    };
    final existing = await _repo.existingPlayerIds(humanIds);
    final match = MatchRecord(
      gameId: config.gameId,
      playedAt: _repo.now(),
      duration: duration,
      // Robots' strength, or the game's own level when one person plays alone
      // (spec 13.6, 13.7); null when two or more people play without robots.
      difficulty: config.robots > 0 || config.seats.length == 1 ? config.difficulty : null,
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
            // Someone on another device: a guest here (spec 14.5) – in the
            // history, but without points, badges or a leaderboard place.
            RemoteSeat() => MatchParticipant(
              seat: seat,
              playerId: null,
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
    final config0 = _rewards;
    final before = await _repo.allMatches();
    final matchId = await _repo.recordMatch(match, events: events);
    final history = await _repo.allMatches();
    final defs = badgesFor(config.gameId);
    final available = {for (final m in _modules) if (m.available) m.id};
    final earned = <EarnedBadge>[];
    final points = <int, PlayerPoints>{};
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
      final mine = <BadgeDef>[];
      for (final badge in evaluateBadges(defs, context, already)) {
        if (await _repo.awardBadge(playerId, badge.id)) {
          earned.add(EarnedBadge(playerId: playerId, badge: badge));
          mine.add(badge);
        }
      }
      final lines = computeMatchPoints(
        config0,
        _pointsInput(match, me, before, context.stats.currentStreak, mine),
      );
      final totalBefore = await _points.totalEarned(playerId);
      final balanceBefore = await _points.balance(playerId);
      await _points.addGameLines(playerId, lines, matchId: matchId);
      points[playerId] = PlayerPoints(
        lines: lines,
        levelBefore: levelFor(totalBefore),
        levelAfter: levelFor(totalBefore + lines.fold<int>(0, (s, l) => s + (l.amount > 0 ? l.amount : 0))),
        balanceBefore: balanceBefore,
      );
    }
    return MatchRewards(badges: earned, points: points);
  });

  PointsInput _pointsInput(
    MatchRecord match,
    MatchParticipant me,
    List<MatchRecord> before,
    int streak,
    List<BadgeDef> badges,
  ) {
    final now = match.playedAt;
    bool sameDay(DateTime t) => t.year == now.year && t.month == now.month && t.day == now.day;
    final mineBefore = [
      for (final m in before)
        if (m.participants.any((p) => p.playerId == me.playerId && !p.robot)) m,
    ];
    final previous = computePlayerStats(me.playerId!, mineBefore).byGame[match.gameId];
    final won = match.isWin(me);
    final fastest = previous?.fastestWin;
    return PointsInput(
      difficulty: match.difficulty,
      seats: match.participants.length,
      humans: match.participants.where((p) => p.playerId != null).length,
      place: me.place,
      draw: match.isDraw(me),
      stars: me.stars,
      multiplier: _modules.where((m) => m.id == match.gameId).firstOrNull?.pointsMultiplier ?? 1,
      streak: streak,
      firstGameToday: !mineBefore.any((m) => sameDay(m.playedAt)),
      newRecord: previous != null && (me.score > previous.bestScore || (won && fastest != null && match.duration < fastest)),
      easyWinsTodayBefore: mineBefore.where((m) {
        final p = m.participants.firstWhere((p) => p.playerId == me.playerId && !p.robot);
        return sameDay(m.playedAt) &&
            m.gameId == match.gameId &&
            m.difficulty == Difficulty.easy &&
            m.participants.where((x) => !x.robot).length == 1 &&
            m.isWin(p);
      }).length,
      badges: [for (final b in badges) (b.id, b.reward)],
    );
  }
}
