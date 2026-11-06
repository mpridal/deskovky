import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/matches/matches_ai.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MatchesRules();
const ai = MatchesAi();

GameConfig config(String start) => GameConfig(
  gameId: 'matches',
  seats: const [RobotSeat(), RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'start': start},
);

MatchesState at(List<int> rows, {int seat = 0}) => MatchesState(rows: rows, starter: seat, history: const []);

List<int> after(List<int> rows, Move move) => List.of(rows)..[move.data['row']! as int] -= move.data['count']! as int;

/// A player: a difficulty of the robot, or null for random legal moves.
typedef Player = Difficulty?;

/// Plays one game; returns the winner.
int duel(List<Player> players, int seed, {String start = MatchesStart.random}) {
  var s = rules.initialState(config(start), seed);
  final random = SeededRandom(seed);
  while (!rules.isOver(s)) {
    final seat = rules.currentSeat(s)!;
    final player = players[seat];
    final legal = rules.legalMoves(s, seat);
    final move = player == null
        ? legal[random.nextInt(legal.length)]
        : ai.chooseMove(s, seat, player, SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: 'seed $seed: $move is illegal');
    s = rules.apply(s, move);
  }
  return s.winner!;
}

/// Every position up to 3-5-7 with at least one match.
Iterable<List<int>> positions() sync* {
  for (var a = 0; a <= 3; a++) {
    for (var b = 0; b <= 5; b++) {
      for (var c = 0; c <= 7; c++) {
        if (a + b + c > 0) yield [a, b, c];
      }
    }
  }
}

void main() {
  test('hard moves from every winning position up to 3-5-7 into a losing one for the other player', () {
    var checked = 0;
    for (final rows in positions()) {
      if (!MatchesRules.winning(rows)) continue;
      for (var seed = 0; seed < 3; seed++) {
        final move = ai.chooseMove(at(rows), 0, Difficulty.hard, SeededRandom(seed));
        expect(rules.isLegal(at(rows), move), isTrue);
        expect(MatchesRules.winning(after(rows, move)), isFalse, reason: '$rows → $move');
      }
      checked++;
    }
    expect(checked, greaterThan(100));
  });

  test('hard in a losing position takes one match from the longest row', () {
    for (final rows in positions()) {
      if (MatchesRules.winning(rows)) continue;
      final move = ai.chooseMove(at(rows), 0, Difficulty.hard, SeededRandom(1));
      expect(move.data['count'], 1, reason: '$rows');
      expect(rows[move.data['row']! as int], rows.reduce((a, b) => a > b ? a : b), reason: '$rows');
    }
  });

  test('hard starting always wins – against easy, medium, hard and random moves', () {
    for (final other in <Player>[Difficulty.easy, Difficulty.medium, Difficulty.hard, null]) {
      for (var seed = 0; seed < 100; seed++) {
        expect(duel([Difficulty.hard, other], seed, start: MatchesStart.first), 0, reason: '$other seed $seed');
      }
    }
  });

  test('hard beats easy in at least 80 % of games with a random start', () {
    var wins = 0;
    for (var seed = 0; seed < 200; seed++) {
      final hardSeat = seed % 2;
      final winner = duel(hardSeat == 0 ? [Difficulty.hard, Difficulty.easy] : [Difficulty.easy, Difficulty.hard], seed);
      if (winner == hardSeat) wins++;
    }
    expect(wins / 200, greaterThanOrEqualTo(0.8), reason: '$wins of 200');
  });

  test('medium beats easy more often than not; easy and medium still lose to hard sometimes as the starter', () {
    var mediumWins = 0;
    for (var seed = 0; seed < 200; seed++) {
      final mediumSeat = seed % 2;
      if (duel(mediumSeat == 0 ? [Difficulty.medium, Difficulty.easy] : [Difficulty.easy, Difficulty.medium], seed) ==
          mediumSeat) {
        mediumWins++;
      }
    }
    expect(mediumWins, greaterThan(100), reason: '$mediumWins of 200');
    var easyStarterWins = 0;
    for (var seed = 0; seed < 100; seed++) {
      if (duel([Difficulty.easy, Difficulty.hard], seed, start: MatchesStart.first) == 0) easyStarterWins++;
    }
    expect(easyStarterWins, lessThan(100), reason: 'easy makes mistakes');
  });

  test('a random player (a child) beats easy now and then', () {
    var childWins = 0;
    for (var seed = 0; seed < 200; seed++) {
      final childSeat = seed % 2;
      if (duel(childSeat == 0 ? [null, Difficulty.easy] : [Difficulty.easy, null], seed) == childSeat) childWins++;
    }
    expect(childWins, greaterThan(40), reason: '$childWins of 200');
  });

  test('easy never takes the last match when it has another choice', () {
    for (final rows in positions()) {
      for (var seed = 0; seed < 20; seed++) {
        final move = ai.chooseMove(at(rows), 0, Difficulty.easy, SeededRandom(seed));
        expect(rules.isLegal(at(rows), move), isTrue);
        final left = after(rows, move).fold(0, (a, b) => a + b);
        if (rows.fold(0, (a, b) => a + b) > 1) expect(left, greaterThan(0), reason: '$rows seed $seed');
      }
    }
  });

  test('medium plays perfectly with three matches or fewer left', () {
    for (final rows in positions()) {
      if (rows.fold(0, (a, b) => a + b) > 3 || !MatchesRules.winning(rows)) continue;
      for (var seed = 0; seed < 20; seed++) {
        final move = ai.chooseMove(at(rows), 0, Difficulty.medium, SeededRandom(seed));
        expect(MatchesRules.winning(after(rows, move)), isFalse, reason: '$rows seed $seed');
      }
    }
  });

  test('perfect moves: about 60 % on medium and 25 % on easy in winning positions', () {
    double rate(Difficulty d) {
      var perfect = 0, all = 0;
      for (final rows in positions()) {
        if (rows.fold(0, (a, b) => a + b) <= 3 || !MatchesRules.winning(rows)) continue;
        for (var seed = 0; seed < 30; seed++) {
          final move = ai.chooseMove(at(rows), 0, d, SeededRandom(seed));
          all++;
          if (!MatchesRules.winning(after(rows, move))) perfect++;
        }
      }
      return perfect / all;
    }

    // A random move is sometimes perfect too, so the rates are a little higher.
    expect(rate(Difficulty.medium), inInclusiveRange(0.55, 0.75));
    expect(rate(Difficulty.easy), inInclusiveRange(0.2, 0.45));
  });

  test('the same random seed gives the same move (replay)', () {
    for (final d in Difficulty.values) {
      final s = at([3, 5, 7]);
      expect(ai.chooseMove(s, 0, d, SeededRandom(42)), ai.chooseMove(s, 0, d, SeededRandom(42)));
    }
  });
}
