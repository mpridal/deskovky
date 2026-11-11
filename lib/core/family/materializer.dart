import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../settings/settings_repository.dart';
import 'family_op.dart';
import 'family_state.dart';

/// Writes the family [state] into the tables the screens read. Rows keep
/// their numeric ids (matched by `uid`), so the active player, saved games
/// and remembered setups keep pointing at the same profiles. Only what
/// differs is written; rows without a uid are left alone. Call it inside a
/// transaction.
Future<void> materialize(AppDatabase db, FamilyState state) async {
  final ids = await _players(db, state);
  final matchIds = await _matches(db, state, ids);
  await _ledger(db, state, ids, matchIds);
  await _perPlayer(db, state, ids);
}

/// Profiles; returns uid → row id.
Future<Map<String, int>> _players(AppDatabase db, FamilyState state) async {
  final rows = await db.select(db.players).get();
  final byUid = {
    for (final r in rows)
      if (r.uid != null) r.uid!: r,
  };
  final activeRow = await (db.select(db.appSettings)..where((s) => s.key.equals(SettingsRepository.activePlayerKey)))
      .getSingleOrNull();
  final activeId = int.tryParse(activeRow?.value ?? '');
  String? activeUid;
  for (final r in rows) {
    if (r.id == activeId) activeUid = r.uid;
  }

  // Gone (deleted, or merged into another): the rows go, their points and
  // badges with them; games keep the seat without the profile.
  for (final r in byUid.values) {
    if (!state.profiles.containsKey(r.uid)) {
      await (db.delete(db.players)..where((p) => p.id.equals(r.id))).go();
    }
  }
  // Names are unique: clear changed names first, so a swap cannot collide.
  final changed = <String>[];
  for (final p in state.profiles.values) {
    final row = byUid[p.uid];
    if (row != null && row.nameKey != p.nameKey) {
      changed.add(p.uid);
      await (db.update(db.players)..where((x) => x.id.equals(row.id))).write(PlayersCompanion(nameKey: Value('\u0001${p.uid}')));
    }
  }
  final ids = <String, int>{};
  for (final p in state.profiles.values) {
    final row = byUid[p.uid];
    final avatar = jsonEncode(p.avatar);
    if (row == null) {
      ids[p.uid] = await db
          .into(db.players)
          .insert(
            PlayersCompanion.insert(
              name: p.name,
              nameKey: p.nameKey,
              avatarJson: avatar,
              favoriteSeat: Value(p.favoriteSeat),
              createdAt: DateTime.fromMillisecondsSinceEpoch(p.createdClock.millis, isUtc: true),
              uid: Value(p.uid),
            ),
          );
      continue;
    }
    ids[p.uid] = row.id;
    if (changed.contains(p.uid) || row.name != p.name || row.avatarJson != avatar || row.favoriteSeat != p.favoriteSeat) {
      await (db.update(db.players)..where((x) => x.id.equals(row.id))).write(
        PlayersCompanion(
          name: Value(p.name),
          nameKey: Value(p.nameKey),
          avatarJson: Value(avatar),
          favoriteSeat: Value(p.favoriteSeat),
        ),
      );
    }
  }
  // The child signed in stays signed in, also when merged into another;
  // when their profile is gone, the oldest profile plays (as on delete).
  if (activeUid != null && !state.profiles.containsKey(activeUid)) {
    final next = ids[state.resolve(activeUid)] ?? (ids.isEmpty ? null : ids.values.first);
    if (next == null) {
      await (db.delete(db.appSettings)..where((s) => s.key.equals(SettingsRepository.activePlayerKey))).go();
    } else {
      await db
          .into(db.appSettings)
          .insertOnConflictUpdate(AppSettingsCompanion.insert(key: SettingsRepository.activePlayerKey, value: '$next'));
    }
  }
  return ids;
}

/// Finished games; returns match uid → row id.
Future<Map<String, int>> _matches(AppDatabase db, FamilyState state, Map<String, int> players) async {
  final rows = await db.select(db.matches).get();
  final byUid = {
    for (final r in rows)
      if (r.uid != null) r.uid!: r,
  };
  final wanted = {for (final m in state.matches) m.matchUid};
  for (final r in byUid.values) {
    if (!wanted.contains(r.uid)) await (db.delete(db.matches)..where((m) => m.id.equals(r.id))).go();
  }
  final ids = <String, int>{};
  for (final m in state.matches) {
    final row = byUid[m.matchUid];
    final int id;
    if (row == null) {
      id = await db
          .into(db.matches)
          .insert(
            MatchesCompanion.insert(
              gameId: m.gameId,
              playedAt: m.playedAtMs,
              durationMs: m.durationMs,
              difficulty: Value(m.difficulty),
              uid: Value(m.matchUid),
            ),
          );
    } else {
      id = row.id;
      if (row.gameId != m.gameId || row.playedAt != m.playedAtMs || row.durationMs != m.durationMs || row.difficulty != m.difficulty) {
        await (db.update(db.matches)..where((x) => x.id.equals(id))).write(
          MatchesCompanion(
            gameId: Value(m.gameId),
            playedAt: Value(m.playedAtMs),
            durationMs: Value(m.durationMs),
            difficulty: Value(m.difficulty),
          ),
        );
      }
    }
    ids[m.matchUid] = id;
    final seats = await (db.select(db.matchParticipants)..where((p) => p.matchId.equals(id))).get();
    final want = [for (final p in m.participants) _seatRow(id, p, players)];
    String key(MatchParticipantRow r) => '${r.seat}|${r.playerId}|${r.robot}|${r.place}|${r.score}|${r.stars}';
    final have = (seats.map(key).toList()..sort()).join(';');
    if (have != (want.map(key).toList()..sort()).join(';')) {
      await (db.delete(db.matchParticipants)..where((p) => p.matchId.equals(id))).go();
      for (final r in want) {
        await db.into(db.matchParticipants).insert(r);
      }
    }
  }
  return ids;
}

MatchParticipantRow _seatRow(int matchId, MatchSeat p, Map<String, int> players) => MatchParticipantRow(
  matchId: matchId,
  seat: p.seat,
  playerId: p.playerUid == null ? null : players[p.playerUid],
  robot: p.robot,
  place: p.place,
  score: p.score,
  stars: p.stars,
);

Future<void> _ledger(AppDatabase db, FamilyState state, Map<String, int> players, Map<String, int> matches) async {
  final rows = await db.select(db.pointsLedger).get();
  final byUid = {
    for (final r in rows)
      if (r.uid != null) r.uid!: r,
  };
  final wanted = <String, PointsLedgerCompanion>{};
  for (final MapEntry(key: uid, value: entries) in state.ledger.entries) {
    final playerId = players[uid];
    if (playerId == null) continue;
    for (final e in entries) {
      wanted[e.entryUid] = PointsLedgerCompanion.insert(
        playerId: playerId,
        amount: e.amount,
        reason: e.reason,
        detail: Value(e.detail),
        matchId: Value(e.matchUid == null ? null : matches[e.matchUid]),
        at: e.atMs,
        uid: Value(e.entryUid),
      );
    }
  }
  for (final r in byUid.values) {
    if (!wanted.containsKey(r.uid)) await (db.delete(db.pointsLedger)..where((x) => x.id.equals(r.id))).go();
  }
  for (final MapEntry(key: uid, value: c) in wanted.entries) {
    final row = byUid[uid];
    if (row == null) {
      await db.into(db.pointsLedger).insert(c);
    } else if (row.playerId != c.playerId.value ||
        row.amount != c.amount.value ||
        row.reason != c.reason.value ||
        row.detail != c.detail.value ||
        row.matchId != c.matchId.value ||
        row.at != c.at.value) {
      await (db.update(db.pointsLedger)..where((x) => x.id.equals(row.id))).write(
        PointsLedgerCompanion(
          playerId: c.playerId,
          amount: c.amount,
          reason: c.reason,
          detail: c.detail,
          matchId: c.matchId,
          at: c.at,
        ),
      );
    }
  }
}

/// Counters, badges and items: small tables, written where they differ.
Future<void> _perPlayer(AppDatabase db, FamilyState state, Map<String, int> players) async {
  final counters = <(int, String), int>{
    for (final MapEntry(key: uid, value: map) in state.counters.entries)
      if (players[uid] case final id?)
        for (final e in map.entries) (id, e.key): e.value,
  };
  final haveCounters = {for (final r in await db.select(db.playerCounters).get()) (r.playerId, r.key): r.value};
  for (final k in haveCounters.keys) {
    if (!counters.containsKey(k)) {
      await (db.delete(db.playerCounters)..where((c) => c.playerId.equals(k.$1) & c.key.equals(k.$2))).go();
    }
  }
  for (final MapEntry(key: k, value: v) in counters.entries) {
    if (haveCounters[k] != v) {
      await db.into(db.playerCounters).insertOnConflictUpdate(PlayerCountersCompanion.insert(playerId: k.$1, key: k.$2, value: v));
    }
  }

  final badges = <(int, String), int>{
    for (final MapEntry(key: uid, value: map) in state.badges.entries)
      if (players[uid] case final id?)
        for (final e in map.entries) (id, e.key): e.value,
  };
  final haveBadges = {for (final r in await db.select(db.earnedBadges).get()) (r.playerId, r.badgeId): r.earnedAt};
  for (final k in haveBadges.keys) {
    if (!badges.containsKey(k)) {
      await (db.delete(db.earnedBadges)..where((b) => b.playerId.equals(k.$1) & b.badgeId.equals(k.$2))).go();
    }
  }
  for (final MapEntry(key: k, value: at) in badges.entries) {
    if (haveBadges[k] != at) {
      await db.into(db.earnedBadges).insertOnConflictUpdate(EarnedBadgesCompanion.insert(playerId: k.$1, badgeId: k.$2, earnedAt: at));
    }
  }

  final items = <(int, String), int>{
    for (final MapEntry(key: uid, value: set) in state.items.entries)
      if (players[uid] case final id?)
        for (final item in set) (id, item): state.itemsAcquiredAt[uid]?[item] ?? 0,
  };
  final haveItems = {for (final r in await db.select(db.playerItems).get()) (r.playerId, r.itemId): r.acquiredAt};
  for (final k in haveItems.keys) {
    if (!items.containsKey(k)) {
      await (db.delete(db.playerItems)..where((i) => i.playerId.equals(k.$1) & i.itemId.equals(k.$2))).go();
    }
  }
  for (final MapEntry(key: k, value: at) in items.entries) {
    if (haveItems[k] != at) {
      await db.into(db.playerItems).insertOnConflictUpdate(PlayerItemsCompanion.insert(playerId: k.$1, itemId: k.$2, acquiredAt: at));
    }
  }
}
