import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/features/home/active_player_bar.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:deskovky/ui_kit/components/thinking_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<int> _player(WidgetTester tester, AppDatabase db, String name) async =>
    (await tester.runAsync(() => PlayerRepository(db).create(name: name, avatar: AvatarSpec.defaults)))!.id;

GameConfig _config(List<SeatConfig> seats, {RobotSpeed speed = RobotSpeed.fast}) => GameConfig(
  gameId: 'sample',
  seats: seats,
  difficulty: Difficulty.hard,
  robotSpeed: speed,
  options: const {'range': 20},
);

Future<void> _startGame(WidgetTester tester, AppDatabase db, Object extra) async {
  await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
  GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: extra);
  await tester.pumpAndSettle();
  expect(find.byType(GameScreen), findsOneWidget);
}

/// Lets real database I/O started inside fake time finish, then settles.
/// With [until], keeps going (up to 5 s of real time) until it is on screen,
/// so a slow CI machine never leaves a read half done.
Future<void> _settleIo(WidgetTester tester, {Finder? until}) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    if (until == null ? i >= 3 : until.evaluate().isNotEmpty) return;
  }
}

GameScreenState _screen(WidgetTester tester) => tester.state<GameScreenState>(find.byType(GameScreen));

Future<void> _tapNumber(WidgetTester tester, int n) async {
  final number = find.byKey(ValueKey('number$n'));
  await tester.ensureVisible(number);
  await tester.tap(number);
  await tester.pump();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('HUD has exit, pause, music, effects and a chip per player', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    for (final label in ['Konec', 'Pauza', 'Hudba', 'Efekty']) {
      expect(find.bySemanticsLabel(RegExp('^$label')), findsWidgets, reason: label);
    }
    expect(find.byKey(const ValueKey('chip0')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('chip1')), matching: find.text('Čipík')), findsOneWidget);
    // The sample game's own hint replaces the generic "Na tahu: …".
    expect(find.text('Tereza, tipni číslo od 1 do 20'), findsOneWidget);
  });

  testWidgets('music switch is remembered', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    await tester.tap(find.bySemanticsLabel(RegExp('^Hudba')));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => SettingsRepository(db).watchMusicOn().first), isFalse);
    expect(find.byIcon(Icons.music_off), findsOneWidget);
  });

  testWidgets('system back opens the pause; robots wait while paused', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    final secret = (_screen(tester).debugSession!.state as SampleState).secret;
    await _tapNumber(tester, secret == 1 ? 2 : 1);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Pokračovat'), findsOneWidget);
    final moves = _screen(tester).debugSession!.moves.length;
    await tester.pump(const Duration(seconds: 2));
    expect(_screen(tester).debugSession!.moves.length, moves);
    await tester.tap(find.text('Pokračovat'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(_screen(tester).debugSession!.moves.length, greaterThan(moves));
  });

  testWidgets('exit asks, saves the game and returns home; resume restores the same game', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    // A miss on purpose: hitting the secret would end the game (seeds vary).
    final secret = (_screen(tester).debugSession!.state as SampleState).secret;
    await _tapNumber(tester, secret == 1 ? 2 : 1);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    final hash = _screen(tester).debugSession!.hash;
    final seat = _screen(tester).debugSession!.rules.currentSeat(_screen(tester).debugSession!.state);

    await tester.tap(find.bySemanticsLabel(RegExp('^Konec')));
    await tester.pumpAndSettle();
    expect(find.text('Opravdu ukončit?'), findsOneWidget);
    expect(find.text('Rozehraná hra se uloží.'), findsOneWidget);
    await tester.tap(find.text('Ukončit'));
    // Saving the game and the home bar's players are real database I/O.
    await _settleIo(tester, until: find.byType(ActivePlayerBar));
    expect(find.byType(GameScreen), findsNothing);
    expect(find.byType(ActivePlayerBar), findsOneWidget);
    expect(await tester.runAsync(() => GameStore(db).savedSession('sample')), isNotNull);

    // "Restart" the app with the same database and continue.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
    await _settleIo(tester, until: find.text('Pokračovat: Hádej číslo'));
    await tester.tap(find.text('Pokračovat: Hádej číslo'));
    await _settleIo(tester, until: find.byType(GameScreen));
    final restored = _screen(tester).debugSession!;
    expect(restored.hash, hash);
    expect(restored.rules.currentSeat(restored.state), seat);
  });

  testWidgets('game time stops in the pause and continues after a resume (spec 13.4)', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await tester.runAsync(
      () => GameStore(db).saveSession(SavedGame(config: _config([HumanSeat(t), const RobotSeat()]), seed: 1, moves: const [], elapsedMs: 5000)),
    );
    await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
    await _settleIo(tester, until: find.text('Pokračovat: Hádej číslo'));
    await tester.tap(find.text('Pokračovat: Hádej číslo'));
    await _settleIo(tester, until: find.byType(GameScreen));
    expect(_screen(tester).debugElapsed, greaterThanOrEqualTo(const Duration(seconds: 5)));

    await tester.tap(find.bySemanticsLabel(RegExp('^Pauza')));
    await tester.pumpAndSettle();
    final paused = _screen(tester).debugElapsed;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 80)));
    expect(_screen(tester).debugElapsed, paused);
  });

  testWidgets("a player's first game shows a controls hint; later games do not (spec 13.4)", (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    expect(find.text('Ťukni na číslo, které tipuješ.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(
      () => StatsRepository(db).recordMatch(
        MatchRecord(
          gameId: 'sample',
          playedAt: DateTime.now(),
          duration: Duration.zero,
          difficulty: Difficulty.hard,
          participants: [
            MatchParticipant(seat: 0, playerId: t, place: 1, score: 1, stars: 3),
            const MatchParticipant(seat: 1, playerId: null, place: 2, score: 0, stars: 0),
          ],
        ),
      ),
    );
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    await _settleIo(tester);
    expect(find.text('Ťukni na číslo, které tipuješ.'), findsNothing);
  });

  testWidgets('pause → Konec → Zrušit goes back to the pause menu instead of a frozen game', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t), const RobotSeat()]));
    await tester.tap(find.bySemanticsLabel(RegExp('^Pauza')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Konec')));
    await tester.pumpAndSettle();
    expect(find.text('Opravdu ukončit?'), findsOneWidget);
    await tester.tap(find.text('Zrušit'));
    await tester.pumpAndSettle();
    expect(find.text('Pokračovat'), findsOneWidget, reason: 'the pause menu is back');
    await tester.tap(find.text('Pokračovat'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a saved game whose player was deleted cannot be resumed', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    final k = await _player(tester, db, 'Kuba');
    await tester.runAsync(() async {
      await GameStore(db).saveSession(SavedGame(config: _config([HumanSeat(t), HumanSeat(k)]), seed: 1, moves: const []));
      await PlayerRepository(db).delete(k);
    });
    await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
    await tester.tap(find.text('Pokračovat: Hádej číslo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Rozehranou hru nejde obnovit.'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(GameSetupScreen), findsOneWidget);
    expect(await tester.runAsync(() => GameStore(db).savedSession('sample')), isNull);
  });

  testWidgets('while a robot is thinking, taps on the board do nothing', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([const RobotSeat(), HumanSeat(t)], speed: RobotSpeed.slow));
    expect(find.text('🤖 Robík přemýšlí…'), findsOneWidget);
    // Desktop-wide chips show the thinking dots next to the robot's name.
    expect(find.descendant(of: find.byKey(const ValueKey('chip0')), matching: find.byType(ThinkingDots)), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('chip1')), matching: find.byType(ThinkingDots)), findsNothing);
    await tester.tap(find.byKey(const ValueKey('number1')), warnIfMissed: false);
    await tester.pump();
    expect(_screen(tester).debugSession!.moves, isEmpty);
    await tester.pump(const Duration(milliseconds: 1300));
    expect(_screen(tester).debugSession!.moves.single.seat, 0);
  });

  testWidgets('a finished game deletes its save and opens the results', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await _startGame(tester, db, _config([HumanSeat(t)]));
    for (var guard = 0; guard < 25 && _screen(tester).debugSession != null; guard++) {
      final s = _screen(tester).debugSession!;
      if (s.rules.isOver(s.state)) break;
      await _tapNumber(tester, (s.state as dynamic).low as int);
    }
    await tester.pumpAndSettle(const Duration(milliseconds: 700));
    final router = GoRouter.of(tester.element(find.byType(Navigator).last));
    expect(router.state.uri.path, '/play/sample/results');
    expect(await tester.runAsync(() => GameStore(db).savedSession('sample')), isNull);
  });

  testWidgets('the player to move pulses gently when animations are allowed', (tester) async {
    final t = await _player(tester, db, 'Tereza');
    await pumpApp(tester, size: const Size(800, 1280), db: db);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: _config([HumanSeat(t)]));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final scales = <double>{};
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      final transition = tester.widget<ScaleTransition>(
        find.descendant(of: find.byKey(const ValueKey('chip0')), matching: find.byType(ScaleTransition)),
      );
      scales.add(transition.scale.value);
    }
    expect(scales.length, greaterThan(1));
    // Leave the game so the endless pulse stops before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  group('review fixes', () {
    testWidgets('4 players fit the HUD on a 360 dp phone (es, 130 %)', (tester) async {
      final t = await _player(tester, db, 'Maximiliánek123');
      await pumpApp(tester, size: const Size(360, 740), locale: const Locale('es'), textScale: 1.3, db: db, disableAnimations: true);
      GoRouter.of(tester.element(find.byType(Navigator).first)).push(
        '/play/sample',
        extra: _config([HumanSeat(t), const RobotSeat(), const RobotSeat(), const RobotSeat()], speed: RobotSpeed.slow),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      for (var seat = 0; seat < 4; seat++) {
        final rect = tester.getRect(find.byKey(ValueKey('chip$seat')));
        expect(rect.left >= 0 && rect.right <= 360, isTrue, reason: 'chip$seat at $rect');
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a saved game with more seats than the game allows is discarded, not crashing', (tester) async {
      final t = await _player(tester, db, 'Tereza');
      await tester.runAsync(() => GameStore(db).saveSession(SavedGame(
        config: _config([HumanSeat(t), for (var i = 0; i < 4; i++) const RobotSeat()]),
        seed: 1,
        moves: const [],
      )));
      await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
      await tester.tap(find.text('Pokračovat: Hádej číslo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      expect(find.text('Rozehranou hru nejde obnovit.'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(GameSetupScreen), findsOneWidget);
    });

    testWidgets('a game never starts with robots only', (tester) async {
      final t = await _player(tester, db, 'Tereza');
      await tester.runAsync(() async {
        await GameStore(db).saveLastConfig(_config([HumanSeat(t), const RobotSeat()]));
        await PlayerRepository(db).delete(t);
      });
      await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
      expect(find.text('Pokračovat: Hádej číslo'), findsNothing, reason: 'nobody could play');
      GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: _config([HumanSeat(t), const RobotSeat()]));
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsNothing);
      expect(find.byType(GameSetupScreen), findsOneWidget);
    });

    testWidgets('continuing with a deleted player tells that a robot took the seat', (tester) async {
      final t = await _player(tester, db, 'Tereza');
      final k = await _player(tester, db, 'Kuba');
      await tester.runAsync(() async {
        await GameStore(db).saveLastConfig(_config([HumanSeat(t), HumanSeat(k)]));
        await PlayerRepository(db).delete(k);
      });
      await pumpApp(tester, size: const Size(800, 1280), db: db, disableAnimations: true);
      await tester.tap(find.text('Pokračovat: Hádej číslo'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.text('Chybějící hráče nahradili roboti.'), findsOneWidget);
      expect(_screen(tester).debugSession!.config.seats, [HumanSeat(t), const RobotSeat()]);
    });

    testWidgets('the exit dialog pauses robots until it is cancelled', (tester) async {
      final t = await _player(tester, db, 'Tereza');
      await _startGame(tester, db, _config([const RobotSeat(), HumanSeat(t)], speed: RobotSpeed.slow));
      await tester.tap(find.bySemanticsLabel(RegExp('^Konec')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(_screen(tester).debugSession!.moves, isEmpty, reason: 'robot waits under the dialog');
      await tester.tap(find.text('Zrušit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));
      expect(_screen(tester).debugSession!.moves, hasLength(1));
    });
  });
}
