import 'dart:convert';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/tictactoe/tictactoe_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = TictactoeRules();

GameConfig config({int board = 3, String start = 'first', bool confirm = false, bool robot = false}) => GameConfig(
  gameId: 'tictactoe',
  seats: [const HumanSeat(1), robot ? const RobotSeat() : const HumanSeat(2)],
  difficulty: Difficulty.hard,
  robotSpeed: RobotSpeed.fast,
  options: {'board': board, 'start': start, 'confirm': confirm},
);

/// Plays (column, row) cells in turn from a fresh game.
TictactoeState play(List<(int, int)> cells, {int board = 3, String start = 'first'}) {
  var s = rules.initialState(config(board: board, start: start), 1);
  for (final (c, r) in cells) {
    final move = TictactoeRules.place(s.current, c, r);
    expect(rules.isLegal(s, move), isTrue, reason: '($c, $r)');
    s = rules.apply(s, move);
  }
  return s;
}

void main() {
  group('start', () {
    test('board sizes and row lengths; unknown size falls back to 3×3', () {
      for (final (board, target) in [(3, 3), (10, 5), (15, 5)]) {
        final s = rules.initialState(config(board: board), 1);
        expect(s.size, board);
        expect(s.target, target);
        expect(s.cells, hasLength(board * board));
        expect(s.cells.every((c) => c == -1), isTrue);
      }
      expect(rules.initialState(config(board: 7), 1).size, 3);
    });

    test('"always player 1" starts with ✕ (seat 0)', () {
      for (var seed = 0; seed < 20; seed++) {
        final s = rules.initialState(config(), seed);
        expect(rules.currentSeat(s), 0);
      }
    });

    test('random and alternate start differ by seed but are deterministic', () {
      for (final start in [TictactoeStart.random, TictactoeStart.alternate]) {
        final starters = {for (var seed = 0; seed < 40; seed++) rules.initialState(config(start: start), seed).starter};
        expect(starters, {0, 1}, reason: start);
        expect(rules.initialState(config(start: start), 5).starter, rules.initialState(config(start: start), 5).starter);
      }
    });

    test('remembers robots, difficulty and the confirm option', () {
      final s = rules.initialState(config(robot: true, confirm: true), 1);
      expect(s.robots, [false, true]);
      expect(s.difficulty, 'hard');
      expect(s.confirm, isTrue);
      expect(rules.initialState(config(), 1).difficulty, isNull);
    });
  });

  group('moves', () {
    test('every empty cell is legal for the seat to move, nothing for the other', () {
      final s = play([(1, 1)]);
      expect(rules.legalMoves(s, 1), hasLength(8));
      expect(rules.legalMoves(s, 0), isEmpty);
      expect(rules.legalMoves(s, 1), isNot(contains(TictactoeRules.place(1, 1, 1))));
    });

    test('taken cells, wrong seat, out of board and bad data are illegal', () {
      final s = play([(1, 1)]);
      expect(rules.isLegal(s, TictactoeRules.place(1, 1, 1)), isFalse);
      expect(rules.isLegal(s, TictactoeRules.place(0, 0, 0)), isFalse);
      expect(rules.isLegal(s, TictactoeRules.place(1, 3, 0)), isFalse);
      expect(rules.isLegal(s, TictactoeRules.place(1, -1, 0)), isFalse);
      expect(rules.isLegal(s, const Move(seat: 1, type: 'place', data: {'c': '0', 'r': 0})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 1, type: 'pass')), isFalse);
      expect(rules.isLegal(s, TictactoeRules.place(1, 0, 0)), isTrue);
    });

    test('seats alternate and the HUD score counts own stones', () {
      final s = play([(0, 0), (1, 1), (2, 2)]);
      expect(s.current, 1);
      expect(rules.score(s, 0), 2);
      expect(rules.score(s, 1), 1);
      expect(s.cell(1, 1), 1);
      expect(s.lastCell, 8);
    });
  });

  group('3×3', () {
    test('three across, down and on both diagonals win', () {
      final rows = {
        'across': [(0, 1), (0, 0), (1, 1), (1, 0), (2, 1)],
        'down': [(2, 0), (0, 0), (2, 1), (1, 0), (2, 2)],
        'diagonal': [(0, 0), (1, 0), (1, 1), (2, 0), (2, 2)],
        'anti-diagonal': [(2, 0), (1, 0), (1, 1), (0, 1), (0, 2)],
      };
      for (final MapEntry(key: name, value: cells) in rows.entries) {
        final s = play(cells);
        expect(s.winner, 0, reason: name);
        expect(rules.isOver(s), isTrue);
        expect(rules.currentSeat(s), isNull);
        expect(s.line, hasLength(3), reason: name);
        expect(s.line, contains(s.lastCell));
        expect(rules.legalMoves(s, 1), isEmpty);
      }
    });

    test('the second player can win too', () {
      final s = play([(0, 0), (1, 0), (2, 2), (1, 1), (0, 2), (1, 2)]);
      expect(s.winner, 1);
      expect(s.line, [1, 4, 7]);
      expect(rules.result(s).places, [2, 1]);
    });

    test('a full board without a row is a draw with two stars each', () {
      final s = play([(0, 0), (1, 1), (2, 2), (0, 1), (2, 1), (2, 0), (0, 2), (1, 2), (1, 0)]);
      expect(s.winner, isNull);
      expect(s.full, isTrue);
      expect(rules.isOver(s), isTrue);
      final result = rules.result(s);
      expect(result.places, [1, 1]);
      expect(result.stars, [2, 2]);
    });

    test('a win on the last cell is a win, not a draw', () {
      final s = play([(1, 0), (0, 0), (2, 0), (2, 1), (1, 1), (0, 2), (0, 1), (2, 2), (1, 2)]);
      expect(s.full, isTrue);
      expect(s.winner, 0);
    });

    test('stars: win 3, loss 1 only after blocking a row at least once', () {
      // ✕ wins; ◯ never blocked anything.
      final quick = play([(0, 0), (0, 1), (1, 0), (1, 1), (2, 0)]);
      expect(rules.result(quick).stars, [3, 0]);
      // ◯ blocks twice, ✕'s fork still wins.
      final blocked = play([(0, 0), (1, 0), (1, 1), (2, 2), (0, 1), (0, 2), (2, 1)]);
      expect(blocked.blocks, [0, 2]);
      expect(blocked.winner, 0);
      expect(rules.result(blocked).stars, [3, 1]);
    });
  });

  group('big boards', () {
    test('five in a row wins on 10×10 and on 15×15, four does not', () {
      for (final board in [10, 15]) {
        final four = play([(0, 0), (0, 5), (1, 0), (1, 5), (2, 0), (2, 5), (3, 0)], board: board);
        expect(four.winner, isNull);
        final five = play([(0, 0), (0, 5), (1, 0), (1, 5), (2, 0), (2, 5), (3, 0), (3, 5), (4, 0)], board: board);
        expect(five.winner, 0, reason: '$board');
        expect(five.line, [0, 1, 2, 3, 4]);
      }
    });

    test('six or more also wins ("5 a více") and the whole row is crossed out', () {
      // ✕ has 0–2 and 4–6 on row 0; filling 3 makes seven.
      final s = play([
        (0, 0), (0, 9), (1, 0), (1, 9), (2, 0), (2, 9), (4, 0), (9, 2), (5, 0), (9, 3), (6, 0), (9, 4), (3, 0), //
      ], board: 10);
      expect(s.winner, 0);
      expect(s.line, [0, 1, 2, 3, 4, 5, 6]);
    });

    test('diagonals near the edge of a 15×15 board', () {
      final s = play([(10, 14), (0, 0), (11, 13), (0, 1), (12, 12), (0, 2), (13, 11), (0, 3), (14, 10)], board: 15);
      expect(s.winner, 0);
      expect(s.line, hasLength(5));
    });

    test('stars: win within 20 own stones 3, later 2; loss after 25 moves 1, sooner 0', () {
      final quick = play([(0, 0), (0, 5), (1, 0), (1, 5), (2, 0), (2, 5), (3, 0), (3, 5), (4, 0)], board: 10);
      expect(rules.result(quick).stars, [3, 0]);

      // 21 stones each in short broken rows, then ✕ makes five on column 9.
      List<(int, int)> rowsFrom(int first) => [
        for (var r = first; r < 10; r += 2)
          for (final c in [0, 1, 3, 4, 6, 7]) (c, r),
      ];
      final crosses = rowsFrom(0), noughts = rowsFrom(1);
      final moves = [
        for (var i = 0; i < 21; i++) ...[crosses[i], noughts[i]],
        for (var r = 0; r < 4; r++) ...[(9, r), (8, r)],
        (9, 4),
      ];
      final s = play(moves, board: 10);
      expect(s.winner, 0);
      expect(s.movesOf(0), greaterThan(20));
      expect(rules.result(s).stars, [2, 1]);
    });
  });

  test('JSON keeps the whole state; the hash input is stable', () {
    final s = play([(1, 1), (0, 0), (2, 2)], start: 'first');
    final json = jsonEncode(rules.stateToJson(s));
    final back = rules.stateFromJson(jsonDecode(json) as Map<String, Object?>);
    expect(jsonEncode(rules.stateToJson(back)), json);
    expect(back.cells, s.cells);
    expect(back.current, s.current);
  });
}
