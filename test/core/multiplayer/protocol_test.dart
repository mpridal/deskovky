import 'dart:convert';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const card = ProfileCard(name: 'Kuba', avatar: {'face': 'round'});
  const config = GameConfig(
    gameId: 'memory',
    seats: [RemoteSeat(clientId: 'host', name: 'Táta', avatar: {}), RemoteSeat(clientId: 'c1', name: 'Kuba', avatar: {}), RobotSeat()],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: {'cards': 16},
  );
  const move = Move(seat: 1, type: 'flip', data: {'card': 3});

  final messages = <NetMessage>[
    const Hello(protocolVersion: 1, appVersion: '0.4.0', roomCode: '1234', token: null, profiles: [card]),
    const Welcome(clientId: 'c1', token: 'abcdefghijklmnop'),
    const LobbyState(
      gameId: 'memory',
      slots: [
        LobbySlot(kind: SlotKind.host, name: 'Táta', avatar: {}, ready: true),
        LobbySlot(kind: SlotKind.remote, name: 'Kuba', avatar: {'face': 'round'}, clientId: 'c1', ready: false),
        LobbySlot(kind: SlotKind.robot, name: 'Čipík', avatar: {}, ready: true),
      ],
      options: {'cards': 16},
      difficulty: Difficulty.medium,
      robotSpeed: RobotSpeed.fast,
    ),
    const Ready(true),
    const Start(config: config, seed: 42, yourSeats: {1: 0}),
    const MoveRequest(move: move, basedOn: 7),
    const MoveApplied(seq: 8, move: move, stateHash: 'h8'),
    const MoveRejected(seq: 7, reason: 'not your turn'),
    const SnapshotRequest(),
    StateSnapshot(seq: 8, saved: SavedGame(config: config, seed: 42, moves: const [move])),
    const Pause(bySeat: 1),
    const Resume(),
    const PeerStatus(connected: {0: true, 1: false}, waitSeconds: 25),
    const GameOver(),
    const Bye(reason: 'left'),
    const Ping(123),
    const Pong(123),
    const Kick(),
  ];

  test('every message survives JSON there and back', () {
    for (final m in messages) {
      final back = NetMessage.fromJson(jsonDecode(jsonEncode(m.toJson())));
      expect(back, m, reason: m.runtimeType.toString());
    }
  });

  test('unknown or broken messages are null, never a crash', () {
    expect(NetMessage.fromJson(null), isNull);
    expect(NetMessage.fromJson('hello'), isNull);
    expect(NetMessage.fromJson({'type': 'nonsense'}), isNull);
    expect(NetMessage.fromJson({'type': 'moveApplied', 'seq': 'x'}), isNull);
    expect(NetMessage.decode('{not json'), isNull);
  });

  test('a remote seat keeps its name and avatar in the game config', () {
    final back = GameConfig.fromJson(jsonDecode(jsonEncode(config.toJson())));
    expect(back, config);
  });

  test('loopback delivers in order, with latency, both ways', () async {
    final (a, b) = LoopbackChannel.pair(latency: const Duration(milliseconds: 20));
    final got = <NetMessage>[];
    final sub = b.incoming.listen(got.add);
    a.send(const Ping(1));
    a.send(const Ping(2));
    a.send(const Ping(3));
    expect(got, isEmpty, reason: 'nothing before the latency');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(got, [const Ping(1), const Ping(2), const Ping(3)]);
    final back = <NetMessage>[];
    a.incoming.listen(back.add);
    b.send(const Pong(9));
    await Future<void>.delayed(const Duration(milliseconds: 40));
    expect(back, [const Pong(9)]);
    await sub.cancel();
    await a.close();
    await b.close();
  });
}
