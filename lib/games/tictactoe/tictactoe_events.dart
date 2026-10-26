import '../../core/game/move.dart';
import 'tictactoe_rules.dart';

/// Badge events (spec 13.5) of a person's [move] in [s], reported with the
/// move that decides them: a win on 15×15 (`tictactoe.win15`, for the
/// badges `five` and `master`), a big-board win within 9 own stones
/// (`tictactoe.blitz`) and a 3×3 draw against the hard robot
/// (`tictactoe.wall`) – also when the robot's last move is the only one left.
List<(String, Map<String, Object?>)> tictactoeEvents(TictactoeState s, Move move) {
  const rules = TictactoeRules();
  final seat = move.seat;
  final next = rules.apply(s, move);
  final data = {'seat': seat};
  final events = <(String, Map<String, Object?>)>[];
  if (next.winner == seat && s.bigBoard) {
    if (s.size == 15) events.add(('tictactoe.win15', data));
    if (next.movesOf(seat) <= 9) events.add(('tictactoe.blitz', data));
  }
  final other = 1 - seat;
  if (!s.bigBoard && s.difficulty == 'hard' && s.robots[other] && next.winner == null) {
    final left = rules.legalMoves(next, other);
    final end = left.length == 1 ? rules.apply(next, left.single) : next;
    if (end.full && end.winner == null) events.add(('tictactoe.wall', data));
  }
  return events;
}
