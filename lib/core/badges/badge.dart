import 'package:flutter/widgets.dart';

import '../game/difficulty.dart';
import '../stats/match_record.dart';
import '../stats/player_stats.dart';
import '../stats/stats_repository.dart';

/// Everything a badge condition may look at, for one player right after a
/// finished game (spec 5.5).
@immutable
class BadgeContext {
  const BadgeContext({
    required this.playerId,
    required this.stats,
    required this.counters,
    required this.match,
    required this.me,
    required this.events,
    required this.availableGames,
  });

  final int playerId;

  /// Statistics including the match just played.
  final PlayerStats stats;

  /// Event totals including this match.
  final Map<String, int> counters;
  final MatchRecord match;
  final MatchParticipant me;
  final List<GameEvent> events;

  /// Ids of the games that can be played now.
  final Set<String> availableGames;
}

/// Declarative badge conditions, combined from these building blocks.
@immutable
sealed class BadgeCondition {
  const BadgeCondition();

  /// At least [count] wins in total.
  const factory BadgeCondition.wins(int count) = _Wins;

  /// [count] wins in a row (a draw or loss breaks it).
  const factory BadgeCondition.winStreak(int count) = _Streak;

  /// At least [count] finished games.
  const factory BadgeCondition.played(int count) = _Played;

  /// The event counter [key] reached [count].
  const factory BadgeCondition.counter(String key, int count) = _Counter;

  /// This match was won against robots on [difficulty].
  const factory BadgeCondition.wonAgainst(Difficulty difficulty) = _WonAgainst;

  /// This match was won.
  const factory BadgeCondition.won() = _Won;

  /// The game reported event [id] in this match for my seat (or for nobody
  /// in particular).
  const factory BadgeCondition.event(String id) = _Event;

  /// Every available game played at least once (needs two or more games,
  /// so it is not earned by the very first game).
  const factory BadgeCondition.allGames() = _AllGames;

  const factory BadgeCondition.all(List<BadgeCondition> conditions) = _All;

  bool test(BadgeContext c);
}

class _Wins extends BadgeCondition {
  const _Wins(this.count);
  final int count;
  @override
  bool test(BadgeContext c) => c.stats.wins >= count;
}

class _Streak extends BadgeCondition {
  const _Streak(this.count);
  final int count;
  @override
  bool test(BadgeContext c) => c.stats.currentStreak >= count;
}

class _Played extends BadgeCondition {
  const _Played(this.count);
  final int count;
  @override
  bool test(BadgeContext c) => c.stats.played >= count;
}

class _Counter extends BadgeCondition {
  const _Counter(this.key, this.count);
  final String key;
  final int count;
  @override
  bool test(BadgeContext c) => (c.counters[key] ?? 0) >= count;
}

class _WonAgainst extends BadgeCondition {
  const _WonAgainst(this.difficulty);
  final Difficulty difficulty;
  @override
  bool test(BadgeContext c) =>
      c.match.isWin(c.me) && c.match.difficulty == difficulty && c.match.participants.any((p) => p.robot);
}

class _Won extends BadgeCondition {
  const _Won();
  @override
  bool test(BadgeContext c) => c.match.isWin(c.me);
}

class _Event extends BadgeCondition {
  const _Event(this.id);
  final String id;
  @override
  bool test(BadgeContext c) => c.events.any((e) => e.$1 == id && eventConcerns(e.$2, c.me.seat));
}

class _AllGames extends BadgeCondition {
  const _AllGames();
  @override
  bool test(BadgeContext c) => c.availableGames.length > 1 && c.stats.gamesPlayed.containsAll(c.availableGames);
}

class _All extends BadgeCondition {
  const _All(this.conditions);
  final List<BadgeCondition> conditions;
  @override
  bool test(BadgeContext c) => conditions.every((x) => x.test(c));
}

/// A badge (spec 5.5): game badges use ids prefixed with `<gameId>.`.
@immutable
class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.reward,
    required this.condition,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;

  /// Points paid when earned (+15 to +50, spec 5.6; paid from milestone 7).
  final int reward;
  final BadgeCondition condition;
}

/// The badges from [defs] that [context] newly earns.
List<BadgeDef> evaluateBadges(List<BadgeDef> defs, BadgeContext context, Set<String> alreadyEarned) => [
  for (final d in defs)
    if (!alreadyEarned.contains(d.id) && d.condition.test(context)) d,
];
