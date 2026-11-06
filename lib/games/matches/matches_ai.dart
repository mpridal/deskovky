import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'matches_rules.dart';

/// The robot of Sirky (design §6). The perfect move of misère Nim is
/// computed at once from the nim sum.
///
/// Hard plays it always; in a losing position it takes one match from the
/// longest row (the game lasts longer and the other player may slip).
/// Medium plays it 60 % of the time, otherwise a random move, and always
/// with three matches or fewer left. Easy plays it 25 % of the time,
/// otherwise a random move that does not take the last match (unless that
/// is all it can do).
class MatchesAi implements AiPlayer<MatchesState> {
  const MatchesAi();

  static const _rules = MatchesRules();

  // `nextInt(100)` rather than `nextDouble()`: the framework seeds each move
  // with `seed + moves`, and the first double of nearby seeds is nearly the
  // same, while its remainder by 100 is not.
  @override
  Move chooseMove(MatchesState state, int seat, Difficulty difficulty, SeededRandom random) {
    final (row, count) = switch (difficulty) {
      Difficulty.hard => perfect(state.rows, random),
      Difficulty.medium =>
        state.total <= 3 || random.nextInt(100) < 60 ? perfect(state.rows, random) : _random(state, seat, random),
      Difficulty.easy => random.nextInt(100) < 25 ? perfect(state.rows, random) : _random(state, seat, random, safe: true),
    };
    return MatchesRules.take(seat, row, count);
  }

  /// The best take (row, count) for the player to move with [rows]: one that
  /// leaves the other player a losing position; without one, a single match
  /// from the longest row.
  static (int, int) perfect(List<int> rows, SeededRandom random) {
    final winning = [
      for (var row = 0; row < rows.length; row++)
        for (var count = 1; count <= rows[row]; count++)
          if (!MatchesRules.winning(List.of(rows)..[row] -= count)) (row, count),
    ];
    if (winning.isNotEmpty) return winning[random.nextInt(winning.length)];
    var longest = 0;
    for (var row = 1; row < rows.length; row++) {
      if (rows[row] > rows[longest]) longest = row;
    }
    return (longest, 1);
  }

  /// A random legal take; with [safe], not the last match when there is a choice.
  static (int, int) _random(MatchesState state, int seat, SeededRandom random, {bool safe = false}) {
    var moves = _rules.legalMoves(state, seat);
    if (safe) {
      final keep = [for (final m in moves) if (m.data['count'] != state.total) m];
      if (keep.isNotEmpty) moves = keep;
    }
    final move = moves[random.nextInt(moves.length)];
    return (move.data['row']! as int, move.data['count']! as int);
  }
}
