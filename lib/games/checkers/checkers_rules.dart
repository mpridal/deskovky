import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';

/// The two rule sets of the option `rules` (spec 13.9).
enum CheckersVariant {
  /// Česká dáma: 8×8, 12 men, men capture only forwards, any capture may be
  /// chosen, but a king must capture when it can.
  czech(8, 3),

  /// Mezinárodní dáma (FMJD): 10×10, 20 men, men capture backwards too, the
  /// capture of the most pieces is compulsory.
  international(10, 4);

  const CheckersVariant(this.size, this.rows);

  final int size;

  /// Rows of men each side starts with.
  final int rows;

  static CheckersVariant byName(Object? name) => values.where((v) => v.name == name).firstOrNull ?? czech;
}

/// Pieces on the board: 0 empty, then a man and a king per seat.
abstract final class CheckersPiece {
  static const empty = 0;
  static int man(int seat) => 1 + 2 * seat;
  static int king(int seat) => 2 + 2 * seat;

  /// The seat of a piece (not of [empty]).
  static int owner(int piece) => (piece - 1) ~/ 2;
  static bool isKing(int piece) => piece != empty && piece.isEven;
}

/// How a game ended: a win by taking all pieces or blocking them, or a draw
/// by agreement, by the third repetition or by 25 king moves each.
enum CheckersEnd { pieces, blocked, agreed, repetition, kings }

/// Totals of one seat during a game (for badges and statistics).
@immutable
class CheckersSeatStats {
  const CheckersSeatStats({this.captures = 0, this.bestCombo = 0, this.promotions = 0});

  final int captures;

  /// The most pieces taken by one move.
  final int bestCombo;
  final int promotions;

  Map<String, Object?> toJson() => {'captures': captures, 'bestCombo': bestCombo, 'promotions': promotions};

  static CheckersSeatStats fromJson(Object? json) {
    final j = json is Map<String, Object?> ? json : const <String, Object?>{};
    return CheckersSeatStats(
      captures: j['captures'] as int? ?? 0,
      bestCombo: j['bestCombo'] as int? ?? 0,
      promotions: j['promotions'] as int? ?? 0,
    );
  }
}

/// One whole move of a piece: the squares it lands on (start first), the
/// pieces it takes on the way and whether it is crowned.
@immutable
class CheckersStep {
  const CheckersStep(this.path, this.captured, this.promotes);

  final List<int> path;
  final List<int> captured;
  final bool promotes;

  int get from => path.first;
  int get to => path.last;
}

/// One game of Dáma. Squares are indexed `row * size + column`, row 0 at the
/// top; pieces stand on the dark squares (`row + column` odd). Seat 0 starts
/// at the bottom and moves up.
@immutable
class CheckersState {
  const CheckersState({
    required this.variant,
    required this.board,
    required this.current,
    required this.start,
    required this.starter,
    this.startQuiet = 0,
    this.winner,
    this.end,
    this.quiet = 0,
    this.positions = const [],
    this.offerBy,
    this.noOfferBy,
    this.log = const [],
    this.lastCaptured = const [],
    this.lastPromoted = false,
    this.stats = const [CheckersSeatStats(), CheckersSeatStats()],
    this.undos = const [0, 0],
    this.robots = const [false, false],
    this.difficulty,
    this.undoOption = true,
    this.hint = true,
    this.rotate = false,
  });

  final CheckersVariant variant;
  final List<int> board;

  /// Whose pieces move next (also while the other one answers a draw offer).
  final int current;

  /// The position the game started from, who moved first there and its
  /// count of quiet moves, so a move can be taken back by replaying [log].
  final List<int> start;
  final int starter;
  final int startQuiet;
  final int? winner;
  final CheckersEnd? end;

  /// Moves in a row made only by kings without a capture (spec 13.9: 25 of
  /// each player is a draw).
  final int quiet;

  /// Positions since the last capture or man move (only those can repeat).
  final List<String> positions;

  /// The seat that offered a draw; the other one answers now.
  final int? offerBy;

  /// A seat whose offer was declined: it moves before offering again.
  final int? noOfferBy;

  /// The paths of all piece moves so far.
  final List<List<int>> log;

  /// What the last move took and whether it crowned its piece (animation).
  final List<int> lastCaptured;
  final bool lastPromoted;
  final List<CheckersSeatStats> stats;

  /// How many times each seat took a move back (spec 13.9: at most 3).
  final List<int> undos;
  final List<bool> robots;
  final String? difficulty;

  /// Options: "Zpět tah", "Nápověda povinného braní", "Otáčet desku".
  final bool undoOption;
  final bool hint;
  final bool rotate;

  int get size => variant.size;
  bool get over => end != null;
  List<int>? get lastPath => log.isEmpty ? null : log.last;

  int count(int seat) {
    var n = 0;
    for (final p in board) {
      if (p != CheckersPiece.empty && CheckersPiece.owner(p) == seat) n++;
    }
    return n;
  }

  /// The board as text, one row per line (for tests and debugging).
  String get picture => [
    for (var r = 0; r < size; r++)
      [
        for (var c = 0; c < size; c++) const ['.', 'w', 'W', 'b', 'B'][board[r * size + c]],
      ].join(),
  ].join('\n');
}

/// Rules of Dáma (spec 13.9), Czech and international, as the Czech
/// draughts federation and FMJD play them:
/// - men move one square diagonally forwards; capturing is compulsory and a
///   multiple capture is finished; pieces are taken off only after the move
///   and none is jumped twice (Turkish strike);
/// - kings fly: they move and capture over any distance and land on any free
///   square behind the piece – one from which they can capture on, when
///   there is such a square;
/// - Czech: men capture forwards only, any capture may be chosen, but when a
///   king can capture, a king must; international: men capture backwards too
///   and the capture of the most pieces is compulsory;
/// - a man ending its move on the last row is crowned (a Czech man cannot
///   capture on from there; an international one passing it does not crown);
/// - whoever cannot move (no pieces or all blocked) loses; a draw by
///   agreement, by the third repetition of a position or after 25 moves of
///   each player only with kings and without capture.
class CheckersRules implements GameRules<CheckersState> {
  const CheckersRules();

  static const move = 'move';
  static const offer = 'offer';
  static const accept = 'accept';
  static const decline = 'decline';
  static const undo = 'undo';

  /// Takebacks per game (spec 13.9).
  static const maxUndos = 3;

  /// Plies of king moves without capture that make a draw.
  static const quietLimit = 50;

  static const _diagonals = [(-1, -1), (1, -1), (-1, 1), (1, 1)];

  /// A piece move: the squares it lands on, start first, as text (`"46-37"`)
  /// – moves compare their data by value, which a list would not.
  static Move moveOf(int seat, List<int> path) => Move(seat: seat, type: move, data: {'path': path.join('-')});

  /// The squares of a `move`, or null when it names none.
  static List<int>? pathOf(Move m) {
    final raw = m.data['path'];
    if (m.type != move || raw is! String) return null;
    final squares = [for (final part in raw.split('-')) int.tryParse(part)];
    return squares.contains(null) ? null : squares.cast<int>();
  }

  @override
  CheckersState initialState(GameConfig config, int seed) {
    final variant = CheckersVariant.byName(config.options['rules']);
    return custom(
      variant,
      startBoard(variant),
      robots: [for (var s = 0; s < 2; s++) s < config.seats.length && config.seats[s] is RobotSeat],
      difficulty: config.robots > 0 ? config.difficulty.name : null,
      undo: config.options['undo'] != false,
      hint: config.options['hint'] != false,
      rotate: config.options['rotate'] == true,
    );
  }

  /// A game from any position (also for tests and rule pictures).
  static CheckersState custom(
    CheckersVariant variant,
    List<int> board, {
    int current = 0,
    List<bool> robots = const [false, false],
    String? difficulty,
    bool undo = true,
    bool hint = true,
    bool rotate = false,
    int quiet = 0,
  }) {
    final b = List<int>.unmodifiable(board);
    return CheckersState(
      variant: variant,
      board: b,
      current: current,
      start: b,
      starter: current,
      startQuiet: quiet,
      quiet: quiet,
      positions: [positionKey(b, current)],
      robots: robots,
      difficulty: difficulty,
      undoOption: undo,
      hint: hint,
      rotate: rotate,
    );
  }

  static List<int> startBoard(CheckersVariant variant) {
    final n = variant.size;
    return [
      for (var r = 0; r < n; r++)
        for (var c = 0; c < n; c++)
          if ((r + c).isEven)
            CheckersPiece.empty
          else if (r < variant.rows)
            CheckersPiece.man(1)
          else if (r >= n - variant.rows)
            CheckersPiece.man(0)
          else
            CheckersPiece.empty,
    ];
  }

  static String positionKey(List<int> board, int current) => '$current${board.join()}';

  // ---- move generation ----

  /// Every legal piece move of the seat whose pieces move next.
  static List<CheckersStep> steps(CheckersState s) =>
      s.over ? const [] : generate(s.board, s.size, s.variant == CheckersVariant.international, s.current);

  /// Every legal move of [seat] on [board] (also used by the AI).
  static List<CheckersStep> generate(List<int> board, int size, bool international, int seat) {
    final jumpers = <int>[];
    for (var i = 0; i < board.length; i++) {
      final piece = board[i];
      if (piece == CheckersPiece.empty || CheckersPiece.owner(piece) != seat) continue;
      final can = CheckersPiece.isKing(piece)
          ? _kingCanJump(board, size, seat, i, const [])
          : _manCanJump(board, size, international, seat, i);
      if (can) jumpers.add(i);
    }
    final work = List.of(board);
    final kingCaptures = <CheckersStep>[], manCaptures = <CheckersStep>[];
    for (final i in jumpers) {
      final piece = work[i];
      // The moving piece leaves its square: a king may pass or land there.
      work[i] = CheckersPiece.empty;
      if (CheckersPiece.isKing(piece)) {
        _kingJumps(work, size, seat, i, [i], const [], kingCaptures);
      } else {
        _manJumps(work, size, international, seat, i, [i], const [], manCaptures);
      }
      work[i] = piece;
    }
    var captures = international
        ? [...kingCaptures, ...manCaptures]
        : (kingCaptures.isNotEmpty ? kingCaptures : manCaptures);
    if (international && captures.isNotEmpty) {
      var most = 0;
      for (final c in captures) {
        if (c.captured.length > most) most = c.captured.length;
      }
      captures = [
        for (final c in captures)
          if (c.captured.length == most) c,
      ];
    }
    if (captures.isNotEmpty) {
      return [for (final c in captures) CheckersStep(c.path, c.captured, _crowns(board[c.from], c.to, size))];
    }
    final quiet = <CheckersStep>[];
    final forward = seat == 0 ? -1 : 1;
    for (var i = 0; i < board.length; i++) {
      final piece = board[i];
      if (piece == CheckersPiece.empty || CheckersPiece.owner(piece) != seat) continue;
      final c = i % size, r = i ~/ size;
      final king = CheckersPiece.isKing(piece);
      for (final (dc, dr) in _diagonals) {
        if (!king && dr != forward) continue;
        var nc = c + dc, nr = r + dr;
        while (nc >= 0 && nr >= 0 && nc < size && nr < size && board[nr * size + nc] == CheckersPiece.empty) {
          final to = nr * size + nc;
          quiet.add(CheckersStep([i, to], const [], _crowns(piece, to, size)));
          if (!king) break;
          nc += dc;
          nr += dr;
        }
      }
    }
    return quiet;
  }

  static bool _crowns(int piece, int to, int size) {
    if (CheckersPiece.isKing(piece)) return false;
    final row = to ~/ size;
    return CheckersPiece.owner(piece) == 0 ? row == 0 : row == size - 1;
  }

  static bool _enemy(int piece, int seat) => piece != CheckersPiece.empty && CheckersPiece.owner(piece) != seat;

  /// Whether the man on [at] can take a piece at all (a quick look first).
  static bool _manCanJump(List<int> b, int size, bool international, int seat, int at) {
    final c = at % size, r = at ~/ size;
    final forward = seat == 0 ? -1 : 1;
    for (final (dc, dr) in _diagonals) {
      if (!international && dr != forward) continue;
      final lc = c + 2 * dc, lr = r + 2 * dr;
      if (lc < 0 || lr < 0 || lc >= size || lr >= size) continue;
      if (_enemy(b[(r + dr) * size + c + dc], seat) && b[lr * size + lc] == CheckersPiece.empty) return true;
    }
    return false;
  }

  static void _manJumps(
    List<int> b,
    int size,
    bool international,
    int seat,
    int at,
    List<int> path,
    List<int> captured,
    List<CheckersStep> out,
  ) {
    final c = at % size, r = at ~/ size;
    final forward = seat == 0 ? -1 : 1;
    var more = false;
    for (final (dc, dr) in _diagonals) {
      if (!international && dr != forward) continue;
      final lc = c + 2 * dc, lr = r + 2 * dr;
      if (lc < 0 || lr < 0 || lc >= size || lr >= size) continue;
      final mid = (r + dr) * size + c + dc, land = lr * size + lc;
      if (!_enemy(b[mid], seat) || captured.contains(mid) || b[land] != CheckersPiece.empty) continue;
      more = true;
      _manJumps(b, size, international, seat, land, [...path, land], [...captured, mid], out);
    }
    if (!more && captured.isNotEmpty) out.add(CheckersStep(path, captured, false));
  }

  static void _kingJumps(
    List<int> b,
    int size,
    int seat,
    int at,
    List<int> path,
    List<int> captured,
    List<CheckersStep> out,
  ) {
    final c = at % size, r = at ~/ size;
    var more = false;
    for (final (dc, dr) in _diagonals) {
      var nc = c + dc, nr = r + dr;
      while (nc >= 0 && nr >= 0 && nc < size && nr < size && b[nr * size + nc] == CheckersPiece.empty) {
        nc += dc;
        nr += dr;
      }
      if (nc < 0 || nr < 0 || nc >= size || nr >= size) continue;
      final hit = nr * size + nc;
      if (!_enemy(b[hit], seat) || captured.contains(hit)) continue;
      final landings = <int>[];
      var lc = nc + dc, lr = nr + dr;
      while (lc >= 0 && lr >= 0 && lc < size && lr < size && b[lr * size + lc] == CheckersPiece.empty) {
        landings.add(lr * size + lc);
        lc += dc;
        lr += dr;
      }
      if (landings.isEmpty) continue;
      more = true;
      final taken = [...captured, hit];
      // A king lands where it can capture on, when there is such a square.
      final onward = [
        for (final l in landings)
          if (_kingCanJump(b, size, seat, l, taken)) l,
      ];
      for (final land in onward.isEmpty ? landings : onward) {
        _kingJumps(b, size, seat, land, [...path, land], taken, out);
      }
    }
    if (!more && captured.isNotEmpty) out.add(CheckersStep(path, captured, false));
  }

  static bool _kingCanJump(List<int> b, int size, int seat, int at, List<int> captured) {
    final c = at % size, r = at ~/ size;
    for (final (dc, dr) in _diagonals) {
      var nc = c + dc, nr = r + dr;
      while (nc >= 0 && nr >= 0 && nc < size && nr < size && b[nr * size + nc] == CheckersPiece.empty) {
        nc += dc;
        nr += dr;
      }
      final lc = nc + dc, lr = nr + dr;
      if (lc < 0 || lr < 0 || lc >= size || lr >= size) continue;
      final hit = nr * size + nc;
      if (_enemy(b[hit], seat) && !captured.contains(hit) && b[lr * size + lc] == CheckersPiece.empty) return true;
    }
    return false;
  }

  // ---- GameRules ----

  @override
  int? currentSeat(CheckersState state) {
    if (state.over) return null;
    final offerBy = state.offerBy;
    return offerBy == null ? state.current : 1 - offerBy;
  }

  /// The piece moves of the seat to move, or the answers to a draw offer.
  /// Offering a draw and taking a move back are legal too ([isLegal]) but not
  /// listed, so a robot never picks them.
  @override
  List<Move> legalMoves(CheckersState state, int seat) {
    if (seat != currentSeat(state)) return const [];
    if (state.offerBy != null) {
      return [Move(seat: seat, type: accept), Move(seat: seat, type: decline)];
    }
    return [for (final step in steps(state)) moveOf(seat, step.path)];
  }

  /// Whether [seat] may take back its last move now (spec 13.9: against an
  /// easy or medium robot, with the option on, at most three times).
  static bool canUndo(CheckersState s, int seat) =>
      !s.over &&
      s.undoOption &&
      s.offerBy == null &&
      s.current == seat &&
      !s.robots[seat] &&
      s.robots[1 - seat] &&
      (s.difficulty == 'easy' || s.difficulty == 'medium') &&
      s.undos[seat] < maxUndos &&
      s.log.length >= 2;

  /// Whether [seat] may offer a draw now.
  static bool canOffer(CheckersState s, int seat) =>
      !s.over && s.offerBy == null && s.current == seat && s.noOfferBy != seat;

  /// The step a `move` names, or null.
  static CheckersStep? stepOf(CheckersState s, Move m) {
    final raw = pathOf(m);
    if (raw == null || raw.length < 2) return null;
    for (final square in raw) {
      if (square < 0 || square >= s.board.length) return null;
    }
    for (final step in steps(s)) {
      if (listEquals(step.path, raw)) return step;
    }
    return null;
  }

  @override
  bool isLegal(CheckersState state, Move m) {
    if (m.seat != currentSeat(state)) return false;
    return switch (m.type) {
      move => state.offerBy == null && stepOf(state, m) != null,
      offer => canOffer(state, m.seat),
      accept || decline => state.offerBy != null,
      undo => canUndo(state, m.seat),
      _ => false,
    };
  }

  @override
  CheckersState apply(CheckersState state, Move m) => switch (m.type) {
    offer => _copy(state, offerBy: m.seat),
    accept => _copy(state, offerBy: null, end: CheckersEnd.agreed),
    decline => _copy(state, offerBy: null, noOfferBy: state.offerBy),
    undo => _undo(state, m.seat),
    _ => step(state, stepOf(state, m)!),
  };

  /// Plays [st], a legal step of the seat to move.
  static CheckersState step(CheckersState s, CheckersStep st) {
    final seat = s.current;
    final board = List.of(s.board);
    final piece = board[st.from];
    board[st.from] = CheckersPiece.empty;
    for (final i in st.captured) {
      board[i] = CheckersPiece.empty;
    }
    board[st.to] = st.promotes ? CheckersPiece.king(seat) : piece;
    final next = 1 - seat;
    final reversible = CheckersPiece.isKing(piece) && st.captured.isEmpty;
    final quiet = reversible ? s.quiet + 1 : 0;
    final key = positionKey(board, next);
    final positions = reversible ? [...s.positions, key] : [key];
    final old = s.stats[seat];
    final stats = [
      for (var i = 0; i < 2; i++)
        i == seat
            ? CheckersSeatStats(
                captures: old.captures + st.captured.length,
                bestCombo: st.captured.length > old.bestCombo ? st.captured.length : old.bestCombo,
                promotions: old.promotions + (st.promotes ? 1 : 0),
              )
            : s.stats[i],
    ];
    CheckersEnd? end;
    int? winner;
    if (!board.any((p) => _enemy(p, seat))) {
      end = CheckersEnd.pieces;
      winner = seat;
    } else if (generate(board, s.size, s.variant == CheckersVariant.international, next).isEmpty) {
      end = CheckersEnd.blocked;
      winner = seat;
    } else if (quiet >= quietLimit) {
      end = CheckersEnd.kings;
    } else if (positions.where((p) => p == key).length >= 3) {
      end = CheckersEnd.repetition;
    }
    return CheckersState(
      variant: s.variant,
      board: List.unmodifiable(board),
      current: next,
      start: s.start,
      starter: s.starter,
      startQuiet: s.startQuiet,
      winner: winner,
      end: end,
      quiet: quiet,
      positions: positions,
      noOfferBy: s.noOfferBy == seat ? null : s.noOfferBy,
      log: [...s.log, st.path],
      lastCaptured: st.captured,
      lastPromoted: st.promotes,
      stats: stats,
      undos: s.undos,
      robots: s.robots,
      difficulty: s.difficulty,
      undoOption: s.undoOption,
      hint: s.hint,
      rotate: s.rotate,
    );
  }

  /// Back to [seat]'s previous turn: the game is replayed without its last
  /// move and the robot's reply.
  static CheckersState _undo(CheckersState s, int seat) {
    var t = CheckersState(
      variant: s.variant,
      board: s.start,
      current: s.starter,
      start: s.start,
      starter: s.starter,
      startQuiet: s.startQuiet,
      quiet: s.startQuiet,
      positions: [positionKey(s.start, s.starter)],
      robots: s.robots,
      difficulty: s.difficulty,
      undoOption: s.undoOption,
      hint: s.hint,
      rotate: s.rotate,
    );
    for (final path in s.log.take(s.log.length - 2)) {
      t = step(t, steps(t).firstWhere((st) => listEquals(st.path, path)));
    }
    return _copy(
      t,
      undos: [for (var i = 0; i < 2; i++) s.undos[i] + (i == seat ? 1 : 0)],
      lastCaptured: const [],
      lastPromoted: false,
    );
  }

  @override
  bool isOver(CheckersState state) => state.over;

  /// Pieces on the board (the counter in the HUD, spec 13.9).
  @override
  int score(CheckersState state, int seat) => state.count(seat);

  /// Rating (spec 13.9): a win with 6 or more own pieces ★★★, a win ★★, a
  /// draw ★, a loss nothing.
  static int stars(CheckersState s, int seat) {
    if (!s.over) return 0;
    if (s.winner == null) return 1;
    if (s.winner != seat) return 0;
    return s.count(seat) >= 6 ? 3 : 2;
  }

  @override
  GameResult result(CheckersState state) {
    final winner = state.winner;
    return GameResult(
      places: [for (var s = 0; s < 2; s++) winner == null || winner == s ? 1 : 2],
      scores: [for (var s = 0; s < 2; s++) score(state, s)],
      stars: [for (var s = 0; s < 2; s++) stars(state, s)],
      stats: {
        'rules': state.variant.name,
        'moves': state.log.length,
        'end': state.end?.name,
        'captures': [for (final st in state.stats) st.captures],
        'kings': [for (final st in state.stats) st.promotions],
      },
    );
  }

  @override
  Map<String, Object?> stateToJson(CheckersState s) => {
    'rules': s.variant.name,
    'board': s.board,
    'current': s.current,
    'start': s.start,
    'starter': s.starter,
    'startQuiet': s.startQuiet,
    'winner': s.winner,
    'end': s.end?.name,
    'quiet': s.quiet,
    'positions': s.positions,
    'offerBy': s.offerBy,
    'noOfferBy': s.noOfferBy,
    'log': s.log,
    'lastCaptured': s.lastCaptured,
    'lastPromoted': s.lastPromoted,
    'stats': [for (final st in s.stats) st.toJson()],
    'undos': s.undos,
    'robots': s.robots,
    'difficulty': s.difficulty,
    'undoOption': s.undoOption,
    'hint': s.hint,
    'rotate': s.rotate,
  };

  @override
  CheckersState stateFromJson(Map<String, Object?> j) {
    List<int> ints(Object? raw) => List.unmodifiable([for (final v in raw! as List) v as int]);
    final end = j['end'];
    return CheckersState(
      variant: CheckersVariant.byName(j['rules']),
      board: ints(j['board']),
      current: j['current']! as int,
      start: ints(j['start']),
      starter: j['starter']! as int,
      startQuiet: j['startQuiet'] as int? ?? 0,
      winner: j['winner'] as int?,
      end: CheckersEnd.values.where((e) => e.name == end).firstOrNull,
      quiet: j['quiet']! as int,
      positions: [for (final p in j['positions']! as List) p as String],
      offerBy: j['offerBy'] as int?,
      noOfferBy: j['noOfferBy'] as int?,
      log: [for (final path in j['log']! as List) ints(path)],
      lastCaptured: ints(j['lastCaptured']),
      lastPromoted: j['lastPromoted'] == true,
      stats: [for (final st in j['stats']! as List) CheckersSeatStats.fromJson(st)],
      undos: ints(j['undos']),
      robots: [for (final r in j['robots']! as List) r == true],
      difficulty: j['difficulty'] as String?,
      undoOption: j['undoOption'] != false,
      hint: j['hint'] != false,
      rotate: j['rotate'] == true,
    );
  }

  static const _keep = Object();

  static CheckersState _copy(
    CheckersState s, {
    Object? offerBy = _keep,
    Object? noOfferBy = _keep,
    CheckersEnd? end,
    List<int>? undos,
    List<int>? lastCaptured,
    bool? lastPromoted,
  }) => CheckersState(
    variant: s.variant,
    board: s.board,
    current: s.current,
    start: s.start,
    starter: s.starter,
    startQuiet: s.startQuiet,
    winner: s.winner,
    end: end ?? s.end,
    quiet: s.quiet,
    positions: s.positions,
    offerBy: identical(offerBy, _keep) ? s.offerBy : offerBy as int?,
    noOfferBy: identical(noOfferBy, _keep) ? s.noOfferBy : noOfferBy as int?,
    log: s.log,
    lastCaptured: lastCaptured ?? s.lastCaptured,
    lastPromoted: lastPromoted ?? s.lastPromoted,
    stats: s.stats,
    undos: undos ?? s.undos,
    robots: s.robots,
    difficulty: s.difficulty,
    undoOption: s.undoOption,
    hint: s.hint,
    rotate: s.rotate,
  );
}
