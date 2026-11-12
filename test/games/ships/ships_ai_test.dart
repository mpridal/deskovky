import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/ships/ships_ai.dart';
import 'package:deskovky/games/ships/ships_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = ShipsRules();
const ai = ShipsAi();

ShipsState start(int seed, {String size = ShipsSize.small}) => rules.initialState(
  GameConfig(
    gameId: 'ships',
    seats: const [RobotSeat(), RobotSeat()],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: {'size': size},
  ),
  seed,
);

/// Plays [a] (seat 0) against [b] (seat 1); returns the winner.
int duel(Difficulty a, Difficulty b, int seed, {String size = ShipsSize.small}) {
  var s = start(seed, size: size);
  final random = SeededRandom(seed);
  while (!rules.isOver(s)) {
    final seat = rules.currentSeat(s)!;
    final move = ai.chooseMove(s, seat, seat == 0 ? a : b, SeededRandom(random.nextInt(1 << 30)));
    expect(rules.isLegal(s, move), isTrue, reason: '$move');
    s = rules.apply(s, move);
  }
  return s.winner!;
}

void main() {
  test('every difficulty places a legal fleet, different from game to game', () {
    final fleets = <String>{};
    for (final d in Difficulty.values) {
      for (var seed = 0; seed < 5; seed++) {
        final move = ai.chooseMove(start(1), 0, d, SeededRandom(seed));
        expect(move.type, 'place');
        expect(rules.isLegal(start(1), move), isTrue);
        fleets.add(move.data['ships']! as String);
      }
    }
    expect(fleets, hasLength(5), reason: "one fleet per seed, whatever the difficulty");
  });

  test('the robot does not peek: where the unseen ships lie does not change its shot', () {
    // Seat 0 (robot) has shot 63 (water) and 7 (hit). Two different seat-1
    // fleets that agree on those two cells.
    const mine = [Ship(0, 0, 4, true), Ship(0, 2, 3, true), Ship(0, 4, 3, true), Ship(0, 6, 2, true)];
    const theirsA = [Ship(7, 0, 4, false), Ship(5, 0, 3, false), Ship(0, 7, 3, true), Ship(3, 4, 2, true)];
    const theirsB = [Ship(7, 0, 4, false), Ship(1, 1, 3, true), Ship(2, 5, 3, false), Ship(4, 7, 2, true)];
    for (final d in Difficulty.values) {
      final moves = {
        for (final theirs in [theirsA, theirsB])
          () {
            var s = rules.apply(start(1), ShipsRules.place(0, mine));
            s = rules.apply(s, ShipsRules.place(1, theirs));
            s = rules.apply(s, ShipsRules.shoot(0, 63));
            s = rules.apply(s, ShipsRules.shoot(1, 63));
            s = rules.apply(s, ShipsRules.shoot(0, 7));
            return ai.chooseMove(s, 0, d, SeededRandom(4)).data['cell'];
          }(),
      };
      expect(moves, hasLength(1), reason: '$d');
    }
  });

  test('medium and hard shoot next to an unsunk hit', () {
    const mine = [Ship(0, 0, 4, true), Ship(0, 2, 3, true), Ship(0, 4, 3, true), Ship(0, 6, 2, true)];
    const theirs = [Ship(7, 0, 4, false), Ship(5, 0, 3, false), Ship(0, 7, 3, true), Ship(3, 4, 2, true)];
    var s = rules.apply(start(1), ShipsRules.place(0, mine));
    s = rules.apply(s, ShipsRules.place(1, theirs));
    s = rules.apply(s, ShipsRules.shoot(0, 35)); // hit on the 2 at 35–36
    for (final d in [Difficulty.medium, Difficulty.hard]) {
      for (var seed = 0; seed < 10; seed++) {
        expect([27, 34, 36, 43], contains(ai.chooseMove(s, 0, d, SeededRandom(seed)).data['cell']), reason: '$d');
      }
    }
  });

  test('hard beats easy in at least 60 % of games, medium beats easy more often than not', () {
    var hard = 0, medium = 0;
    const games = 60;
    for (var seed = 0; seed < games; seed++) {
      // Each side starts half the games.
      if (seed.isEven) {
        if (duel(Difficulty.hard, Difficulty.easy, seed) == 0) hard++;
        if (duel(Difficulty.medium, Difficulty.easy, seed) == 0) medium++;
      } else {
        if (duel(Difficulty.easy, Difficulty.hard, seed) == 1) hard++;
        if (duel(Difficulty.easy, Difficulty.medium, seed) == 1) medium++;
      }
    }
    expect(hard / games, greaterThanOrEqualTo(0.6), reason: 'hard won $hard of $games');
    expect(medium / games, greaterThan(0.5), reason: 'medium won $medium of $games');
  });

  test('hard on the 10 × 10 sea is quick enough and finishes', () {
    final watch = Stopwatch()..start();
    duel(Difficulty.hard, Difficulty.hard, 3, size: ShipsSize.big);
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}
