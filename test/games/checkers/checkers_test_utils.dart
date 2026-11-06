import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/checkers/checkers_rules.dart';

const rules = CheckersRules();

/// A game config: seat 0 a person, seat 1 a person or a robot.
GameConfig config({
  String variant = 'czech',
  bool robot = false,
  bool robotFirst = false,
  Difficulty difficulty = Difficulty.easy,
  bool undo = true,
  bool hint = true,
  bool rotate = false,
}) => GameConfig(
  gameId: 'checkers',
  seats: robotFirst ? const [RobotSeat(), HumanSeat(1)] : [const HumanSeat(1), robot ? const RobotSeat() : const HumanSeat(2)],
  difficulty: difficulty,
  robotSpeed: RobotSpeed.fast,
  options: {'rules': variant, 'undo': undo, 'hint': hint, 'rotate': rotate},
);

/// The square index of (column, row); row 0 is at the top.
int sq(int column, int row, [int size = 8]) => row * size + column;

/// A position from a picture, one string per row from the top: `.` empty,
/// `w`/`W` a man/king of seat 0 (moving up), `b`/`B` of seat 1.
CheckersState diagram(
  List<String> rows, {
  int current = 0,
  List<bool> robots = const [false, false],
  String? difficulty,
  bool undo = true,
  int quiet = 0,
}) {
  final size = rows.length;
  final board = [
    for (final row in rows)
      for (final ch in row.split(''))
        switch (ch) {
          'w' => CheckersPiece.man(0),
          'W' => CheckersPiece.king(0),
          'b' => CheckersPiece.man(1),
          'B' => CheckersPiece.king(1),
          _ => CheckersPiece.empty,
        },
  ];
  return CheckersRules.custom(
    size == 10 ? CheckersVariant.international : CheckersVariant.czech,
    board,
    current: current,
    robots: robots,
    difficulty: difficulty,
    undo: undo,
    quiet: quiet,
  );
}

/// An empty board of [size] with [pieces] on (column, row), for [diagram].
List<String> board(Map<(int, int), String> pieces, [int size = 8]) => [
  for (var r = 0; r < size; r++) [for (var c = 0; c < size; c++) pieces[(c, r)] ?? '.'].join(),
];

/// Paths of every legal piece move, as lists of (column, row).
Set<String> paths(CheckersState s) => {
  for (final step in CheckersRules.steps(s)) _name(step.path, s.size),
};

String _name(List<int> path, int size) => path.map((i) => '${i % size},${i ~/ size}').join('>');

/// A path written as (column, row) pairs.
String p(List<(int, int)> squares) => squares.map((e) => '${e.$1},${e.$2}').join('>');

Move go(CheckersState s, List<(int, int)> squares) =>
    CheckersRules.moveOf(s.current, [for (final (c, r) in squares) r * s.size + c]);

CheckersState play(CheckersState s, List<(int, int)> squares) {
  final move = go(s, squares);
  if (!rules.isLegal(s, move)) throw StateError('illegal $move in\n${s.picture}');
  return rules.apply(s, move);
}
