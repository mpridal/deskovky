import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import '../family/family_op.dart';
import '../family/family_store.dart';
import '../family/uid.dart';
import 'points_math.dart';

@immutable
class PointsEntry {
  const PointsEntry({
    required this.playerId,
    required this.amount,
    required this.reason,
    required this.at,
    this.detail,
    this.matchId,
  });

  final int playerId;
  final int amount;
  final PointsReason reason;
  final DateTime at;

  /// Badge id, item id or stars/streak count.
  final String? detail;
  final int? matchId;
}

/// The points ledger (spec 5.6): every movement is one entry.
class PointsRepository {
  PointsRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  Future<void> addGameLines(int playerId, List<PointsLine> lines, {int? matchId}) async {
    for (final line in lines) {
      await _add(
        playerId,
        line.amount,
        line.reason.name,
        detail: line.badgeId ?? line.count?.toString(),
        matchId: matchId,
      );
    }
  }

  /// "Dárek od rodiče" (spec 5.6).
  Future<void> gift(int playerId, int amount) {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'must be positive');
    return _add(playerId, amount, PointsReason.gift.name);
  }

  /// Parents' reset of the balance; a negative entry, so the total earned
  /// (positive entries) stays. The family op is the shop's `PointsReset`.
  /// Given a [uid], the shop's `PointsReset` op covers it in the family log.
  Future<void> addReset(int playerId, int amount, {String? uid, int? at}) =>
      _add(playerId, amount, PointsReason.reset.name, uid: uid, at: at, log: uid == null);

  /// A spend; given a [uid], the shop's `ItemBought` op covers it.
  Future<void> spend(int playerId, int amount, {required String itemId, String? uid, int? at}) =>
      _add(playerId, -amount, 'purchase', detail: itemId, uid: uid, at: at, log: uid == null);

  /// Writes an entry and, unless another op covers it ([log] false), the
  /// family op saying the same.
  Future<void> _add(
    int playerId,
    int amount,
    String reason, {
    String? detail,
    int? matchId,
    String? uid,
    int? at,
    bool log = true,
  }) => _db.transaction(() async {
    final entryUid = uid ?? newUid();
    final time = at ?? _now().millisecondsSinceEpoch;
    await _db
        .into(_db.pointsLedger)
        .insert(
          PointsLedgerCompanion.insert(
            playerId: playerId,
            amount: amount,
            reason: reason,
            detail: Value(detail),
            matchId: Value(matchId),
            at: time,
            uid: Value(entryUid),
          ),
        );
    if (!log) return;
    final match = matchId == null ? null : await (_db.select(_db.matches)..where((m) => m.id.equals(matchId))).getSingleOrNull();
    await FamilyStore.of(_db).append(
      PointsAdded(
        entryUid: entryUid,
        playerUid: await FamilyStore.playerUid(_db, playerId),
        amount: amount,
        reason: reason,
        detail: detail,
        matchUid: match?.uid,
        atMs: time,
      ),
    );
  });

  Future<int> balance(int playerId) async => (await history(playerId)).fold<int>(0, (s, e) => s + e.amount);

  Future<int> totalEarned(int playerId) async =>
      (await history(playerId)).where((e) => e.amount > 0).fold<int>(0, (s, e) => s + e.amount);

  /// Newest first.
  Future<List<PointsEntry>> history(int playerId) async => [
    for (final r in await (_db.select(_db.pointsLedger)
          ..where((e) => e.playerId.equals(playerId))
          ..orderBy([(e) => OrderingTerm.desc(e.at), (e) => OrderingTerm.desc(e.id)]))
        .get())
      _entry(r),
  ];

  /// Every entry of every player, oldest first (leaderboards).
  Stream<List<PointsEntry>> watchAll() => (_db.select(_db.pointsLedger)..orderBy([(e) => OrderingTerm.asc(e.id)]))
      .watch()
      .map((rows) => [for (final r in rows) _entry(r)]);

  static PointsEntry _entry(PointsEntryRow r) => PointsEntry(
    playerId: r.playerId,
    amount: r.amount,
    reason: PointsReason.values.where((p) => p.name == r.reason).firstOrNull ?? PointsReason.participation,
    at: DateTime.fromMillisecondsSinceEpoch(r.at),
    detail: r.detail,
    matchId: r.matchId,
  );
}
