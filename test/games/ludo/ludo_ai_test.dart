import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/ludo/ludo_ai.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ludo_test_utils.dart';

const ai = LudoAi();

Move choose(LudoState s, Difficulty d, [int seed = 1]) => ai.chooseMove(s, s.current, d, SeededRandom(seed));

/// Plays one game where seat i uses [difficulties][i]; returns the final state.
LudoState playGame(List<Difficulty> difficulties, int seed, {Map<String, Object?> options = const {}}) {
  var s = rules.initialState(ludoConfig(players: difficulties.length, options: options), seed);
  final random = SeededRandom(seed * 7 + 1);
  for (var i = 0; i < 20000 && !rules.isOver(s); i++) {
    final seat = rules.currentSeat(s)!;
    final move = ai.chooseMove(s, seat, difficulties[seat], SeededRandom(random.nextInt(1 << 30)));
    if (!rules.isLegal(s, move) || !rules.legalMoves(s, seat).contains(move)) {
      fail('illegal move $move in game $seed');
    }
    s = rules.apply(s, move);
  }
  expect(rules.isOver(s), isTrue, reason: 'game $seed ends');
  return s;
}

void main() {
  test('every robot rolls when it is time to roll', () {
    final s = position([[base], [base]]);
    for (final d in Difficulty.values) {
      expect(choose(s, d), roll(s));
    }
  });

  group('Střední follows priorities', () {
    test('capture first', () {
      final s = rolled(position([[5, 0], [28]]), 3);
      expect(choose(s, Difficulty.medium), pick(s, 0));
    });

    test('enters a piece only when nothing else moves (three tries make waiting cheap)', () {
      final s = rolled(position([[base, 10], [base]]), 6);
      expect(choose(s, Difficulty.medium), pick(s, 1));
      final stuck = rolled(position([[base, 38], [base]]), 6);
      expect(choose(stuck, Difficulty.medium), pick(stuck, 0));
    });

    test('then go into the home', () {
      final s = rolled(position([[3, 37], [base]]), 4);
      expect(choose(s, Difficulty.medium), pick(s, 1));
    });

    test('then run away from a threat', () {
      // Seat 1 (corner 2) at 26 = field 6, two behind seat 0's piece on field 8.
      final s = rolled(position([[2, 8], [26]]), 5);
      expect(choose(s, Difficulty.medium), pick(s, 1));
    });

    test('else move the foremost piece that stays safe', () {
      final s = rolled(position([[12, 3], [base]]), 2);
      expect(choose(s, Difficulty.medium), pick(s, 0));
      // Seat 1 at rel 35 = field 15: piece 0 would land 1 in front of it.
      final risky = rolled(position([[12, 3], [35]]), 4);
      expect(choose(risky, Difficulty.medium), pick(risky, 1));
    });
  });

  group('Těžká', () {
    test('captures a piece that is far along', () {
      final s = rolled(position([[5, 0], [28]]), 3);
      expect(choose(s, Difficulty.hard), pick(s, 0));
    });

    test('does not step right in front of a rival when it can wait', () {
      // Moving piece 0 from 0 to 4 lands 1 ahead of seat 1's piece on field 3
      // (rel 23); piece 1 moves on safely far ahead.
      final s = rolled(position([[0, 20], [23]]), 4);
      expect(choose(s, Difficulty.hard), pick(s, 1));
    });

    test('counts threats only where rivals can really land', () {
      final s = position([[1], [39]]);
      // Seat 1 at rel 39 goes home, never onto field 1.
      expect(LudoAi.threats(s, 0, 1), 0);
      expect(LudoAi.threats(position([[3], [21]]), 0, 3), 1);
      // A rival in its corner threatens its own start field.
      expect(LudoAi.threats(position([[20], [base]]), 0, 20), 1);
    });
  });

  test('100 games on each difficulty without an illegal move (4 players, all options)', () {
    for (final d in Difficulty.values) {
      for (var seed = 0; seed < 100; seed++) {
        final options = {
          'length': seed.isEven ? 'full' : 'short',
          'mustCapture': seed % 3 == 0,
          'threeTries': seed % 4 != 0,
          'playOut': seed % 5 == 0,
        };
        playGame(List.filled(seed % 3 + 2, d), seed, options: options);
      }
    }
  });

  test('Těžká beats Lehká in at least 60 % of games', () {
    var wins = 0;
    const games = 200;
    for (var seed = 0; seed < games; seed++) {
      // Alternate who starts.
      final hardSeat = seed % 2;
      final s = playGame(hardSeat == 0 ? [Difficulty.hard, Difficulty.easy] : [Difficulty.easy, Difficulty.hard], seed);
      if (s.finished.first == hardSeat) wins++;
    }
    // ignore: avoid_print
    print('Těžká vs Lehká: $wins / $games');
    expect(wins / games, greaterThanOrEqualTo(0.6));
  });

  test('Střední beats Lehká more often than not', () {
    var wins = 0;
    const games = 300;
    for (var seed = 0; seed < games; seed++) {
      final mediumSeat = seed % 2;
      final s = playGame(
        mediumSeat == 0 ? [Difficulty.medium, Difficulty.easy] : [Difficulty.easy, Difficulty.medium],
        1000 + seed,
      );
      if (s.finished.first == mediumSeat) wins++;
    }
    // ignore: avoid_print
    print('Střední vs Lehká: $wins / $games');
    expect(wins / games, greaterThanOrEqualTo(0.5));
  });

  test('Těžká beats Střední more often than not', () {
    var wins = 0;
    const games = 200;
    for (var seed = 0; seed < games; seed++) {
      final hardSeat = seed % 2;
      final s = playGame(
        hardSeat == 0 ? [Difficulty.hard, Difficulty.medium] : [Difficulty.medium, Difficulty.hard],
        2000 + seed,
      );
      if (s.finished.first == hardSeat) wins++;
    }
    // ignore: avoid_print
    print('Těžká vs Střední: $wins / $games');
    expect(wins / games, greaterThan(0.5));
  });

  test('a seat of robots gives a valid game config', () {
    expect(ludoConfig(players: 2, robots: 1).seats.last, isA<RobotSeat>());
  });
}
