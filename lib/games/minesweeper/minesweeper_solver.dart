import 'minesweeper_state.dart';

/// What a player can see of one square, for the solver and the AI.
abstract final class Seen {
  /// Hidden, nothing known.
  static const hidden = -1;

  /// A mine everybody knows about (uncovered by mistake, or deduced).
  static const mine = -2;
  // 0–8: uncovered square with that many mines around.
}

/// Squares the solver proved safe or mined.
class Deduction {
  const Deduction(this.safe, this.mines);

  final Set<int> safe;
  final Set<int> mines;

  bool get isEmpty => safe.isEmpty && mines.isEmpty;
}

/// How hard the solver thinks.
enum SolverDepth {
  /// Only one number at a time ("2 hidden squares around a 2").
  single,

  /// Also pairs of neighbouring numbers and the total count of mines.
  full,
}

/// A Minesweeper solver without guessing (spec 13.7): it proves squares
/// safe or mined from the numbers. Used to generate boards that need no
/// guessing, by the AI and by the hint at the first game.
class MinesweeperSolver {
  MinesweeperSolver(this.columns, this.rows) : _neighbours = _allNeighbours(columns, rows);

  final int columns;
  final int rows;
  final List<List<int>> _neighbours;

  static final _cache = <(int, int), List<List<int>>>{};

  static List<List<int>> _allNeighbours(int columns, int rows) => _cache.putIfAbsent(
    (columns, rows),
    () => [for (var i = 0; i < columns * rows; i++) MinesweeperState.neighboursOf(i, columns, rows)],
  );

  List<int> neighbours(int cell) => _neighbours[cell];

  /// What [seat] sees of [state]: numbers of uncovered squares and the
  /// mines uncovered by mistake. Flags are ignored – they may be wrong.
  static List<int> viewOf(MinesweeperState state) => [
    for (var i = 0; i < state.cellCount; i++)
      if (state.isRevealed(i))
        state.numbers[i]
      else if (state.exploded.contains(i))
        Seen.mine
      else
        Seen.hidden,
  ];

  /// Squares provably safe or mined in [view] with [totalMines] on the board.
  Deduction deduce(List<int> view, int totalMines, {SolverDepth depth = SolverDepth.full}) {
    // 0 unknown, 1 safe, 2 mine – for hidden squares only.
    final known = List.filled(view.length, 0);
    for (var i = 0; i < view.length; i++) {
      if (view[i] == Seen.mine) known[i] = 2;
    }
    final safe = <int>{}, mines = <int>{};
    void setSafe(Iterable<int> cells) {
      for (final c in cells) {
        if (known[c] == 0) {
          known[c] = 1;
          safe.add(c);
        }
      }
    }

    void setMine(Iterable<int> cells) {
      for (final c in cells) {
        if (known[c] == 0) {
          known[c] = 2;
          mines.add(c);
        }
      }
    }

    while (true) {
      final before = safe.length + mines.length;
      final constraints = _constraints(view, known);
      for (final (cells, need) in constraints) {
        if (need == 0) {
          setSafe(cells);
        } else if (need == cells.length) {
          setMine(cells);
        }
      }
      if (safe.length + mines.length != before) continue;
      if (depth == SolverDepth.single) break;

      _pairs(constraints, setSafe, setMine);
      if (safe.length + mines.length != before) continue;

      // The total count of mines.
      var unknown = 0, knownMines = 0;
      for (var i = 0; i < view.length; i++) {
        if (view[i] >= 0) continue;
        if (known[i] == 0) unknown++;
        if (known[i] == 2) knownMines++;
      }
      final left = totalMines - knownMines;
      if (unknown > 0 && (left == 0 || left == unknown)) {
        final rest = [
          for (var i = 0; i < view.length; i++)
            if (view[i] < 0 && known[i] == 0) i,
        ];
        left == 0 ? setSafe(rest) : setMine(rest);
        continue;
      }
      break;
    }
    return Deduction(safe, mines);
  }

  /// For every number next to unknown squares: those squares and how many
  /// mines among them are still missing.
  List<(List<int>, int)> _constraints(List<int> view, List<int> known) {
    final result = <(List<int>, int)>[];
    for (var i = 0; i < view.length; i++) {
      final n = view[i];
      if (n < 0) continue;
      var need = n;
      final cells = <int>[];
      for (final c in _neighbours[i]) {
        if (view[c] >= 0) continue;
        if (known[c] == 2) {
          need--;
        } else if (known[c] == 0) {
          cells.add(c);
        }
      }
      if (cells.isNotEmpty) result.add((cells, need));
    }
    return result;
  }

  /// Two overlapping numbers: when B needs exactly as many more mines than A
  /// as B has squares of its own, those are all mines and A's own are safe.
  void _pairs(
    List<(List<int>, int)> constraints,
    void Function(Iterable<int>) setSafe,
    void Function(Iterable<int>) setMine,
  ) {
    final byCell = <int, List<int>>{};
    for (var k = 0; k < constraints.length; k++) {
      for (final c in constraints[k].$1) {
        (byCell[c] ??= []).add(k);
      }
    }
    for (var a = 0; a < constraints.length; a++) {
      final (cellsA, needA) = constraints[a];
      final others = <int>{
        for (final c in cellsA) ...byCell[c]!,
      }..remove(a);
      for (final b in others) {
        final (cellsB, needB) = constraints[b];
        final onlyB = [for (final c in cellsB) if (!cellsA.contains(c)) c];
        if (needB - needA == onlyB.length && onlyB.isNotEmpty) {
          setMine(onlyB);
          setSafe([for (final c in cellsA) if (!cellsB.contains(c)) c]);
        } else if (needB == needA && onlyB.isNotEmpty && cellsA.every(cellsB.contains)) {
          // A inside B with the same count: B's own squares are safe.
          setSafe(onlyB);
        }
      }
    }
  }

  /// Chance of a mine on each square of [view] (0 for uncovered ones): proven
  /// squares 0 or 1, next to numbers the worst local estimate, elsewhere the
  /// density of the mines left.
  List<double> probabilities(List<int> view, int totalMines, Deduction deduction) {
    final known = List.filled(view.length, 0);
    for (var i = 0; i < view.length; i++) {
      if (view[i] == Seen.mine || deduction.mines.contains(i)) known[i] = 2;
      if (deduction.safe.contains(i)) known[i] = 1;
    }
    final local = List<double?>.filled(view.length, null);
    for (final (cells, need) in _constraints(view, known)) {
      final p = need / cells.length;
      for (final c in cells) {
        if (local[c] == null || p > local[c]!) local[c] = p;
      }
    }
    var unknown = 0, knownMines = 0;
    for (var i = 0; i < view.length; i++) {
      if (view[i] >= 0) continue;
      if (known[i] == 0) unknown++;
      if (known[i] == 2) knownMines++;
    }
    final density = unknown == 0 ? 0.0 : ((totalMines - knownMines) / unknown).clamp(0.0, 1.0);
    return [
      for (var i = 0; i < view.length; i++)
        if (view[i] >= 0)
          0.0
        else if (known[i] == 2)
          1.0
        else if (known[i] == 1)
          0.0
        else
          local[i] ?? density,
    ];
  }

  /// Can the board [mines] be cleared from [start] without a single guess?
  /// Uncovers what the solver proves safe until nothing is left.
  bool solvable(Set<int> mines, int start) {
    final cells = columns * rows;
    final numbers = List.filled(cells, 0);
    for (final m in mines) {
      for (final n in _neighbours[m]) {
        numbers[n]++;
      }
    }
    final view = List.filled(cells, Seen.hidden);
    var open = 0;
    void uncover(int cell) {
      final queue = [cell];
      while (queue.isNotEmpty) {
        final c = queue.removeLast();
        if (view[c] != Seen.hidden) continue;
        view[c] = numbers[c];
        open++;
        if (numbers[c] == 0) queue.addAll(_neighbours[c]);
      }
    }

    uncover(start);
    while (open < cells - mines.length) {
      final d = deduce(view, mines.length);
      if (d.safe.isEmpty) return false;
      for (final m in d.mines) {
        view[m] = Seen.mine;
      }
      d.safe.forEach(uncover);
    }
    return true;
  }
}
