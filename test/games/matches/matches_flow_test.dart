import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/matches/matches_ai.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

GameScreenState _screen(WidgetTester tester) => tester.state<GameScreenState>(find.byType(GameScreen));

MatchesState _state(WidgetTester tester) => _screen(tester).debugSession!.state as MatchesState;

/// Lets real database I/O started inside fake time finish, then settles.
Future<void> _settleIo(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pumpAndSettle();
  }
}

/// The person selects [count] matches of [row] on the board and takes them.
Future<void> _take(WidgetTester tester, int row, int count) async {
  var picked = 0;
  for (var i = 0; i < MatchesRules.initialRows[row] && picked < count; i++) {
    final match = find.byKey(ValueKey('match$row,$i'));
    if (match.evaluate().isEmpty) continue;
    await tester.tapAt(tester.getCenter(match));
    await tester.pump();
    picked++;
  }
  await tester.tap(find.byKey(const ValueKey('matchesTake')));
  await tester.pump();
}

Future<void> _open(WidgetTester tester, int person, Difficulty difficulty) async {
  GoRouter.of(tester.element(find.byType(Navigator).first)).push(
    '/play/matches',
    extra: GameConfig(
      gameId: 'matches',
      seats: [HumanSeat(person), const RobotSeat()],
      difficulty: difficulty,
      robotSpeed: RobotSpeed.fast,
      options: const {'start': MatchesStart.first},
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('a perfect game against the hard robot, ended by its forced last move: ★★★, first, master and flawless', (
    tester,
  ) async {
    final tereza = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!.id;
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _open(tester, tereza, Difficulty.hard);
    expect(find.text('Tereza, vezmi sirky z jedné řady'), findsOneWidget);

    for (var guard = 0; guard < 40; guard++) {
      if (find.byType(GameScreen).evaluate().isEmpty) break;
      final s = _state(tester);
      if (s.over) break;
      if (s.current == 0) {
        final (row, count) = MatchesAi.perfect(s.rows, SeededRandom(guard));
        await _take(tester, row, count);
      }
      await tester.pump(const Duration(milliseconds: 300));
    }

    for (var i = 0; i < 30 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);

    final stats = StatsRepository(db);
    final match = (await tester.runAsync(stats.allMatches))!.single;
    expect(match.gameId, 'matches');
    expect(match.participants.first.place, 1);
    expect(match.participants.first.stars, 3);
    expect(match.participants.first.score, 1);
    final counters = (await tester.runAsync(() => stats.counters(tereza)))!;
    expect(counters['matches.win'], 1);
    final badges = (await tester.runAsync(() => stats.earnedBadges(tereza)))!.keys.toSet();
    expect(badges, containsAll(['matches.first', 'matches.master', 'matches.flawless']));
    expect(badges, isNot(contains('matches.collector')));
  });

  testWidgets('a game is saved on exit and continues the same after a restart', (tester) async {
    final tereza = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!.id;
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _open(tester, tereza, Difficulty.easy);
    await _take(tester, 2, 2);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    final session = _screen(tester).debugSession!;
    expect(session.moves, hasLength(2), reason: 'the person and the robot');
    final hash = session.hash;

    await tester.tap(find.bySemanticsLabel(RegExp('^Konec')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit'));
    await _settleIo(tester);
    expect(await tester.runAsync(() => GameStore(db).savedSession('matches')), isNotNull);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    await _settleIo(tester);
    await tester.tap(find.text('Pokračovat: Sirky'));
    await _settleIo(tester);
    final restored = _screen(tester).debugSession!;
    expect(restored.hash, hash);
    expect(_state(tester).total, lessThan(13));
    // The board shows what is left and takes the next move.
    await _take(tester, _state(tester).rows.indexWhere((n) => n > 0), 1);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    expect(_screen(tester).debugSession!.moves.length, greaterThan(2));
  });
}
