import 'package:flutter/foundation.dart';

import '../game/difficulty.dart';
import 'match_record.dart';

/// A player's results in one game.
@immutable
class GameBest {
  const GameBest({
    required this.played,
    required this.wins,
    required this.bestScore,
    required this.fastestWin,
    required this.bestStars,
  });

  final int played;
  final int wins;
  final int bestScore;

  /// Shortest won game; null without a win (personal record, spec 5.4).
  final Duration? fastestWin;
  final int bestStars;
}

/// A player's statistics (spec 5.4).
@immutable
class PlayerStats {
  const PlayerStats({
    required this.played,
    required this.wins,
    required this.draws,
    required this.currentStreak,
    required this.bestStreak,
    required this.byGame,
    required this.winsAgainst,
  });

  final int played;
  final int wins;
  final int draws;

  /// Wins in a row up to the latest game; a draw or loss resets it.
  final int currentStreak;
  final int bestStreak;
  final Map<String, GameBest> byGame;

  /// Robot difficulties this player has beaten.
  final Set<Difficulty> winsAgainst;

  double get winRate => played == 0 ? 0 : wins / played;

  Set<String> get gamesPlayed => byGame.keys.toSet();
}

/// Statistics of [playerId] from [matches], oldest first.
PlayerStats computePlayerStats(int playerId, Iterable<MatchRecord> matches) {
  var played = 0, wins = 0, draws = 0, streak = 0, bestStreak = 0;
  final byGame = <String, GameBest>{};
  final winsAgainst = <Difficulty>{};
  for (final match in matches) {
    final me = match.participants.where((p) => p.playerId == playerId && !p.robot).firstOrNull;
    if (me == null) continue;
    // Alone at the table, 1st place means the game was completed (a win,
    // spec 5.6) and 2nd place that it failed.
    final won = match.isWin(me);
    played++;
    if (won) {
      wins++;
      streak++;
      if (bestStreak < streak) bestStreak = streak;
      if (match.difficulty != null && match.participants.any((p) => p.robot)) winsAgainst.add(match.difficulty!);
    } else {
      if (match.isDraw(me)) draws++;
      streak = 0;
    }
    final old = byGame[match.gameId];
    final fastest = old?.fastestWin;
    byGame[match.gameId] = GameBest(
      played: (old?.played ?? 0) + 1,
      wins: (old?.wins ?? 0) + (won ? 1 : 0),
      bestScore: old == null || me.score > old.bestScore ? me.score : old.bestScore,
      fastestWin: won && (fastest == null || match.duration < fastest) ? match.duration : fastest,
      bestStars: old == null || me.stars > old.bestStars ? me.stars : old.bestStars,
    );
  }
  return PlayerStats(
    played: played,
    wins: wins,
    draws: draws,
    currentStreak: streak,
    bestStreak: bestStreak,
    byGame: byGame,
    winsAgainst: winsAgainst,
  );
}
