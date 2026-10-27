import 'dart:convert';
import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/game_option.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'game_test_host.dart';

/// The contract every game passes (spec 8 bod 4, 13.4 Definition of Done).
/// Skeletons and unfinished games use `playable: false`: then only the
/// manifest, texts, sounds and icon are checked.
///
/// ```dart
/// void main() => runGameContract(memoryModule);
/// ```
void runGameContract(GameModule<Object?> module, {bool playable = true, int maxMoves = 5000}) {
  module.withType(<S>(m) {
    group('contract ${m.id}', () {
      _manifest(m);
      if (playable) _playable(m, maxMoves);
    });
    return null;
  });
}

void _manifest<S>(GameModule<S> m) {
  final id = m.id;

  test('manifest: id, keys with the "$id." prefix, players, points multiplier', () {
    expect(id, matches(RegExp(r'^[a-z_]+$')));
    for (final key in [m.titleKey, m.descriptionKey, m.rulesKey]) {
      expect(key, startsWith('$id.'), reason: key);
    }
    expect(m.minPlayers, inInclusiveRange(1, 4));
    expect(m.maxPlayers, inInclusiveRange(m.minPlayers, 4));
    expect(m.pointsMultiplier, inInclusiveRange(0.5, 2.0));
    expect(m.difficulties, isNotEmpty);
    expect(m.musicTrack, id, reason: 'music is music/<id>.ogg');
  });

  test('every text exists in Czech, English and Spanish', () {
    final t = m.texts;
    final used = <String>{
      m.titleKey, m.descriptionKey, m.rulesKey,
      for (final o in m.options) o.labelKey,
      for (final o in m.options.whereType<ChoiceOption>())
        for (final (_, label) in o.choices) if (label.startsWith('$id.')) label,
      for (final b in m.badges) ...[b.titleKey, b.descriptionKey],
    };
    for (final key in {...used, ...t.keys}) {
      expect(key, startsWith('$id.'), reason: key);
      for (final language in [t.cs, t.en, t.es]) {
        expect(language[key], isNotNull, reason: '$key is missing in a language');
        expect(language[key]!.trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('options: unique ids, defaults among the choices', () {
    final ids = [for (final o in m.options) o.id];
    expect(ids.toSet().length, ids.length);
    for (final o in m.options.whereType<ChoiceOption>()) {
      expect([for (final (v, _) in o.choices) v], contains(o.defaultValue), reason: o.id);
    }
  });

  test('badges and sounds belong to the game and exist', () {
    for (final b in m.badges) {
      expect(b.id, startsWith('$id.'));
      expect(b.reward, greaterThanOrEqualTo(0));
    }
    expect(m.sfx.length, lessThanOrEqualTo(3), reason: 'spec 13.4: at most three own effects');
    for (final MapEntry(key: sfx, value: path) in m.sfx.entries) {
      expect(sfx, startsWith('$id.'));
      expect(path, startsWith('games/$id/sfx/'));
      expect(File('assets/$path').existsSync(), isTrue, reason: path);
    }
    expect(File('assets/audio/music/$id.ogg').existsSync(), isTrue);
  });

  testWidgets('the icon draws', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Center(child: SizedBox.square(dimension: 120, child: m.icon(_Context.of(tester))))));
    expect(tester.takeException(), isNull);
  });
}

/// Every seating the setup screen allows: n seats, each a person or a robot,
/// at least one person (spec 5.7).
List<List<SeatConfig>> _seatings(GameModule<Object?> m) => [
  for (var n = m.minPlayers; n <= m.maxPlayers; n++)
    for (var mask = 0; mask < (1 << n); mask++)
      if (mask != 0 && (m.supportsAi || mask == (1 << n) - 1))
        [for (var s = 0; s < n; s++) (mask & (1 << s)) != 0 ? HumanSeat(s + 1) : const RobotSeat()],
];

GameConfig _config(GameModule<Object?> m, List<SeatConfig> seats, Difficulty difficulty) => GameConfig(
  gameId: m.id,
  seats: seats,
  difficulty: difficulty,
  robotSpeed: RobotSpeed.fast,
  options: {for (final o in m.options) o.id: o.defaultValue},
);

/// Plays a whole game: robots (or everyone, with [allAi]) by the game's AI,
/// people by a seeded random legal move. Checks every move on the way.
GameSession<S> _playOut<S>(GameModule<S> m, GameConfig config, int seed, int maxMoves, {bool allAi = false}) {
  final session = GameSession<S>.start(m.rules, config, seed);
  final random = SeededRandom(seed);
  for (var i = 0; i < maxMoves && !m.rules.isOver(session.state); i++) {
    final seat = m.rules.currentSeat(session.state);
    expect(seat, isNotNull, reason: 'a running game has a seat to move');
    final legal = m.rules.legalMoves(session.state, seat!);
    expect(legal, isNotEmpty, reason: 'seat $seat must have a legal move');
    final robot = allAi || config.seats[seat] is RobotSeat;
    final ai = m.ai;
    final move = robot && ai != null
        ? ai.chooseMove(session.state, seat, config.difficulty, SeededRandom(random.nextInt(1 << 30)))
        : legal[random.nextInt(legal.length)];
    expect(m.rules.isLegal(session.state, move), isTrue, reason: 'move $i ${move.toJson()} is illegal');
    expect(session.apply(move), isTrue);
  }
  expect(m.rules.isOver(session.state), isTrue, reason: 'the game ends within $maxMoves moves');
  return session;
}

void _playable<S>(GameModule<S> m, int maxMoves) {
  test('starts for every number of players, people and robots, and difficulty', () {
    for (final seats in _seatings(m)) {
      for (final difficulty in m.difficulties) {
        final config = _config(m, seats, difficulty);
        final state = m.rules.initialState(config, 7);
        final seat = m.rules.currentSeat(state);
        expect(seat, isNotNull, reason: '$seats $difficulty');
        expect(m.rules.legalMoves(state, seat!), isNotEmpty, reason: '$seats $difficulty');
      }
    }
  });

  test('the AI plays whole games by itself on every difficulty, legally', () {
    for (final difficulty in m.difficulties) {
      for (var seed = 0; seed < 3; seed++) {
        final seats = [for (var s = 0; s < m.maxPlayers; s++) s == 0 ? const HumanSeat(1) : const RobotSeat()];
        _playOut(m, _config(m, seats, difficulty), seed, maxMoves, allAi: true);
      }
    }
  });

  test('every choice of every option starts and plays out (e.g. each board size)', () {
    final seats = [const HumanSeat(1), for (var s = 1; s < m.minPlayers; s++) const RobotSeat()];
    final base = _config(m, seats, Difficulty.medium);
    final variants = [
      for (final o in m.options)
        ...switch (o) {
          ChoiceOption(:final choices) => [for (final (v, _) in choices) (o.id, v)],
          ToggleOption() => [(o.id, true), (o.id, false)],
        },
    ];
    for (final (id, value) in variants) {
      final config = base.copyWith(options: {...base.options, id: value});
      _playOut(m, config, 3, maxMoves);
    }
  });

  test('a finished game gives a valid result', () {
    for (final seats in _seatings(m).take(6)) {
      final session = _playOut(m, _config(m, seats, Difficulty.medium), 11, maxMoves);
      final result = m.rules.result(session.state);
      final n = seats.length;
      expect(result.places, hasLength(n));
      expect(result.scores, hasLength(n));
      expect(result.stars, hasLength(n));
      for (final place in result.places) {
        // Alone, a lost game is place 2 (spec 5.6); otherwise places 1..n.
        expect(place, inInclusiveRange(1, n == 1 ? 2 : n));
      }
      if (n > 1) expect(result.places, contains(1));
      for (final stars in result.stars) {
        expect(stars, inInclusiveRange(0, 3));
      }
    }
  });

  test('state and moves survive JSON; replay and save–restore give the same game', () {
    final seats = [const HumanSeat(1), for (var s = 1; s < m.minPlayers; s++) HumanSeat(s + 1)];
    final config = _config(m, seats, Difficulty.medium);
    final session = _playOut(m, config, 5, maxMoves);
    for (final move in session.moves) {
      expect(Move.fromJson(jsonDecode(jsonEncode(move.toJson()))), move);
    }
    final json = jsonEncode(m.rules.stateToJson(session.state));
    expect(jsonEncode(m.rules.stateToJson(m.rules.stateFromJson(jsonDecode(json) as Map<String, Object?>))), json);

    final replay = GameSession<S>.start(m.rules, config, session.seed);
    for (final move in session.moves) {
      replay.apply(move);
    }
    expect(replay.hash, session.hash);

    // Saved in the middle of the game, restored the same.
    final half = GameSession<S>.start(m.rules, config, session.seed);
    for (final move in session.moves.take(session.moves.length ~/ 2)) {
      half.apply(move);
    }
    final halfSaved = SavedGame.fromJson(jsonDecode(jsonEncode(half.toSave().toJson())))!;
    expect(GameSession.restore(m.rules, halfSaved)!.hash, half.hash);

    final saved = SavedGame.fromJson(jsonDecode(jsonEncode(session.toSave(elapsed: const Duration(seconds: 3)).toJson())))!;
    final restored = GameSession.restore(m.rules, saved)!;
    expect(restored.hash, session.hash);
    expect(restored.elapsedBefore, const Duration(seconds: 3));
  });

  testWidgets('the board draws at the start of a game', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 915);
    addTearDown(tester.view.reset);
    final config = _config(m, [for (var s = 0; s < m.minPlayers; s++) HumanSeat(s + 1)], Difficulty.easy);
    final state = m.rules.initialState(config, 1);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('cs'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Builder(
            builder: (context) => m.board(
              context,
              GameBoardView<S>(
                state: state,
                lastMove: null,
                mySeat: m.rules.currentSeat(state),
                canAct: true,
                submit: (_) async => true,
                host: GameTestHost(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}

/// A context for building an icon outside the widget tree.
abstract final class _Context {
  static BuildContext of(WidgetTester tester) => tester.binding.rootElement!;
}
