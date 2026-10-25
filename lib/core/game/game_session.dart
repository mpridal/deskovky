import 'game_config.dart';
import 'game_rules.dart';
import 'move.dart';
import 'state_hash.dart';

/// One running game: state plus the log of applied moves (owned by the
/// framework, not by the game).
class GameSession<S> {
  GameSession._(this.rules, this.config, this.seed, this._state);

  factory GameSession.start(GameRules<S> rules, GameConfig config, int seed) =>
      GameSession._(rules, config, seed, rules.initialState(config, seed));

  /// Replays a saved game; null if any saved move is no longer legal.
  static GameSession<S>? restore<S>(GameRules<S> rules, SavedGame save) {
    final session = GameSession.start(rules, save.config, save.seed);
    for (final move in save.moves) {
      if (!session.apply(move)) return null;
    }
    return session;
  }

  final GameRules<S> rules;
  final GameConfig config;
  final int seed;
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

  SavedGame toSave() => SavedGame(config: config, seed: seed, moves: moves);
}
