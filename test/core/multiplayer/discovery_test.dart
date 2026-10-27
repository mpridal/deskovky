import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:deskovky/core/multiplayer/local_address.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_announcer.dart';
import 'package:deskovky/core/multiplayer/room_finder.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:flutter_test/flutter_test.dart';

RoomInfo _room({String code = '4321', int free = 2}) => RoomInfo(
  code: code,
  gameId: 'memory',
  hostName: 'Táta',
  hostAvatar: const {'face': 'round'},
  port: 50505,
  free: free,
  ip: '127.0.0.1',
);

/// Waits until [done] is true, at most [limit].
Future<void> _until(bool Function() done, {Duration limit = const Duration(seconds: 3)}) async {
  final end = DateTime.now().add(limit);
  while (!done() && DateTime.now().isBefore(end)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// A free UDP port, so parallel test runs do not meet each other.
Future<int> _freePort() async {
  final s = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
  final port = s.port;
  s.close();
  return port;
}

void main() {
  test('rooms are announced on UDP 47123 every 2 s and vanish after 6 s', () {
    expect(RoomAnnouncer.defaultPort, 47123);
    expect(RoomAnnouncer.defaultInterval, const Duration(seconds: 2));
    expect(RoomFinder.defaultStaleAfter, const Duration(seconds: 6));
  });

  test('an announced room is found over the loopback interface', () async {
    final port = await _freePort();
    final finder = await RoomFinder.start(port: port, address: InternetAddress.loopbackIPv4);
    final seen = <List<RoomInfo>>[];
    final sub = finder.rooms.listen(seen.add);
    final announcer = await RoomAnnouncer.start(
      _room(),
      port: port,
      targets: [InternetAddress.loopbackIPv4],
      interval: const Duration(milliseconds: 100),
    );
    await _until(() => seen.isNotEmpty && seen.last.isNotEmpty);
    expect(seen.last.single, _room());
    announcer.update(_room(free: 1));
    await _until(() => seen.last.single.free == 1);
    expect(seen.last.single.free, 1);
    announcer.close();
    await sub.cancel();
    finder.close();
  });

  test('a room that stops announcing disappears', () async {
    final port = await _freePort();
    final finder = await RoomFinder.start(
      port: port,
      address: InternetAddress.loopbackIPv4,
      staleAfter: const Duration(milliseconds: 400),
    );
    final announcer = await RoomAnnouncer.start(
      _room(),
      port: port,
      targets: [InternetAddress.loopbackIPv4],
      interval: const Duration(milliseconds: 100),
    );
    await _until(() => finder.current.isNotEmpty);
    expect(finder.current, hasLength(1));
    announcer.close();
    await _until(() => finder.current.isEmpty);
    expect(finder.current, isEmpty);
    finder.close();
  });

  test('broken packets, other versions and other apps are ignored', () async {
    final port = await _freePort();
    final finder = await RoomFinder.start(port: port, address: InternetAddress.loopbackIPv4);
    final sender = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    for (final junk in [
      '{not json',
      '[]',
      jsonEncode({'app': 'something-else'}),
      jsonEncode({..._room().toJson(), 'v': protocolVersion + 1}),
      jsonEncode({..._room().toJson(), 'port': 'x'}),
    ]) {
      sender.send(utf8.encode(junk), InternetAddress.loopbackIPv4, port);
    }
    sender.send(List.generate(3000, (i) => i % 256), InternetAddress.loopbackIPv4, port);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(finder.current, isEmpty);
    sender.send(utf8.encode(jsonEncode(_room(code: '1111').toJson())), InternetAddress.loopbackIPv4, port);
    await _until(() => finder.current.isNotEmpty);
    expect(finder.current.single.code, '1111');
    sender.close();
    finder.close();
  });

  test('the Wi-Fi address is the private IPv4 of the wlan interface', () {
    expect(
      pickWifiAddress([('lo', '127.0.0.1'), ('rmnet0', '10.120.4.7'), ('wlan0', '192.168.1.23')]),
      '192.168.1.23',
    );
    // A phone's own hotspot.
    expect(pickWifiAddress([('lo', '127.0.0.1'), ('ap0', '192.168.43.1')]), '192.168.43.1');
    // Not on Wi-Fi: only mobile data.
    expect(pickWifiAddress([('lo', '127.0.0.1'), ('rmnet0', '100.72.1.9')]), isNull);
    // An emulator or a desktop: some private address is better than none.
    expect(pickWifiAddress([('eth0', '10.0.2.15')]), '10.0.2.15');
    expect(subnetBroadcast('192.168.1.23'), '192.168.1.255');
  });

  test('the join link carries address, port and room code there and back', () {
    const ticket = JoinTicket(ip: '192.168.1.23', port: 50505, code: '0042');
    expect(ticket.toUri().toString(), 'deskovky://join?ip=192.168.1.23&port=50505&code=0042');
    expect(JoinTicket.parse(ticket.toUri().toString()), ticket);
    expect(JoinTicket.parse('deskovky://join?ip=1.2.3.4&port=abc&code=1'), isNull);
    expect(JoinTicket.parse('https://example.com'), isNull);
  });

  test('room codes are four digits', () {
    final random = Random(1);
    for (var i = 0; i < 50; i++) {
      expect(newRoomCode(random), matches(RegExp(r'^\d{4}$')));
    }
  });
}
