import 'dart:convert';

import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ludo_test_utils.dart';

void main() {
  group('start', () {
    test('every piece waits in its corner, seat 0 rolls', () {
      final s = rules.initialState(ludoConfig(), 3);
      expect(s.pieces, everyElement(equals([base, base, base, base])));
      expect(rules.currentSeat(s), 0);
      expect(rules.legalMoves(s, 0), [const Move(seat: 0, type: 'roll')]);
      expect(rules.legalMoves(s, 1), isEmpty);
    });

    test('the short game has two pieces; options default to the classic', () {
      final s = rules.initialState(ludoConfig(options: {'length': 'short'}), 3);
      expect(s.pieces.first, hasLength(2));
      expect(s.options.mustCapture, isFalse);
      expect(s.options.threeTries, isTrue);
      expect(s.options.playOut, isFalse);
      expect(s.options.autoMove, isTrue);
    });

    test('two players sit opposite each other, 3 and 4 around the board', () {
      final two = position([[0], [0]]);
      expect(LudoRules.ringField(two, 1, 0), 20);
      final four = position([[0], [0], [0], [0]]);
      expect([for (var s = 0; s < 4; s++) LudoRules.ringField(four, s, 0)], [0, 10, 20, 30]);
      expect(LudoRules.ringField(four, 1, 35), 5, reason: 'the ring wraps around');
    });

    test('robots are remembered per seat', () {
      final s = rules.initialState(ludoConfig(players: 3, robots: 2), 1);
      expect(s.robots, [false, true, true]);
    });
  });

  group('the die', () {
    test('rolls come from the seed: same seed, same rolls; all six faces appear', () {
      List<int> rolls(int seed) {
        var s = rules.initialState(ludoConfig(players: 2), seed);
        final values = <int>[];
        for (var i = 0; i < 300; i++) {
          s = rules.apply(s.copyWith(phase: LudoPhase.roll, pieces: [[base], [base]]), roll(s));
          values.add(s.dice!);
        }
        return values;
      }

      expect(rolls(42), rolls(42));
      expect(rolls(42), isNot(rolls(43)));
      expect(rolls(42).toSet(), {1, 2, 3, 4, 5, 6});
    });

    test('a roll is legal only when it is time to roll', () {
      final s = rolled(position([[5, base], [base, base]]), 3);
      expect(s.phase, LudoPhase.move);
      expect(rules.isLegal(s, roll(s)), isFalse);
      expect(rules.isLegal(s, const Move(seat: 1, type: 'roll')), isFalse);
    });
  });

  group('entering', () {
    test('only a six puts a piece on the start field', () {
      for (var d = 1; d <= 5; d++) {
        expect(LudoRules.steps(position([[base], [base]]), 0, d), isEmpty, reason: '$d');
      }
      final s = rolled(position([[base, base], [base, base]]), 6);
      expect(rules.legalMoves(s, 0), [pick(s, 0), pick(s, 1)]);
      final after = rules.apply(s, pick(s, 0));
      expect(after.pieces[0], [0, base]);
    });

    test('a six rolls again – after moving and when nothing can move', () {
      final s = rolled(position([[base], [base]]), 6);
      final after = rules.apply(s, pick(s, 0));
      expect(after.current, 0);
      expect(after.phase, LudoPhase.roll);

      // One piece too far along for a six, the other one home: no move.
      final blocked = rolled(position([[38, 43], [base, base]]), 6);
      expect(blocked.phase, LudoPhase.roll);
      expect(blocked.current, 0);
      expect(blocked.noMove, isTrue);
    });

    test('three tries for a six with no piece on the ring', () {
      var s = position([[base, base], [base, base]]);
      s = rolled(s, 2);
      expect((s.current, s.tries, s.noMove), (0, 1, true));
      s = rolled(s, 4);
      expect((s.current, s.tries), (0, 2));
      s = rolled(s, 1);
      expect((s.current, s.tries), (1, 0), reason: 'the third miss passes the die');
    });

    test('pieces home do not count as on the board: still three tries', () {
      var s = position([[42, base], [base, base]]);
      s = rolled(s, 3);
      expect((s.current, s.tries), (0, 1));
    });

    test('without the three tries option one miss passes the die', () {
      final s = rolled(position([[base], [base]], options: {'threeTries': false}), 5);
      expect(s.current, 1);
    });

    test('a seat with a piece on the ring that cannot move has no extra tries', () {
      // A piece 39 fields along can only go 1–4 into the home.
      final five = rolled(position([[39, base], [base, base]]), 5);
      expect(five.current, 1);
      expect(five.noMove, isTrue);
    });

    test('entering on an opponent sends it back', () {
      // Seat 1 (opposite) stands 20 fields along = seat 0's start field.
      final s = rolled(position([[base], [20]]), 6);
      final after = rules.apply(s, pick(s, 0));
      expect(after.pieces, [[0], [base]]);
      expect(after.stats[0].captures, 1);
      expect(after.stats[1].captured, 1);
    });
  });

  group('moving', () {
    test('a piece moves by the roll; the next seat rolls after a non-six', () {
      final s = rolled(position([[3], [base]]), 4);
      final after = rules.apply(s, pick(s, 0));
      expect(after.pieces[0], [7]);
      expect(after.current, 1);
      expect(after.phase, LudoPhase.roll);
    });

    test('landing on an opponent sends it to its corner', () {
      // Seat 0 at 5 + 3 = field 8; seat 1 (corner 2) at 28 = field 8.
      final s = rolled(position([[5], [28]]), 3);
      final step = LudoRules.currentSteps(s).single;
      expect(step.captures, (1, 0));
      final after = rules.apply(s, pick(s, 0));
      expect(after.pieces, [[8], [base]]);
    });

    test('jumping over pieces on the ring is fine', () {
      final s = rolled(position([[5, 6], [27]]), 4);
      expect(LudoRules.currentSteps(s).map((m) => m.piece), [0, 1]);
    });

    test('never onto your own piece', () {
      final s = rolled(position([[5, 8], [base]]), 3);
      expect(LudoRules.currentSteps(s).map((m) => m.piece), [1]);
    });

    test('pieces of 4 players meet on shared fields', () {
      // Seat 3 (corner 3) 15 fields along = field 5; seat 0 lands there with 5.
      final s = rolled(position([[0], [base], [base], [15]]), 5);
      expect(LudoRules.currentSteps(s).single.captures, (3, 0));
    });

    test('if you can move you must: only piece moves are offered, no pass', () {
      final s = rolled(position([[5, base], [base, base]]), 2);
      final moves = rules.legalMoves(s, 0);
      expect(moves, [pick(s, 0)]);
      expect(rules.isLegal(s, roll(s)), isFalse);
    });
  });

  group('the home', () {
    test('a piece enters the home only with an exact roll', () {
      final s = position([[37], [base]]);
      expect(LudoRules.stepFor(s, 0, 0, 3)!.to, 40);
      expect(LudoRules.stepFor(s, 0, 0, 6)!.to, 43);
      expect(LudoRules.stepFor(s, 0, 0, 7), isNull);
      expect(LudoRules.stepFor(position([[38], [base]]), 0, 0, 6), isNull, reason: 'past the last home field');
    });

    test('home fields are never jumped, and a taken field is not free', () {
      final s = position([[38, 41], [base]]);
      expect(LudoRules.stepFor(s, 0, 0, 2)!.to, 40);
      expect(LudoRules.stepFor(s, 0, 0, 3), isNull, reason: 'own piece on 41');
      expect(LudoRules.stepFor(s, 0, 0, 4), isNull, reason: 'would jump 41');
    });

    test('a piece may move on inside the home, without jumping', () {
      final s = position([[40, 43], [base]]);
      expect(LudoRules.stepFor(s, 0, 0, 2)!.to, 42);
      expect(LudoRules.stepFor(s, 0, 0, 3), isNull);
      expect(LudoRules.stepFor(position([[40, 42], [base]]), 0, 0, 3), isNull);
    });

    test('opponents never enter or capture in my home', () {
      // Seat 1 sits opposite; its pieces never reach seat 0's home fields.
      final s = position([[41], [37]]);
      final step = LudoRules.stepFor(s, 1, 0, 3)!;
      expect(step.to, 40);
      expect(step.captures, isNull);
    });

    test('the last piece home wins at once', () {
      final s = rolled(position([[37, 43], [5, base]]), 3);
      expect(LudoRules.currentSteps(s).map((m) => m.to), [40]);
      final after = rules.apply(s, pick(s, 0));
      expect(after.finished, [0]);
      expect(rules.isOver(after), isTrue);
      expect(rules.currentSeat(after), isNull);
      expect(rules.legalMoves(after, 0), isEmpty);
      final result = rules.result(after);
      expect(result.places, [1, 2]);
      expect(result.stars, [3, 2]);
      expect(result.scores, [2, 0]);
    });
  });

  group('places', () {
    test('with "play out" the game goes on until one seat is left', () {
      var s = position([[39], [base], [10]], options: {'playOut': true, 'length': 'short'});
      s = s.copyWith(pieces: [[39, 42], [base, base], [10, 11]]);
      s = rolled(s, 1);
      s = rules.apply(s, pick(s, 0));
      expect(s.finished, [0]);
      expect(rules.isOver(s), isFalse);
      expect(s.current, 1);
      // Seat 0 is skipped from now on.
      s = rolled(s.copyWith(current: 2), 1);
      s = rules.apply(s, pick(s, 1));
      expect(s.current, 1);
    });

    test('the play-out ends with the second-to-last seat; ranks follow the finish', () {
      var s = position([[42], [39], [3]], options: {'playOut': true, 'length': 'short'});
      s = s.copyWith(pieces: [[43, 42], [43, 39], [3, base]], finished: [0], current: 1);
      s = rolled(s, 2);
      s = rules.apply(s, pick(s, 1));
      expect(rules.isOver(s), isTrue);
      expect(rules.result(s).places, [1, 2, 3]);
      expect(rules.result(s).stars, [3, 2, 1]);
    });

    test('"Ukončit a seřadit": anyone on turn may stop; ranks by progress, ties share, no stars', () {
      final s = position([[10, base], [4, 5], [20, 41], [base, base]], current: 2);
      final stop = const Move(seat: 2, type: 'stop');
      expect(rules.isLegal(s, stop), isTrue);
      expect(rules.legalMoves(s, 2), isNot(contains(stop)), reason: 'robots never stop a game');
      expect(rules.isLegal(s, const Move(seat: 1, type: 'stop')), isFalse);
      final after = rules.apply(s, stop);
      expect(rules.isOver(after), isTrue);
      // Progress: 11, 11, 63, 0.
      final result = rules.result(after);
      expect(result.places, [2, 2, 1, 4]);
      expect(result.stars, [0, 0, 0, 0], reason: 'an early end earns no stars');
      expect(result.stats['endedEarly'], isTrue);
      expect(rules.isLegal(after, stop), isFalse);
    });

    test('stopping is possible only once some piece is home (no free wins)', () {
      const stop = Move(seat: 0, type: 'stop');
      expect(rules.isLegal(rules.initialState(ludoConfig(), 1), stop), isFalse, reason: 'right at the start');
      final oneOut = position([[0, base, base, base], [base, base, base, base]]);
      expect(rules.isLegal(oneOut, stop), isFalse, reason: 'one piece entered, robots nothing');
      expect(LudoRules.canStop(oneOut), isFalse);
      final home = position([[0, base, base, base], [41, base, base, base]]);
      expect(rules.isLegal(home, stop), isTrue);
      expect(LudoRules.canStop(home), isTrue);
    });

    test('a normal end is not an early end', () {
      final s = rolled(position([[37, 43], [5, base]]), 3);
      final after = rules.apply(s, pick(s, 0));
      expect(rules.result(after).stats['endedEarly'], isFalse);
    });

    test('finished seats stay ahead of everyone when the game is stopped', () {
      final s = position([[43, 42], [30, 30], [base, base]], finished: [0], options: {'playOut': true, 'length': 'short'});
      final after = rules.apply(s.copyWith(current: 1), const Move(seat: 1, type: 'stop'));
      expect(rules.result(after).places, [1, 2, 3]);
    });
  });

  group('must capture', () {
    test('when a capture is possible only capturing moves are legal', () {
      final s = rolled(position([[5, 0], [28]], options: {'mustCapture': true}), 3);
      expect(LudoRules.currentSteps(s).map((m) => m.piece), [0]);
      final free = rolled(position([[5, 0], [28]]), 3);
      expect(LudoRules.currentSteps(free).map((m) => m.piece), [0, 1]);
    });

    test('entering onto a rival counts as a capture', () {
      final s = rolled(position([[base, 2], [20]], options: {'mustCapture': true}), 6);
      expect(LudoRules.currentSteps(s).map((m) => m.piece), [0]);
    });
  });

  group('badge totals', () {
    test('sixes in a row are counted per turn and reset by the next seat', () {
      var s = position([[base], [base]]);
      for (var i = 0; i < 3; i++) {
        s = rolled(s, 6);
        if (s.phase == LudoPhase.move) s = rules.apply(s, pick(s, 0));
      }
      expect(s.stats[0].bestSixRun, 3);
      expect(s.stats[0].sixes, 3);
      s = rolled(s, 2);
      s = rules.apply(s, pick(s, 0));
      expect(s.current, 1);
      expect(s.sixRun, 0);
    });
  });

  group('JSON and replay', () {
    test('state survives JSON', () {
      final s = rolled(position([[5, 41], [28, base]], options: {'mustCapture': true}), 3);
      final json = jsonEncode(rules.stateToJson(s));
      expect(jsonEncode(rules.stateToJson(rules.stateFromJson(jsonDecode(json) as Map<String, Object?>))), json);
    });

    test('a whole random game replays to the same state', () {
      final config = ludoConfig(players: 3);
      final a = GameSession.start(rules, config, 99);
      var k = 0;
      while (!rules.isOver(a.state) && k++ < 3000) {
        final legal = rules.legalMoves(a.state, rules.currentSeat(a.state)!);
        expect(a.apply(legal[k % legal.length]), isTrue);
      }
      expect(rules.isOver(a.state), isTrue);
      final b = GameSession.start(rules, config, 99);
      for (final m in a.moves) {
        expect(b.apply(m), isTrue);
      }
      expect(b.hash, a.hash);
    });

    test('illegal moves are refused', () {
      final s = rolled(position([[5, base], [base, base]]), 2);
      expect(rules.isLegal(s, pick(s, 1)), isFalse, reason: 'piece in the corner without a six');
      expect(rules.isLegal(s, pick(s, 7)), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'jump')), isFalse);
      expect(rules.isLegal(s, const Move(seat: 1, type: 'move', data: {'piece': 0})), isFalse);
    });
  });
}
