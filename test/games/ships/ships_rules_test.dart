import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/ships/ships_events.dart';
import 'package:deskovky/games/ships/ships_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = ShipsRules();

GameConfig config({String size = ShipsSize.small, String bonus = ShipsBonus.again}) => GameConfig(
  gameId: 'ships',
  seats: const [HumanSeat(1), HumanSeat(2)],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'size': size, 'bonus': bonus},
);

/// 8 × 8, fleet 4 3 3 2. Seat 0's fleet and seat 1's fleet, both legal.
final fleetA = [
  const Ship(0, 0, 4, true), // cells 0–3
  const Ship(0, 2, 3, true), // 16–18
  const Ship(0, 4, 3, true), // 32–34
  const Ship(0, 6, 2, true), // 48–49
];
final fleetB = [
  const Ship(7, 0, 4, false), // 7 15 23 31
  const Ship(5, 0, 3, false), // 5 13 21
  const Ship(0, 7, 3, true), // 56–58
  const Ship(3, 4, 2, true), // 35? no: 3,4 → 35–36
];

ShipsState placed({String bonus = ShipsBonus.again}) {
  var s = rules.initialState(config(bonus: bonus), 1);
  s = rules.apply(s, ShipsRules.place(0, fleetA));
  return rules.apply(s, ShipsRules.place(1, fleetB));
}

ShipsState shoot(ShipsState s, int seat, List<int> cells) {
  for (final c in cells) {
    expect(rules.isLegal(s, ShipsRules.shoot(seat, c)), isTrue, reason: 'seat $seat at $c');
    s = rules.apply(s, ShipsRules.shoot(seat, c));
  }
  return s;
}

void main() {
  group('setup', () {
    test('8 × 8 has the fleet 4 3 3 2, 10 × 10 the fleet 5 4 3 3 2', () {
      final small = rules.initialState(config(), 1);
      expect(small.size, 8);
      expect(small.fleet, [4, 3, 3, 2]);
      final big = rules.initialState(config(size: ShipsSize.big), 1);
      expect(big.size, 10);
      expect(big.fleet, [5, 4, 3, 3, 2]);
    });

    test('seat 0 places first, then seat 1, then seat 0 shoots', () {
      var s = rules.initialState(config(), 1);
      expect(rules.currentSeat(s), 0);
      expect(s.placing, isTrue);
      expect(rules.legalMoves(s, 0).single.type, 'place');
      expect(rules.legalMoves(s, 1), isEmpty);
      s = rules.apply(s, ShipsRules.place(0, fleetA));
      expect(rules.currentSeat(s), 1);
      s = rules.apply(s, ShipsRules.place(1, fleetB));
      expect(s.placing, isFalse);
      expect(rules.currentSeat(s), 0);
    });

    test('the offered placement is legal and the same for the same state', () {
      for (final size in [ShipsSize.small, ShipsSize.big]) {
        final s = rules.initialState(config(size: size), 5);
        final move = rules.legalMoves(s, 0).single;
        expect(rules.isLegal(s, move), isTrue);
        expect(rules.legalMoves(s, 0).single, move);
      }
    });

    test('random fleets never touch, not even by a corner, and stay at sea', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final (size, fleet) in [(8, const [4, 3, 3, 2]), (10, const [5, 4, 3, 3, 2])]) {
          final ships = ShipsRules.randomFleet(size, fleet, SeededRandom(seed));
          expect([for (final ship in ships) ship.length], fleet);
          expect(ShipsRules.validFleet(size, fleet, ships), isTrue, reason: 'seed $seed size $size');
        }
      }
    });

    test('touching, overlapping, off-sea or wrong-length fleets are illegal', () {
      final s = rules.initialState(config(), 1);
      bool ok(List<Ship> ships) => rules.isLegal(s, ShipsRules.place(0, ships));
      expect(ok(fleetA), isTrue);
      // Ship 2 one row lower touches ship 1 by a side.
      expect(ok([fleetA[0], const Ship(0, 1, 3, true), fleetA[2], fleetA[3]]), isFalse);
      // Touching by a corner.
      expect(ok([fleetA[0], const Ship(4, 1, 3, true), fleetA[2], fleetA[3]]), isFalse);
      // Overlap.
      expect(ok([fleetA[0], const Ship(1, 0, 3, false), fleetA[2], fleetA[3]]), isFalse);
      // Off the sea.
      expect(ok([const Ship(6, 0, 4, true), fleetA[1], fleetA[2], fleetA[3]]), isFalse);
      // A ship missing (lengths come from the fleet's order, so the text
      // cannot carry a wrong one).
      expect(ok([fleetA[0], fleetA[1], fleetA[2]]), isFalse);
    });

    test('a fleet travels as text and comes back the same', () {
      final text = ShipsRules.place(0, fleetB).data['ships']! as String;
      expect(ShipsRules.parseFleet(text, const [4, 3, 3, 2]), fleetB);
      expect(ShipsRules.parseFleet('nonsense', const [4, 3, 3, 2]), isNull);
    });
  });

  group('battle', () {
    test('a miss passes the turn; a shot cell cannot be shot again', () {
      var s = placed();
      s = shoot(s, 0, [63]);
      expect(s.isHit(0, 63), isFalse);
      expect(rules.currentSeat(s), 1);
      s = shoot(s, 1, [63]);
      expect(rules.isLegal(s, ShipsRules.shoot(0, 63)), isFalse);
      expect(rules.legalMoves(s, 0).length, 63);
    });

    test('a hit shoots again (default); with "alternate" the turn passes anyway', () {
      var s = shoot(placed(), 0, [7]);
      expect(s.isHit(0, 7), isTrue);
      expect(rules.currentSeat(s), 0);
      s = shoot(placed(bonus: ShipsBonus.alternate), 0, [7]);
      expect(rules.currentSeat(s), 1);
    });

    test('a sunk ship marks the water around it, which cannot be shot', () {
      var s = shoot(placed(), 0, [35, 36]);
      expect(s.sunkShips(1), [3]);
      // Around cells 35–36 (row 4, columns 3–4): rows 3–5, columns 2–5.
      final water = s.knownWater(0);
      expect(water, containsAll([26, 27, 28, 29, 34, 37, 42, 43, 44, 45]));
      expect(water, isNot(contains(35)));
      expect(rules.isLegal(s, ShipsRules.shoot(0, 27)), isFalse);
      expect(rules.legalMoves(s, 0).map((m) => m.data['cell']), isNot(contains(27)));
    });

    test('sinking the whole fleet wins; places, stars, scores and stats', () {
      var s = placed();
      s = shoot(s, 0, [63]); // miss
      s = shoot(s, 1, [0, 1, 2, 3, 63]); // sinks the 4, then misses
      s = shoot(s, 0, [7, 15, 23, 31, 5, 13, 21, 56, 57, 58, 35, 36]);
      expect(rules.isOver(s), isTrue);
      expect(rules.currentSeat(s), isNull);
      expect(s.winner, 0);
      final r = rules.result(s);
      expect(r.places, [1, 2]);
      expect(r.scores, [12, 4]);
      // Seat 1 hit 4 of 12 cells: under half.
      expect(r.stars, [3, 1]);
      expect(r.stats, {'shots': [13, 5], 'hits': [12, 4]});
    });

    test('the loser with at least half of the cells hit gets two stars', () {
      var s = placed();
      s = shoot(s, 0, [63]);
      s = shoot(s, 1, [0, 1, 2, 3, 16, 17, 62]);
      s = shoot(s, 0, [7, 15, 23, 31, 5, 13, 21, 56, 57, 58, 35, 36]);
      expect(rules.result(s).stars, [3, 2]);
    });

    test('a 10 × 10 game of random shots ends', () {
      final r = SeededRandom(9);
      var s = rules.initialState(config(size: ShipsSize.big), 2);
      var moves = 0;
      while (!rules.isOver(s)) {
        final legal = rules.legalMoves(s, rules.currentSeat(s)!);
        s = rules.apply(s, legal[r.nextInt(legal.length)]);
        expect(++moves, lessThan(250));
      }
    });

    test('JSON keeps every part of the state', () {
      var s = shoot(placed(), 0, [63]);
      s = shoot(s, 1, [0, 1, 2, 3]);
      final back = rules.stateFromJson(rules.stateToJson(s));
      expect(rules.stateToJson(back), rules.stateToJson(s));
      expect(back.knownWater(1), s.knownWater(1));
      final start = rules.initialState(config(), 3);
      expect(rules.stateToJson(rules.stateFromJson(rules.stateToJson(start))), rules.stateToJson(start));
    });
  });

  group('events', () {
    test('a sharp win (≥ 60 %) and an untouched win (no ship lost)', () {
      var s = placed();
      s = shoot(s, 0, [63]);
      s = shoot(s, 1, [0, 62]); // a hit on the 4, no ship lost
      s = shoot(s, 0, [7, 15, 23, 31, 5, 13, 21, 56, 57, 58, 35, 36]);
      expect(ShipsEvents.of(s).keys, {'${ShipsEvents.sharp}#0', '${ShipsEvents.untouched}#0'});
    });

    test('no events before the end, none for the loser', () {
      var s = placed();
      s = shoot(s, 0, [7, 15, 23, 31, 5, 13, 21, 56, 57, 58, 35]);
      expect(ShipsEvents.of(s), isEmpty, reason: 'one cell short of the win');
    });
  });
}
