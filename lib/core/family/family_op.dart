import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'hlc.dart';

/// One change to the family's shared data (family sync, spec "Rodinná
/// synchronizace" kap. 6–7): who made it ([origin], its [seq]-th op), when
/// ([clock]) and what ([body]). Ops are never changed or removed; every
/// device computes the same family state from the same set of ops.
@immutable
class FamilyOp {
  const FamilyOp({required this.origin, required this.seq, required this.clock, required this.body});

  final String origin;
  final int seq;
  final Hlc clock;
  final OpBody body;

  Map<String, Object?> toJson() => {'o': origin, 's': seq, 'c': clock.pack(), 'b': body.toJson()};

  /// Null for anything broken or of an unknown type (a newer app version).
  static FamilyOp? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final origin = json['o'], seq = json['s'], clock = json['c'];
    if (origin is! String || seq is! int || clock is! String) return null;
    final hlc = Hlc.unpack(clock);
    final body = OpBody.fromJson(json['b']);
    if (hlc == null || body == null) return null;
    return FamilyOp(origin: origin, seq: seq, clock: hlc, body: body);
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyOp && other.origin == origin && other.seq == seq && jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => Object.hash(origin, seq);

  @override
  String toString() => 'FamilyOp($origin#$seq ${body.toJson()})';
}

@immutable
sealed class OpBody {
  const OpBody();

  String get type;

  Map<String, Object?> get fields;

  Map<String, Object?> toJson() => {'t': type, ...fields};

  static OpBody? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    try {
      return switch (json['t']) {
        'profileCreated' => ProfileCreated(
          uid: json['uid']! as String,
          name: json['name']! as String,
          avatar: json['avatar']! as Map<String, Object?>,
          favoriteSeat: json['fav'] as int?,
        ),
        'profileUpdated' => ProfileUpdated(
          uid: json['uid']! as String,
          name: json['name']! as String,
          avatar: json['avatar']! as Map<String, Object?>,
          favoriteSeat: json['fav'] as int?,
        ),
        'profileDeleted' => ProfileDeleted(uid: json['uid']! as String),
        'profilesMerged' => ProfilesMerged(fromUid: json['from']! as String, intoUid: json['into']! as String),
        'matchRecorded' => MatchRecorded(
          matchUid: json['match']! as String,
          gameId: json['game']! as String,
          playedAtMs: json['at']! as int,
          durationMs: json['ms']! as int,
          difficulty: json['diff'] as String?,
          participants: [for (final p in json['seats']! as List) MatchSeat.fromJson(p as Map<String, Object?>)],
          points: [for (final p in json['points']! as List) PointLine.fromJson(p as Map<String, Object?>)],
          counters: [for (final c in json['counters']! as List) CounterLine.fromJson(c as Map<String, Object?>)],
        ),
        'pointsAdded' => PointsAdded(
          entryUid: json['entry']! as String,
          playerUid: json['player']! as String,
          amount: json['amount']! as int,
          reason: json['reason']! as String,
          detail: json['detail'] as String?,
          matchUid: json['match'] as String?,
          atMs: json['at']! as int,
        ),
        'itemBought' => ItemBought(
          itemUid: json['item']! as String,
          playerUid: json['player']! as String,
          itemId: json['itemId']! as String,
          price: json['price']! as int,
          atMs: json['at']! as int,
        ),
        'badgeAwarded' => BadgeAwarded(
          playerUid: json['player']! as String,
          badgeId: json['badge']! as String,
          atMs: json['at']! as int,
        ),
        'pointsReset' => PointsReset(
          resetUid: json['reset']! as String,
          playerUid: json['player']! as String,
          amount: json['amount']! as int,
          itemIds: [for (final i in json['items']! as List) i as String],
          atMs: json['at'] as int? ?? 0,
        ),
        'countersAdded' => CountersAdded(
          playerUid: json['player']! as String,
          deltas: {for (final e in (json['deltas']! as Map<String, Object?>).entries) e.key: e.value! as int},
        ),
        'deviceJoined' => DeviceJoined(deviceId: json['device']! as String, name: json['name']! as String),
        'deviceRemoved' => DeviceRemoved(deviceId: json['device']! as String),
        _ => null,
      };
    } on Object {
      return null;
    }
  }
}

/// A new profile; [avatar] is `AvatarSpec.toJson()`.
class ProfileCreated extends OpBody {
  const ProfileCreated({required this.uid, required this.name, required this.avatar, this.favoriteSeat});

  final String uid;
  final String name;
  final Map<String, Object?> avatar;
  final int? favoriteSeat;

  @override
  String get type => 'profileCreated';

  @override
  Map<String, Object?> get fields => {'uid': uid, 'name': name, 'avatar': avatar, 'fav': favoriteSeat};
}

/// The whole editable profile after a change (the last change wins).
class ProfileUpdated extends OpBody {
  const ProfileUpdated({required this.uid, required this.name, required this.avatar, this.favoriteSeat});

  final String uid;
  final String name;
  final Map<String, Object?> avatar;
  final int? favoriteSeat;

  @override
  String get type => 'profileUpdated';

  @override
  Map<String, Object?> get fields => {'uid': uid, 'name': name, 'avatar': avatar, 'fav': favoriteSeat};
}

/// A deleted profile; it never comes back, whatever arrives for it later.
class ProfileDeleted extends OpBody {
  const ProfileDeleted({required this.uid});

  final String uid;

  @override
  String get type => 'profileDeleted';

  @override
  Map<String, Object?> get fields => {'uid': uid};
}

/// Two profiles of the same person paired: everything of [fromUid] – also
/// what arrives later – belongs to [intoUid].
class ProfilesMerged extends OpBody {
  const ProfilesMerged({required this.fromUid, required this.intoUid});

  final String fromUid;
  final String intoUid;

  @override
  String get type => 'profilesMerged';

  @override
  Map<String, Object?> get fields => {'from': fromUid, 'into': intoUid};
}

@immutable
class MatchSeat {
  const MatchSeat({
    required this.seat,
    required this.playerUid,
    required this.robot,
    required this.place,
    required this.score,
    required this.stars,
  });

  final int seat;

  /// Null for robots and guests (people outside the family).
  final String? playerUid;
  final bool robot;
  final int place;
  final int score;
  final int stars;

  Map<String, Object?> toJson() => {
    'seat': seat,
    'player': playerUid,
    'robot': robot,
    'place': place,
    'score': score,
    'stars': stars,
  };

  static MatchSeat fromJson(Map<String, Object?> j) => MatchSeat(
    seat: j['seat']! as int,
    playerUid: j['player'] as String?,
    robot: j['robot']! as bool,
    place: j['place']! as int,
    score: j['score']! as int,
    stars: j['stars']! as int,
  );

  MatchSeat withPlayer(String? uid) =>
      MatchSeat(seat: seat, playerUid: uid, robot: robot, place: place, score: score, stars: stars);
}

@immutable
class PointLine {
  const PointLine({required this.entryUid, required this.playerUid, required this.amount, required this.reason, this.detail});

  final String entryUid;
  final String playerUid;
  final int amount;

  /// `PointsReason.name`.
  final String reason;
  final String? detail;

  Map<String, Object?> toJson() => {'entry': entryUid, 'player': playerUid, 'amount': amount, 'reason': reason, 'detail': detail};

  static PointLine fromJson(Map<String, Object?> j) => PointLine(
    entryUid: j['entry']! as String,
    playerUid: j['player']! as String,
    amount: j['amount']! as int,
    reason: j['reason']! as String,
    detail: j['detail'] as String?,
  );
}

@immutable
class CounterLine {
  const CounterLine({required this.playerUid, required this.key, required this.delta});

  final String playerUid;
  final String key;
  final int delta;

  Map<String, Object?> toJson() => {'player': playerUid, 'key': key, 'delta': delta};

  static CounterLine fromJson(Map<String, Object?> j) =>
      CounterLine(playerUid: j['player']! as String, key: j['key']! as String, delta: j['delta']! as int);
}

/// A finished game with the points and counters of this device's people.
/// A network game has one [matchUid] from the host, so every device's
/// record of it becomes one match.
class MatchRecorded extends OpBody {
  const MatchRecorded({
    required this.matchUid,
    required this.gameId,
    required this.playedAtMs,
    required this.durationMs,
    required this.difficulty,
    required this.participants,
    required this.points,
    required this.counters,
  });

  final String matchUid;
  final String gameId;
  final int playedAtMs;
  final int durationMs;
  final String? difficulty;
  final List<MatchSeat> participants;
  final List<PointLine> points;
  final List<CounterLine> counters;

  @override
  String get type => 'matchRecorded';

  @override
  Map<String, Object?> get fields => {
    'match': matchUid,
    'game': gameId,
    'at': playedAtMs,
    'ms': durationMs,
    'diff': difficulty,
    'seats': [for (final p in participants) p.toJson()],
    'points': [for (final p in points) p.toJson()],
    'counters': [for (final c in counters) c.toJson()],
  };
}

/// Points outside a match: a parent's gift, a badge reward, entries
/// imported from before the family existed.
class PointsAdded extends OpBody {
  const PointsAdded({
    required this.entryUid,
    required this.playerUid,
    required this.amount,
    required this.reason,
    this.detail,
    this.matchUid,
    required this.atMs,
  });

  final String entryUid;
  final String playerUid;
  final int amount;
  final String reason;
  final String? detail;
  final String? matchUid;
  final int atMs;

  @override
  String get type => 'pointsAdded';

  @override
  Map<String, Object?> get fields => {
    'entry': entryUid,
    'player': playerUid,
    'amount': amount,
    'reason': reason,
    'detail': detail,
    'match': matchUid,
    'at': atMs,
  };
}

/// An avatar upgrade bought for [price] points (the spend is part of it).
class ItemBought extends OpBody {
  const ItemBought({required this.itemUid, required this.playerUid, required this.itemId, required this.price, required this.atMs});

  final String itemUid;
  final String playerUid;
  final String itemId;
  final int price;
  final int atMs;

  @override
  String get type => 'itemBought';

  @override
  Map<String, Object?> get fields => {'item': itemUid, 'player': playerUid, 'itemId': itemId, 'price': price, 'at': atMs};
}

/// A badge; its reward points come as a `PointsAdded` with reason `badge`
/// and the badge id as detail – paid once per profile and badge.
class BadgeAwarded extends OpBody {
  const BadgeAwarded({required this.playerUid, required this.badgeId, required this.atMs});

  final String playerUid;
  final String badgeId;
  final int atMs;

  @override
  String get type => 'badgeAwarded';

  @override
  Map<String, Object?> get fields => {'player': playerUid, 'badge': badgeId, 'at': atMs};
}

/// A parent's reset: takes away exactly the [amount] and [itemIds] the
/// resetting device knew (spec kap. 6), nothing that arrives later.
class PointsReset extends OpBody {
  const PointsReset({
    required this.resetUid,
    required this.playerUid,
    required this.amount,
    required this.itemIds,
    this.atMs = 0,
  });

  final String resetUid;
  final String playerUid;
  final int amount;
  final List<String> itemIds;
  final int atMs;

  @override
  String get type => 'pointsReset';

  @override
  Map<String, Object?> get fields => {'reset': resetUid, 'player': playerUid, 'amount': amount, 'items': itemIds, 'at': atMs};
}

/// Badge counters added outside a match (imported from before the family).
class CountersAdded extends OpBody {
  const CountersAdded({required this.playerUid, required this.deltas});

  final String playerUid;
  final Map<String, int> deltas;

  @override
  String get type => 'countersAdded';

  @override
  Map<String, Object?> get fields => {'player': playerUid, 'deltas': deltas};
}

class DeviceJoined extends OpBody {
  const DeviceJoined({required this.deviceId, required this.name});

  final String deviceId;
  final String name;

  @override
  String get type => 'deviceJoined';

  @override
  Map<String, Object?> get fields => {'device': deviceId, 'name': name};
}

/// A device taken out of the family: the others refuse to sync with it.
class DeviceRemoved extends OpBody {
  const DeviceRemoved({required this.deviceId});

  final String deviceId;

  @override
  String get type => 'deviceRemoved';

  @override
  Map<String, Object?> get fields => {'device': deviceId};
}
