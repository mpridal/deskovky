import 'dart:math';

import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import '../../core/game_kit/game_search.dart';
import 'checkers_rules.dart';

/// A light position for the search: the board, who moves, the count of
/// quiet king moves (the 25-move draw) and how deep below the root it lies.
/// Its moves and, once ordered, its children are computed once.
class CheckersNode {
  CheckersNode(this.board, this.seat, this.size, this.international, this.quiet, [this.ply = 0]);

  factory CheckersNode.of(CheckersState s) =>
      CheckersNode(s.board, s.current, s.size, s.variant == CheckersVariant.international, s.quiet);

  final List<int> board;
  final int seat;
  final int size;
  final bool international;
  final int quiet;
  final int ply;

  List<CheckersStep>? _steps;
  List<CheckersNode?>? _children;

  /// Legal steps; none once the game is drawn by the 25-move rule.
  List<CheckersStep> get steps => _steps ??= quiet >= CheckersRules.quietLimit
      ? const []
      : CheckersRules.generate(board, size, international, seat);

  /// The position after step [i], kept for later.
  CheckersNode child(int i) {
    final children = _children ??= List.filled(steps.length, null);
    return children[i] ??= play(steps[i]);
  }

  /// The position after step [i]: the kept one, or a new one not kept (the
  /// many nodes near the horizon would only fill the memory).
  CheckersNode next(int i) => _children?[i] ?? play(steps[i]);

  CheckersNode play(CheckersStep st) {
    final b = List.of(board);
    final piece = b[st.from];
    b[st.from] = CheckersPiece.empty;
    for (final i in st.captured) {
      b[i] = CheckersPiece.empty;
    }
    b[st.to] = st.promotes ? CheckersPiece.king(seat) : piece;
    final reversible = CheckersPiece.isKing(piece) && st.captured.isEmpty;
    return CheckersNode(b, 1 - seat, size, international, reversible ? quiet + 1 : 0, ply + 1);
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
    final best = _Search(root).best(seat, depth, time, random);
    return CheckersRules.moveOf(seat, steps[best.data['i']! as int].path);
  }

  /// How good [n] is for [me]; a lost position is −[win], a draw 0.
  static int evaluate(CheckersNode n, int me) {
    if (n.steps.isEmpty) {
      if (n.quiet >= CheckersRules.quietLimit) return 0;
      return n.seat == me ? -win : win;
    }
    // Mobility of the side to move.
    return judge(n, me) + (n.seat == me ? 1 : -1) * n.steps.length * 2;
  }

  /// The board alone, without looking at moves (cheap, for move ordering).
  static int judge(CheckersNode n, int me) {
    final size = n.size, board = n.board;
    var material = 0, position = 0, mine = 0, theirs = 0;
    final centreLow = size ~/ 2 - 2, centreHigh = size ~/ 2 + 1;
    for (var i = 0; i < board.length; i++) {
      final p = board[i];
      if (p == CheckersPiece.empty) continue;
      final seat = CheckersPiece.owner(p);
      final sign = seat == me ? 1 : -1;
      final c = i % size, r = i ~/ size;
      if (CheckersPiece.isKing(p)) {
        if (seat == me) {
          mine += 300;
        } else {
          theirs += 300;
        }
        // Kings like the long diagonals.
        if (c == r || c + r == size - 1) position += 8 * sign;
        continue;
      }
      if (seat == me) {
        mine += 100;
      } else {
        theirs += 100;
      }
      final advance = seat == 0 ? size - 1 - r : r;
      var v = advance * 3;
      if (c >= centreLow && c <= centreHigh && r >= centreLow && r <= centreHigh) v += 6;
      if (advance == 0) v += 8; // guards the crowning row
      if (c == 0 || c == size - 1) v += 3; // cannot be jumped
      position += v * sign;
    }
    material = mine - theirs;
    // Ahead, trade down: the same lead counts more with fewer pieces left.
    return material + position + material * 400 ~/ (mine + theirs + 200);
  }
}

/// One search of [GameSearch] from [root]. Moves are indexes into a node's
/// steps. GameSearch orders only the root moves; this orders the moves of
/// every node at least two plies above the horizon by a quick look at the
/// board after them, best first – that lets alpha-beta cut far more. The
/// horizon is known from the iteration: GameSearch tries each root move once
/// per depth.
class _Search {
  _Search(this.root);

  final CheckersNode root;
  var _rootApplies = 0;

  /// Moves searched at a node three or more plies above the horizon.
  static const _width = 5;

  /// Index moves made once, shared by every search.
  static final _moves = [
    for (var seat = 0; seat < 2; seat++)
      [
        for (var i = 0; i < 160; i++) Move(seat: seat, type: 'i', data: {'i': i}),
      ],
  ];

  Move best(int seat, int depth, Duration time, SeededRandom random) => GameSearch<CheckersNode>(
    moves: _movesOf,
    apply: _apply,
    currentSeat: (n) => n.seat,
    evaluate: CheckersAi.evaluate,
  ).best(root, seat, maxDepth: depth, timeLimit: time, tieBreak: random)!;

  int get _iteration => _rootApplies ~/ root.steps.length + 1;

  CheckersNode _apply(CheckersNode n, Move m) {
    if (identical(n, root)) {
      _rootApplies++;
      return n.child(m.data['i']! as int);
    }
    return n.next(m.data['i']! as int);
  }

  List<Move> _movesOf(CheckersNode n) {
    final count = n.steps.length;
    final moves = _moves[n.seat];
    if (count > moves.length) {
      return [
        for (var i = 0; i < count; i++) Move(seat: n.seat, type: 'i', data: {'i': i}),
      ];
    }
    final left = _iteration - n.ply;
    if (count < 2 || identical(n, root) || left < 2) return moves.sublist(0, count);
    final scored = [for (var i = 0; i < count; i++) (i, CheckersAi.judge(n.child(i), n.seat))]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    // Far from the horizon only the most promising moves are searched, so
    // the many moves of flying kings do not eat the whole time.
    final width = left >= 3 ? min(count, _width) : count;
    return [for (final (i, _) in scored.take(width)) moves[i]];
  }
}
