import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';

/// Who starts (option `start`, spec 13.5).
abstract final class TictactoeStart {
  static const alternate = 'alternate';
  static const random = 'random';
  static const first = 'first';
}

/// One game of Piškvorky. Seat 0 plays ✕, seat 1 plays ◯. Cells are indexed
/// `row * size + column`; each holds the seat that took it, or -1.
@immutable
class TictactoeState {
  const TictactoeState({
    required this.size,
    required this.target,
    required this.starter,
    required this.history,
    required this.cells,
    required this.blocks,
    this.winner,
    this.line = const [],
    this.confirm = false,
    this.robots = const [false, false],
    this.difficulty,
  });

  /// 3, 10 or 15 cells a side.
  final int size;

  /// Stones in a row that win: 3 on 3×3, 5 (or more) on the big boards.
  final int target;
  final int starter;

  /// Cells in the order they were taken; the seats alternate from [starter].
  final List<int> history;
  final List<int> cells;

  /// How many times each seat blocked a row the other one would have
  /// finished with its next stone (for ★ after a loss on 3×3).
  final List<int> blocks;
  final int? winner;

  /// The winning row, every stone of it in order (5 or more on a big board).
  final List<int> line;

  /// A big-board move is placed only by a second tap on the same cell.
  final bool confirm;

  /// Which seats are robots and how strong (for the `tictactoe.wall` badge).
  final List<bool> robots;
  final String? difficulty;

  bool get bigBoard => size > 3;
  bool get full => history.length == cells.length;
  bool get over => winner != null || full;

  /// The seat to move while the game runs.
  int get current => (starter + history.length) % 2;

  int? get lastCell => history.isEmpty ? null : history.last;

  /// Stones [seat] has placed so far.
  int movesOf(int seat) => (history.length + (seat == starter ? 1 : 0)) ~/ 2;

  int cell(int column, int row) => cells[row * size + column];
}

/// Rules of Piškvorky (spec 13.5): players take turns placing their mark;
/// whoever first makes a row of [TictactoeState.target] wins – across, down
/// or diagonally, on the big boards five or more. A full board is a draw.
class TictactoeRules implements GameRules<TictactoeState> {
  const TictactoeRules();

  static const sizes = [3, 10, 15];
  static const defaultSize = 3;

  /// Row directions as (column, row) steps: across, down and both diagonals.
  static const directions = [(1, 0), (0, 1), (1, 1), (1, -1)];

  @override
  TictactoeState initialState(GameConfig config, int seed) {
    final raw = config.options['board'];
    final size = sizes.contains(raw) ? raw! as int : defaultSize;
    final starter = switch (config.options['start']) {
      TictactoeStart.first => 0,
      // The rules never learn who started the previous game, so "take turns"
      // also comes from the seed (see README and FRAMEWORK_REQUESTS.md).
      _ => SeededRandom(seed).nextInt(2),
    };
    return TictactoeState(
      size: size,
      target: size == 3 ? 3 : 5,
      starter: starter,
      history: const [],
      cells: List.filled(size * size, -1),
      blocks: const [0, 0],
      confirm: config.options['confirm'] == true,
      robots: [for (var s = 0; s < 2; s++) s < config.seats.length && config.seats[s] is RobotSeat],
      difficulty: config.robots > 0 ? config.difficulty.name : null,
    );
  }

  static Move place(int seat, int column, int row) => Move(seat: seat, type: 'place', data: {'c': column, 'r': row});

  /// The cell index a move takes, or null when it names no cell of [s].
  static int? cellOf(TictactoeState s, Move move) {
    final column = move.data['c'], row = move.data['r'];
    if (column is! int || row is! int || column < 0 || row < 0 || column >= s.size || row >= s.size) return null;
    return row * s.size + column;
  }

  @override
  int? currentSeat(TictactoeState state) => state.over ? null : state.current;

  @override
  List<Move> legalMoves(TictactoeState state, int seat) => [
    if (!state.over && seat == state.current)
      for (var i = 0; i < state.cells.length; i++)
        if (state.cells[i] < 0) place(seat, i % state.size, i ~/ state.size),
  ];

  @override
  bool isLegal(TictactoeState state, Move move) {
    if (state.over || move.type != 'place' || move.seat != state.current) return false;
    final cell = cellOf(state, move);
    return cell != null && state.cells[cell] < 0;
  }

  @override
  TictactoeState apply(TictactoeState state, Move move) {
    final cell = cellOf(state, move)!;
    final seat = move.seat;
    final blocked = wouldWin(state.cells, state.size, state.target, cell, 1 - seat);
    final cells = List.of(state.cells)..[cell] = seat;
    final line = winningLine(cells, state.size, state.target, cell);
    return _copy(
      state,
      history: [...state.history, cell],
      cells: cells,
      blocks: blocked ? [for (var s = 0; s < 2; s++) state.blocks[s] + (s == seat ? 1 : 0)] : state.blocks,
      winner: line.isEmpty ? null : seat,
      line: line,
    );
  }

  /// Whether [seat] taking the empty [cell] would make a winning row.
  static bool wouldWin(List<int> cells, int size, int target, int cell, int seat) {
    final column = cell % size, row = cell ~/ size;
    for (final (dc, dr) in directions) {
      final run = 1 + _run(cells, size, column, row, dc, dr, seat) + _run(cells, size, column, row, -dc, -dr, seat);
      if (run >= target) return true;
    }
    return false;
  }

  /// The row through [cell] (taken already) that wins, ordered from one end
  /// to the other; empty when there is none.
  static List<int> winningLine(List<int> cells, int size, int target, int cell) {
    final seat = cells[cell];
    final column = cell % size, row = cell ~/ size;
    for (final (dc, dr) in directions) {
      final back = _run(cells, size, column, row, -dc, -dr, seat);
      final forward = _run(cells, size, column, row, dc, dr, seat);
      if (1 + back + forward >= target) {
        return [for (var k = -back; k <= forward; k++) (row + k * dr) * size + column + k * dc];
      }
    }
    return const [];
  }

  /// Stones of [seat] next to (column, row) in one direction, not counting it.
  static int _run(List<int> cells, int size, int column, int row, int dc, int dr, int seat) {
    var n = 0;
    var c = column + dc, r = row + dr;
    while (c >= 0 && r >= 0 && c < size && r < size && cells[r * size + c] == seat) {
      n++;
      c += dc;
      r += dr;
    }
    return n;
  }

  @override
  bool isOver(TictactoeState state) => state.over;

  @override
  int score(TictactoeState state, int seat) => state.movesOf(seat);

  @override
  GameResult result(TictactoeState state) {
    final winner = state.winner;
    return GameResult(
      places: [for (var s = 0; s < 2; s++) winner == null || winner == s ? 1 : 2],
      scores: [for (var s = 0; s < 2; s++) score(state, s)],
      stars: [for (var s = 0; s < 2; s++) stars(state, s)],
      stats: {'board': state.size, 'moves': state.history.length, 'blocks': state.blocks[0] + state.blocks[1]},
    );
  }

  /// Rating (spec 13.5). 3×3: win ★★★, draw ★★, a loss ★ when the player
  /// blocked a row at least once. Big board: a win within 20 own stones ★★★,
  /// a later win ★★, a draw or loss after at least 25 moves of the game ★.
  static int stars(TictactoeState state, int seat) {
    final won = state.winner == seat;
    if (!state.bigBoard) {
      if (won) return 3;
      if (state.winner == null) return 2;
      return state.blocks[seat] > 0 ? 1 : 0;
    }
    if (won) return state.movesOf(seat) <= 20 ? 3 : 2;
    return state.history.length >= 25 ? 1 : 0;
  }

  @override
  Map<String, Object?> stateToJson(TictactoeState s) => {
    'size': s.size,
    'target': s.target,
    'starter': s.starter,
    'history': s.history,
    'blocks': s.blocks,
    'winner': s.winner,
    'line': s.line,
    'confirm': s.confirm,
    'robots': s.robots,
    'difficulty': s.difficulty,
  };

  @override
  TictactoeState stateFromJson(Map<String, Object?> j) {
    final size = j['size']! as int;
    final starter = j['starter']! as int;
    final history = [for (final c in j['history']! as List) c as int];
    final cells = List.filled(size * size, -1);
    for (var i = 0; i < history.length; i++) {
      cells[history[i]] = (starter + i) % 2;
    }
    return TictactoeState(
      size: size,
      target: j['target']! as int,
      starter: starter,
      history: history,
      cells: cells,
      blocks: [for (final b in j['blocks']! as List) b as int],
      winner: j['winner'] as int?,
      line: [for (final c in j['line']! as List) c as int],
      confirm: j['confirm'] == true,
      robots: [for (final r in j['robots']! as List) r == true],
      difficulty: j['difficulty'] as String?,
    );
  }

  static TictactoeState _copy(
    TictactoeState s, {
    required List<int> history,
    required List<int> cells,
    required List<int> blocks,
    required int? winner,
    required List<int> line,
  }) => TictactoeState(
    size: s.size,
    target: s.target,
    starter: s.starter,
    history: history,
    cells: cells,
    blocks: blocks,
    winner: winner,
    line: line,
    confirm: s.confirm,
    robots: s.robots,
    difficulty: s.difficulty,
  );
}
