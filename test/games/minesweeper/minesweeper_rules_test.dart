import 'dart:convert';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/minesweeper/minesweeper_generator.dart';
import 'package:deskovky/games/minesweeper/minesweeper_rules.dart';
import 'package:deskovky/games/minesweeper/minesweeper_solver.dart';
import 'package:deskovky/games/minesweeper/minesweeper_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('board size = difficulty', () {
    for (final (difficulty, columns, rows, mines) in [
      (Difficulty.easy, 9, 9, 10),
      (Difficulty.medium, 12, 16, 30),
      (Difficulty.hard, 16, 24, 70),
    ]) {
      test('$difficulty: $columns×$rows with $mines mines, placed only after the first tap', () {
        final s = rules.initialState(config(difficulty: difficulty), 3);
        expect((s.columns, s.rows, s.level.mines), (columns, rows, mines));
        expect(s.mines, isEmpty);
        expect(s.started, isFalse);
        final after = rules.apply(s, reveal(2, 3));
        expect(after.mines, hasLength(mines));
        expect(after.mines.toSet(), hasLength(mines));
      });
    }

    test('options: question marks and the ⛏/🚩 switch are kept in the state', () {
      final s = rules.initialState(config(questionMarks: true, controls: 'switch'), 1);
      expect(s.questionMarks, isTrue);
      expect(s.switchControls, isTrue);
      final d = rules.initialState(config(), 1);
      expect(d.questionMarks, isFalse);
      expect(d.switchControls, isFalse);
    });
  });

  group('first tap', () {
    test('is always safe and opens an empty area, on every board and many seeds', () {
      for (final difficulty in Difficulty.values) {
        for (var seed = 0; seed < 15; seed++) {
          final s0 = rules.initialState(config(difficulty: difficulty), seed);
          final c = seed % s0.columns, r = (seed * 7) % s0.rows;
          final s = rules.apply(s0, reveal(c, r));
          final cell = s.cellOf(c, r);
          expect(s.exploded, isEmpty);
          expect(s.numbers[cell], 0, reason: 'the first square has no mine around');
          expect(s.revealedCount, greaterThan(1), reason: 'an empty area opens');
          expect(s.mineSet.intersection({cell, ...s.neighbours(cell)}), isEmpty);
        }
      }
    });

    test('the mines come from the seed: same seed and tap, same board; another seed, another board', () {
      final a = rules.apply(rules.initialState(config(), 42), reveal(4, 4));
      final b = rules.apply(rules.initialState(config(), 42), reveal(4, 4));
      final c = rules.apply(rules.initialState(config(), 43), reveal(4, 4));
      expect(a.mines, b.mines);
      expect(a.mines, isNot(c.mines));
    });

    test('easy and medium boards need no guessing (checked by the solver), hard is a common board', () {
      for (final level in MinesweeperLevel.values) {
        for (var seed = 0; seed < 20; seed++) {
          final start = level.columns ~/ 2 + (level.rows ~/ 2) * level.columns;
          final (mines, noGuess) = MinesweeperGenerator.generate(level, seed, start);
          expect(noGuess, level != MinesweeperLevel.hard, reason: '$level seed $seed');
          if (noGuess) {
            expect(MinesweeperSolver(level.columns, level.rows).solvable(mines.toSet(), start), isTrue);
          }
        }
      }
    });

    test('generating a board without guessing stays fast (spec 13.7: max. 300 ms)', () {
      final watch = Stopwatch()..start();
      for (var seed = 0; seed < 20; seed++) {
        MinesweeperGenerator.generate(MinesweeperLevel.medium, seed, 0);
      }
      // Desktop is several times faster than a phone; 20 boards in 300 ms
      // leaves room for one board on a slow phone.
      expect(watch.elapsedMilliseconds, lessThan(300));
    });
  });

  group('one player', () {
    test('uncovering a mine ends the game: place 2, no stars, the mine is the puff', () {
      final s = play(board([(0, 0), (8, 8)]), [reveal(1, 1), reveal(0, 0, t: 5000)]);
      expect(s.over, isTrue);
      expect(s.exploded, [0]);
      expect(rules.currentSeat(s), isNull);
      final result = rules.result(s);
      expect(result.places, [2]);
      expect(result.stars, [0]);
    });

    test('an empty area opens up to the numbers', () {
      final s = play(board([(0, 0)]), [reveal(8, 8)]);
      // Only the mine is hidden: everything else is connected to empty squares.
      expect(s.revealedCount, 80);
      expect(s.cleared, isTrue);
    });

    test('an empty area stops at flags and keeps them', () {
      var s = board([(0, 0)]);
      s = play(s, [mark(5, 5), reveal(8, 8)]);
      expect(s.isRevealed(s.cellOf(5, 5)), isFalse);
      expect(s.marks[s.cellOf(5, 5)], Mark.flag);
      expect(s.over, isFalse);
    });

    test('clearing the board wins; stars by the time sent in the move (60 s target on easy)', () {
      for (final (ms, stars) in [(20000, 3), (29999, 3), (30000, 2), (59999, 2), (60000, 1), (200000, 1)]) {
        final s = clearAll(play(board([(0, 0), (2, 0), (0, 2)]), [reveal(8, 8, t: ms)]), t: ms);
        expect(s.cleared, isTrue);
        expect(s.finishMs, ms);
        final result = rules.result(s);
        expect(result.places, [1]);
        expect(result.stars, [stars], reason: '$ms ms');
        expect(result.stats['timeMs'], ms);
      }
    });

    test('targets: medium 180 s, hard 480 s; without a time only one star', () {
      final medium = clearAll(board([(0, 0)], level: MinesweeperLevel.medium), t: 89000);
      expect(MinesweeperRules.soloStars(medium), 3);
      final hard = clearAll(board([(0, 0)], level: MinesweeperLevel.hard), t: 300000);
      expect(MinesweeperRules.soloStars(hard), 2);
      final untimed = clearAll(board([(0, 0)]));
      expect(MinesweeperRules.soloStars(untimed), 1);
    });

    test('the score is the number of uncovered squares', () {
      final s = play(board([(0, 0), (1, 0), (0, 1)]), [reveal(8, 8)]);
      expect(rules.score(s, 0), s.revealedCount);
    });
  });

  group('marks', () {
    test('a mark cycles flag → nothing; with question marks flag → ? → nothing', () {
      var s = board([(0, 0)]);
      final cell = s.cellOf(3, 3);
      s = rules.apply(s, mark(3, 3));
      expect(s.marks[cell], Mark.flag);
      s = rules.apply(s, mark(3, 3));
      expect(s.marks[cell], Mark.none);

      var q = board([(0, 0)], questionMarks: true);
      q = rules.apply(q, mark(3, 3));
      expect(q.marks[cell], Mark.flag);
      q = rules.apply(q, mark(3, 3));
      expect(q.marks[cell], Mark.question);
      q = rules.apply(q, mark(3, 3));
      expect(q.marks[cell], Mark.none);
      expect(q.flagsPlaced, 1);
    });

    test('a flag protects its square; a question mark does not', () {
      final flagged = play(board([(0, 0)]), [mark(0, 0)]);
      expect(rules.isLegal(flagged, reveal(0, 0)), isFalse);
      final questioned = play(board([(0, 0)], questionMarks: true), [mark(0, 0), mark(0, 0)]);
      expect(rules.isLegal(questioned, reveal(0, 0)), isTrue);
    });

    test('uncovered squares cannot be marked; marks do not pass the turn', () {
      final s = play(board([(0, 0)], seats: 2), [reveal(1, 1)]);
      expect(rules.isLegal(s, mark(1, 1, seat: 1)), isFalse);
      final m = rules.apply(s, mark(0, 0, seat: 1));
      expect(m.current, 1);
    });

    test('flags are counted for the badge "Bez vlajek"', () {
      final s = play(board([(0, 0)]), [mark(1, 1), mark(1, 1), mark(1, 1)]);
      expect(s.flagsPlaced, 2);
    });
  });

  group('chording', () {
    // Mines at (0,0) and (2,0): the 2 at (1,1) has both around it.
    MinesweeperState opened() {
      var s = board([(0, 0), (2, 0), (5, 5)]);
      return play(s, [reveal(1, 1)]);
    }

    test('tapping a number with all its flags uncovers the other squares around', () {
      var s = opened();
      expect(s.numbers[s.cellOf(1, 1)], 2);
      expect(rules.isLegal(s, chord(1, 1)), isFalse, reason: 'no flags yet');
      s = play(s, [mark(0, 0)]);
      expect(rules.isLegal(s, chord(1, 1)), isFalse, reason: 'one flag is missing');
      s = play(s, [mark(2, 0), chord(1, 1)]);
      for (final (c, r) in [(1, 0), (0, 1), (2, 1), (0, 2), (1, 2), (2, 2)]) {
        expect(s.isRevealed(s.cellOf(c, r)), isTrue, reason: '($c, $r)');
      }
      expect(s.exploded, isEmpty);
    });

    test('a wrong flag makes chording hit a mine', () {
      var s = opened();
      s = play(s, [mark(0, 0), mark(1, 0), chord(1, 1)]);
      expect(s.over, isTrue);
      expect(s.exploded, [s.cellOf(2, 0)]);
      expect(rules.result(s).places, [2]);
    });

    test('chording is not part of Střídačka (one square per turn)', () {
      var s = play(board([(0, 0), (2, 0), (5, 5)], seats: 2), [reveal(1, 1)]);
      s = play(s, [mark(0, 0, seat: 1), mark(2, 0, seat: 1)]);
      expect(rules.isLegal(s, chord(1, 1, seat: 1)), isFalse);
    });

    test('chording can win the game and records the time', () {
      var s = play(board([(0, 0)]), [reveal(1, 1), mark(0, 0), chord(1, 1, t: 10000)]);
      expect(s.cleared, isTrue);
      expect(s.finishMs, 10000);
      expect(rules.result(s).stars, [3]);
    });
  });

  group('Střídačka', () {
    test('players take turns, one square each', () {
      var s = board([(0, 0), (8, 8), (4, 4)], seats: 3);
      s = play(s, [reveal(1, 1, seat: 0)]);
      expect(s.current, 1);
      expect(rules.isLegal(s, reveal(3, 3, seat: 0)), isFalse, reason: 'not their turn');
      s = play(s, [reveal(3, 3, seat: 1)]);
      expect(s.current, 2);
      expect(rules.legalMoves(s, 0), isEmpty);
      expect(rules.legalMoves(s, 2), isNotEmpty);
    });

    test('whoever uncovers a mine is out, the game goes on, the next player skips them', () {
      var s = board([(0, 0), (8, 8), (4, 4)], seats: 3);
      s = play(s, [reveal(0, 0, seat: 0)]);
      expect(s.isOut(0), isTrue);
      expect(s.over, isFalse);
      expect(s.current, 1);
      s = play(s, [reveal(1, 1, seat: 1), reveal(3, 3, seat: 2)]);
      expect(s.current, 1, reason: 'seat 0 is out');
    });

    test('the last player left wins; those out rank by how long they lasted', () {
      var s = board([(0, 0), (8, 8), (4, 4)], seats: 3);
      s = play(s, [reveal(0, 0, seat: 0), reveal(8, 8, seat: 1)]);
      expect(s.over, isTrue);
      final result = rules.result(s);
      expect(result.places, [3, 2, 1]);
      expect(result.stars, [1, 2, 3]);
    });

    test('a cleared board: players still in rank by their squares, ties share a place', () {
      final s = clearAll(board([(0, 0), (8, 8), (4, 4)], seats: 2));
      expect(s.over, isTrue);
      final scores = [rules.score(s, 0), rules.score(s, 1)];
      expect(scores[0] + scores[1], 81 - 3);
      final places = rules.result(s).places;
      if (scores[0] == scores[1]) {
        expect(places, [1, 1]);
      } else {
        expect(places, scores[0] > scores[1] ? [1, 2] : [2, 1]);
      }
    });

    test('players out rank below those still in, even with more squares', () {
      final s = board([(0, 0)], seats: 3).copyWith(
        revealedBy: [for (var i = 0; i < 81; i++) i == 0 ? -1 : (i < 50 ? 0 : (i < 70 ? 1 : (i < 75 ? 2 : -1)))],
        exploded: [0],
        explodedBy: [0],
      );
      expect(MinesweeperRules.placesOf(s), [3, 1, 2]);
    });

    test('the mines left count does not include mines found in Střídačka', () {
      final s = play(board([(0, 0), (8, 8), (4, 4)], seats: 3), [reveal(0, 0, seat: 0)]);
      expect(s.exploded, hasLength(1));
      expect(MinesweeperSolver.viewOf(s)[0], Seen.mine);
    });
  });

  group('legal moves and validation', () {
    test('legal moves: reveal and mark on hidden squares, none for others or after the end', () {
      final s = rules.initialState(config(), 1);
      final moves = rules.legalMoves(s, 0);
      expect(moves.where((m) => m.type == MinesweeperMove.reveal), hasLength(81));
      expect(moves.where((m) => m.type == MinesweeperMove.mark), hasLength(81));
      for (final m in moves) {
        expect(rules.isLegal(s, m), isTrue, reason: '$m');
      }
      expect(rules.legalMoves(s, 1), isEmpty);
      final over = play(board([(0, 0)]), [reveal(0, 0)]);
      expect(rules.legalMoves(over, 0), isEmpty);
    });

    test('rejects squares off the board, unknown types and bad times', () {
      final s = rules.initialState(config(), 1);
      expect(rules.isLegal(s, reveal(9, 0)), isFalse);
      expect(rules.isLegal(s, reveal(-1, 0)), isFalse);
      expect(rules.isLegal(s, reveal(0, 0, seat: 1)), isFalse);
      expect(rules.isLegal(s, reveal(0, 0, t: -5)), isFalse);
      expect(rules.isLegal(s, reveal(0, 0).copyWithType('dig')), isFalse);
    });

    test('state survives JSON exactly', () {
      final opened = play(rules.initialState(config(seats: 3, questionMarks: true, controls: 'switch'), 9), [
        reveal(4, 4),
      ]);
      final mine = opened.mines.first;
      final s = play(opened, [mark(mine % 9, mine ~/ 9, seat: 1)]);
      final json = jsonEncode(rules.stateToJson(s));
      expect(jsonEncode(rules.stateToJson(rules.stateFromJson(jsonDecode(json) as Map<String, Object?>))), json);
    });
  });
}

extension on Move {
  Move copyWithType(String type) => Move(seat: seat, type: type, data: data);
}
