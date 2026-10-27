import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'minesweeper_rules.dart';
import 'minesweeper_solver.dart';
import 'minesweeper_state.dart';

/// Robot for Střídačka (spec 13.7). Easy uncovers a sure square only when
/// one number shows it (and not always), otherwise anything; medium uses the
/// whole solver but then guesses blindly; hard uses the solver and, when
/// it must guess, the square least likely to hide a mine.
class MinesweeperAi implements AiPlayer<MinesweeperState> {
  const MinesweeperAi();

  @override
  Move chooseMove(MinesweeperState state, int seat, Difficulty difficulty, SeededRandom random) {
    final cell = _choose(state, difficulty, random);
    final c = cell % state.columns, r = cell ~/ state.columns;
    // Somebody's flag on the chosen square: take it away first (the robot
    // is asked again, as the turn stays with it).
    final type = state.marks[cell] == Mark.flag ? MinesweeperMove.mark : MinesweeperMove.reveal;
    return MinesweeperMove.of(seat, type, c, r);
  }

  int _choose(MinesweeperState state, Difficulty difficulty, SeededRandom random) {
    final hidden = [
      for (var i = 0; i < state.cellCount; i++)
        if (!state.isRevealed(i) && !state.exploded.contains(i)) i,
    ];
    if (!state.started) {
      // The first tap is always safe; a hard robot opens in the middle.
      return difficulty == Difficulty.hard
          ? state.cellOf(state.columns ~/ 2, state.rows ~/ 2)
          : hidden[random.nextInt(hidden.length)];
    }
    final solver = MinesweeperSolver(state.columns, state.rows);
    final view = MinesweeperSolver.viewOf(state);
    switch (difficulty) {
      case Difficulty.easy:
        // Sees an easy sure square two times out of three.
        if (random.nextInt(3) < 2) {
          final d = solver.deduce(view, state.mines.length, depth: SolverDepth.single);
          if (d.safe.isNotEmpty) return _pick(d.safe.toList()..sort(), random);
        }
        return _pick(hidden, random);
      case Difficulty.medium:
        final d = solver.deduce(view, state.mines.length);
        if (d.safe.isNotEmpty) return _pick(d.safe.toList()..sort(), random);
        final unsure = [
          for (final c in hidden)
            if (!d.mines.contains(c)) c,
        ];
        return _pick(unsure.isEmpty ? hidden : unsure, random);
      case Difficulty.hard:
        final d = solver.deduce(view, state.mines.length);
        if (d.safe.isNotEmpty) return _pick(d.safe.toList()..sort(), random);
        final p = solver.probabilities(view, state.mines.length, d);
        var best = 2.0;
        final candidates = <int>[];
        for (final c in hidden) {
          if (p[c] < best - 1e-9) {
            best = p[c];
            candidates.clear();
          }
          if ((p[c] - best).abs() <= 1e-9) candidates.add(c);
        }
        return _pick(candidates, random);
    }
  }

  static int _pick(List<int> cells, SeededRandom random) => cells[random.nextInt(cells.length)];
}
