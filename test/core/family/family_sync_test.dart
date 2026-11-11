import 'dart:convert';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_identity.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/family/family_sync.dart';
import 'package:deskovky/core/family/fold.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// One family device: its own in-memory database.
class _Device {
  _Device(this.family) : db = AppDatabase(NativeDatabase.memory());

  final AppDatabase db;
  FamilyIdentity family;

  FamilyStore get store => FamilyStore.of(db);
  PlayerRepository get players => PlayerRepository(db);
  PointsRepository get points => PointsRepository(db);

  Future<String> stateJson() async => jsonEncode(foldFamily(await store.all()).toJson());

  Future<Map<String, int>> balances() async => {
    for (final p in await players.all()) p.name: await points.balance(p.id),
  };
}

/// Both ends of one meeting on the Wi-Fi.
Future<(SyncOutcome, SyncOutcome)> _meet(_Device a, _Device b) async {
  final (ca, cb) = LoopbackChannel.pair();
  final results = await Future.wait([
    syncOver(ca, store: a.store, family: a.family, initiator: true),
    syncOver(cb, store: b.store, family: b.family, initiator: false),
  ]);
  return (results[0], results[1]);
}

void main() {
  final family = FamilyIdentity.create();
  final devices = <_Device>[];
  _Device device([FamilyIdentity? f]) => _Device(f ?? family)..let(devices.add);
  tearDown(() async {
    for (final d in devices) {
      await d.db.close();
    }
    devices.clear();
  });

  test('a family ticket in the QR code survives the link there and back; others are not tickets', () {
    final ticket = FamilyTicket(familyId: family.familyId, key: family.key, ip: '192.168.1.5', port: 50600);
    final link = ticket.toUri().toString();
    expect(link, startsWith('deskovky://family?'));
    expect(FamilyTicket.parse(link), ticket);
    expect(FamilyTicket.parse('deskovky://join?ip=1.2.3.4&port=1&code=1234'), isNull);
    expect(FamilyTicket.parse('deskovky://family?id=x&key=short&ip=1.2.3.4&port=1'), isNull);
    expect(family.key, hasLength(64), reason: '32 random bytes as hex');
  });

  test('two devices converge after offline changes on both', () async {
    final tablet = device(), phone = device();
    final viky = await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await tablet.points.gift(viky.id, 30);
    final kuba = await phone.players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
    await phone.points.gift(kuba.id, 12);

    final (a, b) = await _meet(tablet, phone);
    expect(a.ok && b.ok, isTrue, reason: '${a.reason} ${b.reason}');
    expect(a.received, 2);
    expect(b.received, 2);
    expect(await tablet.balances(), {'Viky': 30, 'Kuba': 12});
    expect(await phone.balances(), {'Viky': 30, 'Kuba': 12});
    expect(await tablet.stateJson(), await phone.stateJson());
  });

  test('three devices converge whatever order they meet in', () async {
    final a = device(), b = device(), c = device();
    await a.players.create(name: 'Ája', avatar: AvatarSpec.defaults);
    await b.players.create(name: 'Bára', avatar: AvatarSpec.defaults);
    await c.players.create(name: 'Cyril', avatar: AvatarSpec.defaults);
    await _meet(b, c);
    await _meet(a, b);
    await _meet(c, a);
    for (final d in [a, b, c]) {
      expect((await d.players.all()).map((p) => p.name).toSet(), {'Ája', 'Bára', 'Cyril'});
    }
    expect({await a.stateJson(), await b.stateJson(), await c.stateJson()}, hasLength(1));
  });

  test('meeting again sends nothing new', () async {
    final a = device(), b = device();
    await a.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    await _meet(a, b);
    final (again, back) = await _meet(a, b);
    expect(again.received + back.received, 0);
    expect(again.sent + back.sent, 0);
  });

  test('a stranger without the family key gets nothing and sends nothing', () async {
    final home = device();
    await home.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    final stranger = device(FamilyIdentity(familyId: family.familyId, key: FamilyIdentity.create().key));
    await stranger.players.create(name: 'Cizí', avatar: AvatarSpec.defaults);
    final (s, h) = await _meet(stranger, home);
    expect(s.ok || h.ok, isFalse);
    expect(h.reason, 'auth');
    expect((await stranger.players.all()).map((p) => p.name), ['Cizí']);
    expect((await home.players.all()).map((p) => p.name), ['Viky']);
  });

  test('another family is turned away before anything is sent', () async {
    final home = device(), other = device(FamilyIdentity.create());
    await other.players.create(name: 'Cizí', avatar: AvatarSpec.defaults);
    final (_, h) = await _meet(other, home);
    expect(h.ok, isFalse);
    expect(h.reason, 'family');
    expect(await home.players.all(), isEmpty);
  });

  test('a removed device is refused', () async {
    final tablet = device(), phone = device();
    await _meet(tablet, phone);
    await tablet.store.append(DeviceRemoved(deviceId: await phone.store.deviceId()));
    await phone.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    final (p, t) = await _meet(phone, tablet);
    expect(t.ok, isFalse);
    expect(t.reason, 'removed');
    expect(p.ok, isFalse);
    expect(await tablet.players.all(), isEmpty);
  });

  test('a device with another sync version is refused with a reason', () async {
    final tablet = device();
    final (mine, theirs) = LoopbackChannel.pair();
    final replies = <NetMessage>[];
    theirs.incoming.listen(replies.add);
    final result = syncOver(mine, store: tablet.store, family: tablet.family, initiator: false);
    theirs.send(FamilyMessage({'t': 'hello', 'v': familySyncVersion + 1, 'family': family.familyId, 'device': 'x', 'nonce': 'n'}));
    final outcome = await result;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(outcome.ok, isFalse);
    expect(outcome.reason, 'version');
    expect(replies.whereType<FamilyMessage>().map((m) => m.body['t']), contains('bye'));
  });

  test('a first sync of 500 games finishes in time', () async {
    final tablet = device(), phone = device();
    final viky = await tablet.players.create(name: 'Viky', avatar: AvatarSpec.defaults);
    final uid = await FamilyStore.playerUid(tablet.db, viky.id);
    for (var i = 0; i < 500; i++) {
      await tablet.store.append(MatchRecorded(
        matchUid: 'm$i', gameId: 'memory', playedAtMs: 1000 + i, durationMs: 60000, difficulty: 'easy',
        participants: [MatchSeat(seat: 0, playerUid: uid, robot: false, place: 1, score: 3, stars: 3)],
        points: [PointLine(entryUid: 'p$i', playerUid: uid, amount: 10, reason: 'win')],
        counters: const [],
      ));
    }
    final watch = Stopwatch()..start();
    final (a, b) = await _meet(tablet, phone);
    expect(a.ok && b.ok, isTrue);
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
    expect(await phone.balances(), {'Viky': 5000});
  });
}

extension<T> on T {
  void let(void Function(T) f) => f(this);
}
