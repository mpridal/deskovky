import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../game/difficulty.dart';
import '../game/game_config.dart';
import '../game/move.dart';

/// Messages between the host and the other devices (spec 14.3). Every
/// message is a small JSON object with a `type`; anything unknown or broken
/// decodes to null and is ignored.
const protocolVersion = 1;

/// A player as another device shows them: name and avatar JSON.
@immutable
class ProfileCard {
  const ProfileCard({required this.name, required this.avatar});

  final String name;
  final Map<String, Object?> avatar;

  Map<String, Object?> toJson() => {'name': name, 'avatar': avatar};

  static ProfileCard? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final name = json['name'], avatar = json['avatar'];
    if (name is! String || avatar is! Map<String, Object?>) return null;
    return ProfileCard(name: name, avatar: avatar);
  }

  @override
  bool operator ==(Object other) => other is ProfileCard && other.name == name && mapEquals(other.avatar, avatar);

  @override
  int get hashCode => Object.hash(name, avatar.length);
}

/// host: a person on the host's device; open: a free place for someone
/// joining.
enum SlotKind { host, remote, robot, open }

/// One place in the room as everybody sees it (spec 14.6: 🏠 / 📱 / 🤖).
@immutable
class LobbySlot {
  const LobbySlot({
    required this.kind,
    required this.name,
    required this.avatar,
    this.clientId,
    required this.ready,
  });

  final SlotKind kind;
  final String name;
  final Map<String, Object?> avatar;

  /// The device of a remote player.
  final String? clientId;
  final bool ready;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'name': name,
    'avatar': avatar,
    'clientId': clientId,
    'ready': ready,
  };

  static LobbySlot? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final kind = SlotKind.values.asNameMap()[json['kind']];
    final name = json['name'], avatar = json['avatar'], clientId = json['clientId'], ready = json['ready'];
    if (kind == null || name is! String || avatar is! Map<String, Object?> || ready is! bool) return null;
    if (clientId != null && clientId is! String) return null;
    return LobbySlot(kind: kind, name: name, avatar: avatar, clientId: clientId as String?, ready: ready);
  }

  @override
  bool operator ==(Object other) =>
      other is LobbySlot &&
      other.kind == kind &&
      other.name == name &&
      mapEquals(other.avatar, avatar) &&
      other.clientId == clientId &&
      other.ready == ready;

  @override
  int get hashCode => Object.hash(kind, name, clientId, ready);
}

@immutable
sealed class NetMessage {
  const NetMessage();

  String get type;

  Map<String, Object?> get body;

  Map<String, Object?> toJson() => {'type': type, ...body};

  String encode() => jsonEncode(toJson());

  static NetMessage? decode(String text) {
    try {
      return fromJson(jsonDecode(text));
    } on FormatException {
      return null;
    }
  }

  static NetMessage? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    try {
      return switch (json['type']) {
        'hello' => Hello._from(json),
        'welcome' => Welcome(clientId: json['clientId']! as String, token: json['token']! as String),
        'lobby' => LobbyState._from(json),
        'ready' => Ready(json['ready']! as bool),
        'start' => Start._from(json),
        'moveRequest' => MoveRequest(move: Move.fromJson(json['move'])!, basedOn: json['basedOn']! as int),
        'moveApplied' => MoveApplied(
          seq: json['seq']! as int,
          move: Move.fromJson(json['move'])!,
          stateHash: json['hash']! as String,
        ),
        'moveRejected' => MoveRejected(seq: json['seq']! as int, reason: json['reason']! as String),
        'snapshotRequest' => const SnapshotRequest(),
        'snapshot' => StateSnapshot(seq: json['seq']! as int, saved: SavedGame.fromJson(json['saved'])!),
        'pause' => Pause(bySeat: json['bySeat'] as int?),
        'resume' => const Resume(),
        'peers' => PeerStatus._from(json),
        'gameOver' => const GameOver(),
        'bye' => Bye(reason: json['reason']! as String),
        'ping' => Ping(json['t']! as int),
        'pong' => Pong(json['t']! as int),
        'kick' => const Kick(),
        _ => null,
      };
    } on Object {
      // A field of the wrong type or missing: an unknown message.
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is NetMessage && other.type == type && jsonEncode(other.body) == jsonEncode(body);

  @override
  int get hashCode => Object.hash(type, jsonEncode(body));

  @override
  String toString() => '$type$body';
}

/// Client → host: who I am and which room (spec 14.2 step 3–4).
class Hello extends NetMessage {
  const Hello({
    required this.protocolVersion,
    required this.appVersion,
    required this.roomCode,
    required this.token,
    required this.profiles,
  });

  final int protocolVersion;
  final String appVersion;
  final String roomCode;

  /// Set when coming back after a dropout (spec 14.4).
  final String? token;
  final List<ProfileCard> profiles;

  @override
  String get type => 'hello';

  @override
  Map<String, Object?> get body => {
    'v': protocolVersion,
    'app': appVersion,
    'code': roomCode,
    'token': token,
    'profiles': [for (final p in profiles) p.toJson()],
  };

  static Hello _from(Map<String, Object?> j) => Hello(
    protocolVersion: j['v']! as int,
    appVersion: j['app']! as String,
    roomCode: j['code']! as String,
    token: j['token'] as String?,
    profiles: [for (final p in j['profiles']! as List) ProfileCard.fromJson(p)!],
  );
}

/// Host → client: accepted; the token lets the device come back.
class Welcome extends NetMessage {
  const Welcome({required this.clientId, required this.token});

  final String clientId;
  final String token;

  @override
  String get type => 'welcome';

  @override
  Map<String, Object?> get body => {'clientId': clientId, 'token': token};
}

/// Host → all: the room's places and the game's settings (read-only for clients).
class LobbyState extends NetMessage {
  const LobbyState({
    required this.gameId,
    required this.slots,
    required this.options,
    required this.difficulty,
    required this.robotSpeed,
  });

  final String gameId;
  final List<LobbySlot> slots;
  final Map<String, Object?> options;
  final Difficulty difficulty;
  final RobotSpeed robotSpeed;

  @override
  String get type => 'lobby';

  @override
  Map<String, Object?> get body => {
    'gameId': gameId,
    'slots': [for (final s in slots) s.toJson()],
    'options': options,
    'difficulty': difficulty.name,
    'robotSpeed': robotSpeed.name,
  };

  static LobbyState _from(Map<String, Object?> j) => LobbyState(
    gameId: j['gameId']! as String,
    slots: [for (final s in j['slots']! as List) LobbySlot.fromJson(s)!],
    options: j['options']! as Map<String, Object?>,
    difficulty: Difficulty.values.byName(j['difficulty']! as String),
    robotSpeed: RobotSpeed.values.byName(j['robotSpeed']! as String),
  );
}

class Ready extends NetMessage {
  const Ready(this.ready);

  final bool ready;

  @override
  String get type => 'ready';

  @override
  Map<String, Object?> get body => {'ready': ready};
}

/// Host → each client: the game starts. [config] has every person as a
/// [RemoteSeat]; [yourSeats] maps this device's seats to its profile index
/// in its [Hello].
class Start extends NetMessage {
  const Start({required this.config, required this.seed, required this.yourSeats});

  final GameConfig config;
  final int seed;
  final Map<int, int> yourSeats;

  @override
  String get type => 'start';

  @override
  Map<String, Object?> get body => {
    'config': config.toJson(),
    'seed': seed,
    'yourSeats': {for (final e in yourSeats.entries) '${e.key}': e.value},
  };

  static Start _from(Map<String, Object?> j) => Start(
    config: GameConfig.fromJson(j['config'])!,
    seed: j['seed']! as int,
    yourSeats: {
      for (final e in (j['yourSeats']! as Map<String, Object?>).entries) int.parse(e.key): e.value! as int,
    },
  );
}

/// Client → host: please play this move; [basedOn] is the last applied seq.
class MoveRequest extends NetMessage {
  const MoveRequest({required this.move, required this.basedOn});

  final Move move;
  final int basedOn;

  @override
  String get type => 'moveRequest';

  @override
  Map<String, Object?> get body => {'move': move.toJson(), 'basedOn': basedOn};
}

/// Host → all: move number [seq] was applied; the state's hash after it.
class MoveApplied extends NetMessage {
  const MoveApplied({required this.seq, required this.move, required this.stateHash});

  final int seq;
  final Move move;
  final String stateHash;

  @override
  String get type => 'moveApplied';

  @override
  Map<String, Object?> get body => {'seq': seq, 'move': move.toJson(), 'hash': stateHash};
}

class MoveRejected extends NetMessage {
  const MoveRejected({required this.seq, required this.reason});

  final int seq;
  final String reason;

  @override
  String get type => 'moveRejected';

  @override
  Map<String, Object?> get body => {'seq': seq, 'reason': reason};
}

class SnapshotRequest extends NetMessage {
  const SnapshotRequest();

  @override
  String get type => 'snapshotRequest';

  @override
  Map<String, Object?> get body => const {};
}

/// Host → client: the whole game so far (after a mismatch or a comeback).
class StateSnapshot extends NetMessage {
  const StateSnapshot({required this.seq, required this.saved});

  final int seq;
  final SavedGame saved;

  @override
  String get type => 'snapshot';

  @override
  Map<String, Object?> get body => {'seq': seq, 'saved': saved.toJson()};
}

class Pause extends NetMessage {
  const Pause({this.bySeat});

  final int? bySeat;

  @override
  String get type => 'pause';

  @override
  Map<String, Object?> get body => {'bySeat': bySeat};
}

class Resume extends NetMessage {
  const Resume();

  @override
  String get type => 'resume';

  @override
  Map<String, Object?> get body => const {};
}

/// Host → all: which seats' devices are connected; [waitSeconds] counts down
/// the 30 s grace of a dropped player (spec 14.4).
class PeerStatus extends NetMessage {
  const PeerStatus({required this.connected, this.waitSeconds});

  final Map<int, bool> connected;
  final int? waitSeconds;

  @override
  String get type => 'peers';

  @override
  Map<String, Object?> get body => {
    'connected': {for (final e in connected.entries) '${e.key}': e.value},
    'wait': waitSeconds,
  };

  static PeerStatus _from(Map<String, Object?> j) => PeerStatus(
    connected: {
      for (final e in (j['connected']! as Map<String, Object?>).entries) int.parse(e.key): e.value! as bool,
    },
    waitSeconds: j['wait'] as int?,
  );
}

class GameOver extends NetMessage {
  const GameOver();

  @override
  String get type => 'gameOver';

  @override
  Map<String, Object?> get body => const {};
}

class Bye extends NetMessage {
  const Bye({required this.reason});

  final String reason;

  @override
  String get type => 'bye';

  @override
  Map<String, Object?> get body => {'reason': reason};
}

class Ping extends NetMessage {
  const Ping(this.t);

  final int t;

  @override
  String get type => 'ping';

  @override
  Map<String, Object?> get body => {'t': t};
}

class Pong extends NetMessage {
  const Pong(this.t);

  final int t;

  @override
  String get type => 'pong';

  @override
  Map<String, Object?> get body => {'t': t};
}

/// Host → client: removed from the room (spec 14.3).
class Kick extends NetMessage {
  const Kick();

  @override
  String get type => 'kick';

  @override
  Map<String, Object?> get body => const {};
}
