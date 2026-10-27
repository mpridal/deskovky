import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:flutter_test/flutter_test.dart';

final _avatar = AvatarSpec.defaults.toJson();
ProfileCard _card(String name) => ProfileCard(name: name, avatar: _avatar);

HostRoom _host({Duration grace = const Duration(milliseconds: 300)}) => HostRoom(
  module: memoryModule,
  roomCode: '4321',
  slots: [LocalSlot(profileId: 1, card: _card('Táta')), const OpenSlot()],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 12, 'set': 'animals'},
  runner: const InlineAiRunner(),
  robotDelay: Duration.zero,
  seed: 11,
  reconnectGrace: grace,
);

Future<void> _settle([int ms = 40]) => Future<void>.delayed(Duration(milliseconds: ms));

/// A device joining [host]; [token] to come back after a dropout.
Future<(ClientRoom, LoopbackChannel)> _join(HostRoom host, {String? token}) async {
  final (hostSide, clientSide) = LoopbackChannel.pair();
  host.accept(hostSide);
  final client = ClientRoom(
    channel: clientSide,
    hello: Hello(protocolVersion: protocolVersion, appVersion: '0.4.0', roomCode: '4321', token: token, profiles: [_card('Kuba')]),
    localProfileIds: const [10],
  );
  await _settle();
  return (client, clientSide);
}

Future<(HostRoom, ClientRoom, LoopbackChannel)> _started({Duration grace = const Duration(milliseconds: 300)}) async {
  final host = _host(grace: grace);
  final (client, line) = await _join(host);
  client.setReady(true);
  await _settle();
  host.start();
  await _settle();
  return (host, client, line);
}

void main() {
  test('sessions and turns are typed by the game, so its board widget gets its own state type', () async {
    final (host, client, _) = await _started();
    expect(host.session, isA<Object>());
    expect(host.session!.state, isA<MemoryState>());
    expect(host.controller!.session.state, isA<MemoryState>());
    expect(host.session.runtimeType.toString(), contains('MemoryState'));
    expect(client.session.runtimeType.toString(), contains('MemoryState'));
    host.dispose();
    client.dispose();
  });

  test('anyone can pause and resume, and the pause reaches every device', () async {
    final (host, client, _) = await _started();
    client.requestPause();
    await _settle();
    expect(host.paused, isTrue);
    expect(client.paused, isTrue);
    expect(await host.submitLocal(host.session!.rules.legalMoves(host.session!.state, 0).first), isFalse);
    host.resume();
    await _settle();
    expect(host.paused, isFalse);
    expect(client.paused, isFalse);
    expect(await host.submitLocal(host.session!.rules.legalMoves(host.session!.state, 0).first), isTrue);
    host.dispose();
    client.dispose();
  });

  test('a dropped device pauses the game with a countdown and comes back with its token', () async {
    final (host, client, line) = await _started(grace: const Duration(seconds: 30));
    final token = client.token!;
    expect(await host.submitLocal(host.session!.rules.legalMoves(host.session!.state, 0).first), isTrue);
    await _settle();
    line.drop();
    await _settle();
    expect(host.paused, isTrue);
    expect(host.waitingFor, {1});
    expect(host.waitSeconds, inInclusiveRange(29, 30));
    expect(client.closedReason, 'lost');
    final (back, _) = await _join(host, token: token);
    await _settle();
    expect(back.clientId, client.clientId);
    expect(host.waitingFor, isEmpty);
    expect(host.paused, isFalse);
    expect(back.session!.hash, host.session!.hash);
    expect(back.mySeats, {1});
    host.dispose();
    client.dispose();
    back.dispose();
  });

  test('after the grace the host decides: a robot takes the place and the player can take it back', () async {
    final (host, client, line) = await _started(grace: const Duration(milliseconds: 200));
    final token = client.token!;
    line.drop();
    await _settle(400);
    expect(host.needsDecision, isTrue);
    host.replaceWithRobot();
    await _settle();
    expect(host.paused, isFalse);
    expect(host.controller!.isRobotSeat(1), isTrue);
    // The host plays its own turns; the stand-in robot plays seat 1.
    for (var i = 0; i < 200 && !host.isOver; i++) {
      final seat = host.session!.rules.currentSeat(host.session!.state);
      if (seat == 0) {
        await host.submitLocal(host.session!.rules.legalMoves(host.session!.state, 0).first);
      }
      await _settle(5);
      if (host.session!.moves.length > 6) break;
    }
    final (back, _) = await _join(host, token: token);
    await _settle();
    expect(host.controller!.isRobotSeat(1), isFalse, reason: 'the player took the place back');
    expect(back.session!.hash, host.session!.hash);
    host.dispose();
    client.dispose();
    back.dispose();
  });

  test('a device that leaves on its own is replaced by a robot at once', () async {
    final (host, client, _) = await _started();
    client.leave();
    await _settle();
    expect(host.paused, isFalse);
    expect(host.controller!.isRobotSeat(1), isTrue);
    host.dispose();
    client.dispose();
  });

  test('only the host ends the game for everyone', () async {
    final (host, client, _) = await _started();
    host.endGame();
    await _settle();
    expect(client.closedReason, 'ended');
    host.dispose();
    client.dispose();
  });

  test('a rematch starts a new game with the same players on every device', () async {
    final (host, client, _) = await _started();
    final firstSeed = host.session!.seed;
    final firstSession = client.session;
    host.rematch();
    await _settle();
    expect(host.session!.seed, isNot(firstSeed));
    expect(client.session, isNot(same(firstSession)));
    expect(client.session!.hash, host.session!.hash);
    expect(client.mySeats, {1});
    host.dispose();
    client.dispose();
  });
}
