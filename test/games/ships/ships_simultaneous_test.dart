import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_rules.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/ships/ships_module.dart';
import 'package:deskovky/games/ships/ships_rules.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = ShipsRules();

const fleetA = [Ship(0, 0, 4, true), Ship(0, 2, 3, true), Ship(0, 4, 3, true), Ship(0, 6, 2, true)];
const fleetB = [Ship(7, 0, 4, false), Ship(5, 0, 3, false), Ship(0, 7, 3, true), Ship(3, 4, 2, true)];

final _avatar = AvatarSpec.defaults.toJson();

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

ShipsState fresh() => rules.initialState(
  GameConfig(
    gameId: 'ships',
    seats: const [HumanSeat(1), HumanSeat(2)],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: const {},
  ),
  1,
);

void main() {
  test('both seats may place their fleet at once; shooting keeps its turns', () {
    expect(rules, isA<OutOfTurnMoves<ShipsState>>());
    var s = fresh();
    expect(rules.currentSeat(s), 0);
    final second = ShipsRules.place(1, fleetB);
    expect((rules as OutOfTurnMoves<ShipsState>).outOfTurn(s, second), isTrue);
    expect(rules.isLegal(s, second), isTrue, reason: 'seat 1 places while seat 0 is still placing');
    s = rules.apply(s, second);
    expect(rules.currentSeat(s), 0);
    expect(rules.isLegal(s, ShipsRules.place(1, fleetB)), isFalse, reason: 'only once');
    s = rules.apply(s, ShipsRules.place(0, fleetA));
    expect(s.placing, isFalse);
    expect(rules.currentSeat(s), 0);
    final outOfTurnShot = ShipsRules.shoot(1, 0);
    expect((rules as OutOfTurnMoves<ShipsState>).outOfTurn(s, outOfTurnShot), isFalse);
    expect(rules.isLegal(s, outOfTurnShot), isFalse);
  });

  test('over Wi-Fi the guest places while the host still places, and the host after', () async {
    final host = HostRoom(
      module: shipsModule,
      roomCode: '4321',
      slots: [
        LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)),
        const OpenSlot(),
      ],
      difficulty: Difficulty.medium,
      robotSpeed: RobotSpeed.fast,
      options: const {},
      runner: const InlineAiRunner(),
      robotDelay: Duration.zero,
      seed: 3,
    );
    final (hostSide, clientSide) = LoopbackChannel.pair();
    host.accept(hostSide);
    final kuba = ClientRoom(
      channel: clientSide,
      hello: Hello(
        protocolVersion: protocolVersion,
        appVersion: '0.12.0',
        roomCode: '4321',
        token: null,
        profiles: [ProfileCard(name: 'Kuba', avatar: _avatar)],
      ),
      localProfileIds: const [10],
    );
    await _settle();
    kuba.setReady(true);
    await _settle();
    host.start();
    await _settle();
    // Seat 0 (Táta, the host) is "on turn" to place; Kuba places anyway.
    expect(await kuba.submit(ShipsRules.place(1, fleetB)), isTrue);
    await _settle();
    expect((host.session!.state as ShipsState).ships[1], fleetB);
    expect(await host.submitLocal(ShipsRules.place(0, fleetA)), isTrue);
    await _settle();
    expect((kuba.session!.state as ShipsState).placing, isFalse);
    // Shooting: Kuba is not on turn.
    expect(await kuba.submit(ShipsRules.shoot(1, 0)), isFalse);
    host.dispose();
    kuba.dispose();
  });
}
