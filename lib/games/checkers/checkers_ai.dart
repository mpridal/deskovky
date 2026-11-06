import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import '../../core/game_kit/game_search.dart';
import 'checkers_rules.dart';

/// A light position for the search: the board, who moves and the count of
/// quiet king moves (the 25-move draw). Its moves are computed once.
class CheckersNode {
  CheckersNode(this.board, this.seat, this.size, this.international, this.quiet);

  factory CheckersNode.of(CheckersState s) =>
      CheckersNode(s.board, s.current, s.size, s.variant == CheckersVariant.international, s.quiet);

  final List<int> board;
  final int seat;
  final int size;
  final bool international;
  final int quiet;

  List<CheckersStep>? _steps;

  /// Legal steps; none once the game is drawn by the 25-move rule.
  List<CheckersStep> get steps =>
      _steps ??= quiet >= CheckersRules.quietLimit ? const [] : CheckersRules.generate(board, size, international, seat);

  CheckersNode play(CheckersStep st) {
    final b = List.of(board);
    final piece = b[st.from];
    b[st.from] = CheckersPiece.empty;
    for (final i in st.captured) {
      b[i] = CheckersPiece.empty;
    }
    b[st.to] = st.promotes ? CheckersPiece.king(seat) : piece;
    final reversible = CheckersPiece.isKing(piece) && st.captured.isEmpty;
    return CheckersNode(b, 1 - seat, size, international, reversible ? quiet + 1 : 0);
  }
}

/// The robot of Dáma (spec 13.9): alpha-beta search ([GameSearch], iterative
/// deepening) over [CheckersNode]s, in the AI isolate.
/// - Lehká: 2 moves deep, and a quarter of its moves are random.
/// - Střední: 5 moves deep within 600 ms.
/// - Těžká: 8 moves deep within 1.5 s.
///
/// A position is judged by material (a king is worth three men), how far the
/// men have come, the centre, safe men (back row, edges), mobility, and – when
/// ahead – by trading pieces down. A draw offer is accepted when the robot is
/// behind (Lehká: when it is not ahead).
class CheckersAi implements AiPlayer<CheckersState> {
  const CheckersAi({
    this.easyDepth = 2,
    this.mediumDepth = 5,
    this.hardDepth = 8,
    this.easyTime = const Duration(milliseconds: 300),
    this.mediumTime = const Duration(milliseconds: 600),
    this.hardTime = const Duration(milliseconds: 1500),
  });

  /// Search depths and time limits per difficulty; strength tests use depth
  /// limits with generous times, so results do not depend on the machine.
  final int easyDepth, mediumDepth, hardDepth;
  final Duration easyTime, mediumTime, hardTime;

  static const win = 1000000;

  @override
  Move chooseMove(CheckersState state, int seat, Difficulty difficulty, SeededRandom random) {
    if (state.offerBy != null) {
      final value = evaluate(CheckersNode.of(state), seat);
      final take = difficulty == Difficulty.easy ? value <= 0 : value <= -100;
      return Move(seat: seat, type: take ? CheckersRules.accept : CheckersRules.decline);
    }
    final root = CheckersNode.of(state);
    final steps = root.steps;
    if (steps.length == 1) return CheckersRules.moveOf(seat, steps.single.path);
    if (difficulty == Difficulty.easy && random.nextInt(4) == 0) {
      return CheckersRules.moveOf(seat, steps[random.nextInt(steps.length)].path);
    }
    final (depth, time) = switch (difficulty) {
      Difficulty.easy => (easyDepth, easyTime),
      Difficulty.medium => (mediumDepth, mediumTime),
      Difficulty.hard => (hardDepth, hardTime),
    };
    final best = search.best(root, seat, maxDepth: depth, timeLimit: time, tieBreak: random);
    return CheckersRules.moveOf(seat, steps[best!.data['i']! as int].path);
  }

  static final search = GameSearch<CheckersNode>(
    moves: _moves,
    apply: (n, m) => n.play(n.steps[m.data['i']! as int]),
    currentSeat: (n) => n.seat,
    evaluate: evaluate,
  );

  /// Moves as indexes into [CheckersNode.steps]: crowning ones first, then
  /// the rest as generated (captures are compulsory, so they come alone).
  static List<Move> _moves(CheckersNode n) {
    final steps = n.steps;
    final first = <Move>[], rest = <Move>[];
    for (var i = 0; i < steps.length; i++) {
      (steps[i].promotes ? first : rest).add(Move(seat: n.seat, type: 'i', data: {'i': i}));
    }
    return [...first, ...rest];
  }

  /// How good [n] is for [me]; a lost position is −[win], a draw 0.
  static int evaluate(CheckersNode n, int me) {
    if (n.steps.isEmpty) {
      if (n.quiet >= CheckersRules.quietLimit) return 0;
      return n.seat == me ? -win : win;
    }
    final size = n.size, board = n.board;
    var material = [0, 0], position = [0, 0];
    final centreLow = size ~/ 2 - 2, centreHigh = size ~/ 2 + 1;
    for (var i = 0; i < board.length; i++) {
      final p = board[i];
      if (p == CheckersPiece.empty) continue;
      final seat = CheckersPiece.owner(p);
      final c = i % size, r = i ~/ size;
      if (CheckersPiece.isKing(p)) {
        material[seat] += 300;
        // Kings like the long diagonals.
        if (c == r || c + r == size - 1) position[seat] += 8;
        continue;
      }
      material[seat] += 100;
      final advance = seat == 0 ? size - 1 - r : r;
      position[seat] += advance * 3;
      if (c >= centreLow && c <= centreHigh && r >= centreLow && r <= centreHigh) position[seat] += 6;
      if (advance == 0) position[seat] += 8; // guards the crowning row
      if (c == 0 || c == size - 1) position[seat] += 3; // cannot be jumped
    }
    final other = 1 - me;
    final diff = material[me] - material[other];
    var value = diff + position[me] - position[other];
    // Ahead, trade down: the same lead counts more with fewer pieces left.
    value += diff * 400 ~/ (material[me] + material[other] + 200);
    // Mobility of the side to move.
    value += (n.seat == me ? 1 : -1) * n.steps.length * 2;
    return value;
  }
}
