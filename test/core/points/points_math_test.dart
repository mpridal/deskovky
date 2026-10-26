import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/rewards_config.dart';
import 'package:flutter_test/flutter_test.dart';

PointsInput _in({
  Difficulty? difficulty = Difficulty.medium,
  int seats = 2,
  int humans = 1,
  int place = 1,
  bool draw = false,
  int stars = 0,
  double multiplier = 1,
  int streak = 1,
  bool firstToday = false,
  bool record = false,
  int easyWinsBefore = 0,
  List<(String, int)> badges = const [],
}) => PointsInput(
  difficulty: difficulty,
  seats: seats,
  humans: humans,
  place: place,
  draw: draw,
  stars: stars,
  multiplier: multiplier,
  streak: streak,
  firstGameToday: firstToday,
  newRecord: record,
  easyWinsTodayBefore: easyWinsBefore,
  badges: badges,
);

int _total(List<PointsLine> lines) => lines.fold(0, (s, l) => s + l.amount);

void main() {
  final c = RewardsConfig.defaults;

  test('the bundled rewards.json matches the defaults in code', () {
    final file = RewardsConfig.parse(File('assets/config/rewards.json').readAsStringSync());
    expect(file, c);
  });

  test('a broken or partial rewards.json falls back to defaults per field', () {
    expect(RewardsConfig.parse('not json'), c);
    final partial = RewardsConfig.parse('{"starBonus": 3, "base": {"win": [1, 2]}}');
    expect(partial.starBonus, 3);
    expect(partial.base['win'], c.base['win'], reason: 'a wrong-length row is ignored');
  });

  group('base by place and difficulty (spec 5.6)', () {
    test('win 10/20/35, draw 5/10/15', () {
      for (final (d, win, draw) in [(Difficulty.easy, 10, 5), (Difficulty.medium, 20, 10), (Difficulty.hard, 35, 15)]) {
        expect(_total(computeMatchPoints(c, _in(difficulty: d))), win);
        expect(_total(computeMatchPoints(c, _in(difficulty: d, draw: true, streak: 0))), draw);
      }
    });

    test('2nd place counts only with 3–4 players; otherwise participation', () {
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.hard, seats: 4, place: 2, streak: 0))), 12);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.hard, seats: 2, place: 2, streak: 0))), 4);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, seats: 4, place: 3, streak: 0))), 2);
    });

    test('people only play the Medium column; one-player failure is participation', () {
      expect(_total(computeMatchPoints(c, _in(difficulty: null, humans: 2))), 20);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, seats: 1, place: 2, streak: 0))), 2);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, seats: 1, place: 1))), 10);
    });

    test("the game's multiplier scales the base only, clamped to 0.5–2", () {
      expect(_total(computeMatchPoints(c, _in(multiplier: 1.5, stars: 2))), 30 + 4);
      expect(_total(computeMatchPoints(c, _in(multiplier: 5))), 40);
      expect(_total(computeMatchPoints(c, _in(multiplier: 0.1))), 10);
    });
  });

  group('bonuses', () {
    test('stars, first game of the day, new record and badges add up as separate lines', () {
      final lines = computeMatchPoints(
        c,
        _in(stars: 3, firstToday: true, record: true, badges: const [('first_win', 15), ('hard_win', 30)]),
      );
      expect([for (final l in lines) l.reason], [
        PointsReason.win,
        PointsReason.stars,
        PointsReason.firstToday,
        PointsReason.record,
        PointsReason.badge,
        PointsReason.badge,
      ]);
      expect(_total(lines), 20 + 6 + 5 + 5 + 15 + 30);
      expect(lines.last.badgeId, 'hard_win');
    });

    test('streak bonus only when the streak reaches exactly 3, 5 or 10', () {
      int streakPoints(int s) =>
          _total(computeMatchPoints(c, _in(streak: s)).where((l) => l.reason == PointsReason.streak).toList());
      expect([for (final s in [1, 2, 3, 4, 5, 6, 9, 10, 11]) streakPoints(s)], [0, 0, 5, 0, 10, 0, 0, 25, 0]);
    });

    test('losing never subtracts points', () {
      expect(computeMatchPoints(c, _in(place: 2, streak: 0)).every((l) => l.amount >= 0), isTrue);
    });
  });

  group('anti-farming (spec 5.6)', () {
    test('Easy, one person: the 11th win of the day in a game is worth 1 point in total', () {
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, easyWinsBefore: 9, stars: 3))), 10 + 6);
      final capped = computeMatchPoints(c, _in(difficulty: Difficulty.easy, easyWinsBefore: 10, stars: 3, firstToday: true));
      expect(_total(capped), 1);
      expect(capped.single.reason, PointsReason.capped);
    });

    test('badge rewards are still paid after the cap', () {
      final capped = computeMatchPoints(c, _in(difficulty: Difficulty.easy, easyWinsBefore: 12, badges: const [('streak5', 30)]));
      expect(_total(capped), 1 + 30);
    });

    test('no cap with two or more people, on Medium, or for a loss', () {
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, humans: 2, easyWinsBefore: 20))), 10);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.medium, easyWinsBefore: 20))), 20);
      expect(_total(computeMatchPoints(c, _in(difficulty: Difficulty.easy, place: 2, streak: 0, easyWinsBefore: 20))), 2);
    });
  });
}
