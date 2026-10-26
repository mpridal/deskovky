import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/memory/memory_cards.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MemoryRules();

GameConfig config({int seats = 2, int cards = 16, String set = 'animals', Difficulty difficulty = Difficulty.medium}) =>
    GameConfig(
      gameId: 'memory',
      seats: [for (var s = 0; s < seats; s++) HumanSeat(s + 1)],
      difficulty: difficulty,
      robotSpeed: RobotSpeed.normal,
      options: {'cards': cards, 'set': set},
    );

/// Positions of the pair of [face].
List<int> pairOf(MemoryState s, int face) => [
  for (var c = 0; c < s.cards; c++)
    if (s.faces[c] == face) c,
];

/// Two face-down cards with different pictures.
(int, int) twoDifferent(MemoryState s) {
  final a = s.owner.indexWhere((o) => o == null);
  final b = List.generate(s.cards, (c) => c).firstWhere((c) => s.owner[c] == null && s.faces[c] != s.faces[a]);
  return (a, b);
}

MemoryState play(MemoryState s, int card, {int? t}) {
  final move = MemoryRules.flip(s.current, card, timeMs: t);
  expect(rules.isLegal(s, move), isTrue, reason: '$move');
  return rules.apply(s, move);
}

MemoryState findPair(MemoryState s, int face) {
  final [a, b] = pairOf(s, face);
  return play(play(s, a), b);
}

void main() {
  group('deal', () {
    test('the seed decides the shuffle; every motif is there twice', () {
      final a = rules.initialState(config(), 42);
      expect(rules.initialState(config(), 42).faces, a.faces);
      expect(rules.initialState(config(), 43).faces, isNot(a.faces));
      expect(a.cards, 16);
      for (final face in a.faces.toSet()) {
        expect(a.faces.where((f) => f == face), hasLength(2));
      }
      expect(a.faces.toSet(), hasLength(8));
    });

    test('every card count and set; unknown options fall back to defaults', () {
      for (final cards in MemoryRules.cardCounts) {
        for (final set in memorySets.keys) {
          final s = rules.initialState(config(cards: cards, set: set), 1);
          expect(s.cards, cards);
          expect(s.set, set);
          expect(s.faces.every((f) => f >= 0 && f < memoryMotifs), isTrue);
        }
      }
      final odd = rules.initialState(config().copyWith(options: {'cards': 13, 'set': 'dinosaurs'}), 1);
      expect(odd.cards, MemoryRules.defaultCards);
      expect(odd.set, memoryDefaultSet);
    });

    test('every set has 24 different motifs', () {
      for (final motifs in memorySets.values) {
        expect(motifs, hasLength(memoryMotifs));
        expect(motifs.toSet(), hasLength(memoryMotifs));
      }
    });

    test('no set has two look-alike motifs a child would take for a pair', () {
      // Noto Emoji families that look the same on a small card.
      const families = {
        'star': {'2b50', '1f31f', '1f4ab', '2728', '1f320'},
        'moon': {
          '1f311',
          '1f312',
          '1f313',
          '1f314',
          '1f315',
          '1f316',
          '1f317',
          '1f318',
          '1f319',
          '1f31a',
          '1f31b',
          '1f31c',
          '1f31d',
        },
        'sun': {'2600', '1f31e', '1f324', '26c5'},
        'earth': {'1f30d', '1f30e', '1f30f', '1f310'},
        'astronaut': {'1f9d1_200d_1f680', '1f468_200d_1f680', '1f469_200d_1f680'},
        'boat': {'26f5', '1f6a4', '1f6f6'},
        'police': {'1f693', '1f694'},
        'taxi': {'1f695', '1f696'},
        'bus': {'1f68c', '1f68d', '1f690'},
        'apple': {'1f34e', '1f34f'},
        'citrus': {'1f34a', '1f34b'},
        'monkey': {'1f435', '1f412', '1f648', '1f649', '1f64a'},
        'bird': {'1f414', '1f413', '1f424', '1f425', '1f426'},
      };
      for (final MapEntry(key: set, value: motifs) in memorySets.entries) {
        for (final MapEntry(key: family, value: members) in families.entries) {
          expect(motifs.where(members.contains).length, lessThanOrEqualTo(1), reason: '$set: two from "$family"');
        }
      }
    });
  });

  group('turns', () {
    test('turning a card is a move; the first player starts and may flip any card', () {
      final s = rules.initialState(config(), 5);
      expect(rules.currentSeat(s), 0);
      expect(rules.legalMoves(s, 0), hasLength(16));
      expect(rules.legalMoves(s, 1), isEmpty);
      final after = play(s, 3);
      expect(after.open, [3]);
      expect(rules.legalMoves(after, 0).map((m) => m.data['card']), isNot(contains(3)));
    });

    test('a pair stays with the player, who plays again', () {
      var s = rules.initialState(config(), 5);
      s = findPair(s, s.faces[0]);
      expect(s.current, 0);
      expect(s.pairsOf(0), 1);
      expect(rules.score(s, 0), 1);
      expect(s.streak, 1);
      expect(s.turns, [1, 0]);
      for (final c in pairOf(s, s.faces[0])) {
        expect(rules.isLegal(s, MemoryRules.flip(0, c)), isFalse, reason: 'found cards stay out');
      }
    });

    test('a miss shows both cards and passes the turn', () {
      var s = rules.initialState(config(seats: 3), 5);
      final (a, b) = twoDifferent(s);
      s = play(play(s, a), b);
      expect(s.current, 1);
      expect(s.miss, [a, b]);
      expect(s.open, isEmpty);
      expect(s.misses, [1, 0, 0]);
      expect(s.streak, 0);
      // The miss is over with the next flip; both may be turned again.
      expect(rules.isLegal(s, MemoryRules.flip(1, a)), isTrue);
      s = play(s, a);
      expect(s.miss, isEmpty);
    });

    test('after the last player the first plays again', () {
      var s = rules.initialState(config(seats: 2), 9);
      for (final seat in [1, 0]) {
        final (a, b) = twoDifferent(s);
        s = play(play(s, a), b);
        expect(s.current, seat);
      }
    });

    test('illegal moves: wrong seat, same card twice, found card, bad data', () {
      final s = rules.initialState(config(), 5);
      expect(rules.isLegal(s, MemoryRules.flip(1, 0)), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'roll', data: {'card': 0})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'flip', data: {'card': 16})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'flip', data: {'card': -1})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'flip', data: {'card': 'x'})), isFalse);
      expect(rules.isLegal(s, const Move(seat: 0, type: 'flip', data: {'card': 0, 't': -5})), isFalse);
      final open = play(s, 0);
      expect(rules.isLegal(open, MemoryRules.flip(0, 0)), isFalse);
    });

    test('the time sent with a move is kept for the rating', () {
      var s = rules.initialState(config(seats: 1), 5);
      s = play(s, 0, t: 1234);
      expect(s.timeMs, 1234);
      s = play(s, 1);
      expect(s.timeMs, 1234);
    });
  });

  group('end and result', () {
    test('the game ends when every pair is found; most pairs wins, ties share', () {
      var s = rules.initialState(config(seats: 3, cards: 12), 8);
      final faces = s.faces.toSet().toList();
      // Seat 0 finds 2 pairs, misses; seat 1 finds 2, misses; seat 2 finds 2.
      var f = 0;
      for (var seat = 0; seat < 3; seat++) {
        s = findPair(findPair(s, faces[f++]), faces[f++]);
        if (seat < 2) {
          final (a, b) = twoDifferent(s);
          s = play(play(s, a), b);
        }
      }
      expect(rules.isOver(s), isTrue);
      expect(rules.currentSeat(s), isNull);
      expect(rules.legalMoves(s, 2), isEmpty);
      final r = rules.result(s);
      expect(r.scores, [2, 2, 2]);
      expect(r.places, [1, 1, 1]);
      expect(r.stars, [3, 3, 3]);
    });

    test('places 1, 3, 2 and stars by place', () {
      var s = rules.initialState(config(seats: 3, cards: 12), 8);
      final faces = s.faces.toSet().toList();
      s = findPair(findPair(findPair(s, faces[0]), faces[1]), faces[2]);
      var (a, b) = twoDifferent(s);
      s = play(play(s, a), b);
      s = findPair(s, faces[3]);
      (a, b) = twoDifferent(s);
      s = play(play(s, a), b);
      s = findPair(findPair(s, faces[4]), faces[5]);
      final r = rules.result(s);
      expect(r.scores, [3, 1, 2]);
      expect(r.places, [1, 3, 2]);
      expect(r.stars, [3, 1, 2]);
      expect(r.stats['cards'], 12);
    });

    test('one player is always first; stars by turns (≤ 1.5× pairs ★★★, ≤ 2× ★★)', () {
      expect(MemoryRules.soloStars(12, 8), 3);
      expect(MemoryRules.soloStars(13, 8), 2);
      expect(MemoryRules.soloStars(16, 8), 2);
      expect(MemoryRules.soloStars(17, 8), 1);
      var s = rules.initialState(config(seats: 1, cards: 12), 3);
      for (final face in s.faces.toSet()) {
        s = findPair(s, face);
      }
      final r = rules.result(s);
      expect(r.places, [1]);
      expect(r.scores, [6]);
      expect(r.stars, [3]);
    });
  });

  group('one player', () {
    test('easy shows a preview, hard swaps; with robots neither', () {
      expect(rules.initialState(config(seats: 1, difficulty: Difficulty.easy), 1).preview, isTrue);
      expect(rules.initialState(config(seats: 1), 1).preview, isFalse);
      expect(rules.initialState(config(seats: 1, difficulty: Difficulty.hard), 1).swapping, isTrue);
      expect(rules.initialState(config(seats: 2, difficulty: Difficulty.hard), 1).swapping, isFalse);
      expect(rules.initialState(config(seats: 2, difficulty: Difficulty.easy), 1).preview, isFalse);
    });

    test('hard: every fourth miss swaps two other face-down cards with different pictures', () {
      var s = rules.initialState(config(seats: 1, difficulty: Difficulty.hard), 7);
      for (var miss = 1; miss <= 8; miss++) {
        final before = s;
        final (a, b) = twoDifferent(s);
        s = play(play(s, a), b);
        if (miss % 4 != 0) {
          expect(s.faces, before.faces);
          expect(s.swaps, before.swaps);
          continue;
        }
        expect(s.swaps, before.swaps + 1);
        final [i, j] = s.swap;
        expect([i, j], everyElement(isNot(anyOf(a, b))));
        expect(s.faces[i], before.faces[j]);
        expect(s.faces[j], before.faces[i]);
        expect(s.faces[i], isNot(s.faces[j]));
        expect(s.known[i] || s.known[j], isFalse);
        // Everything else stays.
        for (var c = 0; c < s.cards; c++) {
          if (c != i && c != j) expect(s.faces[c], before.faces[c]);
        }
      }
      expect(s.swaps, 2);
    });

    test('medium never swaps', () {
      var s = rules.initialState(config(seats: 1), 7);
      final faces = s.faces;
      for (var miss = 0; miss < 8; miss++) {
        final (a, b) = twoDifferent(s);
        s = play(play(s, a), b);
      }
      expect(s.faces, faces);
    });
  });

  group('mistakes and badges', () {
    test('a mistake = missing a seen partner, or turning a known card that cannot match', () {
      var s = rules.initialState(config(seats: 1), 11);
      final (a, b) = twoDifferent(s);
      s = play(play(s, a), b); // Nothing seen yet: no mistake.
      expect(s.mistakes, [0]);
      final partnerOfA = pairOf(s, s.faces[a]).firstWhere((c) => c != a);
      final other = List.generate(
        s.cards,
        (c) => c,
      ).firstWhere((c) => c != a && c != b && c != partnerOfA && s.faces[c] != s.faces[b]);
      s = play(play(s, partnerOfA), other); // Partner of a was seen: mistake.
      expect(s.mistakes, [1]);
      final fresh = List.generate(s.cards, (c) => c).firstWhere(
        (c) => !s.known[c] && s.faces[c] != s.faces[a] && s.faces[c] != s.faces[b] && s.faces[c] != s.faces[other],
      );
      s = play(play(s, fresh), b); // b is known and cannot match: mistake.
      expect(s.mistakes, [2]);
    });

    test('events: a pair counts, five pairs in one turn is a streak', () {
      var s = rules.initialState(config(cards: 24), 4);
      final faces = s.faces.toSet().toList();
      final events = <String>[];
      for (var i = 0; i < 5; i++) {
        final [a, b] = pairOf(s, faces[i]);
        final mid = play(s, a);
        final after = play(mid, b);
        events.addAll(MemoryRules.eventsAfter(mid, MemoryRules.flip(0, b), after).map((e) => e.$1));
        expect(MemoryRules.eventsAfter(s, MemoryRules.flip(0, a), mid), isEmpty);
        s = after;
      }
      expect(events.where((e) => e == 'memory.pairs'), hasLength(5));
      expect(events.where((e) => e == 'memory.streak'), hasLength(1));
    });

    test('speed: 16 cards alone under 40 s', () {
      MemoryState almostDone() {
        var s = rules.initialState(config(seats: 1), 4);
        final faces = s.faces.toSet().toList();
        for (final face in faces.take(7)) {
          s = findPair(s, face);
        }
        return s;
      }

      for (final (t, expected) in [(39000, true), (41000, false)]) {
        final s = almostDone();
        final [a, b] = pairOf(s, s.faces[s.owner.indexWhere((o) => o == null)]);
        final mid = play(s, a);
        final move = MemoryRules.flip(0, b, timeMs: t);
        final after = rules.apply(mid, move);
        expect(rules.isOver(after), isTrue);
        expect(MemoryRules.eventsAfter(mid, move, after).any((e) => e.$1 == 'memory.speed'), expected, reason: '$t');
      }
    });

    test('elephant with others: only who found at least half of the pairs', () {
      var s = rules.initialState(config(seats: 2), 6);
      final faces = s.faces.toSet().toList();
      s = findPair(s, faces[0]); // Seat 0: one pair, then a blind miss.
      final (a, b) = twoDifferent(s);
      s = play(play(s, a), b);
      for (final face in faces.skip(1).take(6)) {
        s = findPair(s, face); // Seat 1: six pairs.
      }
      expect(s.pairsLeft, 1);
      expect(s.mistakes, [0, 0]);
      expect(MemoryRules.elephants(s), [1], reason: 'one or two lucky turns are not enough');

      var even = rules.initialState(config(seats: 2), 6);
      for (final face in faces.take(4)) {
        even = findPair(even, face); // Seat 0: four of eight pairs.
      }
      final (c, d) = twoDifferent(even);
      even = play(play(even, c), d);
      for (final face in faces.skip(4).take(3)) {
        even = findPair(even, face);
      }
      // Exactly half is enough; seat 1 has three of eight before the last pair.
      expect(MemoryRules.elephants(even), [0]);
    });

    test('elephant: no mistake by the time one pair is left, 16+ cards', () {
      var s = rules.initialState(config(seats: 2), 6);
      final faces = s.faces.toSet().toList();
      final (a, b) = twoDifferent(s);
      s = play(play(s, a), b); // Seat 0 misses blindly – no mistake.
      for (final face in faces) {
        if (s.pairsLeft == 1) break;
        expect(MemoryRules.elephants(s), isEmpty);
        s = findPair(s, face);
      }
      // Seat 1 found every pair without a mistake; seat 0 found none.
      expect(MemoryRules.elephants(s), [1]);
      final small = rules.initialState(config(seats: 1, cards: 12), 6);
      var t = small;
      for (final face in t.faces.toSet().take(5)) {
        t = findPair(t, face);
      }
      expect(MemoryRules.elephants(t), isEmpty, reason: 'needs at least 16 cards');
    });
  });

  test('JSON round trip', () {
    var s = rules.initialState(config(seats: 1, difficulty: Difficulty.hard), 2);
    for (var i = 0; i < 4; i++) {
      final (a, b) = twoDifferent(s);
      s = play(play(s, a), b);
    }
    expect(rules.stateToJson(rules.stateFromJson(rules.stateToJson(s))), rules.stateToJson(s));
  });
}
