import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/games/matches/matches_events.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MatchesRules();

MatchesState play(List<(int, int)> takes) {
  var s = rules.initialState(
    const GameConfig(
      gameId: 'matches',
      seats: [HumanSeat(1), HumanSeat(2)],
      difficulty: Difficulty.medium,
      robotSpeed: RobotSpeed.fast,
      options: {'start': MatchesStart.first},
    ),
    1,
  );
  for (final (row, count) in takes) {
    s = rules.apply(s, MatchesRules.take(s.current, row, count));
  }
  return s;
}

void main() {
  test('nothing while the game is open', () {
    expect(MatchesEvents.of(play([])), isEmpty);
    expect(MatchesEvents.of(play([(0, 3), (1, 5)])), isEmpty);
  });

  test('a win as soon as only one match is left: the other player must take it', () {
    final s = play([(0, 3), (1, 5), (2, 6)]);
    expect(rules.isOver(s), isFalse);
    expect(MatchesEvents.of(s), {
      'matches.win#0': {'seat': 0},
    });
    // The same events once the last match is taken – reported only once by the board.
    expect(MatchesEvents.of(rules.apply(s, MatchesRules.take(1, 2, 1))), MatchesEvents.of(s));
  });

  test('a win after the other one took several last matches at once', () {
    expect(MatchesEvents.of(play([(0, 3), (1, 5), (2, 7)])), {
      'matches.win#1': {'seat': 1},
    });
  });

  test('a flawless win reports flawless too', () {
    final s = play([(0, 1), (2, 6), (1, 2), (0, 2), (1, 3)]);
    expect(MatchesEvents.of(s), {
      'matches.win#0': {'seat': 0},
      'matches.flawless#0': {'seat': 0},
    });
    expect(MatchesEvents.idOf('matches.flawless#0'), 'matches.flawless');
  });
}
