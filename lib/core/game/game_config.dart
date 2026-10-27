import 'package:flutter/foundation.dart';

import 'difficulty.dart';
import 'move.dart';

/// Who sits at one place at the table (spec 5.7).
@immutable
sealed class SeatConfig {
  const SeatConfig();

  Map<String, Object?> toJson();

  static SeatConfig? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final profileId = json['profileId'];
    return switch (json['type']) {
      'robot' => const RobotSeat(),
      'human' when profileId is int => HumanSeat(profileId),
      'remote' => RemoteSeat.fromJson(json),
      _ => null,
    };
  }
}

class HumanSeat extends SeatConfig {
  const HumanSeat(this.profileId);

  final int profileId;

  @override
  Map<String, Object?> toJson() => {'type': 'human', 'profileId': profileId};

  @override
  bool operator ==(Object other) => other is HumanSeat && other.profileId == profileId;

  @override
  int get hashCode => profileId.hashCode;

  @override
  String toString() => 'HumanSeat($profileId)';
}

class RobotSeat extends SeatConfig {
  const RobotSeat();

  @override
  Map<String, Object?> toJson() => {'type': 'robot'};

  @override
  bool operator ==(Object other) => other is RobotSeat;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'RobotSeat()';
}

/// A person playing on another device in a network game (spec 14): this
/// device only knows their name and avatar. In the host's shared config every
/// person is a [RemoteSeat]; each device turns its own back into [HumanSeat]s.
class RemoteSeat extends SeatConfig {
  const RemoteSeat({required this.clientId, required this.name, required this.avatar});

  /// The device they play on ('host' for the host's own players).
  final String clientId;
  final String name;
  final Map<String, Object?> avatar;

  @override
  Map<String, Object?> toJson() => {'type': 'remote', 'clientId': clientId, 'name': name, 'avatar': avatar};

  static RemoteSeat? fromJson(Map<String, Object?> json) {
    final clientId = json['clientId'], name = json['name'], avatar = json['avatar'];
    if (clientId is! String || name is! String || avatar is! Map<String, Object?>) return null;
    return RemoteSeat(clientId: clientId, name: name, avatar: avatar);
  }

  @override
  bool operator ==(Object other) =>
      other is RemoteSeat && other.clientId == clientId && other.name == name && mapEquals(other.avatar, avatar);

  @override
  int get hashCode => Object.hash(clientId, name);

  @override
  String toString() => 'RemoteSeat($clientId, $name)';
}

/// Everything chosen on the setup screen; remembered per game (spec 5.7).
@immutable
class GameConfig {
  const GameConfig({
    required this.gameId,
    required this.seats,
    required this.difficulty,
    required this.robotSpeed,
    required this.options,
  });

  final String gameId;
  final List<SeatConfig> seats;
  final Difficulty difficulty;
  final RobotSpeed robotSpeed;
  final Map<String, Object?> options;

  int get humans => seats.whereType<HumanSeat>().length;
  int get robots => seats.whereType<RobotSeat>().length;

  /// People at the table: on this device and on others (spec 14).
  int get people => humans + seats.whereType<RemoteSeat>().length;

  /// This device's view of a network game's shared config (spec 14.5): the
  /// seats in [localProfiles] (seat → profile id) become [HumanSeat]s, the
  /// other people stay [RemoteSeat]s, robots stay robots.
  GameConfig forDevice(Map<int, int> localProfiles) => copyWith(
    seats: [
      for (final (i, seat) in seats.indexed)
        if (localProfiles[i] case final id?) HumanSeat(id) else seat,
    ],
  );

  GameConfig copyWith({
    List<SeatConfig>? seats,
    Difficulty? difficulty,
    RobotSpeed? robotSpeed,
    Map<String, Object?>? options,
  }) => GameConfig(
    gameId: gameId,
    seats: seats ?? this.seats,
    difficulty: difficulty ?? this.difficulty,
    robotSpeed: robotSpeed ?? this.robotSpeed,
    options: options ?? this.options,
  );

  Map<String, Object?> toJson() => {
    'gameId': gameId,
    'seats': [for (final s in seats) s.toJson()],
    'difficulty': difficulty.name,
    'robotSpeed': robotSpeed.name,
    'options': options,
  };

  /// Null for missing or corrupted data, so callers fall back to defaults.
  static GameConfig? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final gameId = json['gameId'];
    final rawSeats = json['seats'];
    if (gameId is! String || rawSeats is! List || rawSeats.isEmpty) return null;
    final seats = [for (final s in rawSeats) SeatConfig.fromJson(s)];
    if (seats.contains(null)) return null;
    final options = json['options'];
    return GameConfig(
      gameId: gameId,
      seats: seats.cast<SeatConfig>(),
      difficulty: Difficulty.values.where((d) => d.name == json['difficulty']).firstOrNull ?? Difficulty.medium,
      robotSpeed: RobotSpeed.values.where((s) => s.name == json['robotSpeed']).firstOrNull ?? RobotSpeed.normal,
      options: options is Map<String, Object?> ? options : const {},
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameConfig &&
      other.gameId == gameId &&
      listEquals(other.seats, seats) &&
      other.difficulty == difficulty &&
      other.robotSpeed == robotSpeed &&
      mapEquals(other.options, options);

  @override
  int get hashCode => Object.hash(gameId, Object.hashAll(seats), difficulty, robotSpeed, options.length);
}

/// A game in progress as config + seed + moves; restoring replays the moves.
@immutable
class SavedGame {
  const SavedGame({required this.config, required this.seed, required this.moves, this.elapsedMs = 0});

  final GameConfig config;
  final int seed;
  final List<Move> moves;

  /// Playing time so far, without pauses (spec 13.4: saved with the game).
  final int elapsedMs;

  Map<String, Object?> toJson() => {
    'config': config.toJson(),
    'seed': seed,
    'moves': [for (final m in moves) m.toJson()],
    'elapsedMs': elapsedMs,
  };

  static SavedGame? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final config = GameConfig.fromJson(json['config']);
    final seed = json['seed'];
    final rawMoves = json['moves'];
    if (config == null || seed is! int || rawMoves is! List) return null;
    final moves = [for (final m in rawMoves) Move.fromJson(m)];
    if (moves.contains(null)) return null;
    final elapsed = json['elapsedMs'];
    return SavedGame(config: config, seed: seed, moves: moves.cast<Move>(), elapsedMs: elapsed is int && elapsed > 0 ? elapsed : 0);
  }

  @override
  bool operator ==(Object other) =>
      other is SavedGame &&
      other.config == config &&
      other.seed == seed &&
      other.elapsedMs == elapsedMs &&
      listEquals(other.moves, moves);

  @override
  int get hashCode => Object.hash(config, seed, elapsedMs, Object.hashAll(moves));
}
