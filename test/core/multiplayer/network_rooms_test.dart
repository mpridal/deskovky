import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/message_channel.dart';
import 'package:deskovky/core/multiplayer/network_rooms.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/multiplayer/fake_network.dart';

final _avatar = AvatarSpec.defaults.toJson();

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

void main() {
  test('a client that lost the line rejoins the same room with its token and gets its places back', () async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
    );
    LoopbackChannel? clientLine;
    final env = FakeNetworkEnv(
      onConnect: (MessageChannel hostSide) => host.accept(hostSide),
    );
    env.onLine = (line) => clientLine = line;
    final rooms = NetworkRooms(env);
    final first = await rooms.join(
      ticket: const JoinTicket(ip: '192.168.1.9', port: 1, code: '4321'),
      profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
      profileIds: const [10],
      appVersion: '0.4.0',
    );
    await _settle();
    first.setReady(true);
    await _settle();
    host.start();
    await _settle();
    clientLine!.drop();
    await _settle();
    expect(first.closedReason, 'lost');
    expect(host.waitingFor, {1});
    final back = await rooms.rejoin();
    await _settle();
    expect(back, isNotNull);
    expect(rooms.client, same(back));
    expect(back!.clientId, first.clientId);
    expect(back.mySeats, {1});
    expect(back.session!.hash, host.session!.hash);
    expect(host.waitingFor, isEmpty);
    await rooms.leave();
    host.dispose();
  });
}
