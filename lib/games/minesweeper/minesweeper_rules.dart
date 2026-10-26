import '../../core/game/difficulty.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import 'minesweeper_generator.dart';
import 'minesweeper_state.dart';

/// Move types: uncover a square, uncover around a number (chording, one
/// player only) and cycle the mark of a hidden square (flag, question mark).
abstract final class MinesweeperMove {
  static const reveal = 'reveal';
  static const chord = 'chord';
  static const mark = 'mark';

  /// [t] is the playing time in ms (spec 13.7: rating by time); the board
  /// sends `view.elapsed()` so a replay rates the game the same.
  static Move of(int seat, String type, int column, int row, {int? t}) =>
      Move(seat: seat, type: type, data: {'c': column, 'r': row, 't': ?t});
}

/// Rules of Miny (spec 13.7): the classic game for one player, "Střídačka"
/// for 2–4 players who take turns uncovering one square each.
class MinesweeperRules implements GameRules<MinesweeperState> {
  const MinesweeperRules();

  static MinesweeperLevel levelOf(Difficulty d) => switch (d) {
    Difficulty.easy => MinesweeperLevel.easy,
    Difficulty.medium => MinesweeperLevel.medium,
    Difficulty.hard => MinesweeperLevel.hard,
  };

  @override
  MinesweeperState initialState(GameConfig config, int seed) => MinesweeperState.start(
    level: levelOf(config.difficulty),
    seats: config.seats.length,
    questionMarks: config.options['questionMarks'] == true,
    switchControls: config.options['controls'] == 'switch',
    seed: seed,
  );

  @override
  int? currentSeat(MinesweeperState state) => state.over ? null : state.current;

  @override
  bool isLegal(MinesweeperState state, Move move) {
    if (state.over || move.seat != state.current) return false;
    final c = move.data['c'], r = move.data['r'], t = move.data['t'];
    if (c is! int || r is! int || c < 0 || r < 0 || c >= state.columns || r >= state.rows) return false;
    if (t != null && (t is! int || t < 0)) return false;
    final cell = state.cellOf(c, r);
    return switch (move.type) {
      MinesweeperMove.reveal => !state.isRevealed(cell) && state.marks[cell] != Mark.flag && !state.exploded.contains(cell),
      MinesweeperMove.chord => state.solo && _chordTargets(state, cell).isNotEmpty,
      MinesweeperMove.mark => !state.isRevealed(cell) && !state.exploded.contains(cell),
      _ => false,
    };
  }

  /// Hidden, unflagged squares around an uncovered number whose flags are
  /// all placed; empty when chording there does nothing.
  static List<int> _chordTargets(MinesweeperState state, int cell) {
    if (!state.isRevealed(cell) || state.numbers[cell] == 0) return const [];
    final around = state.neighbours(cell);
    final flags = around.where((n) => !state.isRevealed(n) && state.marks[n] == Mark.flag).length;
    if (flags != state.numbers[cell]) return const [];
    return [
      for (final n in around)
        if (!state.isRevealed(n) && state.marks[n] != Mark.flag) n,
    ];
  }

  @override
  List<Move> legalMoves(MinesweeperState state, int seat) {
    if (state.over || seat != state.current) return const [];
    final moves = <Move>[];
    for (var cell = 0; cell < state.cellCount; cell++) {
      final c = cell % state.columns, r = cell ~/ state.columns;
      if (state.exploded.contains(cell)) continue;
      if (!state.isRevealed(cell)) {
        if (state.marks[cell] != Mark.flag) moves.add(MinesweeperMove.of(seat, MinesweeperMove.reveal, c, r));
        moves.add(MinesweeperMove.of(seat, MinesweeperMove.mark, c, r));
      } else if (state.solo && _chordTargets(state, cell).isNotEmpty) {
        moves.add(MinesweeperMove.of(seat, MinesweeperMove.chord, c, r));
      }
    }
    return moves;
  }

  @override
  MinesweeperState apply(MinesweeperState state, Move move) {
    final cell = state.cellOf(move.data['c']! as int, move.data['r']! as int);
    final t = move.data['t'] as int?;
    switch (move.type) {
      case MinesweeperMove.mark:
        final next = switch (state.marks[cell]) {
          Mark.none => Mark.flag,
          Mark.flag => state.questionMarks ? Mark.question : Mark.none,
          _ => Mark.none,
        };
        return state.copyWith(
          marks: List.of(state.marks)..[cell] = next,
          flagsPlaced: state.flagsPlaced + (next == Mark.flag ? 1 : 0),
        );
      case MinesweeperMove.chord:
        return _uncover(state, _chordTargets(state, cell), move.seat, t);
      default:
        var s = state;
        if (!s.started) {
          final (mines, noGuess) = MinesweeperGenerator.generate(s.level, s.seed, cell);
          s = s.copyWith(mines: mines, noGuess: noGuess);
        }
        return _uncover(s, [cell], move.seat, t);
    }
  }

  /// Uncovers [cells] for [seat], opening empty areas; a mine among them
  /// ends the game (one player) or puts the seat out (Střídačka).
  MinesweeperState _uncover(MinesweeperState state, List<int> cells, int seat, int? t) {
    final revealed = List.of(state.revealedBy);
    final marks = List.of(state.marks);
    int? boom;
    for (final cell in cells) {
      if (state.mineSet.contains(cell)) {
        boom ??= cell;
        continue;
      }
      final queue = [cell];
      while (queue.isNotEmpty) {
        final c = queue.removeLast();
        if (revealed[c] >= 0 || state.mineSet.contains(c)) continue;
        // An empty area stops at flags; question marks are opened.
        if (c != cell && marks[c] == Mark.flag) continue;
        revealed[c] = seat;
        marks[c] = Mark.none;
        if (state.numbers[c] == 0) queue.addAll(state.neighbours(c));
      }
    }
    if (boom != null) marks[boom] = Mark.none;
    var next = state.copyWith(revealedBy: revealed, marks: marks);
    if (boom != null) {
      next = next.copyWith(exploded: [...state.exploded, boom], explodedBy: [...state.explodedBy, seat]);
    }
    if (next.solo) {
      return next.cleared && boom == null ? next.copyWith(finishMs: t ?? 0) : next;
    }
    return next.over ? next : next.copyWith(current: _nextSeat(next, seat));
  }

  static int _nextSeat(MinesweeperState state, int seat) {
    for (var i = 1; i <= state.seats; i++) {
      final s = (seat + i) % state.seats;
      if (!state.isOut(s)) return s;
    }
    return seat;
  }

  @override
  bool isOver(MinesweeperState state) => state.over;

  @override
  int score(MinesweeperState state, int seat) => state.revealedBy.where((s) => s == seat).length;

  /// ★ for one player (spec 13.7): a win ★, under the target time ★★, under
  /// half of it ★★★; a lost game 0. Without a time in the move only ★.
  static int soloStars(MinesweeperState state) {
    if (!state.cleared) return 0;
    final ms = state.finishMs ?? 0;
    final target = state.level.targetSeconds * 1000;
    if (ms <= 0) return 1;
    if (ms < target / 2) return 3;
    if (ms < target) return 2;
    return 1;
  }

  @override
  GameResult result(MinesweeperState state) {
    final n = state.seats;
    final scores = [for (var s = 0; s < n; s++) score(state, s)];
    final stats = <String, Object?>{
      'level': state.level.name,
      'mines': state.level.mines,
      'noGuess': state.noGuess,
      'flags': state.flagsPlaced,
      if (state.finishMs != null) 'timeMs': state.finishMs,
    };
    if (state.solo) {
      final won = state.cleared && state.exploded.isEmpty;
      return GameResult(places: [won ? 1 : 2], scores: scores, stars: [soloStars(state)], stats: stats);
    }
    final places = placesOf(state);
    return GameResult(
      places: places,
      scores: scores,
      stars: [for (final p in places) p == 1 ? 3 : (p == 2 ? 2 : 1)],
      stats: stats,
    );
  }

  /// Střídačka (spec 13.7): players still in rank above those out, by the
  /// squares they uncovered (equal counts share a place); players out rank
  /// by how long they lasted.
  static List<int> placesOf(MinesweeperState state) {
    final n = state.seats;
    int rank(int s) {
      final out = state.explodedBy.indexOf(s);
      // Still in: high key by score; out: lower, later out is better.
      return out < 0 ? 100000 + state.revealedBy.where((x) => x == s).length : out;
    }

    final keys = [for (var s = 0; s < n; s++) rank(s)];
    return [for (var s = 0; s < n; s++) 1 + keys.where((k) => k > keys[s]).length];
  }

  @override
  Map<String, Object?> stateToJson(MinesweeperState state) => state.toJson();

  @override
  MinesweeperState stateFromJson(Map<String, Object?> json) => MinesweeperState.fromJson(json);
}
