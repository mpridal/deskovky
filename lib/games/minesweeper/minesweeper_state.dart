import 'package:flutter/foundation.dart';

/// Board sizes (spec 13.7): difficulty = board size. Columns × rows in the
/// board's own (portrait) orientation; the board widget turns it on wide screens.
enum MinesweeperLevel {
  easy(9, 9, 10, 60),
  medium(12, 16, 30, 180),
  hard(16, 24, 70, 480);

  const MinesweeperLevel(this.columns, this.rows, this.mines, this.targetSeconds);

  final int columns;
  final int rows;
  final int mines;

  /// Target time for ★★ (spec 13.7); half of it gives ★★★.
  final int targetSeconds;
}

/// Mark on a hidden square.
abstract final class Mark {
  static const none = 0;
  static const flag = 1;
  static const question = 2;
}

/// One game of Miny: the classic game for one player or "Střídačka" (take
/// turns) for 2–4. Immutable; squares are indexed `row * columns + column`.
@immutable
class MinesweeperState {
  MinesweeperState({
    required this.level,
    required this.seats,
    required this.questionMarks,
    required this.seed,
    this.switchControls = false,
    required this.mines,
    required this.revealedBy,
    required this.marks,
    required this.exploded,
    required this.explodedBy,
    required this.current,
    this.noGuess = false,
    this.flagsPlaced = 0,
    this.finishMs,
  });

  /// A new game: no mines yet – they are placed after the first tap.
  factory MinesweeperState.start({
    required MinesweeperLevel level,
    required int seats,
    required bool questionMarks,
    required int seed,
    bool switchControls = false,
  }) {
    final cells = level.columns * level.rows;
    return MinesweeperState(
      level: level,
      seats: seats,
      questionMarks: questionMarks,
      seed: seed,
      switchControls: switchControls,
      mines: const [],
      revealedBy: List.filled(cells, -1),
      marks: List.filled(cells, Mark.none),
      exploded: const [],
      explodedBy: const [],
      current: 0,
    );
  }

  final MinesweeperLevel level;
  final int seats;
  final bool questionMarks;
  final int seed;

  /// Controls chosen in the setup (spec 13.7): a ⛏/🚩 switch instead of a
  /// long press for flags. Kept here so a resumed game keeps them.
  final bool switchControls;

  /// Squares with a mine, sorted; empty until the first square is uncovered.
  final List<int> mines;

  /// Who uncovered each square (its seat), or -1 while it is hidden.
  final List<int> revealedBy;

  /// [Mark] of each hidden square.
  final List<int> marks;

  /// Mines uncovered by mistake and the seat who found each, in order.
  final List<int> exploded;
  final List<int> explodedBy;

  final int current;

  /// The mines were checked by the solver: no guessing needed (spec 13.7).
  final bool noGuess;

  /// Flags ever placed (badge "Bez vlajek").
  final int flagsPlaced;

  /// Playing time when the board was cleared, from the winning move.
  final int? finishMs;

  int get columns => level.columns;
  int get rows => level.rows;
  int get cellCount => columns * rows;
  bool get solo => seats == 1;
  bool get started => mines.isNotEmpty;

  late final Set<int> mineSet = mines.toSet();

  /// Number of mines around each square.
  late final List<int> numbers = _numbers();

  late final int revealedCount = revealedBy.where((s) => s >= 0).length;

  bool get cleared => started && revealedCount == cellCount - mines.length;

  bool isOut(int seat) => explodedBy.contains(seat);

  late final int alive = [for (var s = 0; s < seats; s++) s].where((s) => !isOut(s)).length;

  bool get over => solo ? exploded.isNotEmpty || cleared : cleared || alive <= 1;

  bool isRevealed(int cell) => revealedBy[cell] >= 0;

  int flagsCount() => marks.where((m) => m == Mark.flag).length;

  int cellOf(int column, int row) => row * columns + column;

  /// Squares around [cell] (3–8 of them).
  List<int> neighbours(int cell) => neighboursOf(cell, columns, rows);

  static List<int> neighboursOf(int cell, int columns, int rows) {
    final c = cell % columns, r = cell ~/ columns;
    return [
      for (var dr = -1; dr <= 1; dr++)
        for (var dc = -1; dc <= 1; dc++)
          if ((dr != 0 || dc != 0) && c + dc >= 0 && c + dc < columns && r + dr >= 0 && r + dr < rows)
            (r + dr) * columns + c + dc,
    ];
  }

  List<int> _numbers() {
    final result = List.filled(cellCount, 0);
    for (final m in mines) {
      for (final n in neighbours(m)) {
        result[n]++;
      }
    }
    return result;
  }

  MinesweeperState copyWith({
    List<int>? mines,
    List<int>? revealedBy,
    List<int>? marks,
    List<int>? exploded,
    List<int>? explodedBy,
    int? current,
    bool? noGuess,
    int? flagsPlaced,
    int? finishMs,
  }) => MinesweeperState(
    level: level,
    seats: seats,
    questionMarks: questionMarks,
    seed: seed,
    switchControls: switchControls,
    mines: mines ?? this.mines,
    revealedBy: revealedBy ?? this.revealedBy,
    marks: marks ?? this.marks,
    exploded: exploded ?? this.exploded,
    explodedBy: explodedBy ?? this.explodedBy,
    current: current ?? this.current,
    noGuess: noGuess ?? this.noGuess,
    flagsPlaced: flagsPlaced ?? this.flagsPlaced,
    finishMs: finishMs ?? this.finishMs,
  );

  Map<String, Object?> toJson() => {
    'level': level.name,
    'seats': seats,
    'questionMarks': questionMarks,
    'seed': seed,
    'switchControls': switchControls,
    'mines': mines,
    'revealedBy': revealedBy,
    'marks': marks,
    'exploded': exploded,
    'explodedBy': explodedBy,
    'current': current,
    'noGuess': noGuess,
    'flagsPlaced': flagsPlaced,
    'finishMs': finishMs,
  };

  static MinesweeperState fromJson(Map<String, Object?> j) {
    List<int> ints(String key) => [for (final v in j[key]! as List) v as int];
    return MinesweeperState(
      level: MinesweeperLevel.values.byName(j['level']! as String),
      seats: j['seats']! as int,
      questionMarks: j['questionMarks']! as bool,
      seed: j['seed']! as int,
      switchControls: j['switchControls'] == true,
      mines: ints('mines'),
      revealedBy: ints('revealedBy'),
      marks: ints('marks'),
      exploded: ints('exploded'),
      explodedBy: ints('explodedBy'),
      current: j['current']! as int,
      noGuess: j['noGuess']! as bool,
      flagsPlaced: j['flagsPlaced']! as int,
      finishMs: j['finishMs'] as int?,
    );
  }
}
