import 'family_op.dart';
import 'family_state.dart';
import 'hlc.dart';

/// The family state from every op (spec "Rodinná synchronizace" kap. 6).
/// Pure and deterministic: the same ops in any order, delivered any number
/// of times, give the same state on every device.
FamilyState foldFamily(Iterable<FamilyOp> input) {
  // One copy of each op, in the family's single order.
  final byId = <(String, int), FamilyOp>{};
  for (final op in input) {
    byId.putIfAbsent((op.origin, op.seq), () => op);
  }
  final ops = byId.values.toList()
    ..sort((a, b) {
      final byClock = a.clock.compareTo(b.clock);
      if (byClock != 0) return byClock;
      final byOrigin = a.origin.compareTo(b.origin);
      return byOrigin != 0 ? byOrigin : a.seq.compareTo(b.seq);
    });

  // Merges and deletions apply to everything, also what came before them.
  final aliases = <String, String>{};
  final deleted = <String>{};
  for (final op in ops) {
    switch (op.body) {
      case ProfilesMerged(:final fromUid, :final intoUid) when fromUid != intoUid:
        aliases.putIfAbsent(fromUid, () => intoUid);
      case ProfileDeleted(:final uid):
        deleted.add(uid);
      default:
        break;
    }
  }
  final chains = <String, List<String>>{};
  List<String> chain(String uid) => chains.putIfAbsent(uid, () {
    final path = [uid];
    for (var next = aliases[path.last]; next != null; next = aliases[path.last]) {
      if (path.contains(next)) {
        // A cycle of merges: the smallest uid in it is where all belong.
        final cycle = path.sublist(path.indexOf(next));
        return [...path.sublist(0, path.indexOf(next)), (cycle..sort()).first];
      }
      path.add(next);
    }
    return path;
  });
  String root(String uid) => chain(uid).last;
  bool dropped(String uid) => chain(uid).any(deleted.contains);

  final profileData = <String, (String, Map<String, Object?>, int?)>{};
  final created = <String, Hlc>{};
  final matchOrder = <String>[];
  final matches = <String, MatchView>{};
  final ledger = <String, List<LedgerView>>{};
  final seenEntries = <String>{};
  final paidBadges = <String>{};
  final counters = <String, Map<String, int>>{};
  final badges = <String, Map<String, int>>{};
  final items = <String, Set<String>>{};
  final itemsAt = <String, Map<String, int>>{};
  final seenItems = <String>{};
  final refunds = <String, List<RefundNotice>>{};
  final devices = <String, DeviceView>{};
  final balances = <String, int>{};

  void addEntry(String player, LedgerView entry) {
    if (dropped(player) || !seenEntries.add(entry.entryUid)) return;
    final r = root(player);
    // A badge's reward is paid once, wherever the badge was earned.
    if (entry.reason == 'badge' && entry.detail != null && !paidBadges.add('$r:${entry.detail}')) return;
    (ledger[r] ??= []).add(entry);
    balances[r] = (balances[r] ?? 0) + entry.amount;
  }

  void addCounter(String player, String key, int delta) {
    if (dropped(player)) return;
    final map = counters[root(player)] ??= {};
    map[key] = (map[key] ?? 0) + delta;
  }

  for (final op in ops) {
    switch (op.body) {
      case ProfileCreated(:final uid, :final name, :final avatar, :final favoriteSeat):
        if (dropped(uid)) break;
        final r = root(uid);
        profileData[r] = (name, avatar, favoriteSeat);
        if (uid == r || !created.containsKey(r)) created[r] = uid == r ? op.clock : (created[r] ?? op.clock);
      case ProfileUpdated(:final uid, :final name, :final avatar, :final favoriteSeat):
        if (dropped(uid)) break;
        profileData[root(uid)] = (name, avatar, favoriteSeat);
      case MatchRecorded():
        final m = op.body as MatchRecorded;
        final existing = matches[m.matchUid];
        if (existing == null) {
          matchOrder.add(m.matchUid);
          matches[m.matchUid] = MatchView(
            matchUid: m.matchUid,
            gameId: m.gameId,
            playedAtMs: m.playedAtMs,
            durationMs: m.durationMs,
            difficulty: m.difficulty,
            participants: m.participants,
          );
        } else {
          // The same network game seen from another device: fill in the
          // people this device knew.
          final seats = {for (final p in existing.participants) p.seat: p};
          for (final p in m.participants) {
            final known = seats[p.seat];
            if (known == null) {
              seats[p.seat] = p;
            } else if (known.playerUid == null && p.playerUid != null) {
              seats[p.seat] = known.withPlayer(p.playerUid);
            }
          }
          matches[m.matchUid] = MatchView(
            matchUid: existing.matchUid,
            gameId: existing.gameId,
            playedAtMs: existing.playedAtMs,
            durationMs: existing.durationMs,
            difficulty: existing.difficulty,
            participants: [for (final s in (seats.keys.toList()..sort())) seats[s]!],
          );
        }
        for (final line in m.points) {
          addEntry(
            line.playerUid,
            LedgerView(
              entryUid: line.entryUid,
              amount: line.amount,
              reason: line.reason,
              detail: line.detail,
              matchUid: m.matchUid,
              atMs: m.playedAtMs,
            ),
          );
        }
        for (final c in m.counters) {
          addCounter(c.playerUid, c.key, c.delta);
        }
      case PointsAdded(:final entryUid, :final playerUid, :final amount, :final reason, :final detail, :final matchUid, :final atMs):
        addEntry(
          playerUid,
          LedgerView(entryUid: entryUid, amount: amount, reason: reason, detail: detail, matchUid: matchUid, atMs: atMs),
        );
      case ItemBought(:final itemUid, :final playerUid, :final itemId, :final price, :final atMs):
        if (dropped(playerUid) || !seenItems.add(itemUid)) break;
        final r = root(playerUid);
        addEntry(
          playerUid,
          LedgerView(entryUid: 'buy:$itemUid', amount: -price, reason: 'purchase', detail: itemId, atMs: atMs),
        );
        final owned = items[r] ??= {};
        if (owned.contains(itemId)) {
          // Bought on two devices before they met: one item, money back.
          addEntry(
            playerUid,
            LedgerView(entryUid: 'refund:$itemUid', amount: price, reason: 'refund', detail: 'duplicate:$itemId', atMs: atMs),
          );
        } else if ((balances[r] ?? 0) < 0) {
          // Spent more than there was, on two devices: the later purchase
          // is taken back (decided by Miloš, spec kap. 6).
          addEntry(
            playerUid,
            LedgerView(entryUid: 'refund:$itemUid', amount: price, reason: 'refund', detail: 'notEnough:$itemId', atMs: atMs),
          );
          (refunds[r] ??= []).add(RefundNotice(itemUid: itemUid, itemId: itemId, reason: RefundReason.notEnough));
        } else {
          owned.add(itemId);
          (itemsAt[r] ??= {})[itemId] = atMs;
        }
      case PointsReset(:final resetUid, :final playerUid, :final amount, :final itemIds):
        if (dropped(playerUid)) break;
        addEntry(playerUid, LedgerView(entryUid: resetUid, amount: -amount, reason: 'reset', atMs: op.clock.millis));
        final r = root(playerUid);
        items[r]?.removeAll(itemIds);
        itemsAt[r]?.removeWhere((id, _) => itemIds.contains(id));
      case BadgeAwarded(:final playerUid, :final badgeId, :final atMs):
        if (dropped(playerUid)) break;
        final map = badges[root(playerUid)] ??= {};
        final before = map[badgeId];
        map[badgeId] = before == null || atMs < before ? atMs : before;
      case CountersAdded(:final playerUid, :final deltas):
        for (final e in deltas.entries) {
          addCounter(playerUid, e.key, e.value);
        }
      case DeviceJoined(:final deviceId, :final name):
        devices[deviceId] = DeviceView(deviceId: deviceId, name: name, removed: devices[deviceId]?.removed ?? false);
      case DeviceRemoved(:final deviceId):
        devices[deviceId] = DeviceView(deviceId: deviceId, name: devices[deviceId]?.name ?? '', removed: true);
      case ProfilesMerged() || ProfileDeleted():
        break;
    }
  }

  // Profiles in creation order; a name taken already gets " 2", " 3"…
  final roots = profileData.keys.where(created.containsKey).toList()
    ..sort((a, b) {
      final byClock = created[a]!.compareTo(created[b]!);
      return byClock != 0 ? byClock : a.compareTo(b);
    });
  final holders = <String, String>{};
  final profiles = <String, ProfileView>{};
  for (final r in roots) {
    final (name, avatar, favoriteSeat) = profileData[r]!;
    var shown = name;
    String? pair;
    if (holders[nameKeyOf(name)] case final first?) {
      pair = first;
      var n = 2;
      while (holders.containsKey(nameKeyOf('$name $n'))) {
        n++;
      }
      shown = '$name $n';
    }
    holders[nameKeyOf(shown)] = r;
    profiles[r] = ProfileView(
      uid: r,
      name: shown,
      avatar: avatar,
      favoriteSeat: favoriteSeat,
      createdClock: created[r]!,
      pairCandidate: pair,
    );
  }

  final matchList = [
    for (final id in matchOrder)
      () {
        final m = matches[id]!;
        return MatchView(
          matchUid: m.matchUid,
          gameId: m.gameId,
          playedAtMs: m.playedAtMs,
          durationMs: m.durationMs,
          difficulty: m.difficulty,
          participants: [
            for (final p in m.participants)
              p.playerUid == null ? p : p.withPlayer(dropped(p.playerUid!) ? null : root(p.playerUid!)),
          ],
        );
      }(),
  ]..sort((a, b) => a.playedAtMs != b.playedAtMs ? a.playedAtMs.compareTo(b.playedAtMs) : a.matchUid.compareTo(b.matchUid));

  return FamilyState(
    profiles: profiles,
    matches: matchList,
    ledger: ledger,
    counters: counters,
    badges: badges,
    items: items,
    itemsAcquiredAt: itemsAt,
    refunds: refunds,
    devices: devices,
    deleted: deleted,
    aliases: aliases,
  );
}
