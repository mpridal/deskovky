import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter_test/flutter_test.dart';

final _avatar = AvatarSpec.defaults.toJson();

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

Hello _hello({int? rules = rulesVersion}) => Hello(
  protocolVersion: protocolVersion,
  appVersion: '0.13.2',
  roomCode: '4321',
  token: null,
  profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
  rules: rules,
);

HostRoom _host() => HostRoom(
  module: memoryModule,
  roomCode: '4321',
  slots: [LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 12, 'set': 'animals'},
  runner: const InlineAiRunner(),
  robotDelay: Duration.zero,
  seed: 5,
);

final _config = GameConfig(
  gameId: 'memory',
  seats: const [RemoteSeat(clientId: 'host', name: 'Táta', avatar: {}), RemoteSeat(clientId: 'c1', name: 'Kuba', avatar: {})],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 12, 'set': 'animals'},
);

void main() {
  test('the rules version travels in hello and start', () {
    final hello = NetMessage.decode(_hello().encode())! as Hello;
    expect(hello.rules, rulesVersion);
    final old = NetMessage.fromJson({..._hello().toJson()}..remove('rules'))! as Hello;
    expect(old.rules, isNull, reason: 'an app from before rules versions');
    final start = Start(config: _config, seed: 1, yourSeats: const {1: 0}, rules: rulesVersion);
    expect((NetMessage.decode(start.encode())! as Start).rules, rulesVersion);
  });

  test('a device with other game rules is turned away with "version" (review R-002)', () async {
    for (final rules in [null, rulesVersion - 1, rulesVersion + 1]) {
      final host = _host();
      final (hostSide, clientSide) = LoopbackChannel.pair();
      host.accept(hostSide);
      final client = ClientRoom(channel: clientSide, hello: _hello(rules: rules), localProfileIds: const [10]);
      await _settle();
      expect(client.closedReason, 'version', reason: 'rules $rules');
      expect(host.slots[1], isA<OpenSlot>());
      host.dispose();
      client.dispose();
    }
  });

  test('a client joining an older host (no rules version in start) leaves with "version"', () async {
    final (hostSide, clientSide) = LoopbackChannel.pair();
    final client = ClientRoom(channel: clientSide, hello: _hello(), localProfileIds: const [10]);
    await _settle();
    hostSide.send(const Welcome(clientId: 'c1', token: 't'));
    hostSide.send(Start(config: _config, seed: 1, yourSeats: const {1: 0}, rules: null));
    await _settle();
    expect(client.closedReason, 'version');
    client.dispose();
  });

  test('a client whose game keeps going apart from the host gives up after a few tries', () async {
    final (hostSide, clientSide) = LoopbackChannel.pair();
    final client = ClientRoom(channel: clientSide, hello: _hello(), localProfileIds: const [10]);
    final requests = <NetMessage>[];
    hostSide.incoming.listen((m) {
      if (m is SnapshotRequest) requests.add(m);
    });
    await _settle();
    hostSide.send(const Welcome(clientId: 'c1', token: 't'));
    hostSide.send(Start(config: _config, seed: 1, yourSeats: const {1: 0}, rules: rulesVersion));
    await _settle();
    final reference = GameSession.start(memoryModule.rules, _config, 1);
    for (var seq = 1; seq <= 6 && client.closedReason == null; seq++) {
      final move = reference.rules.legalMoves(reference.state, reference.rules.currentSeat(reference.state)!).first;
      // The host says its state after the move is something this device never gets.
      hostSide.send(MoveApplied(seq: seq, move: move, stateHash: 'other-rules-$seq'));
      await _settle();
      hostSide.send(StateSnapshot(seq: seq, saved: reference.toSave()));
      await _settle();
    }
    expect(client.closedReason, 'version');
    expect(requests.length, lessThanOrEqualTo(4));
    client.dispose();
  });
}
