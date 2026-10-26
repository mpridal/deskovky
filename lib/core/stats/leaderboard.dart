import 'package:flutter/foundation.dart';

import '../game/difficulty.dart';
import '../points/points_repository.dart';
import 'match_record.dart';
import 'player_stats.dart';

enum StatsPeriod { week, month, all }

/// Which games a leaderboard counts (spec 5.4); null means all.
@immutable
class LeaderboardQuery {
  const LeaderboardQuery({this.gameId, this.difficulty, this.period = StatsPeriod.all});

  final String? gameId;
  final Difficulty? difficulty;
  final StatsPeriod period;

  LeaderboardQuery copyWith({String? Function()? gameId, Difficulty? Function()? difficulty, StatsPeriod? period}) =>
      LeaderboardQuery(
        gameId: gameId == null ? this.gameId : gameId(),
        difficulty: difficulty == null ? this.difficulty : difficulty(),
        period: period ?? this.period,
      );

  @override
  bool operator ==(Object other) =>
      other is LeaderboardQuery && other.gameId == gameId && other.difficulty == difficulty && other.period == period;

  @override
  int get hashCode => Object.hash(gameId, difficulty, period);
}

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.wins,
    required this.played,
    this.points = 0,
  });

  final int rank;
  final int playerId;
  final int wins;
  final int played;

  /// Points earned in the counted games (gifts and purchases excluded).
  final int points;

  double get winRate => played == 0 ? 0 : wins / played;
}

/// Start of [period] in local time: Monday 00:00 for a week, the 1st for a
/// month; null for all time.
DateTime? periodStart(StatsPeriod period, DateTime now) => switch (period) {
  StatsPeriod.week => DateTime(now.year, now.month, now.day - (now.weekday - DateTime.monday)),
  StatsPeriod.month => DateTime(now.year, now.month),
  StatsPeriod.all => null,
};

/// When the week or month views change next: the earlier of next Monday
/// 00:00 and the next 1st 00:00.
DateTime nextPeriodBoundary(DateTime now) {
  final monday = DateTime(now.year, now.month, now.day + 8 - now.weekday);
  final month = DateTime(now.year, now.month + 1);
  return monday.isBefore(month) ? monday : month;
}

/// People ranked by points earned in the selected games (spec 5.4, 5.6),
/// then wins, win rate and fewer games. Robots,
/// deleted players and anyone outside [players] (when given) never appear.
List<LeaderboardEntry> leaderboard(
  Iterable<MatchRecord> matches,
  LeaderboardQuery query, {
  required DateTime now,
  Set<int>? players,
  List<PointsEntry> points = const [],
}) {
  final start = periodStart(query.period, now);
  final selected = matches.where(
    (m) =>
        (query.gameId == null || m.gameId == query.gameId) &&
        (query.difficulty == null || m.difficulty == query.difficulty) &&
        (start == null || !m.playedAt.isBefore(start)),
  ).toList();
  final ranked = {
    for (final m in selected)
      for (final p in m.participants)
        if (!p.robot && (players == null || players.contains(p.playerId))) ?p.playerId,
  };
  final counted = {for (final m in selected) ?m.id};
  final earned = <int, int>{};
  for (final e in points) {
    if (e.amount > 0 && counted.contains(e.matchId)) earned[e.playerId] = (earned[e.playerId] ?? 0) + e.amount;
  }
  final rows = [
    for (final id in ranked)
      () {
        final s = computePlayerStats(id, selected);
        return (id: id, wins: s.wins, played: s.played, rate: s.winRate, points: earned[id] ?? 0);
      }(),
  ]..sort((a, b) {
      final byPoints = b.points.compareTo(a.points);
      if (byPoints != 0) return byPoints;
      final byWins = b.wins.compareTo(a.wins);
      if (byWins != 0) return byWins;
      final byRate = b.rate.compareTo(a.rate);
      if (byRate != 0) return byRate;
      final byPlayed = a.played.compareTo(b.played);
      return byPlayed != 0 ? byPlayed : a.id.compareTo(b.id);
    });
  final result = <LeaderboardEntry>[];
  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    final tied = i > 0 && rows[i - 1].points == r.points && rows[i - 1].wins == r.wins && rows[i - 1].played == r.played;
    result.add(
      LeaderboardEntry(
        rank: tied ? result[i - 1].rank : i + 1,
        playerId: r.id,
        wins: r.wins,
        played: r.played,
        points: r.points,
      ),
    );
  }
  return result;
}
