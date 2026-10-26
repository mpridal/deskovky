import 'package:flutter/foundation.dart';

/// Outcome of a finished game, indexed by seat (spec 8).
@immutable
class GameResult {
  const GameResult({required this.places, required this.scores, required this.stars, this.stats = const {}});

  /// 1-based place per seat; equal places mean a tie.
  final List<int> places;
  final List<int> scores;

  /// Rating 0–3 per seat (spec 5.5).
  final List<int> stars;
  final Map<String, Object?> stats;
}
