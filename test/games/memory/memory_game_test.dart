import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

GameConfig config(List<SeatConfig> seats, {int cards = 12, Difficulty difficulty = Difficulty.medium}) => GameConfig(
  gameId: 'memory',
  seats: seats,
  difficulty: difficulty,
  robotSpeed: RobotSpeed.fast,
  options: {'cards': cards, 'set': 'animals'},
);

/// Real time for the database writes and the 600 ms before the results.
Future<void> letRecord(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    if (i >= 5 && find.byType(ResultsScreen).evaluate().isNotEmpty) break;
  }
  await tester.pumpAndSettle();
}

MemoryState? liveState(WidgetTester tester) {
  final screen = find.byType(GameScreen);
  if (screen.evaluate().isEmpty) return null;
  return tester.state<GameScreenState>(screen).debugSession!.state as MemoryState;
}

/// Taps the card a perfect player would turn next (seat 0 is the person).
Future<void> tapBest(WidgetTester tester) async {
  final s = liveState(tester)!;
  int target;
  if (s.open.isEmpty) {
    target = s.owner.indexWhere((o) => o == null);
  } else {
    final a = s.open.single;
    target = List.generate(
      s.cards,
      (c) => c,
    ).firstWhere((c) => c != a && s.owner[c] == null && s.faces[c] == s.faces[a]);
  }
  final card = find.byKey(ValueKey('memory.card$target'));
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pump();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<int> player(WidgetTester tester) async =>
      (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!.id;

  testWidgets('one player clears the board: results with ★★★, the game and pairs are recorded', (tester) async {
    final id = await player(tester);
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/memory', extra: config([HumanSeat(id)]));
    await tester.pumpAndSettle();
    expect(find.text('Tereza, otoč kartu'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await tapBest(tester);
    }
    await letRecord(tester);
    expect(find.byType(ResultsScreen), findsOneWidget);
    final matches = (await tester.runAsync(() => StatsRepository(db).allMatches()))!;
    expect(matches.single.participants.single.stars, 3);
    expect(matches.single.participants.single.score, 6);
    final counters = (await tester.runAsync(() => StatsRepository(db).counters(id)))!;
    expect(counters['memory.pairs'], 6);
  });

  testWidgets('against a robot the game runs to the end, turning the phone on the way', (tester) async {
    final id = await player(tester);
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first))
        .push('/play/memory', extra: config([HumanSeat(id), const RobotSeat()], difficulty: Difficulty.easy));
    await tester.pumpAndSettle();
    for (var i = 0; i < 300 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      if (i == 10) tester.view.physicalSize = const Size(915, 412);
      if (i == 20) tester.view.physicalSize = const Size(412, 915);
      final s = liveState(tester);
      if (s != null && !const MemoryRules().isOver(s) && s.current == 0) {
        // A forgetful person: always a new card, never the remembered one.
        final target = s.owner.indexWhere((o) => o == null);
        final pick = s.open.contains(target)
            ? List.generate(s.cards, (c) => c).firstWhere((c) => s.owner[c] == null && !s.open.contains(c))
            : target;
        final card = find.byKey(ValueKey('memory.card$pick'));
        await tester.tap(card);
      }
      await tester.pump(const Duration(milliseconds: 300));
      if (s != null && const MemoryRules().isOver(s)) await letRecord(tester);
    }
    await letRecord(tester);
    expect(find.byType(ResultsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    final matches = (await tester.runAsync(() => StatsRepository(db).allMatches()))!;
    expect(matches.single.participants, hasLength(2));
  });

  testWidgets('a game in progress is saved and continues the same after a restart', (tester) async {
    final id = await player(tester);
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first))
        .push('/play/memory', extra: config([HumanSeat(id)], cards: 16, difficulty: Difficulty.hard));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tapBest(tester);
    }
    final before = liveState(tester)!;
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    final saved = await tester.runAsync(() => GameStore(db).savedSession('memory'));
    expect(saved, isNotNull);
    expect(saved!.moves, hasLength(5));

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/memory', extra: saved);
    await tester.pumpAndSettle();
    final after = liveState(tester)!;
    expect(const MemoryRules().stateToJson(after), const MemoryRules().stateToJson(before));
    for (var i = 0; i < 40 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      final s = liveState(tester);
      if (s != null && !const MemoryRules().isOver(s)) await tapBest(tester);
      if (s != null && s.pairsLeft <= 1 && s.open.isNotEmpty) await letRecord(tester);
    }
    await letRecord(tester);
    expect(find.byType(ResultsScreen), findsOneWidget);
    // Pairs found before the restart count once, together with the rest.
    expect((await tester.runAsync(() => StatsRepository(db).counters(id)))!['memory.pairs'], 8);
    expect(await tester.runAsync(() => GameStore(db).savedSession('memory')), isNull);
  });
}
