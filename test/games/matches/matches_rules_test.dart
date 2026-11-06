import 'dart:convert';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MatchesRules();

GameConfig config({String start = MatchesStart.first}) => GameConfig(
  gameId: 'matches',
  seats: const [HumanSeat(1), HumanSeat(2)],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'start': start},
);

/// Plays (row, count) takes in turn from the start, seat 0 first.
MatchesState play(List<(int, int)> takes) {
  var s = rules.initialState(config(), 1);
  for (final (row, count) in takes) {
    final move = MatchesRules.take(s.current, row, count);
    expect(rules.isLegal(s, move), isTrue, reason: '$row,$count');
    s = rules.apply(s, move);
  }
  return s;
}

void main() {
  group('start', () {
    test('three rows of 3, 5 and 7 matches; "always player 1" starts with seat 0', () {
      final s = rules.initialState(config(), 5);
      expect(s.rows, [3, 5, 7]);
      expect(s.total, 15);
      expect(s.current, 0);
      expect(rules.currentSeat(s), 0);
      expect(rules.isOver(s), isFalse);
    });

    test('"random" picks the starter from the seed: both seats start for some seed, always the same for one seed', () {
      final starters = {for (var seed = 0; seed < 20; seed++) rules.initialState(config(start: MatchesStart.random), seed).starter};
      expect(starters, {0, 1});
      expect(
        rules.initialState(config(start: MatchesStart.random), 9).starter,
        rules.initialState(config(start: MatchesStart.random), 9).starter,
      );
    });

    test('legal moves: every (row, count) – 15 at the start, none for the other seat', () {
      final s = rules.initialState(config(), 1);
      expect(rules.legalMoves(s, 0), hasLength(15));
      expect(rules.legalMoves(s, 1), isEmpty);
      expect(rules.legalMoves(s, 0), contains(MatchesRules.take(0, 2, 7)));
    });
  });

  group('moves', () {
    test('taking some matches from one row; the turn passes', () {
      final s = play([(1, 2)]);
      expect(s.rows, [3, 3, 7]);
      expect(s.current, 1);
      expect(s.history, [(1, 2)]);
      expect(s.takenBy(0), 2);
      expect(s.takenBy(1), 0);
    });

    test('a whole row may be taken at once', () {
      final s = play([(2, 7)]);
      expect(s.rows, [3, 5, 0]);
      expect(rules.legalMoves(s, 1).where((m) => m.data['row'] == 2), isEmpty, reason: 'an empty row offers nothing');
    });

    test('illegal: zero or more than are left, a row that does not exist, the wrong seat, a strange move', () {
      final s = play([(0, 2)]);
      for (final move in [
        MatchesRules.take(1, 0, 2), // only 1 left
        MatchesRules.take(1, 1, 0),
        MatchesRules.take(1, 1, -1),
        MatchesRules.take(1, 3, 1),
        MatchesRules.take(1, -1, 1),
        MatchesRules.take(0, 1, 1), // not seat 0's turn
        const Move(seat: 1, type: 'take', data: {'row': '1', 'count': 1}),
        const Move(seat: 1, type: 'pass'),
      ]) {
        expect(rules.isLegal(s, move), isFalse, reason: '$move');
      }
      expect(rules.isLegal(s, MatchesRules.take(1, 0, 1)), isTrue);
    });

    test('whoever takes the last match loses; nothing is legal after the end', () {
      // 3-5-7 → 0-5-7 → 0-0-7 → 0-0-1 → 0-0-0: seat 1 takes the last one.
      final s = play([(0, 3), (1, 5), (2, 6), (2, 1)]);
      expect(rules.isOver(s), isTrue);
      expect(s.loser, 1);
      expect(s.winner, 0);
      expect(rules.currentSeat(s), isNull);
      expect(rules.legalMoves(s, 0), isEmpty);
      expect(rules.isLegal(s, MatchesRules.take(0, 2, 1)), isFalse);
      final r = rules.result(s);
      expect(r.places, [1, 2]);
      expect(r.scores, [1, 0]);
    });

    test('taking several last matches at once also loses', () {
      final s = play([(0, 3), (1, 5), (2, 7)]);
      expect(rules.isOver(s), isTrue);
      expect(s.loser, 0);
      expect(rules.result(s).places, [2, 1]);
    });

    test('the HUD score is 0 for both while playing and the same as the result at the end', () {
      final s = play([(0, 3)]);
      expect([rules.score(s, 0), rules.score(s, 1)], [0, 0]);
      final end = play([(0, 3), (1, 5), (2, 6), (2, 1)]);
      expect([rules.score(end, 0), rules.score(end, 1)], rules.result(end).scores);
    });
  });

  group('misère positions', () {
    test('who to move wins', () {
      expect(MatchesRules.winning([3, 5, 7]), isTrue, reason: 'nim sum 1');
      expect(MatchesRules.winning([1, 2, 3]), isFalse, reason: 'nim sum 0');
      expect(MatchesRules.winning([0, 0, 1]), isFalse, reason: 'must take the last one');
      expect(MatchesRules.winning([1, 1, 1]), isFalse);
      expect(MatchesRules.winning([1, 1, 0]), isTrue);
      expect(MatchesRules.winning([0, 0, 5]), isTrue, reason: 'leave one');
      expect(MatchesRules.winning([0, 1, 4]), isTrue, reason: 'take the whole four');
      expect(MatchesRules.winning([0, 2, 2]), isFalse);
      expect(MatchesRules.winning([0, 0, 0]), isTrue, reason: 'the other one took the last match');
    });
  });

  group('stars', () {
    test('win ★★★; a loss after letting a winning position go ★★; otherwise ★', () {
      // Seat 0 leaves 0-5-7 (winning for seat 1); seat 1 lets it go with 0-0-7,
      // which seat 0 wins by leaving one match.
      final s = play([(0, 3), (1, 5), (2, 6), (2, 1)]);
      expect(s.hadWin, [true, true]);
      expect(rules.result(s).stars, [3, 2]);
    });

    test('the starting position does not count for ★★', () {
      // Seat 0 starts winning but throws it away (3-5-0); seat 1 then always
      // leaves a losing position (3-3-0, 0-1-0).
      final s = play([(2, 7), (1, 2), (0, 3), (1, 2), (1, 1)]);
      expect(rules.isOver(s), isTrue);
      expect(s.loser, 0);
      expect(s.hadWin[0], isFalse);
      expect(rules.result(s).stars, [1, 3]);
    });

    test('flawless: every move of the seat left the other one in a losing position', () {
      // 3-5-7 → 2-5-7 (nim sum 0) → 2-5-1 → 2-3-1 (nim sum 0) → 0-3-1 → 0-0-1 → 0-0-0.
      final s = play([(0, 1), (2, 6), (1, 2), (0, 2), (1, 3), (2, 1)]);
      expect(rules.isOver(s), isTrue);
      expect(s.winner, 0);
      expect(s.flawless, [true, false]);
    });
  });

  test('state survives JSON with its history and flags', () {
    final s = play([(0, 3), (1, 2)]);
    final json = jsonEncode(rules.stateToJson(s));
    final back = rules.stateFromJson(jsonDecode(json) as Map<String, Object?>);
    expect(jsonEncode(rules.stateToJson(back)), json);
    expect(back.rows, s.rows);
    expect(back.current, s.current);
    expect(back.history, s.history);
    expect(back.hadWin, s.hadWin);
    expect(back.flawless, s.flawless);
  });
}
