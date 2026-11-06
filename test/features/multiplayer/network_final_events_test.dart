import 'dart:async';

import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/matches/matches_module.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

final _avatar = AvatarSpec.defaults.toJson();

/// Lets the database streams and the loopback lines deliver.
Future<void> _settle(WidgetTester tester, [int rounds = 3]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  // The game screen collects badge events when the game ends; an event the
  // board reports from the final state of a move made on another device must
  // still be in time (Sirky: the opponent takes all the last matches at once).
  testWidgets('a win decided by a move from another device still counts for the badges here', (tester) async {
    final env = FakeNetworkEnv();
    final tereza = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!.id;
    await pumpApp(
      tester,
      size: const Size(412, 915),
      db: db,
      disableAnimations: true,
      overrides: [networkEnvProvider.overrideWithValue(env)],
    );
    await _settle(tester);
    final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
    final host = (await tester.runAsync(
      () => rooms.openHost(
        module: matchesModule,
        slots: [LocalSlot(profileId: tereza, card: ProfileCard(name: 'Tereza', avatar: _avatar)), const OpenSlot()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {'start': MatchesStart.first},
        runner: const InlineAiRunner(),
        hostCard: ProfileCard(name: 'Tereza', avatar: _avatar),
      ),
    ))!;
    final kuba = ClientRoom(
      channel: env.connectToServed(),
      hello: Hello(
        protocolVersion: protocolVersion,
        appVersion: '0.6.0',
        roomCode: host.roomCode,
        token: null,
        profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
      ),
      localProfileIds: const [99],
    );
    await _settle(tester);
    kuba.setReady(true);
    await _settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/room');
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('roomStart')));
    await _settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);

    // Tereza (seat 0) starts; she leaves Kuba (seat 1) three matches in one row.
    Future<void> play(int seat, int row, int count) async {
      final move = MatchesRules.take(seat, row, count);
      if (seat == 0) {
        unawaited(host.submitLocal(move));
      } else {
        for (var i = 0; i < 20 && kuba.seq != host.seq; i++) {
          await _settle(tester, 1);
        }
        unawaited(kuba.submit(move));
      }
      final before = host.seq;
      for (var i = 0; i < 20 && host.seq == before; i++) {
        await _settle(tester, 1);
      }
    }

    await play(0, 0, 3);
    await play(1, 1, 5);
    await play(0, 2, 4);
    expect((host.session!.state as MatchesState).rows, [0, 0, 3]);
    await play(1, 2, 3); // Kuba takes all three, the last one too.

    for (var i = 0; i < 30 && find.byType(ResultsScreen).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    }
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);
    final counters = (await tester.runAsync(() => StatsRepository(db).counters(tereza)))!;
    expect(counters['matches.win'], 1, reason: "Tereza's win reaches the 25-win badge counter");
    expect((await tester.runAsync(() => StatsRepository(db).earnedBadges(tereza)))!.keys, contains('matches.first'));
    kuba.dispose();
    await tester.runAsync(rooms.leave);
    await tester.pump();
  });
}
