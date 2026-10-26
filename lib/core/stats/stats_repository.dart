import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../game/difficulty.dart';
import 'match_record.dart';

/// A game event reported through `GameHost.reportEvent` (spec 8).
typedef GameEvent = (String id, Map<String, Object?> data);

/// Whether an event concerns [seat]: events naming a seat concern only it.
bool eventConcerns(Map<String, Object?> data, int seat) => data['seat'] is! int || data['seat'] == seat;

/// Finished games, event counters and earned badges (spec 5.4, 5.5).
class StatsRepository {
  StatsRepository(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  DateTime now() => _now();

  /// Runs [action] atomically (drift nests inner transactions as savepoints).
  Future<T> transaction<T>(Future<T> Function() action) => _db.transaction(action);

  /// Stores [match]; [events] add up in the human players' counters
  /// (`data['count']`, default 1; only the player at `data['seat']` when the
  /// event names a seat). Returns the match id.
  Future<int> recordMatch(MatchRecord match, {List<GameEvent> events = const []}) => _db.transaction(() async {
    final id = await _db
        .into(_db.matches)
        .insert(
          MatchesCompanion.insert(
            gameId: match.gameId,
            playedAt: match.playedAt.millisecondsSinceEpoch,
            durationMs: match.duration.inMilliseconds,
            difficulty: Value(match.difficulty?.name),
          ),
        );
    for (final p in match.participants) {
      await _db
          .into(_db.matchParticipants)
          .insert(
            MatchParticipantsCompanion.insert(
              matchId: id,
              seat: p.seat,
              playerId: Value(p.playerId),
              robot: p.robot,
              place: p.place,
              score: p.score,
              stars: p.stars,
            ),
          );
    }
    for (final (key, data) in events) {
      final count = data['count'] is int ? data['count']! as int : 1;
      for (final player in {
        for (final p in match.participants)
          if (eventConcerns(data, p.seat)) ?p.playerId,
      }) {
        await _db.customStatement(
          'INSERT INTO player_counters (player_id, key, value) VALUES (?, ?, ?) '
          'ON CONFLICT (player_id, key) DO UPDATE SET value = value + excluded.value',
          [player, key, count],
        );
      }
    }
    return id;
  });

  Future<MatchRecord?> matchById(int id) async =>
      (await _load((_db.select(_db.matches)..where((m) => m.id.equals(id))).get())).firstOrNull;

  /// Every stored match, oldest first.
  Future<List<MatchRecord>> allMatches() =>
      _load((_db.select(_db.matches)..orderBy([(m) => OrderingTerm.asc(m.playedAt), (m) => OrderingTerm.asc(m.id)])).get());

  /// All matches now and after every change. Watches participants: they are
  /// written with every new match, and deleting a player clears their id.
  Stream<List<MatchRecord>> watchAllMatches() =>
      _db.select(_db.matchParticipants).watch().asyncMap((_) => allMatches());

  Stream<Map<String, DateTime>> watchEarnedBadges(int playerId) =>
      (_db.select(_db.earnedBadges)..where((b) => b.playerId.equals(playerId))).watch().asyncMap(
        (_) => earnedBadges(playerId),
      );

  Stream<(int playerId, String badgeId)?> watchLastBadge() =>
      _db.select(_db.earnedBadges).watch().asyncMap((_) => lastBadge());

  Future<List<MatchRecord>> _load(Future<List<MatchRow>> rows) async {
    final matches = await rows;
    if (matches.isEmpty) return const [];
    final seats = await (_db.select(_db.matchParticipants)
          ..where((p) => p.matchId.isIn(matches.map((m) => m.id)))
          ..orderBy([(p) => OrderingTerm.asc(p.seat)]))
        .get();
    final byMatch = <int, List<MatchParticipant>>{};
    for (final s in seats) {
      (byMatch[s.matchId] ??= []).add(
        MatchParticipant(
          seat: s.seat,
          playerId: s.playerId,
          robot: s.robot,
          place: s.place,
          score: s.score,
          stars: s.stars,
        ),
      );
    }
    return [
      for (final m in matches)
        MatchRecord(
          id: m.id,
          gameId: m.gameId,
          playedAt: DateTime.fromMillisecondsSinceEpoch(m.playedAt),
          duration: Duration(milliseconds: m.durationMs),
          difficulty: Difficulty.values.where((d) => d.name == m.difficulty).firstOrNull,
          participants: byMatch[m.id] ?? const [],
        ),
    ];
  }

  /// Which of [ids] still have a profile.
  Future<Set<int>> existingPlayerIds(Iterable<int> ids) async => {
    for (final p in await (_db.select(_db.players)..where((p) => p.id.isIn(ids))).get()) p.id,
  };

  Future<int> counter(int playerId, String key) async =>
      (await (_db.select(_db.playerCounters)..where((c) => c.playerId.equals(playerId) & c.key.equals(key)))
              .getSingleOrNull())
          ?.value ??
      0;

  Future<Map<String, int>> counters(int playerId) async => {
    for (final c in await (_db.select(_db.playerCounters)..where((c) => c.playerId.equals(playerId))).get())
      c.key: c.value,
  };

  /// Records [badgeId] for [playerId]; false if it was already earned.
  Future<bool> awardBadge(int playerId, String badgeId) => _db.transaction(() async {
    final existing = await (_db.select(_db.earnedBadges)
          ..where((b) => b.playerId.equals(playerId) & b.badgeId.equals(badgeId)))
        .getSingleOrNull();
    if (existing != null) return false;
    await _db
        .into(_db.earnedBadges)
        .insert(
          EarnedBadgesCompanion.insert(playerId: playerId, badgeId: badgeId, earnedAt: _now().millisecondsSinceEpoch),
        );
    return true;
  });

  /// Earned badges with the time they were earned, oldest first.
  Future<Map<String, DateTime>> earnedBadges(int playerId) async => {
    for (final b in await (_db.select(_db.earnedBadges)
          ..where((b) => b.playerId.equals(playerId))
          ..orderBy([(b) => OrderingTerm.asc(b.earnedAt)]))
        .get())
      b.badgeId: DateTime.fromMillisecondsSinceEpoch(b.earnedAt),
  };

  /// The most recently earned badge on this device (tablet "Poslední odměna").
  Future<(int playerId, String badgeId)?> lastBadge() async {
    final row = await (_db.select(_db.earnedBadges)
          ..orderBy([
            (b) => OrderingTerm.desc(b.earnedAt),
            (_) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : (row.playerId, row.badgeId);
  }
}
