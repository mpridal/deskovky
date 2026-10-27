import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter_test/flutter_test.dart';

final _avatar = AvatarSpec.defaults.toJson();
ProfileCard _card(String name) => ProfileCard(name: name, avatar: _avatar);

/// A host with one person of its own, [remotes] open places and [robots].
HostRoom _host({int remotes = 1, int robots = 0}) => HostRoom(
  module: memoryModule,
  roomCode: '4321',
  slots: [
    LocalSlot(profileId: 1, card: _card('Táta')),
    for (var i = 0; i < remotes; i++) const OpenSlot(),
    for (var i = 0; i < robots; i++) const RobotSlot(),
  ],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 12, 'set': 'animals'},
  runner: const InlineAiRunner(),
  robotDelay: Duration.zero,
  seed: 77,
);

Future<ClientRoom> _join(HostRoom host, String name, {Duration latency = Duration.zero, int version = protocolVersion}) async {
  final (hostSide, clientSide) = LoopbackChannel.pair(latency: latency);
  host.accept(hostSide);
  final client = ClientRoom(
    channel: clientSide,
    hello: Hello(protocolVersion: version, appVersion: '0.4.0', roomCode: '4321', token: null, profiles: [_card(name)]),
    localProfileIds: const [10],
  );
  await _settle(latency);
  return client;
}

Future<void> _settle([Duration latency = Duration.zero]) =>
    Future<void>.delayed(latency * 3 + const Duration(milliseconds: 30));

/// Plays until the end: whoever's turn it is plays a seeded random legal
/// move from their own device; robots play on the host.
Future<void> _playOut(HostRoom host, List<ClientRoom> clients, {Duration latency = Duration.zero}) async {
  final random = SeededRandom(5);
  for (var guard = 0; guard < 2000 && !host.isOver; guard++) {
    final seat = host.session!.rules.currentSeat(host.session!.state);
    if (seat == null) break;
    final owner = host.ownerOf(seat);
    if (owner == null) {
      // A robot: the host's turn controller plays it.
      await _settle(latency);
      continue;
    }
    if (owner == HostRoom.hostId) {
      final legal = host.session!.rules.legalMoves(host.session!.state, seat);
      expect(await host.submitLocal(legal[random.nextInt(legal.length)]), isTrue);
    } else {
      final client = clients.firstWhere((c) => c.clientId == owner);
      await _settle(latency);
      final legal = client.session!.rules.legalMoves(client.session!.state, seat);
      expect(await client.submit(legal[random.nextInt(legal.length)]), isTrue);
    }
  }
  await _settle(latency);
}

void main() {
  test('a whole game of Pexeso on 2, 3 and 4 devices with a robot ends the same everywhere', () async {
    for (final devices in [2, 3, 4]) {
      final host = _host(remotes: devices - 1, robots: devices < 4 ? 1 : 0);
      final clients = [for (var i = 0; i < devices - 1; i++) await _join(host, 'Hráč $i', latency: const Duration(milliseconds: 15))];
      for (final c in clients) {
        c.setReady(true);
      }
      await _settle(const Duration(milliseconds: 15));
      expect(host.canStart, isTrue, reason: '$devices devices');
      host.start();
      await _settle(const Duration(milliseconds: 15));
      await _playOut(host, clients, latency: const Duration(milliseconds: 15));
      expect(host.isOver, isTrue, reason: '$devices devices');
      for (final c in clients) {
        expect(c.session!.hash, host.session!.hash, reason: '$devices devices');
        expect(c.session!.rules.result(c.session!.state).places, host.session!.rules.result(host.session!.state).places);
      }
      host.dispose();
      for (final c in clients) {
        c.dispose();
      }
    }
  });

  test('each device sees its own players as people of its own and the others as remote', () async {
    final host = _host();
    final client = await _join(host, 'Kuba');
    client.setReady(true);
    await _settle();
    host.start();
    await _settle();
    expect(client.mySeats, {1});
    expect(client.deviceConfig!.seats[1], const HumanSeat(10));
    expect(client.deviceConfig!.seats[0], isA<RemoteSeat>());
    expect(host.deviceConfig!.seats[0], const HumanSeat(1));
    expect(host.deviceConfig!.seats[1], isA<RemoteSeat>());
    host.dispose();
    client.dispose();
  });

  test("the host refuses a move for someone else's seat, out of turn or based on an old state", () async {
    final host = _host();
    final client = await _join(host, 'Kuba');
    client.setReady(true);
    await _settle();
    host.start();
    await _settle();
    final before = host.session!.hash;
    // Seat 0 (the host's person) moves first; the client tries to play it.
    final legal0 = host.session!.rules.legalMoves(host.session!.state, 0);
    expect(await client.submit(legal0.first), isFalse);
    expect(await client.submit(Move(seat: 1, type: legal0.first.type, data: legal0.first.data)), isFalse);
    expect(host.session!.hash, before);
    expect(client.session!.hash, before);
    host.dispose();
    client.dispose();
  });

  test('a client whose state got broken is put right by a snapshot', () async {
    final host = _host();
    final client = await _join(host, 'Kuba');
    client.setReady(true);
    await _settle();
    host.start();
    await _settle();
    // Break the client's copy behind the host's back.
    final legal = client.session!.rules.legalMoves(client.session!.state, 0);
    client.session!.apply(legal.last);
    expect(client.session!.hash, isNot(host.session!.hash));
    // The next real move reveals the mismatch; the client asks for a snapshot.
    final move = host.session!.rules.legalMoves(host.session!.state, 0).first;
    expect(await host.submitLocal(move), isTrue);
    await _settle();
    expect(client.session!.hash, host.session!.hash);
    host.dispose();
    client.dispose();
  });

  test('a device with another protocol version is turned away with a reason', () async {
    final host = _host();
    final client = await _join(host, 'Kuba', version: protocolVersion + 1);
    expect(client.closedReason, 'version');
    expect(host.slots[1], isA<OpenSlot>());
    host.dispose();
    client.dispose();
  });

  test('a wrong room code or a full room is refused', () async {
    final host = _host();
    final (hostSide, clientSide) = LoopbackChannel.pair();
    host.accept(hostSide);
    final wrong = ClientRoom(
      channel: clientSide,
      hello: Hello(protocolVersion: protocolVersion, appVersion: '0.4.0', roomCode: '0000', token: null, profiles: [_card('X')]),
      localProfileIds: const [10],
    );
    await _settle();
    expect(wrong.closedReason, 'code');
    final first = await _join(host, 'Kuba');
    final second = await _join(host, 'Ema');
    expect(first.clientId, isNotNull);
    expect(second.closedReason, 'full');
    host.dispose();
    for (final c in [wrong, first, second]) {
      c.dispose();
    }
  });

  test('a move based on an old state is refused as stale', () async {
    final host = _host();
    final (hostSide, raw) = LoopbackChannel.pair();
    final got = <NetMessage>[];
    raw.incoming.listen(got.add);
    host.accept(hostSide);
    raw.send(Hello(protocolVersion: protocolVersion, appVersion: '0.4.0', roomCode: '4321', token: null, profiles: [_card('Kuba')]));
    await _settle();
    raw.send(const Ready(true));
    await _settle();
    host.start();
    await _settle();
    final first = host.session!.rules.legalMoves(host.session!.state, 0).first;
    expect(await host.submitLocal(first), isTrue);
    // Seat 0 keeps playing or seat 1 is on; either way basedOn 0 is old now.
    final seat = host.session!.rules.currentSeat(host.session!.state)!;
    final move = host.session!.rules.legalMoves(host.session!.state, seat).first;
    raw.send(MoveRequest(move: Move(seat: 1, type: move.type, data: move.data), basedOn: 0));
    await _settle();
    expect(got.whereType<MoveRejected>().single.reason, 'stale');
    expect(host.seq, 1);
    host.dispose();
    await raw.close();
  });

  test('a slow line (500 ms) still keeps every device in step', () async {
    const slow = Duration(milliseconds: 500);
    final host = _host(robots: 1);
    final client = await _join(host, 'Kuba', latency: slow);
    client.setReady(true);
    await _settle(slow);
    host.start();
    await _settle(slow);
    final random = SeededRandom(9);
    for (var i = 0; i < 8 && !host.isOver; i++) {
      final seat = host.session!.rules.currentSeat(host.session!.state)!;
      final owner = host.ownerOf(seat);
      if (owner == HostRoom.hostId) {
        final legal = host.session!.rules.legalMoves(host.session!.state, seat);
        expect(await host.submitLocal(legal[random.nextInt(legal.length)]), isTrue);
      } else if (owner != null) {
        await _settle(slow);
        final legal = client.session!.rules.legalMoves(client.session!.state, seat);
        expect(await client.submit(legal[random.nextInt(legal.length)]), isTrue);
      }
      await _settle(slow);
    }
    expect(host.seq, greaterThan(3));
    expect(client.seq, host.seq);
    expect(client.session!.hash, host.session!.hash);
    host.dispose();
    client.dispose();
  });
}
