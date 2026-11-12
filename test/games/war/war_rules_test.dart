import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/war/war_ai.dart';
import 'package:deskovky/games/war/war_events.dart';
import 'package:deskovky/games/war/war_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = WarRules();

int c(int rank, [int suit = 0]) => WarCard.of(rank, suit);

GameConfig config(int players, {Map<String, Object?> options = const {}}) => GameConfig(
  gameId: 'war',
  seats: [for (var i = 0; i < players; i++) HumanSeat(i + 1)],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: options,
);

/// A state with the given piles (top card first) and nothing on the table.
WarState deal(List<List<int>> decks, {int maxRounds = 30}) => WarState(
  decks: decks,
  table: [for (final _ in decks) const []],
  contenders: [for (var s = 0; s < decks.length; s++) s],
  flipped: const [],
  warDepth: 0,
  battleWinner: null,
  round: 0,
  maxRounds: maxRounds,
  out: const [],
  lowest: [for (final d in decks) d.length],
  doubleWar: [for (final _ in decks) false],
  wars: 0,
  over: false,
);

/// Plays the only legal move until the battle has a winner.
WarState flipAll(WarState s) {
  while (s.battleWinner == null && !s.over) {
    s = rules.apply(s, WarRules.flip(rules.currentSeat(s)!));
  }
  return s;
}

void main() {
  group('deal', () {
    test('32 cards by default, split evenly; 52 with the option', () {
      final two = rules.initialState(config(2), 7);
      expect(two.decks.map((d) => d.length), [16, 16]);
      expect({...two.decks[0], ...two.decks[1]}.length, 32);
      expect([...two.decks[0], ...two.decks[1]].every((card) => WarCard.rank(card) >= 7), isTrue);
      final full = rules.initialState(config(2, options: {'deck': WarDeck.full}), 7);
      expect(full.decks.map((d) => d.length), [26, 26]);
    });

    test('three players get the same number; the rest stays in the box', () {
      final s = rules.initialState(config(3), 1);
      expect(s.decks.map((d) => d.length), [10, 10, 10]);
    });

    test('the same seed deals the same cards, another seed others', () {
      expect(rules.initialState(config(2), 5).decks, rules.initialState(config(2), 5).decks);
      expect(rules.initialState(config(2), 5).decks, isNot(rules.initialState(config(2), 6).decks));
    });

    test('the length option sets the battles', () {
      expect(rules.initialState(config(2), 1).maxRounds, 30);
      expect(rules.initialState(config(2, options: {'length': WarLength.long}), 1).maxRounds, 100);
      expect(rules.initialState(config(2, options: {'length': WarLength.full}), 1).maxRounds, WarLength.cap);
    });
  });

  group('a battle', () {
    test('seats turn in order; the only move is the flip of the one on turn', () {
      final s = deal([
        [c(9), c(7)],
        [c(8), c(10)],
      ]);
      expect(rules.currentSeat(s), 0);
      expect(rules.legalMoves(s, 0), [WarRules.flip(0)]);
      expect(rules.legalMoves(s, 1), isEmpty);
      expect(rules.isLegal(s, WarRules.flip(1)), isFalse);
      expect(rules.isLegal(s, WarRules.collect(0)), isFalse);
      final after = rules.apply(s, WarRules.flip(0));
      expect(after.table[0], [(c(9), true)]);
      expect(after.decks[0], [c(7)]);
      expect(rules.currentSeat(after), 1);
    });

    test('the higher card wins and collects everything under its pile', () {
      var s = flipAll(deal([
        [c(9), c(7)],
        [c(12), c(10)],
      ]));
      expect(s.battleWinner, 1);
      expect(rules.currentSeat(s), 1);
      expect(rules.legalMoves(s, 1), [WarRules.collect(1)]);
      s = rules.apply(s, WarRules.collect(1));
      expect(s.decks[1], [c(10), c(9), c(12)]);
      expect(s.decks[0], [c(7)]);
      expect(s.table.every((t) => t.isEmpty), isTrue);
      expect(s.round, 1);
      expect(rules.currentSeat(s), 0);
    });

    test('the ace is highest', () {
      final s = flipAll(deal([
        [c(14), c(7)],
        [c(13), c(8)],
      ]));
      expect(s.battleWinner, 0);
    });

    test('with three players only the tied highest go to war', () {
      var s = deal([
        [c(11), c(7), c(8)],
        [c(11, 1), c(9), c(13)],
        [c(8, 2), c(10), c(10, 3)],
      ]);
      for (final seat in [0, 1, 2]) {
        s = rules.apply(s, WarRules.flip(seat));
      }
      expect(s.contenders, [0, 1]);
      expect(s.warDepth, 1);
      expect(s.battleWinner, isNull);
    });
  });

  group('war', () {
    test('a tie: one card face down and one face up; the higher takes all', () {
      var s = flipAll(deal([
        [c(10), c(7), c(9), c(8)],
        [c(10, 1), c(8, 1), c(14), c(7, 1)],
      ]));
      expect(s.warDepth, 1);
      expect(s.wars, 1);
      expect(s.table[0], [(c(10), true), (c(7), false), (c(9), true)]);
      expect(s.battleWinner, 1);
      s = rules.apply(s, WarRules.collect(1));
      expect(s.decks[1], hasLength(7));
      expect(s.decks[0], [c(8)]);
    });

    test('a seat with a single card left plays it face up', () {
      final s = flipAll(deal([
        [c(10), c(13)],
        [c(10, 1), c(7), c(8)],
      ]));
      expect(s.table[0], [(c(10), true), (c(13), true)]);
      expect(s.battleWinner, 0);
    });

    test('a seat with no card for the war loses it to the one that has', () {
      final s = flipAll(deal([
        [c(10)],
        [c(10, 1), c(7), c(8)],
      ]));
      expect(s.battleWinner, 1);
      expect(s.warDepth, 1);
    });

    test('a war after a war earns the doubleWar event for its winner', () {
      var s = flipAll(deal([
        [c(10), c(7), c(9), c(7, 2), c(13), c(8)],
        [c(10, 1), c(8, 1), c(9, 1), c(8, 2), c(12), c(7, 1)],
      ]));
      expect(s.warDepth, 2);
      expect(s.battleWinner, 0);
      // Known before the collect move – the screen takes events when the game ends.
      expect(WarEvents.of(s).keys, contains('${WarEvents.doubleWar}#0'));
      s = rules.apply(s, WarRules.collect(0));
      expect(s.doubleWar, [true, false]);
    });
  });

  group('the end', () {
    test('a seat out of cards is out; the last one in wins', () {
      var s = flipAll(deal([
        [c(9)],
        [c(12), c(10)],
      ]));
      s = rules.apply(s, WarRules.collect(1));
      expect(s.out, [
        [0],
      ]);
      expect(s.over, isTrue);
      expect(rules.currentSeat(s), isNull);
      final r = rules.result(s);
      expect(r.places, [2, 1]);
      expect(r.scores, [0, 3]);
      expect(r.stars, [1, 3]);
    });

    test('after the last round the most cards win; equal cards share a place', () {
      var s = flipAll(deal([
        [c(13), c(7), c(8)],
        [c(9), c(10), c(11)],
        [c(8, 1), c(12), c(14)],
      ], maxRounds: 1));
      s = rules.apply(s, WarRules.collect(0));
      expect(s.over, isTrue);
      final r = rules.result(s);
      expect(r.scores, [5, 2, 2]);
      expect(r.places, [1, 2, 2]);
      expect(r.stars, [3, 2, 2]);
    });

    test('of two seats out, the one out later places better', () {
      final s = deal([
        [c(9), c(10), c(11)],
        [c(9)],
        [c(9)],
      ]).copyWith(
        out: [
          [2],
          [1],
        ],
        over: true,
      );
      expect(WarRules.places(s), [1, 2, 3]);
    });

    test('winning from three cards or fewer earns the comeback event', () {
      final s = flipAll(deal([
        [c(12)],
        [c(9)],
      ]).copyWith(lowest: [1, 1]));
      expect(WarEvents.of(s).keys, contains('${WarEvents.comeback}#0'));
      expect(WarEvents.of(s).keys, isNot(contains('${WarEvents.comeback}#1')));
    });

    test('robots always finish within the game length', () {
      for (final players in [2, 3, 4]) {
        for (final length in [WarLength.short, WarLength.full]) {
          for (var seed = 0; seed < 20; seed++) {
            var s = rules.initialState(config(players, options: {'length': length, 'deck': WarDeck.full}), seed);
            var moves = 0;
            while (!s.over) {
              final seat = rules.currentSeat(s)!;
              final move = const WarAi().chooseMove(s, seat, Difficulty.medium, SeededRandom(seed));
              expect(rules.isLegal(s, move), isTrue);
              s = rules.apply(s, move);
              moves++;
              expect(moves, lessThan(5000));
            }
            expect(s.round, lessThanOrEqualTo(s.maxRounds));
            final total = [for (var i = 0; i < players; i++) s.cardsOf(i)].fold(0, (a, b) => a + b);
            expect(total, (52 ~/ players) * players, reason: 'no card is lost');
          }
        }
      }
    });
  });

  test('JSON round trip keeps everything, a war on the table too', () {
    var s = deal([
      [c(10), c(7), c(9), c(8)],
      [c(10, 1), c(8, 1), c(9, 1), c(7, 1)],
    ]);
    // A tie, then seat 0 lays its war cards; seat 1 has yet to.
    for (final seat in [0, 1, 0]) {
      s = rules.apply(s, WarRules.flip(seat));
    }
    expect(s.warDepth, 1);
    expect(s.table[0], hasLength(3));
    final again = rules.stateFromJson(rules.stateToJson(s));
    expect(rules.stateToJson(again), rules.stateToJson(s));
  });
}
