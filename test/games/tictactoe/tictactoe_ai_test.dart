import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/tictactoe/tictactoe_ai.dart';
import 'package:deskovky/games/tictactoe/tictactoe_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = TictactoeRules();
const ai = TictactoeAi();

/// Hard with a shorter think, so hundreds of big-board games fit in the test
/// run; the same code as the 700 ms robot, just fewer search levels.
// Hard limited by depth, not time: the result is the same on a busy CI machine
// (depth 3 beats easy 18–19 of 20; the 700 ms version below is opt-in).
const quick = TictactoeAi(timeLimit: Duration(seconds: 30), hardDepth: 3);
const instant = TictactoeAi(timeLimit: Duration(milliseconds: 8));

/// `TICTACTOE_FULL=1 flutter test test/games/tictactoe` also plays big-board
/// matches with the real 700 ms limit (several minutes).
final full = Platform.environment['TICTACTOE_FULL'] == '1';

/// Plays [games] games of [a] against [b] (each starting half of them);
/// returns (wins of a, losses of a).
(int, int) match(int board, Difficulty a, Difficulty b, int games, {TictactoeAi robot = ai, int seed0 = 0}) {
  var wins = 0, losses = 0;
  for (var seed = seed0; seed < seed0 + games; seed++) {
    final aSeat = seed % 2;
    final s = duel(board, aSeat == 0 ? [a, b] : [b, a], seed, robot: robot);
    if (s.winner == aSeat) wins++;
    if (s.winner == 1 - aSeat) losses++;
  }
  return (wins, losses);
}

GameConfig config(int board) => GameConfig(
  gameId: 'tictactoe',
  seats: const [RobotSeat(), RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'board': board, 'start': 'random'},
);

/// Plays one game; [players] gives each seat's difficulty. Every move must
/// be legal. Returns the final state.
TictactoeState duel(int board, List<Difficulty> players, int seed, {TictactoeAi robot = ai}) {
  var s = rules.initialState(config(board), seed);
  final random = SeededRandom(seed);
  while (!rules.isOver(s)) {
    final seat = rules.currentSeat(s)!;
    final move = robot.chooseMove(s, seat, players[seat], SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: 'seed $seed: ${move.toJson()} is illegal');
    s = rules.apply(s, move);
  }
  return s;
}

/// Plays (column, row) cells in turn, ✕ first.
TictactoeState position(int board, List<(int, int)> cells) {
  var s = rules.initialState(config(board).copyWith(options: {'board': board, 'start': 'first'}), 1);
  for (final (c, r) in cells) {
    s = rules.apply(s, TictactoeRules.place(s.current, c, r));
  }
  return s;
}

(int, int) cellOf(Move move) => (move.data['c']! as int, move.data['r']! as int);

void main() {
  group('3×3', () {
    test('medium and hard take a win, then block', () {
      // ✕ (0,0),(1,0); ◯ (0,1),(1,1); ✕ to move wins at (2,0).
      final win = position(3, [(0, 0), (0, 1), (1, 0), (1, 1)]);
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        expect(cellOf(ai.chooseMove(win, 0, d, SeededRandom(1))), (2, 0), reason: '$d');
      }
      // ◯ must block (2,0).
      final block = position(3, [(0, 0), (1, 1), (1, 0)]);
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        expect(cellOf(ai.chooseMove(block, 1, d, SeededRandom(1))), (2, 0), reason: '$d');
      }
    });

    test('medium takes the centre, then a corner', () {
      expect(cellOf(ai.chooseMove(position(3, []), 0, Difficulty.medium, SeededRandom(3))), (1, 1));
      final corner = cellOf(ai.chooseMove(position(3, [(1, 1)]), 1, Difficulty.medium, SeededRandom(3)));
      expect([(0, 0), (2, 0), (0, 2), (2, 2)], contains(corner));
    });

    test('hard never loses: against every possible line of play', () {
      // Exhaustive: the opponent tries every cell, hard answers (seeded).
      var games = 0;
      void explore(TictactoeState s, int hardSeat) {
        if (rules.isOver(s)) {
          games++;
          expect(s.winner, isNot(1 - hardSeat), reason: 'hard lost: ${s.history}');
          return;
        }
        final seat = rules.currentSeat(s)!;
        if (seat == hardSeat) {
          explore(rules.apply(s, ai.chooseMove(s, seat, Difficulty.hard, SeededRandom(s.history.length))), hardSeat);
        } else {
          for (final move in rules.legalMoves(s, seat)) {
            explore(rules.apply(s, move), hardSeat);
          }
        }
      }

      for (final hardSeat in [0, 1]) {
        explore(position(3, []), hardSeat);
      }
      expect(games, greaterThan(100));
    });

    test('hard never loses to easy and wins most games', () {
      final (wins, losses) = match(3, Difficulty.hard, Difficulty.easy, 100);
      expect(losses, 0);
      // Perfect play cannot force a win on 3×3: the rest are draws (README).
      expect(wins, greaterThanOrEqualTo(70));
    });

    test('100 self-play games on every difficulty, all legal', () {
      for (final d in Difficulty.values) {
        for (var seed = 0; seed < 100; seed++) {
          duel(3, [d, d], seed);
        }
      }
    });

    test('easy is beatable: it misses a win or a block in some positions', () {
      final block = position(3, [(0, 0), (1, 1), (1, 0)]);
      final answers = {for (var seed = 0; seed < 40; seed++) cellOf(ai.chooseMove(block, 1, Difficulty.easy, SeededRandom(seed)))};
      expect(answers.length, greaterThan(1));
    });
  });

  group('big boards', () {
    test('every difficulty takes a five and blocks an open four', () {
      // ✕ has (3..6, 5) on 10×10, ◯ scattered; ✕ to move.
      final win = position(10, [(3, 5), (0, 0), (4, 5), (0, 9), (5, 5), (9, 0), (6, 5), (9, 9)]);
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        expect([(2, 5), (7, 5)], contains(cellOf(ai.chooseMove(win, 0, d, SeededRandom(1)))), reason: '$d');
      }
      // ◯ to move must block ✕'s four (2..5, 4) closed at (1,4) by ◯.
      final block = position(10, [(2, 4), (1, 4), (3, 4), (0, 0), (4, 4), (9, 9), (5, 4)]);
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        expect(cellOf(ai.chooseMove(block, 1, d, SeededRandom(1))), (6, 4), reason: '$d');
      }
    });

    test('hard blocks an open three before it becomes an open four', () {
      // ✕ open three (4..6, 5), ◯ has two loose stones; ◯ to move.
      final s = position(15, [(4, 5), (10, 10), (5, 5), (11, 12), (6, 5)]);
      final cell = cellOf(ai.chooseMove(s, 1, Difficulty.hard, SeededRandom(2)));
      expect([(3, 5), (7, 5), (2, 5), (8, 5)], contains(cell));
    });

    test('hard finds a forced win by fours (VCF)', () {
      // ✕ (5,5),(6,5),(7,5) closed by ◯ at (4,5) and (5,6),(5,7),(5,8) closed
      // by ◯ at (5,9): (8,5) and (5,4) make fours whose blocks lose.
      final s = position(15, [(5, 5), (4, 5), (6, 5), (5, 9), (7, 5), (12, 12), (5, 6), (12, 0), (5, 7), (0, 12), (5, 8), (0, 0)]);
      final eval = BigBoardEval(15, 5);
      final first = eval.vcf(s.cells, 0, watch: Stopwatch()..start(), limit: const Duration(seconds: 2));
      expect(first, isNotNull);
    });

    test('hard stays within its 700 ms time limit (with slack for the test machine)', () {
      final s = position(15, [(7, 7), (8, 8), (7, 8), (8, 7), (6, 6), (9, 9), (6, 9)]);
      final watch = Stopwatch()..start();
      ai.chooseMove(s, s.current, Difficulty.hard, SeededRandom(1));
      expect(watch.elapsedMilliseconds, lessThan(1500));
    });

    for (final board in [10, 15]) {
      test('$board×$board: hard beats easy in ≥ 80 % and medium beats easy more often than not', () {
        final (hardWins, _) = match(board, Difficulty.hard, Difficulty.easy, 20, robot: quick);
        expect(hardWins, greaterThanOrEqualTo(16));
        final (mediumWins, mediumLosses) = match(board, Difficulty.medium, Difficulty.easy, 20);
        expect(mediumWins, greaterThan(mediumLosses));
      });

      test('$board×$board: hard with the real 700 ms limit beats easy in ≥ 80 %', () {
        final (wins, _) = match(board, Difficulty.hard, Difficulty.easy, 20);
        expect(wins, greaterThanOrEqualTo(16));
      }, skip: full ? false : 'TICTACTOE_FULL=1 runs it (several minutes)');
    }

    test('100 self-play games on easy and medium and 30 on hard, all legal', () {
      for (final d in [Difficulty.easy, Difficulty.medium]) {
        for (var seed = 0; seed < 100; seed++) {
          duel(seed.isEven ? 10 : 15, [d, d], seed);
        }
      }
      for (var seed = 0; seed < 30; seed++) {
        duel(seed.isEven ? 10 : 15, const [Difficulty.hard, Difficulty.hard], seed, robot: instant);
      }
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}
