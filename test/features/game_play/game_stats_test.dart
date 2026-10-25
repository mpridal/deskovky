import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/players/player_repository.dart';
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
}
