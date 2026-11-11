import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late FamilyStore store;
  setUp(() {
    db = testDatabase();
    store = FamilyStore(db, now: () => DateTime.fromMillisecondsSinceEpoch(1762000000000));
  });
  tearDown(() => db.close());

  Future<int> idOf(String uid) async => (await (db.select(db.players)..where((p) => p.uid.equals(uid))).getSingle()).id;

  test('a new device gets an id once and its clock only moves forward', () async {
    final id = await store.deviceId();
    expect(id, hasLength(32));
    expect(await store.deviceId(), id);
    final a = await store.nextClock(), b = await store.nextClock();
    expect(b.compareTo(a), greaterThan(0));
  });

  test('appended ops get increasing numbers; the version vector and opsAfter see them', () async {
    await store.append(const ProfileCreated(uid: 'viky', name: 'Viky', avatar: {}));
    await store.append(const PointsAdded(entryUid: 'e1', playerUid: 'viky', amount: 10, reason: 'gift', atMs: 1));
    final me = await store.deviceId();
    expect(await store.versionVector(), {me: 2});
    expect((await store.opsAfter({me: 1})).single.body, isA<PointsAdded>());
    expect(await store.opsAfter({me: 2}), isEmpty);
  });

  test('remote ops are taken once; the state shows them after a rebuild', () async {
    final remote = [
      FamilyOp(origin: 'pho', seq: 1, clock: (await store.nextClock()).receive(await store.nextClock(), 0), body: const ProfileCreated(uid: 'kuba', name: 'Kuba', avatar: {})),
    ];
    expect(await store.insertRemote(remote), 1);
    expect(await store.insertRemote(remote), 0);
    await store.rebuild();
    expect((await PlayerRepository(db).all()).map((p) => p.name), ['Kuba']);
  });

  test('a rename keeps the profile number; a merge removes B, moves its games and points to A and keeps the active player', () async {
    await store.append(const ProfileCreated(uid: 'a', name: 'Viky', avatar: {}));
    await store.append(const ProfileCreated(uid: 'b', name: 'Viki', avatar: {}));
    await store.append(const PointsAdded(entryUid: 'e1', playerUid: 'b', amount: 40, reason: 'gift', atMs: 1));
    await store.append(const MatchRecorded(
      matchUid: 'm1', gameId: 'memory', playedAtMs: 5, durationMs: 1, difficulty: null,
      participants: [MatchSeat(seat: 0, playerUid: 'b', robot: false, place: 1, score: 1, stars: 3)],
      points: [], counters: [],
    ));
    await store.rebuild();
    final aId = await idOf('a'), bId = await idOf('b');
    await SettingsRepository(db).setActivePlayerId(bId);

    await store.append(const ProfileUpdated(uid: 'a', name: 'Vikinka', avatar: {}));
    await store.rebuild();
    expect(await idOf('a'), aId, reason: 'the same row, renamed');
    expect((await PlayerRepository(db).byId(aId))!.name, 'Vikinka');

    await store.append(const ProfilesMerged(fromUid: 'b', intoUid: 'a'));
    await store.rebuild();
    expect(await PlayerRepository(db).byId(bId), isNull);
    expect(await PointsRepository(db).balance(aId), 40);
    expect((await StatsRepository(db).allMatches()).single.participants.single.playerId, aId);
    expect(await SettingsRepository(db).watchActivePlayerId().first, aId, reason: 'the merged child stays signed in');
  });

  test('a deleted profile disappears with its points; its games stay without it', () async {
    await store.append(const ProfileCreated(uid: 'babi', name: 'Babička', avatar: {}));
    await store.append(const PointsAdded(entryUid: 'e1', playerUid: 'babi', amount: 5, reason: 'gift', atMs: 1));
    await store.append(const MatchRecorded(
      matchUid: 'm1', gameId: 'memory', playedAtMs: 5, durationMs: 1, difficulty: null,
      participants: [MatchSeat(seat: 0, playerUid: 'babi', robot: false, place: 1, score: 1, stars: 3)],
      points: [], counters: [],
    ));
    await store.rebuild();
    await store.append(const ProfileDeleted(uid: 'babi'));
    await store.rebuild();
    expect(await PlayerRepository(db).all(), isEmpty);
    expect(await db.select(db.pointsLedger).get(), isEmpty);
    expect((await StatsRepository(db).allMatches()).single.participants.single.playerId, isNull);
  });

  test('rebuilding the same ops twice changes nothing', () async {
    await store.append(const ProfileCreated(uid: 'viky', name: 'Viky', avatar: {}));
    await store.append(const PointsAdded(entryUid: 'e1', playerUid: 'viky', amount: 10, reason: 'gift', atMs: 1));
    await store.append(const ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'hat', price: 5, atMs: 2));
    await store.rebuild();
    final ledger = await db.select(db.pointsLedger).get();
    await store.rebuild();
    expect(await db.select(db.pointsLedger).get(), ledger);
  });
}
