import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';

/// Who starts (option `start`): the same values as in Piškvorky.
abstract final class MatchesStart {
  static const random = 'random';
  static const first = 'first';
}

/// One game of Sirky: matches left in each row, who started and every take
/// so far as (row, count); the seats alternate from [starter].
@immutable
class MatchesState {
  const MatchesState({
    required this.rows,
    required this.starter,
    required this.history,
    this.hadWin = const [false, false],
    this.flawless = const [true, true],
  });

  final List<int> rows;
  final int starter;
  final List<(int, int)> history;

  /// The other seat's move once left this seat a winning position (★★ after
  /// a loss). The starting position does not count.
  final List<bool> hadWin;

  /// Every move of this seat left the other one in a losing position
  /// (badge `matches.flawless`).
  final List<bool> flawless;

  int get total => rows.fold(0, (a, b) => a + b);
  bool get over => total == 0;

  /// The seat to move while the game runs.
  int get current => (starter + history.length) % 2;

  /// Who made move [index] of [history].
  int seatOf(int index) => (starter + index) % 2;

  /// Whoever took the last match, once the game is over.
  int? get loser => over && history.isNotEmpty ? seatOf(history.length - 1) : null;
  int? get winner => loser == null ? null : 1 - loser!;

  /// Matches [seat] has taken so far (their pile on the table).
  int takenBy(int seat) {
    var n = 0;
    for (var i = 0; i < history.length; i++) {
      if (seatOf(i) == seat) n += history[i].$2;
    }
    return n;
  }
}

/// Rules of Sirky (design §2): rows of 3, 5 and 7 matches; in a move a
/// player takes any number (at least one) from a single row; whoever takes
/// the last match loses. Misère Nim.
class MatchesRules implements GameRules<MatchesState> {
  const MatchesRules();

  static const initialRows = [3, 5, 7];

  static Move take(int seat, int row, int count) => Move(seat: seat, type: 'take', data: {'row': row, 'count': count});

  /// Whether the player to move with [rows] on the table wins with perfect
  /// play (misère Nim). With nothing left, the other one took the last match.
  static bool winning(List<int> rows) {
    if (rows.every((n) => n <= 1)) return rows.where((n) => n == 1).length.isEven;
    return rows.fold(0, (a, b) => a ^ b) != 0;
  }

  @override
  MatchesState initialState(GameConfig config, int seed) => MatchesState(
    rows: initialRows,
    starter: config.options['start'] == MatchesStart.first ? 0 : SeededRandom(seed).nextInt(2),
    history: const [],
  );

  @override
  int? currentSeat(MatchesState state) => state.over ? null : state.current;

  @override
  List<Move> legalMoves(MatchesState state, int seat) => [
    if (!state.over && seat == state.current)
      for (var row = 0; row < state.rows.length; row++)
        for (var count = 1; count <= state.rows[row]; count++) take(seat, row, count),
  ];

  @override
  bool isLegal(MatchesState state, Move move) {
    if (state.over || move.type != 'take' || move.seat != state.current) return false;
    final row = move.data['row'], count = move.data['count'];
    return row is int && count is int && row >= 0 && row < state.rows.length && count >= 1 && count <= state.rows[row];
  }

  @override
  MatchesState apply(MatchesState state, Move move) {
    final row = move.data['row']! as int, count = move.data['count']! as int;
    final seat = move.seat;
    final rows = List.of(state.rows)..[row] -= count;
    final leftWinning = winning(rows);
    return MatchesState(
      rows: rows,
      starter: state.starter,
      history: [...state.history, (row, count)],
      hadWin: [for (var s = 0; s < 2; s++) state.hadWin[s] || (s != seat && leftWinning && rows.any((n) => n > 0))],
      flawless: [for (var s = 0; s < 2; s++) state.flawless[s] && (s != seat || !leftWinning)],
    );
  }

  @override
  bool isOver(MatchesState state) => state.over;

  /// Winner 1, otherwise 0 – in the HUD as in the results (design §5).
  @override
  int score(MatchesState state, int seat) => state.winner == seat ? 1 : 0;

  @override
  GameResult result(MatchesState state) => GameResult(
    places: [for (var s = 0; s < 2; s++) state.winner == s ? 1 : 2],
    scores: [for (var s = 0; s < 2; s++) score(state, s)],
    stars: [for (var s = 0; s < 2; s++) stars(state, s)],
    stats: {'moves': state.history.length},
  );

  /// Rating (design §7): win ★★★; a loss after once having a winning
  /// position from the other's move ★★; another loss ★.
  static int stars(MatchesState state, int seat) {
    if (state.winner == seat) return 3;
    return state.hadWin[seat] ? 2 : 1;
  }

  @override
  Map<String, Object?> stateToJson(MatchesState s) => {
    'rows': s.rows,
    'starter': s.starter,
    'history': [for (final (row, count) in s.history) [row, count]],
    'hadWin': s.hadWin,
    'flawless': s.flawless,
  };

  @override
  MatchesState stateFromJson(Map<String, Object?> j) => MatchesState(
    rows: [for (final n in j['rows']! as List) n as int],
    starter: j['starter']! as int,
    history: [
      for (final t in j['history']! as List) ((t as List)[0] as int, t[1] as int),
    ],
    hadWin: [for (final b in j['hadWin']! as List) b == true],
    flawless: [for (final b in j['flawless']! as List) b == true],
  );
}
