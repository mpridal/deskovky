import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_option.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/move_transport.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/game/state_hash.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_game.dart';

const _rules = FakeRules();

void main() {
  group('SeededRandom', () {
    test('same seed gives the same sequence', () {
      List<int> seq(int seed) {
        final r = SeededRandom(seed);
        return [for (var i = 0; i < 10; i++) r.nextInt(1000)];
      }

      expect(seq(42), seq(42));
      expect(seq(42), isNot(seq(43)));
    });

    test('sequence never changes (saved games replay with it)', () {
      final r = SeededRandom(42);
      expect([for (var i = 0; i < 8; i++) r.nextInt(1000000)], [
        506609, 121042, 610489, 831413, 786203, 188545, 534600, 258001,
      ]);
    });

    test('seed 0 still produces numbers', () {
      final r = SeededRandom(0);
      expect({for (var i = 0; i < 20; i++) r.nextInt(1000)}.length, greaterThan(10));
    });

    test('nextInt covers the whole range', () {
      final r = SeededRandom(7);
      final seen = {for (var i = 0; i < 10000; i++) r.nextInt(6)};
      expect(seen, {0, 1, 2, 3, 4, 5});
    });

    test('nextDouble is in [0, 1)', () {
      final r = SeededRandom(3);
      for (var i = 0; i < 1000; i++) {
        final d = r.nextDouble();
        expect(d >= 0 && d < 1, isTrue);
      }
    });
  });

  group('stateHash', () {
    test('ignores key order, sees content', () {
      expect(stateHash({'b': 1, 'a': [1, 2]}), stateHash({'a': [1, 2], 'b': 1}));
      expect(stateHash({'a': 1}), isNot(stateHash({'a': 2})));
      expect(stateHash({'a': {'y': 1, 'x': 2}}), stateHash({'a': {'x': 2, 'y': 1}}));
    });
  });

  group('JSON', () {
    test('GameConfig round-trips', () {
      final c = fakeConfig(seats: 3).copyWith(options: {'range': 20});
      expect(GameConfig.fromJson(c.toJson()), c);
    });

    test('broken GameConfig gives null', () {
      expect(GameConfig.fromJson(null), isNull);
      expect(GameConfig.fromJson({'gameId': 'x', 'seats': [{'type': 'alien'}]}), isNull);
      expect(GameConfig.fromJson({'gameId': 'x', 'seats': <Object>[]}), isNull);
      expect(GameConfig.fromJson({'seats': [{'type': 'robot'}]}), isNull);
    });

    test('unknown difficulty or speed fall back to medium / normal', () {
      final json = fakeConfig().toJson()
        ..['difficulty'] = 'insane'
        ..['robotSpeed'] = 'warp';
      final c = GameConfig.fromJson(json)!;
      expect(c.difficulty, Difficulty.medium);
      expect(c.robotSpeed, RobotSpeed.normal);
    });

    test('Move and SavedGame round-trip; broken save gives null', () {
      const m = Move(seat: 1, type: 'add', data: {'n': 2});
      expect(Move.fromJson(m.toJson()), m);
      final save = SavedGame(config: fakeConfig(), seed: 9, moves: const [m]);
      expect(SavedGame.fromJson(save.toJson()), save);
      expect(SavedGame.fromJson(null), isNull);
      expect(SavedGame.fromJson({'seed': 'x'}), isNull);
    });
  });

  group('normalizeOptions', () {
    const schema = [
      ChoiceOption(id: 'range', labelKey: 'r', choices: [(20, 'a'), (50, 'b')], defaultValue: 50),
      ToggleOption(id: 'hints', labelKey: 'h', defaultValue: true),
    ];

    test('fills defaults, drops unknown keys and invalid values', () {
      expect(normalizeOptions(schema, null), {'range': 50, 'hints': true});
      expect(normalizeOptions(schema, {'range': 20, 'extra': 1}), {'range': 20, 'hints': true});
      expect(normalizeOptions(schema, {'range': 33, 'hints': 'yes'}), {'range': 50, 'hints': true});
    });
  });

  group('GameSession', () {
    test('illegal move changes nothing', () {
      final s = GameSession.start(_rules, fakeConfig(), 1);
      final hash = s.hash;
      expect(s.apply(const Move(seat: 1, type: 'add', data: {'n': 1})), isFalse);
      expect(s.apply(const Move(seat: 0, type: 'add', data: {'n': 5})), isFalse);
      expect(s.hash, hash);
      expect(s.moves, isEmpty);
    });

    test('replay of a saved game gives the same state', () {
      for (var seed = 0; seed < 20; seed++) {
        final s = GameSession.start(_rules, fakeConfig(seats: 3), seed);
        final r = SeededRandom(seed);
        while (!_rules.isOver(s.state)) {
          s.apply(Move(seat: _rules.currentSeat(s.state)!, type: 'add', data: {'n': 1 + r.nextInt(2)}));
        }
        final restored = GameSession.restore(_rules, SavedGame.fromJson(s.toSave().toJson())!)!;
        expect(restored.hash, s.hash, reason: 'seed $seed');
        expect(_rules.currentSeat(restored.state), _rules.currentSeat(s.state));
        expect(restored.moves, s.moves);
      }
    });

    test('restore refuses a save with an illegal move', () {
      final save = SavedGame(config: fakeConfig(), seed: 1, moves: const [Move(seat: 1, type: 'add', data: {'n': 1})]);
      expect(GameSession.restore(_rules, save), isNull);
    });
  });

  group('LocalTransport', () {
    test('broadcasts legal moves only', () async {
      final session = GameSession.start(_rules, fakeConfig(), 1);
      final transport = LocalTransport(session);
      addTearDown(transport.dispose);
      final applied = <Move>[];
      transport.applied.listen(applied.add);
      expect(await transport.submit(const Move(seat: 0, type: 'add', data: {'n': 1})), isTrue);
      expect(await transport.submit(const Move(seat: 0, type: 'add', data: {'n': 1})), isFalse);
      await pumpEventQueue();
      expect(applied, hasLength(1));
      expect(session.moves, hasLength(1));
    });
  });

  group('AiRunner', () {
    test('inline and isolate runners agree', () async {
      final state = _rules.initialState(fakeConfig(), 5);
      const ai = FakeAi();
      final inline = await const InlineAiRunner().run(ai, state, 0, Difficulty.medium, 11);
      final isolate = await const IsolateAiRunner().run(ai, state, 0, Difficulty.medium, 11);
      expect(isolate, inline);
    });
  });
}
