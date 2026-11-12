import 'package:deskovky/app/family_controller.dart';
import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_identity.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/family/family_sync.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../app/fake_family_net.dart';

/// A family device with its own database.
class _Device {
  _Device() : db = AppDatabase(NativeDatabase.memory());

  final AppDatabase db;

  PlayerRepository get players => PlayerRepository(db);
  StatsService get stats => StatsService(StatsRepository(db), points: PointsRepository(db));
}

Future<void> _meet(_Device a, _Device b, FamilyIdentity family) async {
  final (ca, cb) = LoopbackChannel.pair();
  await Future.wait([
    syncOver(ca, store: FamilyStore.of(a.db), family: family, initiator: true),
    syncOver(cb, store: FamilyStore.of(b.db), family: family, initiator: false),
  ]);
}

void main() {
  final devices = <_Device>[];
  _Device device() => _Device()..let(devices.add);
  tearDown(() async {
    for (final d in devices) {
      await d.db.close();
    }
    devices.clear();
  });

  test('the start of a family game carries one match id and the family ids of the seats', () {
    final config = GameConfig(
      gameId: 'memory',
      seats: const [RemoteSeat(clientId: 'host', name: 'Táta', avatar: {}), RemoteSeat(clientId: 'c1', name: 'Viky', avatar: {})],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {},
    );
    final start = Start(config: config, seed: 7, yourSeats: const {1: 0}, matchUid: '4321-7', seatUids: const {0: 'tata', 1: 'viky'});
    final back = NetMessage.decode(start.encode())! as Start;
    expect(back.matchUid, '4321-7');
    expect(back.seatUids, {0: 'tata', 1: 'viky'});
    // An older host sends neither: no match id, nobody known.
    final old = NetMessage.fromJson({...start.toJson()}..remove('match')..remove('seatUids'))! as Start;
    expect(old.matchUid, isNull);
    expect(old.seatUids, isEmpty);
    expect(ProfileCard.fromJson(const ProfileCard(name: 'Viky', avatar: {}, uid: 'viky').toJson())!.uid, 'viky');
  });

  test('a family network game is one match on every device, with both players and points once each', () async {
    final family = FamilyIdentity.create();
    final tablet = device(), phone = device();
    final tata = await tablet.players.create(name: 'Táta', avatar: AvatarSpec.defaults);
    await _meet(tablet, phone, family);
    final viky = await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await _meet(tablet, phone, family);
    final tataUid = await FamilyStore.playerUid(tablet.db, tata.id), vikyUid = await FamilyStore.playerUid(phone.db, viky.id);
    const result = GameResult(places: [1, 2], scores: [5, 3], stars: [3, 2]);
    // The host (tablet) and the client (phone) each record the same game.
    await tablet.stats.recordFinished(
      config: GameConfig(
        gameId: 'memory',
        seats: [HumanSeat(tata.id), const RemoteSeat(clientId: 'c1', name: 'Viky', avatar: {})],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {},
      ),
      result: result,
      events: const [],
      duration: const Duration(minutes: 1),
      matchUid: '4321-7',
      familyUids: {1: vikyUid},
    );
    final phoneVikyId = (await phone.players.all()).firstWhere((p) => p.name == 'Viky').id;
    await phone.stats.recordFinished(
      config: GameConfig(
        gameId: 'memory',
        seats: [const RemoteSeat(clientId: 'host', name: 'Táta', avatar: {}), HumanSeat(phoneVikyId)],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {},
      ),
      result: result,
      events: const [],
      duration: const Duration(minutes: 1),
      matchUid: '4321-7',
      familyUids: {0: tataUid},
    );
    await _meet(tablet, phone, family);
    for (final d in [tablet, phone]) {
      final matches = await StatsRepository(d.db).allMatches();
      expect(matches, hasLength(1));
      final names = {
        for (final p in matches.single.participants)
          (await d.players.byId(p.playerId!))!.name,
      };
      expect(names, {'Táta', 'Viky'});
      final byName = {for (final p in await d.players.all()) p.name: p.id};
      final tataPoints = await PointsRepository(d.db).balance(byName['Táta']!);
      final vikyPoints = await PointsRepository(d.db).balance(byName['Viky']!);
      expect(tataPoints, greaterThan(0));
      expect(vikyPoints, greaterThan(0));
      // Once each: the same on both devices, from one device's record.
      expect(tataPoints, await PointsRepository(tablet.db).balance(tata.id));
      expect(vikyPoints, await PointsRepository(phone.db).balance(phoneVikyId));
    }
  });

  test('a seat whose family id this device does not know stays a guest', () async {
    final tablet = device();
    final tata = await tablet.players.create(name: 'Táta', avatar: AvatarSpec.defaults);
    await tablet.stats.recordFinished(
      config: GameConfig(
        gameId: 'memory',
        seats: [HumanSeat(tata.id), const RemoteSeat(clientId: 'c1', name: 'Cizí', avatar: {})],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {},
      ),
      result: const GameResult(places: [1, 2], scores: [5, 3], stars: [3, 2]),
      events: const [],
      duration: const Duration(minutes: 1),
      matchUid: 'x-1',
      familyUids: const {1: 'somebody-else'},
    );
    await FamilyStore.of(tablet.db).rebuild();
    final match = (await StatsRepository(tablet.db).allMatches()).single;
    expect(match.participants[1].playerId, isNull);
  });

  group('invitations', () {
    late FakeLan lan;
    final controllers = <FamilyController>[];
    FamilyController controller(_Device d) => FamilyController(
      db: d.db,
      net: lan.device(),
      stats: d.stats,
      resyncAfter: const Duration(milliseconds: 50),
    )..let(controllers.add);
    setUp(() => lan = FakeLan());
    tearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
      controllers.clear();
    });

    Future<void> settle([int ms = 300]) => Future<void>.delayed(Duration(milliseconds: ms));

    test('an invitation reaches the family device and names the child, the game and the host', () async {
      final tablet = device(), phone = device();
      final host = controller(tablet), child = controller(phone);
      await host.createFamily(deviceName: 'Tablet');
      await child.joinFamily(host.ticket!, deviceName: 'Telefon');
      final viky = await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
      await settle(600);
      final got = <FamilyInvite>[];
      final sub = child.invites.listen(got.add);
      final vikyUid = await FamilyStore.playerUid(phone.db, viky.id);
      const room = JoinTicket(ip: '192.168.1.10', port: 50505, code: '4321');
      expect(await host.invite(profileUid: vikyUid, room: room, gameId: 'memory', hostName: 'Táta'), isTrue);
      await settle();
      expect(got, hasLength(1));
      expect(got.single.profileUid, vikyUid);
      expect(got.single.room, room);
      expect(got.single.gameId, 'memory');
      expect(got.single.hostName, 'Táta');
      await sub.cancel();
    });

    test('a device in a game is not interrupted by an invitation', () async {
      final tablet = device(), phone = device();
      final host = controller(tablet), child = controller(phone);
      await host.createFamily(deviceName: 'Tablet');
      await child.joinFamily(host.ticket!, deviceName: 'Telefon');
      await settle(600);
      final got = <FamilyInvite>[];
      final sub = child.invites.listen(got.add);
      child.setInGame(true);
      for (var i = 0; i < 100 && (host.syncing || child.syncing); i++) {
        await settle(20);
      }
      await host.invite(profileUid: 'x', room: const JoinTicket(ip: '1.2.3.4', port: 1, code: '1234'), gameId: 'memory', hostName: 'Táta');
      await settle();
      expect(got, isEmpty);
      await sub.cancel();
    });

    test('without family devices on the Wi-Fi nobody is invited', () async {
      final host = controller(device());
      await host.createFamily(deviceName: 'Tablet');
      expect(
        await host.invite(profileUid: 'x', room: const JoinTicket(ip: '1.2.3.4', port: 1, code: '1234'), gameId: 'memory', hostName: 'Táta'),
        isFalse,
      );
    });
  });
}

extension<T> on T {
  void let(void Function(T) f) => f(this);
}
