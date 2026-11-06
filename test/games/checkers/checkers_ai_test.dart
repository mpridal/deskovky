import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/checkers/checkers_ai.dart';
import 'package:deskovky/games/checkers/checkers_rules.dart';
import 'package:flutter_test/flutter_test.dart';

import 'checkers_test_utils.dart';

const ai = CheckersAi();

/// Depth limits with plenty of time: the same games on any machine.
const deep = CheckersAi(
  mediumDepth: 4,
  hardDepth: 5,
  easyTime: Duration(minutes: 1),
  mediumTime: Duration(minutes: 1),
  hardTime: Duration(minutes: 1),
);

/// Short thinks for hundreds of games that only check legality.
const instant = CheckersAi(
  easyTime: Duration(milliseconds: 5),
  mediumTime: Duration(milliseconds: 5),
  hardTime: Duration(milliseconds: 5),
);

/// `CHECKERS_FULL=1 flutter test test/games/checkers` also plays matches
/// with the real time limits (several minutes).
final full = Platform.environment['CHECKERS_FULL'] == '1';

/// A player: a difficulty of [robot], or a 7-year-old ([child]).
typedef Player = Move Function(CheckersState s, int seat, SeededRandom random);

Player robotOf(Difficulty d, [CheckersAi robot = deep]) => (s, seat, random) => robot.chooseMove(s, seat, d, random);

/// A child of about seven: takes the biggest capture, never leaves a piece
/// where it is taken at once if it can help it, otherwise moves at random.
Move child(CheckersState s, int seat, SeededRandom random) {
  if (s.offerBy != null) return Move(seat: seat, type: CheckersRules.decline);
  final steps = CheckersRules.steps(s);
  if (steps.first.captured.isNotEmpty) {
    final most = steps.map((st) => st.captured.length).reduce((a, b) => a > b ? a : b);
    final best = [for (final st in steps) if (st.captured.length == most) st];
    return CheckersRules.moveOf(seat, best[random.nextInt(best.length)].path);
  }
  final safe = [
    for (final st in steps)
      if (CheckersRules.steps(CheckersRules.step(s, st)).every((reply) => reply.captured.isEmpty)) st,
  ];
  final pool = safe.isNotEmpty ? safe : steps;
  return CheckersRules.moveOf(seat, pool[random.nextInt(pool.length)].path);
}

/// One game; returns the final state.
CheckersState duel(List<Player> players, int seed, {String variant = 'czech', int maxPlies = 400}) {
  final random = SeededRandom(seed);
  var s = rules.initialState(config(variant: variant), seed);
  for (var i = 0; i < maxPlies && !rules.isOver(s); i++) {
    final seat = rules.currentSeat(s)!;
    final move = players[seat](s, seat, SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: 'ply $i: $move\n${s.picture}');
    s = rules.apply(s, move);
  }
  return s;
}

/// [games] games of [a] against [b], each starting half of them: (wins of a, losses of a).
(int, int) match(Player a, Player b, int games, {String variant = 'czech'}) {
  var wins = 0, losses = 0;
  for (var seed = 0; seed < games; seed++) {
    final aSeat = seed % 2;
    final s = duel(aSeat == 0 ? [a, b] : [b, a], seed, variant: variant);
    if (s.winner == aSeat) wins++;
    if (s.winner == 1 - aSeat) losses++;
  }
  return (wins, losses);
}

void main() {
  group('choices', () {
    test('the only move is played at once, on every difficulty', () {
      final s = diagram(board({(3, 4): 'w', (4, 3): 'b', (0, 7): 'w'}));
      for (final d in Difficulty.values) {
        expect(pathOf(ai.chooseMove(s, 0, d, SeededRandom(1))), pathOf(go(s, [(3, 4), (5, 2)])));
      }
    });

    test('medium and hard take two pieces rather than one (Czech free choice)', () {
      final s = diagram(board({(1, 6): 'w', (2, 5): 'b', (4, 3): 'b', (7, 4): 'w', (6, 3): 'b', (0, 1): 'b'}));
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        expect(pathOf(deep.chooseMove(s, 0, d, SeededRandom(1))), pathOf(go(s, [(1, 6), (3, 4), (5, 2)])), reason: '$d');
      }
    });

    test('medium and hard do not give a piece away for nothing', () {
      // (4,5) to (5,4) would be taken by (6,3); (4,5) to (3,4) is safe.
      final s = diagram(board({(4, 5): 'w', (6, 3): 'b', (7, 2): 'b', (0, 7): 'w'}));
      for (final d in [Difficulty.medium, Difficulty.hard]) {
        for (var seed = 0; seed < 5; seed++) {
          expect(pathOf(deep.chooseMove(s, 0, d, SeededRandom(seed))), isNot(pathOf(go(s, [(4, 5), (5, 4)]))), reason: '$d $seed');
        }
      }
    });

    test('hard crowns a man when nothing stops it', () {
      final s = diagram(board({(2, 1): 'w', (7, 6): 'b', (6, 7): 'w'}));
      expect(pathOf(deep.chooseMove(s, 0, Difficulty.hard, SeededRandom(1))), anyOf(equals([sq(2, 1), sq(1, 0)]), equals([sq(2, 1), sq(3, 0)])));
    });

    test('a draw offer is accepted when the robot is behind and declined when ahead', () {
      final behind = diagram(board({(1, 6): 'w', (3, 6): 'w', (5, 6): 'w', (0, 1): 'b'}));
      final ahead = diagram(board({(1, 6): 'w', (0, 1): 'b', (2, 1): 'b', (4, 1): 'b'}));
      for (final d in Difficulty.values) {
        final a = rules.apply(behind, const Move(seat: 0, type: CheckersRules.offer));
        expect(ai.chooseMove(a, 1, d, SeededRandom(1)).type, CheckersRules.accept, reason: '$d');
        final b = rules.apply(ahead, const Move(seat: 0, type: CheckersRules.offer));
        expect(ai.chooseMove(b, 1, d, SeededRandom(1)).type, CheckersRules.decline, reason: '$d');
      }
    });

    test('a lost position scores −win, a draw by the 25-move rule 0', () {
      final lost = CheckersNode.of(diagram(board({(0, 1): 'b', (1, 2): 'w', (2, 3): 'w'}), current: 1));
      expect(CheckersAi.evaluate(lost, 1), -CheckersAi.win);
      expect(CheckersAi.evaluate(lost, 0), CheckersAi.win);
      final drawn = CheckersNode(diagram(board({(7, 6): 'W', (0, 1): 'B'})).board, 0, 8, false, 50);
      expect(CheckersAi.evaluate(drawn, 0), 0);
    });
  });

  group('strength', () {
    test('Těžká beats Lehká in at least 80 % of games', () {
      final (wins, losses) = match(robotOf(Difficulty.hard), robotOf(Difficulty.easy), 20);
      // ignore: avoid_print
      print('Těžká vs Lehká: $wins wins, $losses losses of 20');
      expect(wins, greaterThanOrEqualTo(16));
    });

    test('Těžká beats Lehká on the international board too', () {
      final (wins, losses) = match(robotOf(Difficulty.hard), robotOf(Difficulty.easy), 10, variant: 'international');
      // ignore: avoid_print
      print('international Těžká vs Lehká: $wins wins, $losses losses of 10');
      expect(wins, greaterThanOrEqualTo(8));
    });

    test('Střední beats Lehká more often than not', () {
      final (wins, losses) = match(robotOf(Difficulty.medium), robotOf(Difficulty.easy), 20);
      // ignore: avoid_print
      print('Střední vs Lehká: $wins wins, $losses losses of 20');
      expect(wins, greaterThan(losses));
      expect(wins, greaterThanOrEqualTo(10));
    });

    test('Lehká is beatable by a 7-year-old: a careful child wins some games', () {
      final (wins, losses) = match(child, robotOf(Difficulty.easy), 20);
      // ignore: avoid_print
      print('child vs Lehká: $wins wins, $losses losses of 20');
      expect(wins, greaterThanOrEqualTo(3));
    });

    test('with the real time limits Těžká beats Lehká in at least 80 %', () {
      final (wins, _) = match(robotOf(Difficulty.hard, ai), robotOf(Difficulty.easy, ai), 10);
      expect(wins, greaterThanOrEqualTo(8));
    }, skip: !full);
  });

  test('100 self-play games on every difficulty without an illegal move', () {
    for (final d in Difficulty.values) {
      for (var seed = 0; seed < 100; seed++) {
        final s = duel([robotOf(d, instant), robotOf(d, instant)], seed, variant: seed.isEven ? 'czech' : 'international');
        expect(rules.isOver(s), isTrue, reason: '$d $seed');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 10)));

  test('hard stays within its 1.5 s limit (with slack for the test machine)', () {
    final s = rules.initialState(config(variant: 'international'), 1);
    final watch = Stopwatch()..start();
    ai.chooseMove(s, 0, Difficulty.hard, SeededRandom(1));
    expect(watch.elapsed, lessThan(const Duration(milliseconds: 2500)));
  });
}
