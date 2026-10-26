import '../game/move.dart';
import '../game/seeded_random.dart';

class _Timeout implements Exception {
  const _Timeout();
}

/// Generic alpha-beta search with iterative deepening and a time limit
/// (game kit, spec 8, 9). It is pure and synchronous, so a game's
/// `AiPlayer.chooseMove` can call it – the framework already runs that in
/// another isolate. With more than two players the other seats are treated
/// as one opponent ("paranoid" search).
class GameSearch<S> {
  const GameSearch({required this.moves, required this.apply, required this.currentSeat, required this.evaluate});

  /// Legal moves in [S]; empty when the game is over.
  final List<Move> Function(S state) moves;
  final S Function(S state, Move move) apply;

  /// The seat to move, or null when the game is over.
  final int? Function(S state) currentSeat;

  /// How good [state] is for [seat]: positive is good. Decisive results
  /// should be far larger than any positional value.
  final int Function(S state, int seat) evaluate;

  static const _infinity = 1 << 40;

  /// The best move for [seat], searching up to [maxDepth] plies within
  /// [timeLimit]. When time runs out it answers with the best move of the
  /// last fully searched depth. Equally good moves are picked by [tieBreak]
  /// (deterministic for a seed) or else the first one. Null without moves.
  Move? best(
    S state,
    int seat, {
    int maxDepth = 4,
    Duration timeLimit = const Duration(milliseconds: 700),
    SeededRandom? tieBreak,
  }) {
    final root = moves(state);
    if (root.isEmpty) return null;
    final watch = Stopwatch()..start();
    var order = root;
    var best = root.first;
    for (var depth = 1; depth <= maxDepth; depth++) {
      try {
        final scored = <(Move, int)>[];
        var top = -_infinity;
        for (final move in order) {
          // A window just below the best so far keeps ties exact.
          final value = _value(apply(state, move), seat, depth - 1, top - 1, _infinity, watch, timeLimit);
          scored.add((move, value));
          if (value > top) top = value;
        }
        scored.sort((a, b) => b.$2.compareTo(a.$2));
        order = [for (final (move, _) in scored) move];
        final equal = [for (final (move, value) in scored) if (value == top) move];
        best = tieBreak == null ? equal.first : equal[tieBreak.nextInt(equal.length)];
      } on _Timeout {
        break;
      }
    }
    return best;
  }

  int _value(S state, int seat, int depth, int alpha, int beta, Stopwatch watch, Duration limit) {
    if (watch.elapsed > limit) throw const _Timeout();
    final turn = currentSeat(state);
    final next = turn == null ? const <Move>[] : moves(state);
    if (next.isEmpty) {
      // Finished: sooner wins and later losses are better.
      final value = evaluate(state, seat);
      return value > 0 ? value + depth : (value < 0 ? value - depth : value);
    }
    if (depth == 0) return evaluate(state, seat);
    if (turn == seat) {
      var value = -_infinity;
      for (final move in next) {
        final v = _value(apply(state, move), seat, depth - 1, alpha, beta, watch, limit);
        if (v > value) value = v;
        if (value > alpha) alpha = value;
        if (alpha >= beta) break;
      }
      return value;
    }
    var value = _infinity;
    for (final move in next) {
      final v = _value(apply(state, move), seat, depth - 1, alpha, beta, watch, limit);
      if (v < value) value = v;
      if (value < beta) beta = value;
      if (alpha >= beta) break;
    }
    return value;
  }
}
