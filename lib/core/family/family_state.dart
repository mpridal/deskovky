import 'package:flutter/foundation.dart';

import 'family_op.dart';
import 'hlc.dart';

/// The family's shared data as every device computes it from all the ops
/// (`foldFamily`). Keys are profile uids after merges ("root" uids).
@immutable
class FamilyState {
  const FamilyState({
    required this.profiles,
    required this.matches,
    required this.ledger,
    required this.counters,
    required this.badges,
    required this.items,
    required this.itemsAcquiredAt,
    required this.refunds,
    required this.devices,
    required this.deleted,
    required this.aliases,
  });

  /// In the order profiles were created.
  final Map<String, ProfileView> profiles;

  /// By time played.
  final List<MatchView> matches;
  final Map<String, List<LedgerView>> ledger;
  final Map<String, Map<String, int>> counters;

  /// Badge id → earned at (ms), the earliest of every device.
  final Map<String, Map<String, int>> badges;
  final Map<String, Set<String>> items;
  final Map<String, Map<String, int>> itemsAcquiredAt;

  /// Purchases taken back because the points were spent twice offline.
  final Map<String, List<RefundNotice>> refunds;
  final Map<String, DeviceView> devices;

  /// Uids deleted in the family (never come back).
  final Set<String> deleted;

  /// Merged uid → the uid it now belongs to (as recorded, unresolved).
  final Map<String, String> aliases;

  int balance(String uid) => (ledger[uid] ?? const []).fold(0, (sum, e) => sum + e.amount);

  /// Where [uid] belongs after merges; [uid] itself when not merged.
  String resolve(String uid) {
    var current = uid;
    final seen = <String>{};
    for (var next = aliases[current]; next != null && seen.add(current); next = aliases[current]) {
      current = next;
    }
    return current;
  }

  Map<String, Object?> toJson() => {
    'profiles': [for (final p in profiles.values) p.toJson()],
    'matches': [for (final m in matches) m.toJson()],
    'ledger': _sorted(ledger.map((k, v) => MapEntry(k, [for (final e in v) e.toJson()]))),
    'counters': _sorted(counters.map((k, v) => MapEntry(k, _sorted(v)))),
    'badges': _sorted(badges.map((k, v) => MapEntry(k, _sorted(v)))),
    'items': _sorted(items.map((k, v) => MapEntry(k, [...v]..sort()))),
    'itemsAt': _sorted(itemsAcquiredAt.map((k, v) => MapEntry(k, _sorted(v)))),
    'refunds': _sorted(refunds.map((k, v) => MapEntry(k, [for (final r in v) r.toJson()]))),
    'devices': _sorted(devices.map((k, v) => MapEntry(k, v.toJson()))),
    'deleted': [...deleted]..sort(),
    'aliases': _sorted(aliases),
  };

  static Map<String, T> _sorted<T>(Map<String, T> map) => {for (final k in [...map.keys]..sort()) k: map[k] as T};
}

@immutable
class ProfileView {
  const ProfileView({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.favoriteSeat,
    required this.createdClock,
    this.pairCandidate,
  });

  final String uid;
  final String name;
  final Map<String, Object?> avatar;
  final int? favoriteSeat;
  final Hlc createdClock;

  /// Another profile with the same name, created earlier: perhaps the same
  /// person, offered to a parent for pairing (spec 5.2).
  final String? pairCandidate;

  String get nameKey => nameKeyOf(name);

  Map<String, Object?> toJson() => {
    'uid': uid,
    'name': name,
    'avatar': avatar,
    'fav': favoriteSeat,
    'created': createdClock.pack(),
    'pair': pairCandidate,
  };
}

/// Names are unique regardless of letter case and surrounding spaces.
String nameKeyOf(String name) => name.trim().toLowerCase();

@immutable
class MatchView {
  const MatchView({
    required this.matchUid,
    required this.gameId,
    required this.playedAtMs,
    required this.durationMs,
    required this.difficulty,
    required this.participants,
  });

  final String matchUid;
  final String gameId;
  final int playedAtMs;
  final int durationMs;
  final String? difficulty;
  final List<MatchSeat> participants;

  Map<String, Object?> toJson() => {
    'match': matchUid,
    'game': gameId,
    'at': playedAtMs,
    'ms': durationMs,
    'diff': difficulty,
    'seats': [for (final p in participants) p.toJson()],
  };
}

@immutable
class LedgerView {
  const LedgerView({
    required this.entryUid,
    required this.amount,
    required this.reason,
    this.detail,
    this.matchUid,
    required this.atMs,
  });

  final String entryUid;
  final int amount;
  final String reason;
  final String? detail;
  final String? matchUid;
  final int atMs;

  Map<String, Object?> toJson() => {
    'entry': entryUid,
    'amount': amount,
    'reason': reason,
    'detail': detail,
    'match': matchUid,
    'at': atMs,
  };
}

enum RefundReason { duplicate, notEnough }

@immutable
class RefundNotice {
  const RefundNotice({required this.itemUid, required this.itemId, required this.reason});

  final String itemUid;
  final String itemId;
  final RefundReason reason;

  Map<String, Object?> toJson() => {'item': itemUid, 'itemId': itemId, 'reason': reason.name};

  @override
  bool operator ==(Object other) =>
      other is RefundNotice && other.itemUid == itemUid && other.itemId == itemId && other.reason == reason;

  @override
  int get hashCode => Object.hash(itemUid, itemId, reason);

  @override
  String toString() => 'RefundNotice($itemId, ${reason.name})';
}

@immutable
class DeviceView {
  const DeviceView({required this.deviceId, required this.name, required this.removed});

  final String deviceId;
  final String name;
  final bool removed;

  Map<String, Object?> toJson() => {'device': deviceId, 'name': name, 'removed': removed};
}
