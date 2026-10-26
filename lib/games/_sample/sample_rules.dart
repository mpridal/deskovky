import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';

/// One tip: who, which number and whether the secret is lower (-1), higher (1)
/// or hit (0).
@immutable
class SampleGuess {
  const SampleGuess({required this.seat, required this.value, required this.verdict});

  final int seat;
  final int value;
  final int verdict;

  Map<String, Object?> toJson() => {'seat': seat, 'value': value, 'verdict': verdict};

  static SampleGuess fromJson(Map<String, Object?> j) =>
      SampleGuess(seat: j['seat']! as int, value: j['value']! as int, verdict: j['verdict']! as int);
}

@immutable
class SampleState {
  const SampleState({
    required this.range,
    required this.seats,
    required this.secret,
    required this.low,
    required this.high,
    required this.current,
    required this.guesses,
    this.winner,
  });

  final int range;
  final int seats;
  final int secret;

  /// Bounds still possible, shared by all players.
  final int low;
  final int high;
  final int current;
  final List<SampleGuess> guesses;
  final int? winner;
}

/// "Guess the number": players take turns guessing a hidden number; each miss
/// tells everybody whether it is higher or lower. Whoever hits it wins.
class SampleRules implements GameRules<SampleState> {
  const SampleRules();

  static const ranges = [20, 50, 100];
  static const defaultRange = 50;

  @override
  SampleState initialState(GameConfig config, int seed) {
    final raw = config.options['range'];
    final range = ranges.contains(raw) ? raw! as int : defaultRange;
    return SampleState(
      range: range,
      seats: config.seats.length,
      secret: 1 + SeededRandom(seed).nextInt(range),
      low: 1,
      high: range,
      current: 0,
      guesses: const [],
    );
  }

  @override
  int? currentSeat(SampleState state) => state.winner == null ? state.current : null;

  @override
  List<Move> legalMoves(SampleState state, int seat) => [
    if (state.winner == null && seat == state.current)
      for (var v = state.low; v <= state.high; v++) Move(seat: seat, type: 'guess', data: {'value': v}),
  ];

  @override
  bool isLegal(SampleState state, Move move) {
    final value = move.data['value'];
    return state.winner == null &&
        move.type == 'guess' &&
        move.seat == state.current &&
        value is int &&
        value >= state.low &&
        value <= state.high;
  }

  @override
  SampleState apply(SampleState state, Move move) {
    final value = move.data['value']! as int;
    final verdict = state.secret.compareTo(value);
    return SampleState(
      range: state.range,
      seats: state.seats,
      secret: state.secret,
      low: verdict > 0 ? value + 1 : state.low,
      high: verdict < 0 ? value - 1 : state.high,
      current: verdict == 0 ? state.current : (state.current + 1) % state.seats,
      guesses: [
        ...state.guesses,
        SampleGuess(seat: move.seat, value: value, verdict: verdict),
      ],
      winner: verdict == 0 ? move.seat : null,
    );
  }

  @override
  bool isOver(SampleState state) => state.winner != null;

  @override
  int score(SampleState state, int seat) => state.guesses.where((g) => g.seat == seat).length;

  @override
  GameResult result(SampleState state) {
    final winner = state.winner;
    final good = _log2Ceil(state.range);
    return GameResult(
      places: [for (var s = 0; s < state.seats; s++) s == winner ? 1 : 2],
      scores: [for (var s = 0; s < state.seats; s++) score(state, s)],
      stars: [
        for (var s = 0; s < state.seats; s++)
          if (state.seats == 1)
            score(state, s) <= good ? 3 : (score(state, s) <= good + 3 ? 2 : 1)
          else
            s == winner ? 3 : 1,
      ],
      stats: {'tips': state.guesses.length, 'range': state.range},
    );
  }

  static int _log2Ceil(int n) {
    var bits = 0;
    while ((1 << bits) < n) {
      bits++;
    }
    return bits;
  }

  @override
  Map<String, Object?> stateToJson(SampleState s) => {
    'range': s.range,
    'seats': s.seats,
    'secret': s.secret,
    'low': s.low,
    'high': s.high,
    'current': s.current,
    'guesses': [for (final g in s.guesses) g.toJson()],
    'winner': s.winner,
  };

  @override
  SampleState stateFromJson(Map<String, Object?> j) => SampleState(
    range: j['range']! as int,
    seats: j['seats']! as int,
    secret: j['secret']! as int,
    low: j['low']! as int,
    high: j['high']! as int,
    current: j['current']! as int,
    guesses: [for (final g in j['guesses']! as List) SampleGuess.fromJson(g as Map<String, Object?>)],
    winner: j['winner'] as int?,
  );
}
