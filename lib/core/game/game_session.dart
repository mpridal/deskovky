import 'game_config.dart';
import 'game_rules.dart';
import 'move.dart';
import 'state_hash.dart';

/// One running game: state plus the log of applied moves (owned by the
/// framework, not by the game).
class GameSession<S> {
  GameSession._(this.rules, this.config, this.seed, this._state, [this.elapsedBefore = Duration.zero]);

  factory GameSession.start(GameRules<S> rules, GameConfig config, int seed) =>
      GameSession._(rules, config, seed, rules.initialState(config, seed));

  /// Replays a saved game; null if any saved move is no longer legal.
  static GameSession<S>? restore<S>(GameRules<S> rules, SavedGame save) {
    final session = GameSession._(
      rules,
      save.config,
      save.seed,
      rules.initialState(save.config, save.seed),
      Duration(milliseconds: save.elapsedMs),
    );
    for (final move in save.moves) {
      if (!session.apply(move)) return null;
    }
    return session;
  }

  final GameRules<S> rules;
  final GameConfig config;
  final int seed;

  /// Playing time from before a resume; the screen adds its own clock.
  final Duration elapsedBefore;
  S _state;
  final List<Move> _moves = [];

  S get state => _state;
  List<Move> get moves => List.unmodifiable(_moves);
  Move? get lastMove => _moves.isEmpty ? null : _moves.last;
  String get hash => stateHash(rules.stateToJson(_state));

  /// Applies [move] if legal; returns false and changes nothing otherwise.
  bool apply(Move move) {
    if (rules.isOver(_state) || !rules.isLegal(_state, move)) return false;
    _state = rules.apply(_state, move);
    _moves.add(move);
    return true;
  }

  /// Puts this session into [save]'s position in place, e.g. a network
  /// client catching up with the host (spec 14.7); false and unchanged when
  /// a saved move does not replay.
  bool replaceWith(SavedGame save) {
    final replay = GameSession.restore(rules, save);
    if (replay == null) return false;
    _state = replay._state;
    _moves
      ..clear()
      ..addAll(replay._moves);
    return true;
  }

  SavedGame toSave({Duration elapsed = Duration.zero}) =>
      SavedGame(config: config, seed: seed, moves: moves, elapsedMs: elapsed.inMilliseconds);
}
