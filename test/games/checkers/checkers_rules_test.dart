import 'dart:convert';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/checkers/checkers_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'checkers_test_utils.dart';

void main() {
  group('start', () {
    test('Czech: 8×8, 12 men each on the dark squares, seat 0 at the bottom starts', () {
      final s = rules.initialState(config(), 1);
      expect(s.variant, CheckersVariant.czech);
      expect(s.size, 8);
      expect(s.count(0), 12);
      expect(s.count(1), 12);
      for (var i = 0; i < 64; i++) {
        final (c, r) = (i % 8, i ~/ 8);
        if (s.board[i] != CheckersPiece.empty) expect((c + r).isOdd, isTrue, reason: '($c, $r)');
        if (r <= 2 && (c + r).isOdd) expect(s.board[i], CheckersPiece.man(1));
        if (r >= 5 && (c + r).isOdd) expect(s.board[i], CheckersPiece.man(0));
      }
      expect(rules.currentSeat(s), 0);
      expect(rules.legalMoves(s, 0), hasLength(7));
      expect(rules.legalMoves(s, 1), isEmpty);
    });

    test('international: 10×10, 20 men each, 9 opening moves', () {
      final s = rules.initialState(config(variant: 'international'), 1);
      expect(s.variant, CheckersVariant.international);
      expect(s.size, 10);
      expect(s.count(0), 20);
      expect(s.count(1), 20);
      expect(rules.legalMoves(s, 0), hasLength(9));
    });

    test('unknown options fall back to the Czech rules', () {
      final c = config();
      final s = rules.initialState(c.copyWith(options: {'rules': 'chess'}), 1);
      expect(s.variant, CheckersVariant.czech);
      expect(s.undoOption, isTrue);
      expect(s.hint, isTrue);
    });
  });

  group('men', () {
    test('move one square diagonally forward only', () {
      final s = diagram(board({(3, 4): 'w', (0, 1): 'b'}));
      expect(paths(s), {p([(3, 4), (2, 3)]), p([(3, 4), (4, 3)])});
      final t = diagram(board({(3, 4): 'w', (0, 1): 'b'}), current: 1);
      expect(paths(t), {p([(0, 1), (1, 2)])});
    });

    test('capturing is compulsory', () {
      final s = diagram(board({(3, 4): 'w', (4, 3): 'b', (0, 7): 'w'}));
      expect(paths(s), {p([(3, 4), (5, 2)])});
      expect(rules.isLegal(s, go(s, [(0, 7), (1, 6)])), isFalse);
    });

    test('Czech men do not capture backwards, international men do', () {
      final cz = diagram(board({(3, 4): 'w', (4, 5): 'b'}));
      expect(paths(cz), {p([(3, 4), (2, 3)]), p([(3, 4), (4, 3)])});
      final intl = diagram(board({(3, 4): 'w', (4, 5): 'b'}, 10));
      expect(paths(intl), {p([(3, 4), (5, 6)])});
    });

    test('a multiple capture is finished – stopping half way is illegal', () {
      final s = diagram(board({(1, 6): 'w', (2, 5): 'b', (4, 3): 'b'}));
      expect(paths(s), {p([(1, 6), (3, 4), (5, 2)])});
      expect(rules.isLegal(s, go(s, [(1, 6), (3, 4)])), isFalse);
      final after = play(s, [(1, 6), (3, 4), (5, 2)]);
      expect(after.count(1), 0);
      expect(after.lastCaptured.toSet(), {sq(2, 5), sq(4, 3)});
    });

    test('Czech: any capture may be chosen, not only the longest', () {
      final s = diagram(board({(1, 6): 'w', (2, 5): 'b', (4, 3): 'b', (7, 4): 'w', (6, 3): 'b'}));
      expect(paths(s), {p([(1, 6), (3, 4), (5, 2)]), p([(7, 4), (5, 2)])});
    });

    test('international: the capture of the most pieces is compulsory', () {
      final s = diagram(board({(1, 8): 'w', (2, 7): 'b', (4, 5): 'b', (9, 6): 'w', (8, 5): 'b'}, 10));
      expect(paths(s), {p([(1, 8), (3, 6), (5, 4)])});
    });

    test('Czech: a man reaching the last row is crowned, also by a capture', () {
      final s = diagram(board({(2, 1): 'w', (7, 0): 'b'}));
      final a = play(s, [(2, 1), (3, 0)]);
      expect(a.board[sq(3, 0)], CheckersPiece.king(0));
      expect(a.lastPromoted, isTrue);
      expect(a.stats[0].promotions, 1);
      final t = diagram(board({(1, 2): 'w', (2, 1): 'b', (7, 0): 'b'}));
      final b = play(t, [(1, 2), (3, 0)]);
      expect(b.board[sq(3, 0)], CheckersPiece.king(0));
      final u = diagram(board({(1, 6): 'b', (7, 0): 'w'}), current: 1);
      expect(play(u, [(1, 6), (0, 7)]).board[sq(0, 7)], CheckersPiece.king(1));
    });

    test('international: crowned only when the move ends on the last row', () {
      final through = diagram(board({(1, 2): 'w', (2, 1): 'b', (4, 1): 'b', (9, 8): 'b'}, 10));
      expect(paths(through), {p([(1, 2), (3, 0), (5, 2)])});
      final a = play(through, [(1, 2), (3, 0), (5, 2)]);
      expect(a.board[sq(5, 2, 10)], CheckersPiece.man(0));
      expect(a.lastPromoted, isFalse);
      final ends = diagram(board({(1, 2): 'w', (2, 1): 'b', (9, 8): 'b'}, 10));
      expect(play(ends, [(1, 2), (3, 0)]).board[sq(3, 0, 10)], CheckersPiece.king(0));
    });
  });

  group('kings', () {
    test('fly any distance along the diagonals until blocked', () {
      final s = diagram(board({(3, 4): 'W', (0, 1): 'b'}));
      final all = paths(s);
      expect(all, hasLength(12));
      expect(all, contains(p([(3, 4), (7, 0)])));
      expect(all, contains(p([(3, 4), (0, 7)])));
      expect(all, isNot(contains(p([(3, 4), (0, 1)]))));
    });

    test('capture from a distance and land on any free square behind', () {
      final s = diagram(board({(0, 7): 'W', (3, 4): 'b'}));
      expect(paths(s), {p([(0, 7), (4, 3)]), p([(0, 7), (5, 2)]), p([(0, 7), (6, 1)]), p([(0, 7), (7, 0)])});
    });

    test('cannot jump two pieces in a row or their own', () {
      final s = diagram(board({(0, 7): 'W', (3, 4): 'b', (4, 3): 'b', (6, 7): 'w'}));
      expect(paths(s), {p([(0, 7), (1, 6)]), p([(0, 7), (2, 5)]), p([(6, 7), (5, 6)]), p([(6, 7), (7, 6)])});
    });

    test('Czech: when a king can capture, a king must capture', () {
      final s = diagram(board({(0, 7): 'W', (2, 5): 'b', (7, 6): 'w', (6, 5): 'b'}));
      expect(paths(s), {
        p([(0, 7), (3, 4)]),
        p([(0, 7), (4, 3)]),
        p([(0, 7), (5, 2)]),
        p([(0, 7), (6, 1)]),
        p([(0, 7), (7, 0)]),
      });
    });

    test('a king lands where it can capture on, and never jumps a piece twice (Turkish strike)', () {
      final s = diagram(board({(1, 4): 'W', (2, 3): 'b', (5, 2): 'b', (4, 5): 'b', (2, 5): 'b'}));
      expect(paths(s), {
        p([(1, 4), (4, 1), (6, 3), (3, 6), (1, 4)]),
        p([(1, 4), (4, 1), (6, 3), (3, 6), (0, 3)]),
        p([(1, 4), (3, 6), (6, 3), (4, 1), (1, 4)]),
        p([(1, 4), (3, 6), (6, 3), (4, 1), (0, 5)]),
      });
      final after = play(s, [(1, 4), (4, 1), (6, 3), (3, 6), (1, 4)]);
      expect(after.count(1), 0);
      expect(after.stats[0].bestCombo, 4);
      expect(after.stats[0].captures, 4);
      expect(after.winner, 0);
    });
  });

  group('end', () {
    test('capturing the last piece wins', () {
      final s = play(diagram(board({(3, 4): 'w', (4, 3): 'b'})), [(3, 4), (5, 2)]);
      expect(s.winner, 0);
      expect(s.end, CheckersEnd.pieces);
      expect(rules.isOver(s), isTrue);
      expect(rules.currentSeat(s), isNull);
      expect(rules.legalMoves(s, 1), isEmpty);
    });

    test('blocking every piece of the other side wins', () {
      final s = play(diagram(board({(0, 1): 'b', (1, 2): 'w', (3, 4): 'w'})), [(3, 4), (2, 3)]);
      expect(s.winner, 0);
      expect(s.end, CheckersEnd.blocked);
    });

    test('25 moves of each player only with kings and without capture is a draw', () {
      final s = diagram(board({(7, 6): 'W', (0, 1): 'B'}), quiet: 48);
      final a = play(s, [(7, 6), (6, 7)]);
      expect(a.quiet, 49);
      expect(rules.isOver(a), isFalse);
      final b = play(a, [(0, 1), (1, 0)]);
      expect(b.end, CheckersEnd.kings);
      expect(b.winner, isNull);
      expect(rules.isOver(b), isTrue);
    });

    test('a man move or a capture starts the count again', () {
      final s = diagram(board({(7, 6): 'W', (0, 1): 'B', (1, 6): 'w'}), quiet: 30);
      expect(play(s, [(1, 6), (0, 5)]).quiet, 0);
      expect(play(s, [(7, 6), (6, 7)]).quiet, 31);
    });

    test('the same position for the third time is a draw', () {
      var s = diagram(board({(7, 6): 'W', (0, 1): 'B'}));
      const there = [
        [(7, 6), (6, 7)],
        [(0, 1), (1, 0)],
        [(6, 7), (7, 6)],
        [(1, 0), (0, 1)],
      ];
      for (var i = 0; i < 7; i++) {
        s = play(s, there[i % 4]);
        expect(rules.isOver(s), isFalse, reason: 'ply $i');
      }
      s = play(s, there[3]);
      expect(s.end, CheckersEnd.repetition);
      expect(s.winner, isNull);
    });
  });

  group('draw offer', () {
    test('the other player accepts or declines it; declined, the offerer moves on', () {
      final s = rules.initialState(config(), 1);
      const offer = Move(seat: 0, type: CheckersRules.offer);
      expect(rules.isLegal(s, offer), isTrue);
      expect(rules.legalMoves(s, 0).where((m) => m.type == CheckersRules.offer), isEmpty, reason: 'robots never offer');
      final offered = rules.apply(s, offer);
      expect(offered.offerBy, 0);
      expect(rules.currentSeat(offered), 1);
      expect(rules.legalMoves(offered, 1), [
        const Move(seat: 1, type: CheckersRules.accept),
        const Move(seat: 1, type: CheckersRules.decline),
      ]);
      expect(rules.isLegal(offered, go(offered, [(0, 5), (1, 4)])), isFalse);
      expect(rules.isLegal(offered, CheckersRules.moveOf(1, [sq(1, 2), sq(0, 3)])), isFalse);

      final drawn = rules.apply(offered, const Move(seat: 1, type: CheckersRules.accept));
      expect(drawn.end, CheckersEnd.agreed);
      expect(rules.isOver(drawn), isTrue);
      expect(rules.result(drawn).places, [1, 1]);
      expect(rules.result(drawn).stars, [1, 1]);

      final declined = rules.apply(offered, const Move(seat: 1, type: CheckersRules.decline));
      expect(rules.currentSeat(declined), 0);
      expect(declined.offerBy, isNull);
      expect(rules.isLegal(declined, offer), isFalse, reason: 'not again before moving');
      final moved = play(declined, [(0, 5), (1, 4)]);
      final back = play(moved, [(1, 2), (0, 3)]);
      expect(rules.isLegal(back, offer), isTrue);
    });

    test('nobody can offer for the other seat, accept without an offer or offer after the end', () {
      final s = rules.initialState(config(), 1);
      expect(rules.isLegal(s, const Move(seat: 1, type: CheckersRules.offer)), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: CheckersRules.accept)), isFalse);
      final over = play(diagram(board({(3, 4): 'w', (4, 3): 'b'})), [(3, 4), (5, 2)]);
      expect(rules.isLegal(over, const Move(seat: 1, type: CheckersRules.offer)), isFalse);
    });
  });

  group('undo', () {
    CheckersState twoMoves(CheckersState s) {
      s = rules.apply(s, rules.legalMoves(s, s.current).first);
      return rules.apply(s, rules.legalMoves(s, s.current).last);
    }

    test('against an easy or medium robot takes back my move and its reply, at most 3×', () {
      for (final d in [Difficulty.easy, Difficulty.medium]) {
        final start = rules.initialState(config(robot: true, difficulty: d), 1);
        const undo = Move(seat: 0, type: CheckersRules.undo);
        expect(rules.isLegal(start, undo), isFalse, reason: 'nothing to take back');
        var s = start;
        for (var i = 0; i < 3; i++) {
          s = twoMoves(s);
          expect(rules.isLegal(s, undo), isTrue);
          expect(rules.legalMoves(s, 0).where((m) => m.type == CheckersRules.undo), isEmpty);
          s = rules.apply(s, undo);
          expect(s.board, start.board);
          expect(s.log, isEmpty);
          expect(rules.currentSeat(s), 0);
          expect(s.undos, [i + 1, 0]);
        }
        s = twoMoves(s);
        expect(rules.isLegal(s, undo), isFalse, reason: 'only three times');
      }
    });

    test('takes back to my previous turn when the robot started', () {
      var s = rules.initialState(config(robotFirst: true), 1);
      s = rules.apply(s, rules.legalMoves(s, 0).first);
      final mine = s;
      s = twoMoves(s);
      expect(rules.currentSeat(s), 1);
      s = rules.apply(s, const Move(seat: 1, type: CheckersRules.undo));
      expect(s.board, mine.board);
      expect(s.log, hasLength(1));
      expect(rules.currentSeat(s), 1);
    });

    test('not against the hard robot, not between people, not when switched off', () {
      for (final c in [config(robot: true, difficulty: Difficulty.hard), config(), config(robot: true, undo: false)]) {
        final s = twoMoves(rules.initialState(c, 1));
        expect(rules.isLegal(s, const Move(seat: 0, type: CheckersRules.undo)), isFalse, reason: '${c.options}');
      }
    });
  });

  group('result', () {
    test('win with 6+ own pieces ★★★, a win ★★, a draw ★, a loss nothing; score = pieces', () {
      final big = play(
        diagram(board({(3, 4): 'w', (4, 3): 'b', (1, 6): 'w', (3, 6): 'w', (5, 6): 'w', (7, 6): 'w', (0, 7): 'w'})),
        [(3, 4), (5, 2)],
      );
      expect(rules.result(big).stars, [3, 0]);
      expect(rules.result(big).places, [1, 2]);
      expect(rules.result(big).scores, [6, 0]);
      final small = play(diagram(board({(3, 4): 'w', (4, 3): 'b'})), [(3, 4), (5, 2)]);
      expect(rules.result(small).stars, [2, 0]);
      final lost = play(diagram(board({(3, 4): 'w', (4, 3): 'b'}), current: 1), [(4, 3), (2, 5)]);
      expect(rules.result(lost).places, [2, 1]);
      expect(rules.result(lost).stars, [0, 2]);
      expect(rules.score(rules.initialState(config(), 1), 1), 12);
    });
  });

  group('moves and JSON', () {
    test('only well-formed moves of the seat to move are legal', () {
      final s = rules.initialState(config(), 1);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'move', data: {'path': 'x'})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'move', data: {'path': [1]})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'move', data: {'path': [999, 1]})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'jump')), isFalse);
      expect(rules.isLegal(s, CheckersRules.moveOf(1, [sq(1, 2), sq(0, 3)])), isFalse);
      expect(rules.isLegal(s, CheckersRules.moveOf(0, [sq(0, 5), sq(1, 4)])), isTrue);
    });

    test('a game in the middle survives JSON and replays the same', () {
      var s = rules.initialState(config(robot: true, variant: 'international'), 3);
      for (var i = 0; i < 30 && !rules.isOver(s); i++) {
        final legal = rules.legalMoves(s, s.current);
        s = rules.apply(s, legal[(i * 7) % legal.length]);
      }
      final json = jsonEncode(rules.stateToJson(s));
      final back = rules.stateFromJson(jsonDecode(json) as Map<String, Object?>);
      expect(jsonEncode(rules.stateToJson(back)), json);
      expect(back.board, s.board);
      expect(back.positions, s.positions);
      expect(paths(back), paths(s));
    });
  });
}
