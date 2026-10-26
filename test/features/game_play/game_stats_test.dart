import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/features/game_play/game_outcome.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_play/seat_identity.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/fake_audio_backend.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

const _config = GameConfig(
  gameId: 'sample',
  seats: [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.hard,
  robotSpeed: RobotSpeed.slow,
  options: {'range': 20},
);

/// The 600 ms pause before results, with real time for the database writes.
Future<void> _letRecord(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  }
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<void> hitSecret(WidgetTester tester) async {
    final session = tester.state<GameScreenState>(find.byType(GameScreen)).debugSession!;
    final tile = find.byKey(ValueKey('number${(session.state as SampleState).secret}'));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump();
  }

  testWidgets('winning records the game once and shows new badges with the achievement sound', (tester) async {
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    final audio = FakeAudioBackend();
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: _config);
    await tester.pumpAndSettle();
    await hitSecret(tester);
    await _letRecord(tester);
    expect(find.byType(ResultsScreen), findsOneWidget);
    for (final title in ['První výhra', 'Přemožitel robotů', 'Trefa!']) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget, reason: title);
    }
    await tester.pump(const Duration(milliseconds: 1500));
    expect([for (final s in audio.sfx) s.$2], contains('sfx/achievement.wav'));

    final matches = await tester.runAsync(() => StatsRepository(db).allMatches());
    expect(matches!.length, 1);
    expect(matches.single.participants.first.place, 1);
  });

  testWidgets('results without new badges show no badge section', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(
      '/play/sample/results',
      extra: GameOutcomeView(
        config: _config,
        result: const GameResult(places: [2, 1], scores: [1, 2], stars: [1, 3]),
        seats: const [
          SeatIdentity(seat: 0, name: 'Tereza', profile: null, difficulty: null),
          SeatIdentity(seat: 1, name: 'Čipík', profile: null, difficulty: Difficulty.hard),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('newBadges')), findsNothing);
  });

  testWidgets('a game continued after a restart is recorded exactly once', (tester) async {
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: _config);
    await tester.pumpAndSettle();
    final session = tester.state<GameScreenState>(find.byType(GameScreen)).debugSession!;
    final s = session.state as SampleState;
    final miss = s.secret == s.low ? s.high : s.low;
    final tile = find.byKey(ValueKey('number$miss'));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await _letRecord(tester);
    final saved = await tester.runAsync(() => GameStore(db).savedSession('sample'));
    expect(saved, isNotNull, reason: 'the game in progress was saved');

    // "Restart": a fresh app on the same database continues the saved game.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample', extra: saved);
    await tester.pumpAndSettle();
    for (var i = 0; i < 40 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      final screen = find.byType(GameScreen);
      if (screen.evaluate().isNotEmpty) {
        final live = tester.state<GameScreenState>(screen).debugSession!;
        final st = live.state as SampleState;
        if (!live.rules.isOver(st) && live.rules.currentSeat(st) == 0) {
          final hit = find.byKey(ValueKey('number${st.secret}'));
          await tester.ensureVisible(hit);
          await tester.tap(hit);
        }
      }
      await _letRecord(tester);
    }
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect((await tester.runAsync(() => StatsRepository(db).allMatches()))!.length, 1);
    expect(await tester.runAsync(() => GameStore(db).savedSession('sample')), isNull);
  });

  testWidgets('two people earn badges in one game: all cards shown, one fanfare', (tester) async {
    final (t, k) = (await tester.runAsync(() async {
      final players = PlayerRepository(db);
      final t = (await players.create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
      final k = (await players.create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
      // Kuba has nine finished games; the tenth earns "Desítka".
      for (var i = 0; i < 9; i++) {
        await StatsRepository(db).recordMatch(
          MatchRecord(
            gameId: 'sample',
            playedAt: DateTime(2026, 10, 1),
            duration: Duration.zero,
            difficulty: Difficulty.easy,
            participants: [
              MatchParticipant(seat: 0, playerId: k, place: 2, score: 0, stars: 0),
              const MatchParticipant(seat: 1, playerId: null, place: 1, score: 1, stars: 3),
            ],
          ),
        );
      }
      return (t, k);
    }))!;
    final audio = FakeAudioBackend();
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(
      '/play/sample',
      extra: GameConfig(
        gameId: 'sample',
        seats: [HumanSeat(t), HumanSeat(k), const RobotSeat()],
        difficulty: Difficulty.hard,
        robotSpeed: RobotSpeed.slow,
        options: const {'range': 20},
      ),
    );
    await tester.pumpAndSettle();
    await hitSecret(tester);
    await _letRecord(tester);
    expect(find.byType(ResultsScreen), findsOneWidget);
    for (final title in ['První výhra', 'Přemožitel robotů', 'Trefa!', 'Desítka']) {
      await tester.scrollUntilVisible(find.text(title), 200);
      expect(find.text(title), findsOneWidget, reason: title);
    }
    await tester.pump(const Duration(milliseconds: 3000));
    expect([for (final s in audio.sfx) s.$2].where((a) => a == 'sfx/achievement.wav').length, 1);
  });
}
