import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/features/game_play/seat_identity.dart';
import 'package:deskovky/l10n/app_localizations_cs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final kubaAvatar = AvatarSpec.defaults.toJson();
  final shared = GameConfig(
    gameId: 'memory',
    seats: [
      RemoteSeat(clientId: 'host', name: 'Táta', avatar: kubaAvatar),
      RemoteSeat(clientId: 'c1', name: 'Kuba', avatar: kubaAvatar),
      const RobotSeat(),
    ],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: const {},
  );

  test("each device turns its own seats into its profiles; the others stay remote", () {
    final onPhone = shared.forDevice({1: 7});
    expect(onPhone.seats, [shared.seats[0], const HumanSeat(7), const RobotSeat()]);
    expect(onPhone.humans, 1);
    expect(onPhone.people, 2, reason: 'people = local + remote');
    expect(onPhone.robots, 1);
  });

  test('a remote player shows their own name and avatar, and is no robot', () {
    final ids = SeatIdentity.forConfig(shared.forDevice({0: 3}), const [], AppLocalizationsCs());
    expect(ids[1].name, 'Kuba');
    expect(ids[1].isRobot, isFalse);
    expect(ids[1].isRemote, isTrue);
    expect(ids[2].isRobot, isTrue);
  });
}
