import 'package:flutter/foundation.dart';

import '../game/difficulty.dart';

/// One seat of a finished game.
@immutable
class MatchParticipant {
  const MatchParticipant({
    required this.seat,
    required this.playerId,
    required this.place,
    required this.score,
    required this.stars,
    bool? robot,
  }) : robot = robot ?? playerId == null;

  final int seat;

  /// The profile; null for a robot or a player deleted since.
  final int? playerId;
  final bool robot;
  final int place;
  final int score;
  final int stars;

  bool get deletedPlayer => !robot && playerId == null;
}

/// A finished game as stored for statistics (spec 5.4).
@immutable
class MatchRecord {
  const MatchRecord({
    this.id,
    required this.gameId,
    required this.playedAt,
    required this.duration,
    required this.difficulty,
    required this.participants,
  });

  final int? id;
  final String gameId;
  final DateTime playedAt;
  final Duration duration;

  /// Robots' difficulty, or the level of a one-person game; null when two or
  /// more people played without robots.
  final Difficulty? difficulty;
  final List<MatchParticipant> participants;

  /// [participant] won outright; a shared first place is a draw. Alone at
  /// the table, 1st place = completed (a win), 2nd place = failed.
  bool isWin(MatchParticipant participant) =>
      participant.place == 1 && participants.where((p) => p.place == 1).length == 1;

  bool isDraw(MatchParticipant participant) =>
      participant.place == 1 && participants.where((p) => p.place == 1).length > 1;
}
