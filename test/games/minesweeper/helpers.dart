import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/minesweeper/minesweeper_rules.dart';
import 'package:deskovky/games/minesweeper/minesweeper_state.dart';

const rules = MinesweeperRules();

GameConfig config({
  int seats = 1,
  int robots = 0,
  Difficulty difficulty = Difficulty.easy,
  bool questionMarks = false,
  String controls = 'longPress',
}) => GameConfig(
  gameId: 'minesweeper',
  seats: [for (var s = 0; s < seats; s++) s < seats - robots ? HumanSeat(s + 1) : const RobotSeat()],
  difficulty: difficulty,
  robotSpeed: RobotSpeed.fast,
  options: {'questionMarks': questionMarks, 'controls': controls},
);

/// A started easy (9×9) board with the mines exactly at [mines] (as
/// `(column, row)`), so tests know the layout.
MinesweeperState board(
  List<(int, int)> mines, {
  int seats = 1,
  bool questionMarks = false,
  MinesweeperLevel level = MinesweeperLevel.easy,
}) => MinesweeperState.start(
  level: level,
  seats: seats,
  questionMarks: questionMarks,
  seed: 1,
).copyWith(mines: [for (final (c, r) in mines) r * level.columns + c]..sort());

Move reveal(int c, int r, {int seat = 0, int? t}) => MinesweeperMove.of(seat, MinesweeperMove.reveal, c, r, t: t);
Move chord(int c, int r, {int seat = 0, int? t}) => MinesweeperMove.of(seat, MinesweeperMove.chord, c, r, t: t);
Move mark(int c, int r, {int seat = 0}) => MinesweeperMove.of(seat, MinesweeperMove.mark, c, r);

/// Applies [moves], checking each one is legal.
MinesweeperState play(MinesweeperState state, List<Move> moves) {
  var s = state;
  for (final m in moves) {
    if (!rules.isLegal(s, m)) throw StateError('illegal $m');
    s = rules.apply(s, m);
  }
  return s;
}

/// Uncovers every safe square that is still hidden, one by one.
MinesweeperState clearAll(MinesweeperState state, {int? t}) {
  var s = state;
  for (var cell = 0; cell < s.cellCount; cell++) {
    if (s.over) break;
    if (s.isRevealed(cell) || s.mineSet.contains(cell)) continue;
    if (s.marks[cell] == Mark.flag) s = rules.apply(s, mark(cell % s.columns, cell ~/ s.columns, seat: s.current));
    s = rules.apply(s, reveal(cell % s.columns, cell ~/ s.columns, seat: s.current, t: t));
  }
  return s;
}
