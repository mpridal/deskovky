import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter_test/flutter_test.dart';

final _avatar = AvatarSpec.defaults.toJson();

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

Future<ClientRoom> _join(HostRoom host, String name) async {
  final (hostSide, clientSide) = LoopbackChannel.pair();
  host.accept(hostSide);
  final client = ClientRoom(
    channel: clientSide,
    hello: Hello(
      protocolVersion: protocolVersion,
      appVersion: '0.12.0',
      roomCode: '4321',
      token: null,
      profiles: [ProfileCard(name: name, avatar: _avatar)],
    ),
    localProfileIds: const [10],
  );
  await _settle();
  client.setReady(true);
  await _settle();
  return client;
}

void main() {
  test('a signal travels as a message and back', () {
    const signal = Signal(seat: 2, data: {'hint': 7});
    final back = NetMessage.decode(signal.encode())! as Signal;
    expect(back.seat, 2);
    expect(back.data, {'hint': 7});
    expect(NetMessage.fromJson({'type': 'signal', 'seat': 'x', 'data': {}}), isNull);
  });

  test("a device's signal reaches the host and the other devices, not back to itself; nobody signals for another's seat",
      () async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot(), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
      seed: 5,
    );
    final kuba = await _join(host, 'Kuba'), viky = await _join(host, 'Viky');
    host.start();
    await _settle();
    final atHost = <BoardSignal>[], atKuba = <BoardSignal>[], atViky = <BoardSignal>[];
    host.signals.listen(atHost.add);
    kuba.signals.listen(atKuba.add);
    viky.signals.listen(atViky.add);

    kuba.sendSignal(1, const {'hint': 3});
    await _settle();
    expect([for (final s in atHost) (s.seat, s.data['hint'])], [(1, 3)]);
    expect([for (final s in atViky) (s.seat, s.data['hint'])], [(1, 3)]);
    expect(atKuba, isEmpty);

    host.sendSignal(0, const {'hint': 5});
    await _settle();
    expect([for (final s in atKuba) s.seat], [0]);
    expect([for (final s in atViky) s.seat], [1, 0]);

    // Kuba claiming Viky's seat: dropped.
    kuba.sendSignal(2, const {'hint': 1});
    await _settle();
    expect(atHost, hasLength(1));
    host.dispose();
    kuba.dispose();
    viky.dispose();
  });
}
