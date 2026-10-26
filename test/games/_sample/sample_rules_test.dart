import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/games/_sample/sample_ai.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const _rules = SampleRules();
const _ai = SampleAi();

GameConfig _config({int seats = 2, int range = 50}) => GameConfig(
  gameId: 'sample',
  seats: [for (var i = 0; i < seats; i++) i == 0 ? const HumanSeat(1) : const RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'range': range},
);

Move _guess(int seat, int value) => Move(seat: seat, type: 'guess', data: {'value': value});

/// Plays [state] to the end with [guessFor] choosing each value.
GameSession<SampleState> _play(GameSession<SampleState> s, int Function(SampleState state) guessFor) {
  while (!_rules.isOver(s.state)) {
    expect(s.apply(_guess(_rules.currentSeat(s.state)!, guessFor(s.state))), isTrue);
  }
  return s;
}

void main() {
  test('the same seed hides the same number in range', () {
    final a = _rules.initialState(_config(range: 20), 7);
    final b = _rules.initialState(_config(range: 20), 7);
    expect(a.secret, b.secret);
    expect(a.secret, inInclusiveRange(1, 20));
    expect((a.low, a.high, a.current), (1, 20, 0));
  });

  test('only the current seat may guess, and only inside the bounds', () {
    final s = _rules.initialState(_config(), 1);
    expect(_rules.isLegal(s, _guess(1, 10)), isFalse);
    expect(_rules.isLegal(s, _guess(0, 0)), isFalse);
    expect(_rules.isLegal(s, _guess(0, 51)), isFalse);
    expect(_rules.isLegal(s, const Move(seat: 0, type: 'flip', data: {'value': 3})), isFalse);
    expect(_rules.isLegal(s, _guess(0, 25)), isTrue);
  });

  test('legal moves are exactly the numbers still possible, for the seat to move only', () {
    final s = _rules.initialState(_config(), 1);
    expect([for (final m in _rules.legalMoves(s, 0)) m.data['value']], [for (var v = s.low; v <= s.high; v++) v]);
    expect(_rules.legalMoves(s, 0).every((m) => _rules.isLegal(s, m)), isTrue);
    expect(_rules.legalMoves(s, 1), isEmpty);
  });

  test('a miss narrows the shared bounds and passes the turn around the table', () {
    final session = GameSession.start(_rules, _config(seats: 3, range: 100), 3);
    final secret = session.state.secret;
    final low = secret > 1 ? 1 : 100;
    session.apply(_guess(0, low));
    if (low < secret) expect(session.state.low, low + 1);
    expect(session.state.current, 1);
    final s2 = session.state;
    session.apply(_guess(1, s2.low == secret ? s2.high : s2.low));
    expect(session.state.current, 2);
  });

  test('a hit ends the game; winner first, everybody else shares second', () {
    final session = GameSession.start(_rules, _config(seats: 3, range: 20), 5);
    final secret = session.state.secret;
    _play(session, (s) => s.current == 2 ? secret : (s.low == secret ? s.high : s.low));
    expect(_rules.isOver(session.state), isTrue);
    expect(_rules.currentSeat(session.state), isNull);
    final result = _rules.result(session.state);
    final winner = session.state.winner!;
    expect(result.places[winner], 1);
    expect([for (var i = 0; i < 3; i++) if (i != winner) result.places[i]], everyElement(2));
    expect(result.stars[winner], 3);
  });

  test('single-player stars on range 50: 6 tips → 3, 9 → 2, 10 → 1', () {
    int starsFor(int tips) {
      // Walk the low end up until the secret, then hit it with the given tip count.
      for (var seed = 0; seed < 500; seed++) {
        final session = GameSession.start(_rules, _config(seats: 1), seed);
        final secret = session.state.secret;
        if (secret < tips) continue;
        for (var i = 1; i < tips; i++) {
          session.apply(_guess(0, i));
        }
        session.apply(_guess(0, secret));
        return _rules.result(session.state).stars.single;
      }
      fail('no suitable seed');
    }

    expect(starsFor(6), 3);
    expect(starsFor(9), 2);
    expect(starsFor(10), 1);
  });

  test('state survives JSON', () {
    final session = GameSession.start(_rules, _config(seats: 2), 9);
    session.apply(_guess(0, 10));
    final json = _rules.stateToJson(session.state);
    expect(_rules.stateToJson(_rules.stateFromJson(json)), json);
  });

  group('AI', () {
    for (final difficulty in Difficulty.values) {
      for (var seats = 1; seats <= 4; seats++) {
        test('$difficulty, $seats seat(s): 100 self-played games end with legal moves and replay exactly', () {
          for (var seed = 0; seed < 100; seed++) {
            final session = GameSession.start(_rules, _config(seats: seats, range: 100), seed);
            var turn = 0;
            while (!_rules.isOver(session.state)) {
              final seat = _rules.currentSeat(session.state)!;
              final move = _ai.chooseMove(session.state, seat, difficulty, SeededRandom(seed * 1000 + turn++));
              expect(session.apply(move), isTrue, reason: 'illegal $move (seed $seed)');
              expect(turn, lessThan(200));
            }
            expect(GameSession.restore(_rules, session.toSave())!.hash, session.hash);
          }
        });
      }
    }

    test('hard AI alone always finds a number in 1–100 within 7 tips', () {
      for (var seed = 0; seed < 200; seed++) {
        final session = GameSession.start(_rules, _config(seats: 1, range: 100), seed);
        _play(session, (s) => _ai.chooseMove(s, 0, Difficulty.hard, SeededRandom(seed)).data['value']! as int);
        expect(session.moves.length, lessThanOrEqualTo(7), reason: 'seed $seed');
      }
    });
  });
}
