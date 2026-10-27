import 'dart:math';

import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import '../../core/game_kit/game_search.dart';
import 'tictactoe_rules.dart';

/// The robot of Piškvorky (spec 13.5).
///
/// 3×3 – easy: a random cell, half of the time it takes a win or blocks one;
/// medium: win → block → centre → corner; hard: perfect minimax (it never
/// loses and, of equally good cells, prefers the one that sets the most traps).
///
/// Big boards – stones are judged by windows of five cells ([BigBoardEval]);
/// only cells up to two steps from a stone are considered. Easy looks one
/// move ahead with noise and sometimes misses a threat; medium searches two
/// moves and always blocks a four; hard looks for a forced win by fours
/// (VCF), then searches alpha-beta four and more moves deep within 700 ms.
class TictactoeAi implements AiPlayer<TictactoeState> {
  const TictactoeAi({this.timeLimit = const Duration(milliseconds: 700), this.hardDepth = 6});

  /// Hard's thinking time on a big board (spec 13.5).
  final Duration timeLimit;

  /// How deep hard searches at most; tests use a small depth with a long
  /// [timeLimit], so the result does not depend on the machine's speed.
  final int hardDepth;

  static const _rules = TictactoeRules();

  @override
  Move chooseMove(TictactoeState state, int seat, Difficulty difficulty, SeededRandom random) {
    final cell = state.bigBoard ? _big(state, seat, difficulty, random) : _small(state, seat, difficulty, random);
    return TictactoeRules.place(seat, cell % state.size, cell ~/ state.size);
  }

  // ---- 3×3 ----

  int _small(TictactoeState s, int seat, Difficulty difficulty, SeededRandom random) {
    final empty = [for (var i = 0; i < 9; i++) if (s.cells[i] < 0) i];
    int? pick(List<int> cells) => cells.isEmpty ? null : cells[random.nextInt(cells.length)];
    List<int> winsFor(int who) => [for (final c in empty) if (TictactoeRules.wouldWin(s.cells, 3, 3, c, who)) c];
    switch (difficulty) {
      case Difficulty.easy:
        if (random.nextInt(2) == 0) {
          final smart = pick(winsFor(seat)) ?? pick(winsFor(1 - seat));
          if (smart != null) return smart;
        }
        return pick(empty)!;
      case Difficulty.medium:
        return pick(winsFor(seat)) ??
            pick(winsFor(1 - seat)) ??
            (s.cells[4] < 0 ? 4 : null) ??
            pick([for (final c in const [0, 2, 6, 8]) if (s.cells[c] < 0) c]) ??
            pick(empty)!;
      case Difficulty.hard:
        return _perfect(s.cells, seat, random);
    }
  }

  /// The best cell by full minimax. Of equally good cells it takes the one
  /// that wins most often against a fallible opponent, then picks by
  /// [random].
  static int _perfect(List<int> cells, int seat, SeededRandom random) {
    final board = List.of(cells);
    final memo = <int, int>{};
    final chances = <int, double>{};
    var bestValue = -1000;
    var bestChance = -1.0;
    final best = <int>[];
    for (var c = 0; c < 9; c++) {
      if (board[c] >= 0) continue;
      board[c] = seat;
      final won = TictactoeRules.winningLine(board, 3, 3, c).isNotEmpty;
      final value = won ? 100 : -_negamax(board, 1 - seat, memo);
      final chance = won ? 1.0 : _chance(board, 1 - seat, seat, memo, chances);
      board[c] = -1;
      if (value > bestValue || (value == bestValue && chance > bestChance + 1e-9)) {
        bestValue = value;
        bestChance = chance;
        best
          ..clear()
          ..add(c);
      } else if (value == bestValue && (chance - bestChance).abs() <= 1e-9) {
        best.add(c);
      }
    }
    return best[random.nextInt(best.length)];
  }

  /// How likely [me] wins from [board] with [toMove] to move, when [me]
  /// always plays a minimax-best cell and the opponent errs like a child.
  static double _chance(List<int> board, int toMove, int me, Map<int, int> memo, Map<int, double> chances) {
    var key = toMove;
    for (final c in board) {
      key = key * 3 + c + 1;
    }
    final known = chances[key];
    if (known != null) return known;
    final empty = [for (var c = 0; c < 9; c++) if (board[c] < 0) c];
    var result = 0.0;
    if (empty.isNotEmpty) {
      if (toMove == me) {
        // Only minimax-best cells, the best chance among them.
        var bestValue = -1000;
        for (final c in empty) {
          board[c] = me;
          final won = TictactoeRules.winningLine(board, 3, 3, c).isNotEmpty;
          final value = won ? 100 : -_negamax(board, 1 - me, memo);
          final chance = won ? 1.0 : _chance(board, 1 - me, me, memo, chances);
          board[c] = -1;
          if (value > bestValue) {
            bestValue = value;
            result = chance;
          } else if (value == bestValue && chance > result) {
            result = chance;
          }
        }
      } else {
        // Half of the time any cell, else a win or a block if there is one
        // (the easy robot, and roughly a young child).
        double average(List<int> options) {
          var sum = 0.0;
          for (final c in options) {
            board[c] = toMove;
            if (TictactoeRules.winningLine(board, 3, 3, c).isEmpty) sum += _chance(board, me, me, memo, chances);
            board[c] = -1;
          }
          return sum / options.length;
        }

        final wins = [for (final c in empty) if (TictactoeRules.wouldWin(board, 3, 3, c, toMove)) c];
        final blocks = [for (final c in empty) if (TictactoeRules.wouldWin(board, 3, 3, c, me)) c];
        final careful = wins.isNotEmpty ? 0.0 : average(blocks.isNotEmpty ? blocks : empty);
        result = (average(empty) + careful) / 2;
      }
    }
    chances[key] = result;
    return result;
  }

  /// Value of [board] for [seat] to move: > 0 a win (sooner is more), 0 a
  /// draw, < 0 a loss.
  static int _negamax(List<int> board, int seat, Map<int, int> memo) {
    var key = seat;
    for (final c in board) {
      key = key * 3 + c + 1;
    }
    final known = memo[key];
    if (known != null) return known;
    var empties = 0;
    var best = -1000;
    for (var c = 0; c < 9; c++) {
      if (board[c] >= 0) continue;
      empties++;
      board[c] = seat;
      final value = TictactoeRules.winningLine(board, 3, 3, c).isNotEmpty ? 10 + _emptyCount(board) : -_negamax(board, 1 - seat, memo);
      board[c] = -1;
      if (value > best) best = value;
    }
    final result = empties == 0 ? 0 : best;
    memo[key] = result;
    return result;
  }

  static int _emptyCount(List<int> board) => board.where((c) => c < 0).length;

  // ---- big boards ----

  int _big(TictactoeState s, int seat, Difficulty difficulty, SeededRandom random) {
    final eval = BigBoardEval(s.size, s.target);
    final cells = s.cells;
    if (s.history.isEmpty) return (s.size ~/ 2) * s.size + s.size ~/ 2;
    final candidates = eval.candidates(cells);
    final wins = [for (final c in candidates) if (TictactoeRules.wouldWin(cells, s.size, s.target, c, seat)) c];
    final threats = [for (final c in candidates) if (TictactoeRules.wouldWin(cells, s.size, s.target, c, 1 - seat)) c];

    switch (difficulty) {
      case Difficulty.easy:
        // One move ahead with noise: misses its own win now and then and
        // overlooks a threat about every third move, so children can win.
        if (wins.isNotEmpty && random.nextInt(10) < 7) return wins.first;
        final careless = random.nextInt(3) == 0;
        var best = candidates.first;
        var top = -1.0;
        for (final c in candidates) {
          final (attack, defense) = eval.delta(cells, c, seat);
          final value = (attack + (careless ? defense * 0.1 : defense * 0.8)) * (0.5 + random.nextDouble());
          if (value > top) {
            top = value;
            best = c;
          }
        }
        return best;
      case Difficulty.medium:
        if (wins.isNotEmpty) return wins.first;
        if (threats.isNotEmpty) return threats.first;
        return _search(s, seat, eval, depth: 2, width: 8, limit: timeLimit, random: random);
      case Difficulty.hard:
        if (wins.isNotEmpty) return wins.first;
        if (threats.isNotEmpty) return eval.bestOf(cells, threats, seat);
        final watch = Stopwatch()..start();
        final vcf = eval.vcf(cells, seat, watch: watch, limit: timeLimit ~/ 4);
        if (vcf != null) return vcf;
        return _search(s, seat, eval, depth: hardDepth, width: 10, limit: timeLimit - watch.elapsed, random: random);
    }
  }

  int _search(
    TictactoeState s,
    int seat,
    BigBoardEval eval, {
    required int depth,
    required int width,
    required Duration limit,
    required SeededRandom random,
  }) {
    final search = GameSearch<TictactoeState>(
      moves: (state) => [
        if (!state.over)
          for (final c in eval.focused(state.cells, state.current, width))
            TictactoeRules.place(state.current, c % state.size, c ~/ state.size),
      ],
      apply: _rules.apply,
      currentSeat: _rules.currentSeat,
      evaluate: (state, me) => eval.evaluate(state, me),
    );
    final move = search.best(s, seat, maxDepth: depth, timeLimit: limit, tieBreak: random);
    return TictactoeRules.cellOf(s, move!)!;
  }
}

/// Pattern judgement of a big board (spec 13.5: open and half-open fours,
/// threes…), counted over every window of [target] cells in a row: a window
/// holding only one player's stones is worth more the more stones it has.
/// An open four lies in two such windows, a half-open one in one.
class BigBoardEval {
  BigBoardEval(this.size, this.target);

  final int size;
  final int target;

  /// Worth of a window with 0–4 own stones and nothing of the opponent.
  static const weights = [0, 1, 12, 150, 2500];
  static const win = 1 << 30;

  /// Empty cells at most two steps from a stone (spec 13.5), centre first
  /// on an empty board.
  List<int> candidates(List<int> cells) {
    final near = <int>{};
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] < 0) continue;
      final c0 = i % size, r0 = i ~/ size;
      for (var r = max(0, r0 - 2); r <= min(size - 1, r0 + 2); r++) {
        for (var c = max(0, c0 - 2); c <= min(size - 1, c0 + 2); c++) {
          if (cells[r * size + c] < 0) near.add(r * size + c);
        }
      }
    }
    if (near.isEmpty) return [for (var i = 0; i < cells.length; i++) if (cells[i] < 0) i];
    return near.toList()..sort();
  }

  /// What a stone of [seat] on the empty [cell] adds: (attack, defence) –
  /// how much it builds own windows and spoils the opponent's.
  (double, double) delta(List<int> cells, int cell, int seat) {
    var attack = 0.0, defense = 0.0;
    final c0 = cell % size, r0 = cell ~/ size;
    for (final (dc, dr) in TictactoeRules.directions) {
      for (var k = 0; k < target; k++) {
        final sc = c0 - k * dc, sr = r0 - k * dr;
        final ec = sc + (target - 1) * dc, er = sr + (target - 1) * dr;
        if (sc < 0 || sr < 0 || sc >= size || sr >= size || ec < 0 || er < 0 || ec >= size || er >= size) continue;
        var mine = 0, theirs = 0;
        for (var j = 0; j < target; j++) {
          final v = cells[(sr + j * dr) * size + sc + j * dc];
          if (v == seat) {
            mine++;
          } else if (v >= 0) {
            theirs++;
          }
        }
        if (theirs == 0) attack += _gain(mine);
        if (mine == 0) defense += _gain(theirs);
      }
    }
    return (attack, defense);
  }

  static double _gain(int stones) => stones >= weights.length - 1
      ? win.toDouble()
      : (weights[stones + 1] - weights[stones]).toDouble();

  /// Up to [width] most promising cells for [seat] to move: a win or a forced
  /// block when there is one, else by [delta].
  List<int> focused(List<int> cells, int seat, int width) {
    final all = candidates(cells);
    final scored = <(int, double)>[];
    final blocks = <int>[];
    for (final c in all) {
      final (attack, defense) = delta(cells, c, seat);
      if (attack >= win) return [c];
      if (defense >= win) blocks.add(c);
      scored.add((c, attack + defense * 0.9));
    }
    if (blocks.isNotEmpty) return blocks;
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final (c, _) in scored.take(width)) c];
  }

  /// Of [options], the cell with the best [delta] for [seat].
  int bestOf(List<int> cells, List<int> options, int seat) {
    var best = options.first;
    var top = -1.0;
    for (final c in options) {
      final (attack, defense) = delta(cells, c, seat);
      if (attack + defense > top) {
        top = attack + defense;
        best = c;
      }
    }
    return best;
  }

  /// Position value for [seat]: decisive results dominate; otherwise own
  /// windows minus the opponent's, with a bonus for the side to move.
  int evaluate(TictactoeState s, int seat) {
    if (s.winner != null) return s.winner == seat ? win : -win;
    if (s.full) return 0;
    final mine = _windows(s.cells, seat), theirs = _windows(s.cells, 1 - seat);
    return s.current == seat ? (mine * 1.2).round() - theirs : mine - (theirs * 1.2).round();
  }

  int _windows(List<int> cells, int seat) {
    var total = 0;
    for (final (dc, dr) in TictactoeRules.directions) {
      for (var sr = 0; sr < size; sr++) {
        for (var sc = 0; sc < size; sc++) {
          final ec = sc + (target - 1) * dc, er = sr + (target - 1) * dr;
          if (ec < 0 || er < 0 || ec >= size || er >= size) continue;
          var mine = 0;
          var blocked = false;
          for (var j = 0; j < target; j++) {
            final v = cells[(sr + j * dr) * size + sc + j * dc];
            if (v == seat) {
              mine++;
            } else if (v >= 0) {
              blocked = true;
              break;
            }
          }
          if (!blocked) total += weights[min(mine, weights.length - 1)];
        }
      }
    }
    return total;
  }

  /// A first move of a forced win by fours (VCF) for [seat], or null: every
  /// move threatens to win at once, the opponent's only answer is to block,
  /// until a move threatens twice. Gives up after [limit].
  int? vcf(List<int> cells, int seat, {required Stopwatch watch, required Duration limit, int depth = 12}) {
    final board = List.of(cells);
    try {
      return _vcf(board, seat, depth, watch, limit);
    } on _OutOfTime {
      return null;
    }
  }

  int? _vcf(List<int> board, int seat, int depth, Stopwatch watch, Duration limit) {
    if (depth == 0) return null;
    if (watch.elapsed > limit) throw const _OutOfTime();
    for (final c in candidates(board)) {
      board[c] = seat;
      final threats = _winningCells(board, seat, c);
      int? found;
      if (threats.length >= 2) {
        found = c;
      } else if (threats.length == 1) {
        final block = threats.single;
        board[block] = 1 - seat;
        // The block must not win, nor leave the opponent a four of its own.
        final safe =
            TictactoeRules.winningLine(board, size, target, block).isEmpty && _winningCells(board, 1 - seat, block).isEmpty;
        if (safe && _vcf(board, seat, depth - 1, watch, limit) != null) found = c;
        board[block] = -1;
      }
      board[c] = -1;
      if (found != null) return found;
    }
    return null;
  }

  /// Empty cells where [seat] would win at once, along the rows through [cell].
  Set<int> _winningCells(List<int> board, int seat, int cell) {
    final result = <int>{};
    final c0 = cell % size, r0 = cell ~/ size;
    for (final (dc, dr) in TictactoeRules.directions) {
      for (var k = -target; k <= target; k++) {
        final c = c0 + k * dc, r = r0 + k * dr;
        if (c < 0 || r < 0 || c >= size || r >= size) continue;
        final i = r * size + c;
        if (board[i] < 0 && TictactoeRules.wouldWin(board, size, target, i, seat)) result.add(i);
      }
    }
    return result;
  }
}

class _OutOfTime implements Exception {
  const _OutOfTime();
}
