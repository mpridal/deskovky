import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/minesweeper/minesweeper_ai.dart';
import 'package:deskovky/games/minesweeper/minesweeper_rules.dart';
import 'package:deskovky/games/minesweeper/minesweeper_solver.dart';
import 'package:deskovky/games/minesweeper/minesweeper_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const ai = MinesweeperAi();

/// Plays a whole Střídačka game with robots of [levels] (one per seat).
MinesweeperState playOut(List<Difficulty> levels, Difficulty board, int seed) {
  var s = rules.initialState(config(seats: levels.length, robots: levels.length - 1, difficulty: board), seed);
  final random = SeededRandom(seed);
  for (var i = 0; i < 2000 && !s.over; i++) {
    final seat = s.current;
    final move = ai.chooseMove(s, seat, levels[seat], SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: 'move $i $move');
    s = rules.apply(s, move);
  }
  expect(s.over, isTrue);
  return s;
}

void main() {
  group('solver', () {
    final solver = MinesweeperSolver(3, 3);
    const h = Seen.hidden;

    test('a number with as many hidden squares as mines: all mines; with its mines found: the rest safe', () {
      // 1 1 h / 1 1 h / h h h  – lower-left corner of a board? Use a full 3×3:
      // the middle 1 with one hidden neighbour proves it a mine.
      final view = [0, 0, 0, 0, 1, 1, 0, 1, h];
      final d = solver.deduce(view, 1);
      expect(d.mines, {8});
      expect(d.safe, isEmpty);
    });

    test('a 1-2 pair proves squares only the pair together shows', () {
      // Row of hidden squares above a 1 and a 2:  h h h / 1 2 1? Use 3×4.
      final s4 = MinesweeperSolver(3, 2);
      // top: h h h ; bottom: 1 2 1 – mines at 0 and 2.
      final view = [h, h, h, 1, 2, 1];
      final d = s4.deduce(view, 2);
      expect(d.mines, {0, 2});
      expect(d.safe, {1});
      final single = s4.deduce(view, 2, depth: SolverDepth.single);
      expect(single.isEmpty, isTrue, reason: 'one number at a time sees nothing here');
    });

    test('the total count of mines finishes the board', () {
      final view = [h, h, 0, 0, 0, 0, 0, 0, 0];
      // Nothing around says anything; the count of 0 mines makes both safe.
      expect(solver.deduce(view, 0).safe, {0, 1});
    });

    test('probabilities: proven squares 0 or 1, the rest between', () {
      final view = [h, h, h, h, 1, h, h, h, h];
      final p = solver.probabilities(view, 1, solver.deduce(view, 1));
      expect(p[4], 0);
      for (final c in [0, 1, 2, 3, 5, 6, 7, 8]) {
        expect(p[c], closeTo(1 / 8, 1e-9));
      }
    });

    test('a known board is solvable without guessing; a 50:50 board is not', () {
      final open = MinesweeperSolver(5, 5);
      expect(open.solvable({24}, 0), isTrue);
      // 4×2: the mine is at the top or the bottom right, both 1s see both.
      expect(MinesweeperSolver(4, 2).solvable({3}, 0), isFalse);
    });
  });

  group('AI', () {
    test('every difficulty plays 100 whole games with itself, legally, on all boards', () {
      for (final difficulty in Difficulty.values) {
        for (var game = 0; game < 100; game++) {
          final seats = 2 + game % 3;
          final board = Difficulty.values[game % 3];
          playOut(List.filled(seats, difficulty), board, game);
        }
      }
    });

    test('a robot never picks a square the solver proves to be a mine (medium, hard)', () {
      for (var seed = 0; seed < 30; seed++) {
        var s = rules.initialState(config(seats: 2, robots: 1, difficulty: Difficulty.medium), seed);
        s = rules.apply(s, reveal(5, 8));
        if (s.over) continue;
        final d = MinesweeperSolver(s.columns, s.rows).deduce(MinesweeperSolver.viewOf(s), s.mines.length);
        for (final difficulty in [Difficulty.medium, Difficulty.hard]) {
          final move = ai.chooseMove(s, s.current, difficulty, SeededRandom(seed));
          final cell = s.cellOf(move.data['c']! as int, move.data['r']! as int);
          expect(d.mines.contains(cell), isFalse);
          if (d.safe.isNotEmpty) expect(d.safe, contains(cell), reason: 'takes a sure square first');
        }
      }
    });

    test('a robot clears a flag somebody put on the square it wants', () {
      var s = play(board([(0, 0)], seats: 2), [reveal(1, 1)]);
      // Everything but the mine and (8,8) flagged: the robot must unflag first.
      for (var cell = 0; cell < s.cellCount; cell++) {
        if (!s.isRevealed(cell) && cell != 0) s = rules.apply(s, mark(cell % 9, cell ~/ 9, seat: 1));
      }
      final move = ai.chooseMove(s, 1, Difficulty.hard, SeededRandom(1));
      expect(rules.isLegal(s, move), isTrue);
    });

    test('hard beats easy in at least 60 % of games (spec 13.4, a game with chance)', () {
      var hardWins = 0;
      const games = 100;
      for (var game = 0; game < games; game++) {
        // Alternate who starts.
        final levels = game.isEven ? [Difficulty.hard, Difficulty.easy] : [Difficulty.easy, Difficulty.hard];
        final s = playOut(levels, Difficulty.medium, 1000 + game);
        final places = MinesweeperRules.placesOf(s);
        final hardSeat = game.isEven ? 0 : 1;
        if (places[hardSeat] == 1 && places[1 - hardSeat] == 2) hardWins++;
      }
      expect(hardWins, greaterThanOrEqualTo(60), reason: 'hard won $hardWins of $games');
    });
  });
}
