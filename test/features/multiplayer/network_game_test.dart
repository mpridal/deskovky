import 'dart:async';

import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/network_rooms.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

final _avatar = AvatarSpec.defaults.toJson();

Future<int> _player(WidgetTester tester, AppDatabase db, String name) async =>
    (await tester.runAsync(() => PlayerRepository(db).create(name: name, avatar: AvatarSpec.defaults)))!.id;

/// Lets the database streams and the loopback lines deliver.
Future<void> _settle(WidgetTester tester, [int rounds = 5]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

NetworkRooms _rooms(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);

Future<void> _go(WidgetTester tester, String path) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).push(path);
  await tester.pump();
}

Future<void> _leave(WidgetTester tester) async {
  await tester.runAsync(_rooms(tester).leave);
  await tester.pump();
}

/// This device hosts a Pexeso room; a virtual device joins as Kuba.
Future<(HostRoom, ClientRoom, LoopbackChannel)> _hostGame(WidgetTester tester, AppDatabase db, FakeNetworkEnv env) async {
  final tata = await _player(tester, db, 'Táta');
  await pumpApp(
    tester,
    size: const Size(412, 915),
    db: db,
    disableAnimations: true,
    overrides: [networkEnvProvider.overrideWithValue(env)],
  );
  await _settle(tester);
  final rooms = _rooms(tester);
  final host = (await tester.runAsync(
    () => rooms.openHost(
      module: memoryModule,
      slots: [LocalSlot(profileId: tata, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      hostCard: ProfileCard(name: 'Táta', avatar: _avatar),
      reconnectGrace: const Duration(milliseconds: 300),
    ),
  ))!;
  final (hostSide, line) = LoopbackChannel.pair();
  env.deliver(hostSide);
  final kuba = ClientRoom(
    channel: line,
    hello: Hello(
      protocolVersion: protocolVersion,
      appVersion: '0.4.0',
      roomCode: host.roomCode,
      token: null,
      profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
    ),
    localProfileIds: const [99],
  );
  await _settle(tester);
  kuba.setReady(true);
  await _settle(tester);
  await _go(tester, '/room');
  await _settle(tester);
  await tester.tap(find.byKey(const ValueKey('roomStart')));
  await _settle(tester);
  expect(find.byType(GameScreen), findsOneWidget);
  return (host, kuba, line);
}

/// Picks the moves: varied, but the same in every run.
final _random = SeededRandom(5);

/// Plays the current turn: on the host through the room, on Kuba's device
/// through its own room. Moves are sent in fake time and pumped through.
Future<void> _playTurn(WidgetTester tester, HostRoom host, ClientRoom kuba) async {
  final seat = host.session!.rules.currentSeat(host.session!.state)!;
  final before = host.session!.moves.length;
  for (var i = 0; i < 20 && seat != 0 && kuba.seq != host.seq; i++) {
    await _settle(tester, 1);
  }
  if (seat == 0) {
    final legal = host.session!.rules.legalMoves(host.session!.state, 0);
    unawaited(host.submitLocal(legal[_random.nextInt(legal.length)]));
  } else {
    final legal = kuba.session!.rules.legalMoves(kuba.session!.state, seat);
    unawaited(kuba.submit(legal[_random.nextInt(legal.length)]));
  }
  for (var i = 0; i < 20 && host.session!.moves.length == before; i++) {
    await _settle(tester, 1);
  }
  await _settle(tester, 1);
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('a move on the other device shows here; whose turn it is is clear on each device', (tester) async {
    final env = FakeNetworkEnv();
    final (host, kuba, _) = await _hostGame(tester, db, env);
    // The device on turn shows the game's own hint (Pexeso: "…, otoč kartu").
    expect(find.text('Táta, otoč kartu'), findsOneWidget);
    // Play until it is Kuba's turn on his device.
    for (var i = 0; i < 20 && host.session!.rules.currentSeat(host.session!.state) == 0; i++) {
      await _playTurn(tester, host, kuba);
    }
    expect(find.text('Na tahu: Kuba (na svém zařízení)'), findsOneWidget);
    // Not the host's turn: its device cannot play Kuba's seat.
    final kubasMove = host.session!.rules.legalMoves(host.session!.state, 1).first;
    expect(await tester.runAsync(() => host.submitLocal(kubasMove)), isFalse);
    final screen = tester.state<GameScreenState>(find.byType(GameScreen));
    final before = screen.debugSession!.moves.length;
    await _playTurn(tester, host, kuba);
    expect(screen.debugSession!.moves.length, before + 1, reason: "Kuba's move arrived on the host");
    kuba.dispose();
    await _leave(tester);
  });

  testWidgets('a dropped device pauses the game with a countdown and the host can let a robot play', (tester) async {
    final env = FakeNetworkEnv();
    final (host, kuba, line) = await _hostGame(tester, db, env);
    line.drop();
    await _settle(tester);
    expect(find.textContaining('Kuba: odpojeno – čekám'), findsOneWidget);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await _settle(tester);
    expect(find.text('Nahradit robotem'), findsOneWidget);
    await tester.tap(find.text('Nahradit robotem'));
    await _settle(tester);
    expect(host.controller!.isRobotSeat(1), isTrue);
    expect(host.paused, isFalse);
    kuba.dispose();
    await _leave(tester);
  });

  testWidgets('a client follows the host: the game starts, moves arrive and results count only its own profile', (
    tester,
  ) async {
    final kubaId = await _player(tester, db, 'Kuba');
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 500, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
    );
    final env = FakeNetworkEnv(
      found: [RoomInfo(code: '4321', gameId: 'memory', hostName: 'Táta', hostAvatar: _avatar, port: 1, free: 1, ip: '192.168.1.9')],
      onConnect: host.accept,
    );
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [networkEnvProvider.overrideWithValue(env)]);
    await _settle(tester);
    await _go(tester, '/join');
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('room4321')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('lobbyReady')));
    await _settle(tester);
    await tester.runAsync(() async => host.start());
    await _settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Na tahu: Táta (na svém zařízení)'), findsOneWidget);
    final kuba = _rooms(tester).client!;
    // Both play first legal moves to the end.
    for (var i = 0; i < 300 && !host.isOver; i++) {
      await _playTurn(tester, host, kuba);
    }
    expect(host.isOver, isTrue);
    await _settle(tester, 10);
    await tester.pump(const Duration(seconds: 1));
    await _settle(tester, 10);
    expect(find.byType(ResultsScreen), findsOneWidget);
    final matches = (await tester.runAsync(() => StatsRepository(db).allMatches()))!;
    expect(matches, hasLength(1));
    final people = matches.single.participants;
    expect(people.where((p) => p.playerId == kubaId), hasLength(1), reason: 'Kuba is recorded on his device');
    expect(people.where((p) => p.playerId == null && !p.robot), hasLength(1), reason: 'Táta is a guest here');
    host.dispose();
    await _leave(tester);
  });

  testWidgets('a client whose line dropped reconnects and is back in the game', (tester) async {
    await _player(tester, db, 'Kuba');
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 500, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
    );
    LoopbackChannel? line;
    final env = FakeNetworkEnv(
      found: [RoomInfo(code: '4321', gameId: 'memory', hostName: 'Táta', hostAvatar: _avatar, port: 1, free: 1, ip: '192.168.1.9')],
      onConnect: host.accept,
    )..onLine = (l) => line = l;
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [networkEnvProvider.overrideWithValue(env)]);
    await _settle(tester);
    await _go(tester, '/join');
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('room4321')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('lobbyReady')));
    await _settle(tester);
    await tester.runAsync(() async => host.start());
    await _settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    line!.drop();
    await _settle(tester);
    expect(find.text('Spojení s hostitelem se přerušilo.'), findsOneWidget);
    expect(host.waitingFor, {1});
    await tester.tap(find.byKey(const ValueKey('netReconnect')));
    await _settle(tester, 10);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(host.waitingFor, isEmpty);
    expect(_rooms(tester).client!.session!.hash, host.session!.hash);
    host.dispose();
    await _leave(tester);
  });

  Future<void> playToResults(WidgetTester tester, HostRoom host, ClientRoom kuba) async {
    for (var i = 0; i < 300 && !host.isOver; i++) {
      await _playTurn(tester, host, kuba);
    }
    expect(host.isOver, isTrue);
    await _settle(tester, 10);
    await tester.pump(const Duration(seconds: 1));
    await _settle(tester, 10);
    expect(find.byType(ResultsScreen), findsOneWidget);
  }

  testWidgets('Odveta on the host starts the next game right away on this device and on the others', (tester) async {
    final env = FakeNetworkEnv();
    final (host, kuba, _) = await _hostGame(tester, db, env);
    await playToResults(tester, host, kuba);
    final firstSession = host.session;
    await tester.tap(find.byKey(const ValueKey('netRematch')));
    await _settle(tester, 10);
    expect(host.session, isNot(same(firstSession)));
    expect(find.byType(GameScreen), findsOneWidget, reason: 'the host is back in the game after one tap');
    final screen = tester.state<GameScreenState>(find.byType(GameScreen));
    expect(screen.debugSession, same(host.session));
    expect(kuba.session!.hash, host.session!.hash);
    kuba.dispose();
    await _leave(tester);
  });

  testWidgets('a client on the results follows the rematch into the new game', (tester) async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 500, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
    );
    await _player(tester, db, 'Kuba');
    final env = FakeNetworkEnv(
      found: [RoomInfo(code: '4321', gameId: 'memory', hostName: 'Táta', hostAvatar: _avatar, port: 1, free: 1, ip: '192.168.1.9')],
      onConnect: host.accept,
    );
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [networkEnvProvider.overrideWithValue(env)]);
    await _settle(tester);
    await _go(tester, '/join');
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('room4321')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('lobbyReady')));
    await _settle(tester);
    await tester.runAsync(() async => host.start());
    await _settle(tester);
    final kuba = _rooms(tester).client!;
    await playToResults(tester, host, kuba);
    await tester.runAsync(() async => host.rematch());
    await _settle(tester, 10);
    expect(find.byType(GameScreen), findsOneWidget, reason: 'the client follows on the first rematch');
    host.dispose();
    await _leave(tester);
  });

  testWidgets('going back from the results closes the room for everyone (no server left open)', (tester) async {
    final env = FakeNetworkEnv();
    final (host, kuba, _) = await _hostGame(tester, db, env);
    await playToResults(tester, host, kuba);
    final rooms = _rooms(tester);
    await tester.binding.handlePopRoute();
    await _settle(tester, 5);
    expect(rooms.host, isNull);
    expect(kuba.closedReason, 'ended');
    kuba.dispose();
  });

  testWidgets('the Čekat / Robot / Ukončit choice closes by itself when the player comes back', (tester) async {
    final env = FakeNetworkEnv();
    final (host, kuba, line) = await _hostGame(tester, db, env);
    final token = kuba.token!;
    line.drop();
    await _settle(tester);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 400)));
    await _settle(tester);
    expect(find.text('Nahradit robotem'), findsOneWidget);
    final (hostSide, clientSide) = LoopbackChannel.pair();
    env.deliver(hostSide);
    final back = ClientRoom(
      channel: clientSide,
      hello: Hello(
        protocolVersion: protocolVersion,
        appVersion: '0.4.0',
        roomCode: host.roomCode,
        token: token,
        profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
      ),
      localProfileIds: const [99],
    );
    await _settle(tester, 8);
    expect(host.waitingFor, isEmpty);
    expect(find.text('Nahradit robotem'), findsNothing, reason: 'nobody to decide about any more');
    expect(host.paused, isFalse);
    kuba.dispose();
    back.dispose();
    await _leave(tester);
  });
}
