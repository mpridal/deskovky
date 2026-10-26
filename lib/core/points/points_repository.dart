import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
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
        line.reason,
        detail: line.badgeId ?? line.count?.toString(),
        matchId: matchId,
      );
    }
  }

  /// "Dárek od rodiče" (spec 5.6).
  Future<void> gift(int playerId, int amount) {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount', 'must be positive');
    return _add(playerId, amount, PointsReason.gift);
  }

  Future<void> spend(int playerId, int amount, {required String itemId}) =>
      _add(playerId, -amount, PointsReason.purchase, detail: itemId);

  Future<void> _add(int playerId, int amount, PointsReason reason, {String? detail, int? matchId}) => _db
      .into(_db.pointsLedger)
      .insert(
        PointsLedgerCompanion.insert(
          playerId: playerId,
          amount: amount,
          reason: reason.name,
          detail: Value(detail),
          matchId: Value(matchId),
          at: _now().millisecondsSinceEpoch,
        ),
      );

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
    reason: PointsReason.values.where((p) => p.name == r.reason).firstOrNull ?? PointsReason.gift,
    at: DateTime.fromMillisecondsSinceEpoch(r.at),
    detail: r.detail,
    matchId: r.matchId,
  );
}
