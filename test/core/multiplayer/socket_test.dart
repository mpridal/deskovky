import 'dart:io';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/net_server.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/socket_channel.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter_test/flutter_test.dart';

final _avatar = AvatarSpec.defaults.toJson();
ProfileCard _card(String name) => ProfileCard(name: name, avatar: _avatar);

HostRoom _host() => HostRoom(
  module: memoryModule,
  roomCode: '4321',
  slots: [LocalSlot(profileId: 1, card: _card('Táta')), const OpenSlot()],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 12, 'set': 'animals'},
  runner: const InlineAiRunner(),
  seed: 3,
);

Hello _hello(String name) =>
    Hello(protocolVersion: protocolVersion, appVersion: '0.4.0', roomCode: '4321', token: null, profiles: [_card(name)]);

/// Waits until [done] is true, at most [limit].
Future<void> _until(bool Function() done, {Duration limit = const Duration(seconds: 5)}) async {
  final end = DateTime.now().add(limit);
  while (!done() && DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  test('the heartbeat is a ping every 3 s and a device is lost after 8 s of silence', () {
    expect(SocketChannel.defaultPingInterval, const Duration(seconds: 3));
    expect(SocketChannel.defaultDeadAfter, const Duration(seconds: 8));
  });

  test('hello, lobby, start and moves over a real socket on 127.0.0.1', () async {
    final host = _host();
    final server = await NetServer.start(address: InternetAddress.loopbackIPv4);
    server.channels.listen(host.accept);
    final client = ClientRoom(
      channel: await SocketChannel.connect('127.0.0.1', server.port),
      hello: _hello('Kuba'),
      localProfileIds: const [10],
    );
    await _until(() => client.lobby != null);
    expect(client.clientId, isNotNull);
    expect(client.lobby!.slots[1].name, 'Kuba');
    client.setReady(true);
    await _until(() => host.canStart);
    host.start();
    await _until(() => client.session != null);
    for (var i = 0; i < 6 && !host.isOver; i++) {
      final seat = host.session!.rules.currentSeat(host.session!.state)!;
      if (host.ownerOf(seat) == HostRoom.hostId) {
        expect(await host.submitLocal(host.session!.rules.legalMoves(host.session!.state, seat).first), isTrue);
      } else {
        await _until(() => client.seq == host.seq);
        expect(await client.submit(client.session!.rules.legalMoves(client.session!.state, seat).first), isTrue);
      }
    }
    await _until(() => client.seq == host.seq);
    expect(client.seq, host.seq);
    expect(client.session!.hash, host.session!.hash);
    client.dispose();
    host.dispose();
    await server.close();
  });

  test('a device that goes silent is seen as gone within the dead time', () async {
    final host = _host();
    final server = await NetServer.start(
      address: InternetAddress.loopbackIPv4,
      pingInterval: const Duration(milliseconds: 100),
      deadAfter: const Duration(milliseconds: 400),
    );
    server.channels.listen(host.accept);
    // A bare WebSocket that says hello and then never answers a ping.
    final mute = await WebSocket.connect('ws://127.0.0.1:${server.port}');
    mute.listen((_) {});
    mute.add(_hello('Kuba').encode());
    await _until(() => host.slots[1] is RemoteSlot);
    expect(host.slots[1], isA<RemoteSlot>());
    final stopwatch = Stopwatch()..start();
    await _until(() => host.slots[1] is OpenSlot, limit: const Duration(seconds: 3));
    expect(host.slots[1], isA<OpenSlot>(), reason: 'the silent device left the room');
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
    await mute.close();
    host.dispose();
    await server.close();
  });

  test('a client sees the host vanish when the server closes', () async {
    final server = await NetServer.start(address: InternetAddress.loopbackIPv4);
    final host = _host();
    server.channels.listen(host.accept);
    final client = ClientRoom(
      channel: await SocketChannel.connect('127.0.0.1', server.port),
      hello: _hello('Kuba'),
      localProfileIds: const [10],
    );
    await _until(() => client.lobby != null);
    host.dispose();
    await server.close();
    await _until(() => client.closedReason != null);
    expect(client.closedReason, isNotNull);
    client.dispose();
  });

  test('after close nothing listens on the port any more', () async {
    final server = await NetServer.start(address: InternetAddress.loopbackIPv4);
    final port = server.port;
    final channel = await SocketChannel.connect('127.0.0.1', port);
    await server.close();
    await channel.close();
    final again = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
    await again.close();
  });

  test('connecting to a port where nobody listens fails quickly', () async {
    final free = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = free.port;
    await free.close();
    await expectLater(SocketChannel.connect('127.0.0.1', port), throwsA(isA<SocketException>()));
  });
}
