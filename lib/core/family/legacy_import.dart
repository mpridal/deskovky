import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'family_op.dart';
import 'family_store.dart';
import 'hlc.dart';
import 'uid.dart';

/// One-off on the update to schema v6: gives every existing profile, game
/// and points entry its family id and writes ops that say exactly what the
/// tables hold, at their original times – so a rebuild changes nothing and
/// the data can later be shared with the family.
Future<void> importLegacy(AppDatabase db) => db.transaction(() async {
  final store = FamilyStore(db);
  final device = await store.deviceId();
  final events = <(int, OpBody)>[];

  final players = <int, String>{};
  for (final p in await (db.select(db.players)..orderBy([(p) => OrderingTerm.asc(p.id)])).get()) {
    final uid = p.uid ?? newUid();
    players[p.id] = uid;
    if (p.uid == null) await (db.update(db.players)..where((x) => x.id.equals(p.id))).write(PlayersCompanion(uid: Value(uid)));
    events.add((
      p.createdAt.millisecondsSinceEpoch,
      ProfileCreated(uid: uid, name: p.name, avatar: _json(p.avatarJson), favoriteSeat: p.favoriteSeat),
    ));
  }

  final matches = <int, String>{};
  for (final m in await (db.select(db.matches)..orderBy([(m) => OrderingTerm.asc(m.id)])).get()) {
    final uid = m.uid ?? newUid();
    matches[m.id] = uid;
    if (m.uid == null) await (db.update(db.matches)..where((x) => x.id.equals(m.id))).write(MatchesCompanion(uid: Value(uid)));
    final seats = await (db.select(db.matchParticipants)
          ..where((p) => p.matchId.equals(m.id))
          ..orderBy([(p) => OrderingTerm.asc(p.seat)]))
        .get();
    events.add((
      m.playedAt,
      MatchRecorded(
        matchUid: uid,
        gameId: m.gameId,
        playedAtMs: m.playedAt,
        durationMs: m.durationMs,
        difficulty: m.difficulty,
        participants: [
          for (final s in seats)
            MatchSeat(
              seat: s.seat,
              playerUid: s.playerId == null ? null : players[s.playerId],
              robot: s.robot,
              place: s.place,
              score: s.score,
              stars: s.stars,
            ),
        ],
        points: const [],
        counters: const [],
      ),
    ));
  }

  // An owned item becomes its purchase: the last spend on it.
  final owned = {for (final i in await db.select(db.playerItems).get()) (i.playerId, i.itemId): i.acquiredAt};
  final ledger = await (db.select(db.pointsLedger)..orderBy([(e) => OrderingTerm.asc(e.id)])).get();
  final lastPurchase = <(int, String), int>{};
  for (final e in ledger) {
    if (e.reason == 'purchase' && e.detail != null) lastPurchase[(e.playerId, e.detail!)] = e.id;
  }
  for (final e in ledger) {
    final player = players[e.playerId];
    if (player == null) continue;
    final key = (e.playerId, e.detail ?? '');
    if (e.reason == 'purchase' && owned.containsKey(key) && lastPurchase[key] == e.id) {
      final itemUid = newUid();
      await (db.update(db.pointsLedger)..where((x) => x.id.equals(e.id))).write(PointsLedgerCompanion(uid: Value('buy:$itemUid')));
      events.add((e.at, ItemBought(itemUid: itemUid, playerUid: player, itemId: e.detail!, price: -e.amount, atMs: owned[key]!)));
      owned.remove(key);
      continue;
    }
    final uid = e.uid ?? newUid();
    if (e.uid == null) await (db.update(db.pointsLedger)..where((x) => x.id.equals(e.id))).write(PointsLedgerCompanion(uid: Value(uid)));
    events.add((
      e.at,
      PointsAdded(
        entryUid: uid,
        playerUid: player,
        amount: e.amount,
        reason: e.reason,
        detail: e.detail,
        matchUid: e.matchId == null ? null : matches[e.matchId],
        atMs: e.at,
      ),
    ));
  }
  // Items owned without a recorded purchase (should not exist): kept free.
  for (final MapEntry(key: (playerId, itemId), value: at) in owned.entries) {
    final player = players[playerId];
    if (player == null) continue;
    final itemUid = newUid();
    events.add((at, ItemBought(itemUid: itemUid, playerUid: player, itemId: itemId, price: 0, atMs: at)));
  }

  for (final b in await db.select(db.earnedBadges).get()) {
    final player = players[b.playerId];
    if (player != null) events.add((b.earnedAt, BadgeAwarded(playerUid: player, badgeId: b.badgeId, atMs: b.earnedAt)));
  }
  final counters = <int, Map<String, int>>{};
  for (final c in await db.select(db.playerCounters).get()) {
    (counters[c.playerId] ??= {})[c.key] = c.value;
  }
  for (final MapEntry(key: playerId, value: deltas) in counters.entries) {
    final player = players[playerId];
    if (player != null) events.add((0, CountersAdded(playerUid: player, deltas: deltas)));
  }

  // In their real order (stable for equal times), so the points balance
  // never dips where it did not on this device.
  final ordered = [for (final (i, e) in events.indexed) (e.$1, i, e.$2)]
    ..sort((a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2));
  var clock = Hlc(0, 0, device);
  final ops = <FamilyOp>[];
  for (final (seq, (ms, _, body)) in ordered.indexed) {
    clock = ms > clock.millis ? Hlc(ms, 0, device) : Hlc(clock.millis, clock.counter + 1, device);
    ops.add(FamilyOp(origin: device, seq: seq + 1, clock: clock, body: body));
  }
  await store.insertOwn(ops, clock.tick(DateTime.now().millisecondsSinceEpoch));
});

Map<String, Object?> _json(String text) {
  try {
    final value = jsonDecode(text);
    return value is Map<String, Object?> ? value : const {};
  } on FormatException {
    return const {};
  }
}
