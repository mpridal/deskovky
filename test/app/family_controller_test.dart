import 'package:deskovky/app/family_controller.dart';
import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_identity.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_family_net.dart';

class _Device {
  _Device(FakeLan lan, this.name, {bool wifi = true, this.systemName}) : db = AppDatabase(NativeDatabase.memory()) {
    net = lan.device(wifi: wifi);
    controller = FamilyController(
      db: db,
      net: net,
      stats: StatsService(StatsRepository(db), points: PointsRepository(db)),
      resyncAfter: const Duration(milliseconds: 50),
      presence: const Duration(milliseconds: 400),
      systemDeviceName: () async => systemName,
    );
  }

  final String name;
  final String? systemName;
  final AppDatabase db;
  late final FakeFamilyNet net;
  late final FamilyController controller;

  PlayerRepository get players => PlayerRepository(db);

  Future<Set<String>> names() async => {for (final p in await players.all()) p.name};
}

Future<void> _settle([int ms = 300]) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  late FakeLan lan;
  final devices = <_Device>[];
  _Device device(String name, {bool wifi = true, String? systemName}) =>
      _Device(lan, name, wifi: wifi, systemName: systemName)..let(devices.add);
  setUp(() => lan = FakeLan());
  tearDown(() async {
    for (final d in devices) {
      d.controller.dispose();
      await d.db.close();
    }
    devices.clear();
  });

  test('a new family shows a ticket of this device; joining with it brings the whole family', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await tablet.controller.createFamily(deviceName: 'Tablet');
    final ticket = tablet.controller.ticket!;
    expect(ticket.ip, tablet.net.ip);
    await phone.players.create(name: 'Kuba', avatar: AvatarSpec.defaults);

    final outcome = await phone.controller.joinFamily(ticket, deviceName: 'Telefon');
    expect(outcome.ok, isTrue, reason: outcome.reason);
    expect(await phone.names(), {'Viky', 'Kuba'});
    await _settle();
    expect(await tablet.names(), {'Viky', 'Kuba'});
    final devicesSeen = await tablet.controller.familyDevices();
    expect(devicesSeen.map((d) => d.name).toSet(), {'Tablet', 'Telefon'});
    expect(devicesSeen.where((d) => d.isMe).single.name, 'Tablet');
  });

  test('moving to another family takes only the profiles that play on this device (review R-032)', () async {
    final tablet = device('Tablet'), phone = device('Telefon'), babi = device('Babi');
    await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await phone.players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
    await _settle();
    expect(await phone.names(), {'Viky', 'Kuba'});

    await babi.players.create(name: 'Ema', avatar: AvatarSpec.defaults);
    await babi.controller.createFamily(deviceName: 'Babi');
    final outcome = await phone.controller.joinFamily(babi.controller.ticket!, deviceName: 'Telefon');
    expect(outcome.ok, isTrue, reason: outcome.reason);
    await _settle();
    expect(await babi.names(), {'Ema', 'Kuba'}, reason: "Viky never played on the phone: she is not grandma's");
    expect(await phone.names(), {'Ema', 'Kuba'});
    expect((await babi.controller.familyDevices()).map((d) => d.name).toSet(), {'Babi', 'Telefon'});
    expect(await tablet.names(), {'Viky', 'Kuba'}, reason: 'the old family keeps what it had');
  });

  test('a move to another family that fails keeps everything as it was', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await phone.players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
    await _settle();
    final elsewhere = FamilyTicket(familyId: 'f' * 32, key: 'a' * 64, ip: '192.168.1.250', port: 4000);
    final outcome = await phone.controller.joinFamily(elsewhere, deviceName: 'Telefon');
    expect(outcome.ok, isFalse);
    expect(await phone.names(), {'Viky', 'Kuba'});
    final before = (await phone.db.select(phone.db.syncOps).get()).length;
    expect(before, greaterThan(3));
    expect((await phone.controller.familyDevices()).map((d) => d.name).toSet(), {'Tablet', 'Telefon'});
  });

  test('family devices on the Wi-Fi sync by themselves after a change', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    final viky = await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await PointsRepository(phone.db).gift(viky.id, 25);
    await _settle(600);
    final onTablet = (await tablet.players.all()).single;
    expect(onTablet.name, 'Viky');
    expect(await PointsRepository(tablet.db).balance(onTablet.id), 25);
    expect(tablet.controller.lastSyncAt, isNotNull);
  });

  test('while a game is played nothing syncs; right after it does', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    tablet.controller.setInGame(true);
    // A sync already running when the game starts may finish; none starts after.
    for (var i = 0; i < 100 && (tablet.controller.syncing || phone.controller.syncing); i++) {
      await _settle(20);
    }
    await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await _settle(600);
    expect(await tablet.names(), isEmpty, reason: 'busy with a game');
    tablet.controller.setInGame(false);
    await _settle(600);
    expect(await tablet.names(), {'Viky'});
  });

  test('a rematch (next game opens before the last one closes) stays a game (review I2)', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    tablet.controller.setInGame(true);
    for (var i = 0; i < 100 && (tablet.controller.syncing || phone.controller.syncing); i++) {
      await _settle(20);
    }
    // pushReplacement: the new game screen starts, then the old one closes.
    tablet.controller.setInGame(true);
    tablet.controller.setInGame(false);
    await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await _settle(600);
    expect(await tablet.names(), isEmpty, reason: 'the rematch is still a game');
    tablet.controller.setInGame(false);
    await _settle(600);
    expect(await tablet.names(), {'Viky'});
  });

  test('the beacon follows the active player (review I6)', () async {
    final tablet = device('Tablet');
    final viky = await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    final kuba = await tablet.players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
    await SettingsRepository(tablet.db).setActivePlayerId(viky.id);
    await tablet.controller.createFamily(deviceName: 'Tablet');
    final heard = <String?>[];
    final sub = lan.device().beacons().listen((b) => heard.add(b.activeUid));
    await _settle(200);
    expect(heard.last, viky.uid);
    await SettingsRepository(tablet.db).setActivePlayerId(kuba.id);
    await _settle(300);
    expect(heard.last, kuba.uid);
    await sub.cancel();
  });

  test('without a family a network game leaves the tables alone (review I9)', () async {
    final tablet = device('Tablet');
    final viky = await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await tablet.db.customStatement("UPDATE players SET name = 'Vikinka' WHERE id = ${viky.id}");
    await tablet.controller.afterNetworkGame();
    expect(await tablet.names(), {'Vikinka'}, reason: 'no family: nothing rebuilt');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await tablet.controller.afterNetworkGame();
    expect(await tablet.names(), {'Viky'}, reason: 'in a family the log is the truth');
  });

  test('a removed device gets nothing new', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    // Wait for the syncs after joining, not for a fixed time (review R-019).
    for (var i = 0; i < 200 && (tablet.controller.syncing || phone.controller.syncing); i++) {
      await _settle(10);
    }
    await tablet.controller.removeDevice(await FamilyStore.of(phone.db).deviceId());
    await tablet.players.create(name: 'Tajná', avatar: AvatarSpec.defaults);
    await _settle(600);
    expect(await phone.names(), isEmpty);
    expect((await tablet.controller.familyDevices()).where((d) => d.removed).single.name, 'Telefon');
  });

  test('a device with another sync version is reported, so the parents can update', () async {
    final tablet = device('Tablet');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    expect(tablet.controller.problem, isNull);
    tablet.controller.debugReport('version');
    expect(tablet.controller.problem, FamilyProblem.otherVersion);
  });

  test('a badge earned with points from two devices is awarded after the sync', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    final viky = await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    // One game on the tablet, so badges can be checked for Viky there.
    await StatsRepository(tablet.db).recordMatch(
      MatchRecord(
        gameId: 'memory',
        playedAt: DateTime(2026, 11, 1),
        duration: const Duration(minutes: 1),
        difficulty: null,
        participants: [MatchParticipant(seat: 0, playerId: viky.id, place: 1, score: 1, stars: 3)],
      ),
    );
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    final uid = await FamilyStore.playerUid(tablet.db, viky.id);
    await FamilyStore.of(phone.db).append(CountersAdded(playerUid: uid, deltas: const {'memory.pairs': 250}));
    await _settle(600);
    expect((await StatsRepository(tablet.db).earnedBadges(viky.id)).keys, contains('memory.collector'));
  });

  test('without Wi-Fi a family can be created but shows no code', () async {
    final offline = device('Tablet', wifi: false);
    await offline.controller.createFamily(deviceName: 'Tablet');
    expect(await FamilyIdentity.load(offline.db), isNotNull);
    expect(offline.controller.ticket, isNull);
    expect(offline.controller.problem, FamilyProblem.noWifi);
  });

  test('who plays now on another family device is known while it is heard; one in a game is busy', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    final viky = await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await SettingsRepository(phone.db).setActivePlayerId(viky.id);
    var notified = 0;
    tablet.controller.addListener(() => notified++);
    await _settle();
    final vikyUid = (await phone.players.all()).single.uid!;
    expect(tablet.controller.playingElsewhere.keys, [vikyUid]);
    expect(tablet.controller.playingElsewhere[vikyUid]!.busy, isFalse);
    expect(notified, greaterThan(0), reason: 'the screens hear about it');
    expect(phone.controller.playingElsewhere, isEmpty, reason: 'nobody plays on the tablet');

    phone.controller.setInGame(true);
    await _settle();
    expect(tablet.controller.playingElsewhere[vikyUid]!.busy, isTrue);
    phone.controller.setInGame(false);
    await _settle();
    expect(tablet.controller.playingElsewhere[vikyUid]!.busy, isFalse);

    // The phone goes quiet (app closed, left the Wi-Fi): after a while it is gone.
    phone.controller.dispose();
    devices.remove(phone);
    await phone.db.close();
    await _settle(700);
    expect(tablet.controller.playingElsewhere, isEmpty);
  });

  test('the device list says which devices are on the Wi-Fi now and who plays on each', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    final viky = await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await SettingsRepository(phone.db).setActivePlayerId(viky.id);
    await _settle();
    final vikyUid = (await phone.players.all()).single.uid;
    var list = await tablet.controller.familyDevices();
    final me = list.singleWhere((d) => d.isMe), other = list.singleWhere((d) => !d.isMe);
    expect(me.online, isTrue, reason: 'this device is always here');
    expect(me.activeUid, isNull, reason: 'nobody chosen on the tablet');
    expect(other.name, 'Telefon');
    expect(other.online, isTrue);
    expect(other.activeUid, vikyUid);
    expect((await phone.controller.familyDevices()).singleWhere((d) => d.isMe).activeUid, vikyUid);

    phone.controller.dispose();
    devices.remove(phone);
    await phone.db.close();
    await _settle(700);
    list = await tablet.controller.familyDevices();
    expect(list.singleWhere((d) => !d.isMe).online, isFalse);
    expect(list.singleWhere((d) => !d.isMe).activeUid, isNull);
  });

  test('a device renamed is renamed on every device', () async {
    final tablet = device('Tablet'), phone = device('Telefon');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await phone.controller.joinFamily(tablet.controller.ticket!, deviceName: 'Telefon');
    await _settle();
    await phone.controller.renameDevice('Kubův telefon');
    await _settle(600);
    expect((await tablet.controller.familyDevices()).map((d) => d.name), contains('Kubův telefon'));
    expect((await phone.controller.familyDevices()).singleWhere((d) => d.isMe).name, 'Kubův telefon');
  });

  test('a device still called just "Tablet" takes the name the system gives it', () async {
    final tablet = device('Tablet', systemName: 'Galaxy Tab A7 Lite');
    await tablet.controller.createFamily(deviceName: 'Tablet');
    await _settle();
    expect((await tablet.controller.familyDevices()).single.name, 'Galaxy Tab A7 Lite');
    // A name chosen by hand stays.
    await tablet.controller.renameDevice('Obývák');
    tablet.controller.syncSoon();
    await _settle();
    expect((await tablet.controller.familyDevices()).single.name, 'Obývák');
  });

  test('a device called just "Handy" or "Телефон" takes the system name too (review R-027)', () async {
    for (final generic in ['Handy', 'Телефон', 'Tablette', 'Celular']) {
      final tablet = device('T', systemName: 'Galaxy Tab A7 Lite');
      await tablet.controller.createFamily(deviceName: generic);
      await _settle();
      expect((await tablet.controller.familyDevices()).single.name, 'Galaxy Tab A7 Lite', reason: generic);
    }
  });
}


extension<T> on T {
  void let(void Function(T) f) => f(this);
}