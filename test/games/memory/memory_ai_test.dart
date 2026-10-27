import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/memory/memory_ai.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MemoryRules();
const ai = MemoryAi();

GameConfig config(int seats, {int cards = 16, Difficulty difficulty = Difficulty.medium}) => GameConfig(
  gameId: 'memory',
  seats: [for (var s = 0; s < seats; s++) const RobotSeat()],
  difficulty: difficulty,
  robotSpeed: RobotSpeed.fast,
  options: {'cards': cards, 'set': 'animals'},
);

/// Plays a whole game, seat i on [levels][i]; checks every move is legal.
MemoryState playOut(List<Difficulty> levels, int seed, {int cards = 16}) {
  var s = rules.initialState(config(levels.length, cards: cards), seed);
  final random = SeededRandom(seed * 31 + 7);
  for (var i = 0; i < 10000 && !rules.isOver(s); i++) {
    final seat = rules.currentSeat(s)!;
    final move = ai.chooseMove(s, seat, levels[seat], SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: '$move');
    s = rules.apply(s, move);
  }
  expect(rules.isOver(s), isTrue);
  return s;
}

void main() {
  test('memory: easy forgets after 3 turns, hard keeps almost everything', () {
    var s = rules.initialState(config(2, cards: 48), 3);
    // Twenty blind turns of two different cards.
    for (var i = 0; i < 20; i++) {
      final free = [
        for (var c = 0; c < s.cards; c++)
          if (s.owner[c] == null) c,
      ];
      final a = free[(i * 7) % free.length];
      final b = free.firstWhere((c) => c != a && s.faces[c] != s.faces[a]);
      s = rules.apply(rules.apply(s, MemoryRules.flip(s.current, a)), MemoryRules.flip(s.current, b));
    }
    final seen = s.reveals.toSet().length;
    final easy = MemoryAi.memory(s, 0, Difficulty.easy);
    final medium = MemoryAi.memory(s, 0, Difficulty.medium);
    final hard = MemoryAi.memory(s, 0, Difficulty.hard);
    // Easy only knows flips from the last 3 turns (6 cards at most).
    final recent = s.reveals.sublist(s.reveals.length - 6).toSet();
    expect(recent.containsAll(easy.keys), isTrue);
    expect(hard.length, greaterThan(medium.length));
    expect(medium.length, greaterThan(easy.length));
    expect(hard.length, greaterThanOrEqualTo(seen * 0.8));
    for (final MapEntry(key: c, value: face) in hard.entries) {
      expect(s.faces[c], face, reason: 'the robot never remembers a wrong picture');
    }
  });

  test('what a robot remembers depends only on the state (same after restore)', () {
    var s = rules.initialState(config(3), 9);
    for (var i = 0; i < 6; i++) {
      s = rules.apply(s, ai.chooseMove(s, s.current, Difficulty.medium, SeededRandom(i)));
    }
    final restored = rules.stateFromJson(rules.stateToJson(s));
    for (final d in Difficulty.values) {
      expect(MemoryAi.memory(restored, 1, d), MemoryAi.memory(s, 1, d));
    }
  });

  test('a robot takes the card it is looking at plus its remembered partner', () {
    var s = rules.initialState(config(2), 4);
    // Seat 0 turns a and b (a miss); seat 1 then turns the partner of a.
    final a = 0;
    final partner = List.generate(s.cards, (c) => c).firstWhere((c) => c != a && s.faces[c] == s.faces[a]);
    final b = List.generate(s.cards, (c) => c).firstWhere((c) => c != a && c != partner && s.faces[c] != s.faces[a]);
    s = rules.apply(rules.apply(s, MemoryRules.flip(0, a)), MemoryRules.flip(0, b));
    s = rules.apply(s, MemoryRules.flip(1, partner));
    // Hard remembers a (95 %); the move must be a.
    expect(MemoryAi.memory(s, 1, Difficulty.hard), containsPair(a, s.faces[a]));
    expect(ai.chooseMove(s, 1, Difficulty.hard, SeededRandom(1)).data['card'], a);
  });

  test('a robot starts with a pair it remembers', () {
    var s = rules.initialState(config(2), 4);
    final a = 0;
    final partner = List.generate(s.cards, (c) => c).firstWhere((c) => c != a && s.faces[c] == s.faces[a]);
    final others = List.generate(s.cards, (c) => c).where((c) => c != a && c != partner).toList();
    final x = others.firstWhere((c) => s.faces[c] != s.faces[a]);
    final y = others.firstWhere((c) => c != x && s.faces[c] != s.faces[partner] && s.faces[c] != s.faces[x]);
    s = rules.apply(rules.apply(s, MemoryRules.flip(0, a)), MemoryRules.flip(0, x));
    s = rules.apply(rules.apply(s, MemoryRules.flip(1, partner)), MemoryRules.flip(1, y));
    final known = MemoryAi.memory(s, 0, Difficulty.hard);
    expect(known.keys, containsAll([a, partner]));
    expect([a, partner], contains(ai.chooseMove(s, 0, Difficulty.hard, SeededRandom(2)).data['card']));
  });

  test('100 games per difficulty by itself, 2–4 robots, never an illegal move', () {
    for (final d in Difficulty.values) {
      for (var seed = 0; seed < 100; seed++) {
        final seats = 2 + seed % 3;
        final cards = MemoryRules.cardCounts[seed % MemoryRules.cardCounts.length];
        playOut(List.filled(seats, d), seed, cards: cards);
      }
    }
  });

  test('hard beats easy in at least 60 % of games (and medium beats easy)', () {
    double winRate(Difficulty strong, Difficulty weak) {
      var wins = 0;
      const games = 200;
      for (var seed = 0; seed < games; seed++) {
        // Taking turns at starting.
        final strongSeat = seed.isEven ? 0 : 1;
        final levels = strongSeat == 0 ? [strong, weak] : [weak, strong];
        final r = rules.result(playOut(levels, 1000 + seed, cards: seed.isEven ? 16 : 24));
        if (r.places[strongSeat] == 1 && r.places[1 - strongSeat] == 2) wins++;
      }
      return wins / games;
    }

    final hard = winRate(Difficulty.hard, Difficulty.easy);
    final medium = winRate(Difficulty.medium, Difficulty.easy);
    // ignore: avoid_print
    print('hard vs easy: ${(hard * 100).round()} %, medium vs easy: ${(medium * 100).round()} %');
    expect(hard, greaterThanOrEqualTo(0.6));
    expect(medium, greaterThan(0.5));
  });
}
