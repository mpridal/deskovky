import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';

/// Where a piece is, counted from its owner's start field: [base] = waiting
/// in the corner, 0–39 = on the ring (0 = start field), 40–43 = home.
abstract final class LudoPos {
  static const base = -1;
  static const ringLength = 40;
  static const homeSize = 4;
  static const lastHome = ringLength + homeSize - 1;

  static bool onRing(int p) => p >= 0 && p < ringLength;
  static bool inHome(int p) => p >= ringLength;
}

/// What happens next: the seat to move rolls the die, or picks a piece.
enum LudoPhase { roll, move }

/// Per-seat numbers for the result and the badges.
@immutable
class LudoSeatStats {
  const LudoSeatStats({this.captures = 0, this.captured = 0, this.sixes = 0, this.bestSixRun = 0});

  /// Opponents this seat sent back to start.
  final int captures;

  /// How often this seat's pieces were sent back.
  final int captured;
  final int sixes;

  /// Longest run of sixes in a row.
  final int bestSixRun;

  LudoSeatStats copyWith({int? captures, int? captured, int? sixes, int? bestSixRun}) => LudoSeatStats(
    captures: captures ?? this.captures,
    captured: captured ?? this.captured,
    sixes: sixes ?? this.sixes,
    bestSixRun: bestSixRun ?? this.bestSixRun,
  );

  List<int> toJson() => [captures, captured, sixes, bestSixRun];

  static LudoSeatStats fromJson(List<Object?> j) => LudoSeatStats(
    captures: j[0]! as int,
    captured: j[1]! as int,
    sixes: j[2]! as int,
    bestSixRun: j[3]! as int,
  );
}

/// Options chosen on the setup screen (spec 13.8).
@immutable
class LudoOptions {
  const LudoOptions({
    this.pieces = 4,
    this.mustCapture = false,
    this.threeTries = true,
    this.playOut = false,
    this.autoMove = true,
  });

  factory LudoOptions.fromConfig(Map<String, Object?> o) => LudoOptions(
    pieces: o['length'] == 'short' ? 2 : 4,
    mustCapture: o['mustCapture'] == true,
    threeTries: o['threeTries'] != false,
    playOut: o['playOut'] == true,
    autoMove: o['autoMove'] != false,
  );

  final int pieces;
  final bool mustCapture;
  final bool threeTries;
  final bool playOut;

  /// The board plays the only possible move by itself.
  final bool autoMove;

  Map<String, Object?> toJson() => {
    'pieces': pieces,
    'mustCapture': mustCapture,
    'threeTries': threeTries,
    'playOut': playOut,
    'autoMove': autoMove,
  };

  static LudoOptions fromJson(Map<String, Object?> j) => LudoOptions(
    pieces: j['pieces']! as int,
    mustCapture: j['mustCapture']! as bool,
    threeTries: j['threeTries']! as bool,
    playOut: j['playOut']! as bool,
    autoMove: j['autoMove']! as bool,
  );
}

@immutable
class LudoState {
  const LudoState({
    required this.options,
    required this.robots,
    required this.pieces,
    required this.current,
    required this.phase,
    required this.dice,
    required this.tries,
    required this.sixRun,
    required this.rng,
    required this.finished,
    required this.stats,
    this.noMove = false,
    this.stopped = false,
  });

  final LudoOptions options;

  /// Which seats are robots (the board reports "Rodinná hra" from it).
  final List<bool> robots;

  /// Piece positions per seat, see [LudoPos].
  final List<List<int>> pieces;
  final int current;
  final LudoPhase phase;

  /// The last roll (of whoever rolled last), null before the first one.
  final int? dice;

  /// Rolls without a six while the seat had no piece on the ring.
  final int tries;

  /// Sixes in a row in this turn.
  final int sixRun;

  /// State of the die's xorshift32 generator.
  final int rng;

  /// Seats with every piece home, in the order they finished.
  final List<int> finished;
  final List<LudoSeatStats> stats;

  /// The last roll could not move any piece.
  final bool noMove;

  /// Ended by "Ukončit a seřadit podle postupu".
  final bool stopped;

  int get seats => pieces.length;

  /// Board corner of [seat]: two players sit opposite each other.
  int corner(int seat) => seats == 2 ? seat * 2 : seat;

  LudoState copyWith({
    List<List<int>>? pieces,
    int? current,
    LudoPhase? phase,
    int? Function()? dice,
    int? tries,
    int? sixRun,
    int? rng,
    List<int>? finished,
    List<LudoSeatStats>? stats,
    bool? noMove,
    bool? stopped,
  }) => LudoState(
    options: options,
    robots: robots,
    pieces: pieces ?? this.pieces,
    current: current ?? this.current,
    phase: phase ?? this.phase,
    dice: dice == null ? this.dice : dice(),
    tries: tries ?? this.tries,
    sixRun: sixRun ?? this.sixRun,
    rng: rng ?? this.rng,
    finished: finished ?? this.finished,
    stats: stats ?? this.stats,
    noMove: noMove ?? this.noMove,
    stopped: stopped ?? this.stopped,
  );
}

/// One possible piece move for the rolled [LudoState.dice].
@immutable
class LudoStep {
  const LudoStep({required this.piece, required this.from, required this.to, this.captures});

  final int piece;
  final int from;
  final int to;

  /// The opponent piece (seat, index) sent back to start, if any.
  final (int, int)? captures;
}

/// Člověče, nezlob se – the Czech classic (spec 13.8). A turn is a `roll`
/// move followed, when some piece can move, by a `move` move naming the
/// piece; `stop` ends the game and ranks by progress.
class LudoRules implements GameRules<LudoState> {
  const LudoRules();

  @override
  LudoState initialState(GameConfig config, int seed) {
    final options = LudoOptions.fromConfig(config.options);
    final n = config.seats.length;
    final mixed = (seed ^ 0x6C75646F) & 0xFFFFFFFF;
    return LudoState(
      options: options,
      robots: [for (final s in config.seats) s is RobotSeat],
      pieces: [for (var s = 0; s < n; s++) List.filled(options.pieces, LudoPos.base)],
      current: 0,
      phase: LudoPhase.roll,
      dice: null,
      tries: 0,
      sixRun: 0,
      rng: mixed == 0 ? 1 : mixed,
      finished: const [],
      stats: List.filled(n, const LudoSeatStats()),
    );
  }

  /// Ring field 0–39 of [pos] (relative to [seat]'s start), null off the ring.
  static int? ringField(LudoState s, int seat, int pos) =>
      LudoPos.onRing(pos) ? (s.corner(seat) * 10 + pos) % LudoPos.ringLength : null;

  /// The piece standing on ring field [field], if any.
  static (int, int)? pieceAt(LudoState s, int field) {
    for (var seat = 0; seat < s.seats; seat++) {
      for (var i = 0; i < s.pieces[seat].length; i++) {
        if (ringField(s, seat, s.pieces[seat][i]) == field) return (seat, i);
      }
    }
    return null;
  }

  /// Where piece [i] of [seat] gets with [roll], or null when it cannot move.
  static LudoStep? stepFor(LudoState s, int seat, int i, int roll) {
    final mine = s.pieces[seat];
    final from = mine[i];
    final int to;
    if (from == LudoPos.base) {
      if (roll != 6) return null;
      to = 0;
    } else {
      to = from + roll;
      if (to > LudoPos.lastHome) return null;
    }
    if (LudoPos.inHome(to)) {
      // Exact roll into a free home field; pieces in the home are never jumped.
      for (var p = (from < LudoPos.ringLength ? LudoPos.ringLength : from + 1); p <= to; p++) {
        if (mine.contains(p)) return null;
      }
      return LudoStep(piece: i, from: from, to: to);
    }
    final hit = pieceAt(s, ringField(s, seat, to)!);
    if (hit == null) return LudoStep(piece: i, from: from, to: to);
    if (hit.$1 == seat) return null;
    return LudoStep(piece: i, from: from, to: to, captures: hit);
  }

  /// Every piece move [seat] may make with [roll] (must-capture applied).
  static List<LudoStep> steps(LudoState s, int seat, int roll) {
    final all = [
      for (var i = 0; i < s.pieces[seat].length; i++) ?stepFor(s, seat, i, roll),
    ];
    if (s.options.mustCapture && all.any((m) => m.captures != null)) {
      return [for (final m in all) if (m.captures != null) m];
    }
    return all;
  }

  /// The piece moves open to the seat to move now (empty while rolling).
  static List<LudoStep> currentSteps(LudoState s) =>
      s.phase == LudoPhase.move && s.dice != null ? steps(s, s.current, s.dice!) : const [];

  /// "Ukončit a seřadit" is offered once some piece (anyone's) is home: an
  /// early end right at the start would hand out free places (spec 5.6).
  static bool canStop(LudoState s) => s.pieces.any((p) => p.any(LudoPos.inHome));

  static bool _done(LudoState s, int seat) => s.pieces[seat].every(LudoPos.inHome);

  static bool _over(LudoState s) =>
      s.stopped ||
      (s.options.playOut ? s.finished.length >= s.seats - 1 : s.finished.isNotEmpty);

  @override
  int? currentSeat(LudoState state) => _over(state) ? null : state.current;

  @override
  List<Move> legalMoves(LudoState state, int seat) {
    if (_over(state) || seat != state.current) return const [];
    if (state.phase == LudoPhase.roll) return [Move(seat: seat, type: 'roll')];
    return [
      for (final m in currentSteps(state)) Move(seat: seat, type: 'move', data: {'piece': m.piece}),
    ];
  }

  /// Also legal, though not in [legalMoves] so no robot ever picks it: a
  /// person ends the game with `stop` ("Ukončit a seřadit podle postupu").
  @override
  bool isLegal(LudoState state, Move move) {
    if (_over(state) || move.seat != state.current) return false;
    return switch (move.type) {
      'stop' => move.data.isEmpty && canStop(state),
      'roll' => state.phase == LudoPhase.roll && move.data.isEmpty,
      'move' => currentSteps(state).any((m) => m.piece == move.data['piece']),
      _ => false,
    };
  }

  @override
  LudoState apply(LudoState state, Move move) {
    switch (move.type) {
      case 'stop':
        return state.copyWith(stopped: true);
      case 'roll':
        final (value, rng) = _roll(state.rng);
        return rollWith(state.copyWith(rng: rng), value);
      default:
        final step = currentSteps(state).firstWhere((m) => m.piece == move.data['piece']);
        return _move(state, step);
    }
  }

  static (int, int) _roll(int x) {
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    x &= 0xFFFFFFFF;
    return (x % 6 + 1, x);
  }

  /// The state after the seat to move rolled [value] (the AI looks ahead
  /// with it): pick a piece, roll again, or pass the die on.
  LudoState rollWith(LudoState s, int value) {
    final seat = s.current;
    final run = value == 6 ? s.sixRun + 1 : 0;
    final old = s.stats[seat];
    final stats = [...s.stats]
      ..[seat] = old.copyWith(
        sixes: old.sixes + (value == 6 ? 1 : 0),
        bestSixRun: run > old.bestSixRun ? run : old.bestSixRun,
      );
    final rolled = s.copyWith(dice: () => value, sixRun: run, stats: stats, noMove: false);
    if (steps(rolled, seat, value).isNotEmpty) return rolled.copyWith(phase: LudoPhase.move);
    // Nothing can move: a six rolls again, so do the three tries of a seat
    // with no piece on the ring; otherwise the next seat rolls.
    final noneOut = !s.pieces[seat].any(LudoPos.onRing);
    final allowed = s.options.threeTries ? 3 : 1;
    if (value == 6) return rolled.copyWith(phase: LudoPhase.roll, noMove: true);
    if (noneOut && s.tries + 1 < allowed) return rolled.copyWith(phase: LudoPhase.roll, tries: s.tries + 1, noMove: true);
    return _next(rolled.copyWith(noMove: true));
  }

  LudoState _move(LudoState s, LudoStep step) {
    final seat = s.current;
    final pieces = [for (final p in s.pieces) [...p]];
    pieces[seat][step.piece] = step.to;
    var stats = s.stats;
    final hit = step.captures;
    if (hit != null) {
      pieces[hit.$1][hit.$2] = LudoPos.base;
      stats = [...stats]
        ..[seat] = stats[seat].copyWith(captures: stats[seat].captures + 1)
        ..[hit.$1] = stats[hit.$1].copyWith(captured: stats[hit.$1].captured + 1);
    }
    var next = s.copyWith(pieces: pieces, stats: stats, phase: LudoPhase.roll, tries: 0);
    if (_done(next, seat) && !next.finished.contains(seat)) {
      next = next.copyWith(finished: [...next.finished, seat]);
    }
    if (_over(next)) return next;
    final again = s.dice == 6 && !next.finished.contains(seat);
    return again ? next : _next(next);
  }

  /// Passes the die to the next seat still playing.
  LudoState _next(LudoState s) {
    var seat = s.current;
    do {
      seat = (seat + 1) % s.seats;
    } while (s.finished.contains(seat) && seat != s.current);
    return s.copyWith(current: seat, phase: LudoPhase.roll, tries: 0, sixRun: 0);
  }

  @override
  bool isOver(LudoState state) => _over(state);

  /// How far [seat] got: every field each piece went (0 in the corner).
  static int progress(LudoState s, int seat) => s.pieces[seat].fold(0, (sum, p) => sum + p + 1);

  /// 1-based places: finished seats in their order, then the rest by
  /// progress (equal progress shares a place).
  static List<int> places(LudoState s) {
    final places = List.filled(s.seats, 0);
    for (final (i, seat) in s.finished.indexed) {
      places[seat] = i + 1;
    }
    final rest = [for (var seat = 0; seat < s.seats; seat++) if (!s.finished.contains(seat)) seat]
      ..sort((a, b) => progress(s, b).compareTo(progress(s, a)));
    for (final (i, seat) in rest.indexed) {
      final tied = i > 0 && progress(s, rest[i - 1]) == progress(s, seat);
      places[seat] = tied ? places[rest[i - 1]] : s.finished.length + i + 1;
    }
    return places;
  }

  @override
  GameResult result(LudoState state) {
    final p = places(state);
    return GameResult(
      places: p,
      scores: [for (var s = 0; s < state.seats; s++) score(state, s)],
      // An early end only ranks the players; stars are for a game played out.
      stars: [for (final place in p) state.stopped || place > 3 ? 0 : 4 - place],
      stats: {
        'captures': state.stats.fold<int>(0, (sum, x) => sum + x.captures),
        'pieces': state.options.pieces,
        'endedEarly': state.stopped,
      },
    );
  }

  /// Pieces home – shown in the HUD.
  @override
  int score(LudoState state, int seat) => state.pieces[seat].where(LudoPos.inHome).length;

  @override
  Map<String, Object?> stateToJson(LudoState s) => {
    'options': s.options.toJson(),
    'robots': s.robots,
    'pieces': s.pieces,
    'current': s.current,
    'phase': s.phase.name,
    'dice': s.dice,
    'tries': s.tries,
    'sixRun': s.sixRun,
    'rng': s.rng,
    'finished': s.finished,
    'stats': [for (final x in s.stats) x.toJson()],
    'noMove': s.noMove,
    'stopped': s.stopped,
  };

  @override
  LudoState stateFromJson(Map<String, Object?> j) => LudoState(
    options: LudoOptions.fromJson(j['options']! as Map<String, Object?>),
    robots: [for (final r in j['robots']! as List) r as bool],
    pieces: [
      for (final seat in j['pieces']! as List) [for (final p in seat as List) p as int],
    ],
    current: j['current']! as int,
    phase: LudoPhase.values.byName(j['phase']! as String),
    dice: j['dice'] as int?,
    tries: j['tries']! as int,
    sixRun: j['sixRun']! as int,
    rng: j['rng']! as int,
    finished: [for (final f in j['finished']! as List) f as int],
    stats: [for (final x in j['stats']! as List) LudoSeatStats.fromJson(x as List<Object?>)],
    noMove: j['noMove']! as bool,
    stopped: j['stopped']! as bool,
  );
}
