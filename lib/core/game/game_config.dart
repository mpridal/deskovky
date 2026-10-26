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
  const SavedGame({required this.config, required this.seed, required this.moves});

  final GameConfig config;
  final int seed;
  final List<Move> moves;

  Map<String, Object?> toJson() => {
    'config': config.toJson(),
    'seed': seed,
    'moves': [for (final m in moves) m.toJson()],
  };

  static SavedGame? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final config = GameConfig.fromJson(json['config']);
    final seed = json['seed'];
    final rawMoves = json['moves'];
    if (config == null || seed is! int || rawMoves is! List) return null;
    final moves = [for (final m in rawMoves) Move.fromJson(m)];
    if (moves.contains(null)) return null;
    return SavedGame(config: config, seed: seed, moves: moves.cast<Move>());
  }

  @override
  bool operator ==(Object other) =>
      other is SavedGame && other.config == config && other.seed == seed && listEquals(other.moves, moves);

  @override
  int get hashCode => Object.hash(config, seed, Object.hashAll(moves));
}
