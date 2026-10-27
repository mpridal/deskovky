import '../../core/game/seeded_random.dart';
import 'minesweeper_solver.dart';
import 'minesweeper_state.dart';

/// Places the mines after the first tap (spec 13.7), deterministically from
/// the seed so a replay gets the same board.
abstract final class MinesweeperGenerator {
  /// Boards tried before settling for one that may need a guess. A fixed
  /// count instead of a clock keeps replays identical; it is chosen so that
  /// the worst case stays under 300 ms on a phone (spec 13.7, see README).
  static const maxAttempts = {MinesweeperLevel.easy: 40, MinesweeperLevel.medium: 40};

  /// The mines for a first tap on [start] and whether the solver proved the
  /// board needs no guessing. The first square and its neighbours are kept
  /// free, so the first tap always opens an empty area.
  static (List<int> mines, bool noGuess) generate(MinesweeperLevel level, int seed, int start) {
    final columns = level.columns, rows = level.rows;
    final free = {start, ...MinesweeperState.neighboursOf(start, columns, rows)};
    final candidates = [
      for (var i = 0; i < columns * rows; i++)
        if (!free.contains(i)) i,
    ];
    final random = SeededRandom(seed ^ 0x5EED);
    final attempts = maxAttempts[level] ?? 0;
    final solver = MinesweeperSolver(columns, rows);
    var mines = _place(candidates, level.mines, random);
    for (var i = 1; i < attempts; i++) {
      if (solver.solvable(mines.toSet(), start)) return (mines, true);
      mines = _place(candidates, level.mines, random);
    }
    if (attempts > 0 && solver.solvable(mines.toSet(), start)) return (mines, true);
    return (mines, false);
  }

  static List<int> _place(List<int> candidates, int count, SeededRandom random) {
    final pool = List.of(candidates);
    for (var i = 0; i < count; i++) {
      final j = i + random.nextInt(pool.length - i);
      final t = pool[i];
      pool[i] = pool[j];
      pool[j] = t;
    }
    return pool.sublist(0, count)..sort();
  }
}
