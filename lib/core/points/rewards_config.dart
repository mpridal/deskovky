import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Point values of spec 5.6, tunable in `assets/config/rewards.json`. Every
/// field missing or invalid in the file keeps its default.
@immutable
class RewardsConfig {
  const RewardsConfig({
    required this.base,
    required this.starBonus,
    required this.streakBonus,
    required this.firstGameOfDay,
    required this.personalRecord,
    required this.easyDailyFullWins,
    required this.cappedMatchPoints,
    required this.multiplierMin,
    required this.multiplierMax,
  });

  static const asset = 'assets/config/rewards.json';

  /// Points by place, each row Easy / Medium / Hard.
  final Map<String, List<int>> base;
  final int starBonus;

  /// Bonus when a win streak reaches exactly this length.
  final Map<int, int> streakBonus;
  final int firstGameOfDay;
  final int personalRecord;

  /// Full points for this many Easy wins a day in one game with one person.
  final int easyDailyFullWins;

  /// What a whole match is worth after that.
  final int cappedMatchPoints;
  final double multiplierMin;
  final double multiplierMax;

  static const defaults = RewardsConfig(
    base: {
      'win': [10, 20, 35],
      'draw': [5, 10, 15],
      'second': [4, 8, 12],
      'participation': [2, 3, 4],
    },
    starBonus: 2,
    streakBonus: {3: 5, 5: 10, 10: 25},
    firstGameOfDay: 5,
    personalRecord: 5,
    easyDailyFullWins: 10,
    cappedMatchPoints: 1,
    multiplierMin: 0.5,
    multiplierMax: 2.0,
  );

  static RewardsConfig parse(String source) {
    Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      debugPrint('RewardsConfig: invalid JSON, using defaults: $e');
    }
    final j = json is Map<String, Object?> ? json : const <String, Object?>{};
    const d = defaults;
    int intOr(Object? v, int fallback) => v is int && v >= 0 ? v : fallback;
    double doubleOr(Object? v, double fallback) => v is num && v > 0 ? v.toDouble() : fallback;
    final rawBase = j['base'] is Map<String, Object?> ? j['base']! as Map<String, Object?> : const <String, Object?>{};
    final rawStreak = j['streakBonus'] is Map<String, Object?>
        ? j['streakBonus']! as Map<String, Object?>
        : const <String, Object?>{};
    final streak = <int, int>{
      for (final MapEntry(:key, :value) in rawStreak.entries)
        if (int.tryParse(key) case final n? when value is int && value >= 0) n: value,
    };
    final min = doubleOr(j['multiplierMin'], d.multiplierMin), max = doubleOr(j['multiplierMax'], d.multiplierMax);
    final multipliers = min >= 0.5 && max <= 2 && min <= max ? (min, max) : (d.multiplierMin, d.multiplierMax);
    return RewardsConfig(
      base: {
        for (final MapEntry(:key, :value) in d.base.entries)
          key: switch (rawBase[key]) {
            final List<Object?> row when row.length == 3 && row.every((x) => x is int && x >= 0) => row.cast<int>(),
            _ => value,
          },
      },
      starBonus: intOr(j['starBonus'], d.starBonus),
      streakBonus: {...d.streakBonus, ...streak},
      firstGameOfDay: intOr(j['firstGameOfDay'], d.firstGameOfDay),
      personalRecord: intOr(j['personalRecord'], d.personalRecord),
      easyDailyFullWins: intOr(j['easyDailyFullWins'], d.easyDailyFullWins),
      cappedMatchPoints: intOr(j['cappedMatchPoints'], d.cappedMatchPoints),
      // Spec 5.6 allows 0.5–2; anything else (or min above max, which
      // would make clamp throw) falls back to both defaults.
      multiplierMin: multipliers.$1,
      multiplierMax: multipliers.$2,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RewardsConfig &&
      mapEquals(
        base.map((k, v) => MapEntry(k, v.join(','))),
        other.base.map((k, v) => MapEntry(k, v.join(','))),
      ) &&
      starBonus == other.starBonus &&
      mapEquals(streakBonus, other.streakBonus) &&
      firstGameOfDay == other.firstGameOfDay &&
      personalRecord == other.personalRecord &&
      easyDailyFullWins == other.easyDailyFullWins &&
      cappedMatchPoints == other.cappedMatchPoints &&
      multiplierMin == other.multiplierMin &&
      multiplierMax == other.multiplierMax;

  @override
  int get hashCode => Object.hash(starBonus, firstGameOfDay, personalRecord, easyDailyFullWins, cappedMatchPoints);
}
