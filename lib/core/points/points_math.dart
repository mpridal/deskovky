import 'package:flutter/foundation.dart';

import '../game/difficulty.dart';
import 'rewards_config.dart';

/// Why points moved; also stored in the points ledger.
enum PointsReason { win, draw, second, participation, stars, streak, firstToday, record, badge, capped, gift, purchase }

/// One line of the points breakdown (spec 5.6 "Výsledky partie").
@immutable
class PointsLine {
  const PointsLine(this.reason, this.amount, {this.badgeId, this.count});

  final PointsReason reason;
  final int amount;

  /// The badge for [PointsReason.badge].
  final String? badgeId;

  /// Stars or streak length, for the label.
  final int? count;

  @override
  bool operator ==(Object other) =>
      other is PointsLine &&
      other.reason == reason &&
      other.amount == amount &&
      other.badgeId == badgeId &&
      other.count == count;

  @override
  int get hashCode => Object.hash(reason, amount, badgeId, count);

  @override
  String toString() => 'PointsLine($reason, $amount${badgeId == null ? '' : ', $badgeId'})';
}

/// One person's situation after a finished game.
@immutable
class PointsInput {
  const PointsInput({
    required this.difficulty,
    required this.seats,
    required this.humans,
    required this.place,
    required this.draw,
    required this.stars,
    required this.multiplier,
    required this.streak,
    required this.firstGameToday,
    required this.newRecord,
    required this.easyWinsTodayBefore,
    required this.badges,
  });

  /// Robots' difficulty; null when only people played.
  final Difficulty? difficulty;
  final int seats;
  final int humans;
  final int place;

  /// A shared first place.
  final bool draw;
  final int stars;

  /// The game's multiplier on the base (clamped by the config).
  final double multiplier;

  /// Win streak including this game.
  final int streak;
  final bool firstGameToday;
  final bool newRecord;

  /// This person's earlier Easy wins today in this game, alone with robots.
  final int easyWinsTodayBefore;

  /// Badges earned with this game and their rewards.
  final List<(String id, int reward)> badges;

  bool get won => place == 1 && !draw;
}

/// Points for one person after a game (spec 5.6). Never negative.
List<PointsLine> computeMatchPoints(RewardsConfig c, PointsInput i) {
  final badges = [for (final (id, reward) in i.badges) PointsLine(PointsReason.badge, reward, badgeId: id)];
  final easy = i.difficulty == Difficulty.easy;
  if (i.won && easy && i.humans == 1 && i.easyWinsTodayBefore >= c.easyDailyFullWins) {
    return [PointsLine(PointsReason.capped, c.cappedMatchPoints), ...badges];
  }
  // People only: the middle column (ruling, milestone 7a).
  final column = switch (i.difficulty) {
    Difficulty.easy => 0,
    Difficulty.hard => 2,
    _ => 1,
  };
  final (reason, row) = switch (i) {
    PointsInput(won: true) => (PointsReason.win, 'win'),
    PointsInput(draw: true) => (PointsReason.draw, 'draw'),
    PointsInput(place: 2, seats: >= 3) => (PointsReason.second, 'second'),
    _ => (PointsReason.participation, 'participation'),
  };
  final multiplier = i.multiplier.clamp(c.multiplierMin, c.multiplierMax);
  final streakBonus = i.won ? c.streakBonus[i.streak] : null;
  return [
    PointsLine(reason, (c.base[row]![column] * multiplier).round()),
    if (i.stars > 0) PointsLine(PointsReason.stars, i.stars * c.starBonus, count: i.stars),
    if (streakBonus != null) PointsLine(PointsReason.streak, streakBonus, count: i.streak),
    if (i.firstGameToday) PointsLine(PointsReason.firstToday, c.firstGameOfDay),
    if (i.newRecord) PointsLine(PointsReason.record, c.personalRecord),
    ...badges,
  ];
}
