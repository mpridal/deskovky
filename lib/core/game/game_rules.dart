import 'game_config.dart';
import 'game_result.dart';
import 'move.dart';

/// Deterministic game logic (spec 8): no UI, no `Random()` – randomness only
/// from the seed via `SeededRandom`, so seed + moves always replay the same game.
abstract class GameRules<S> {
  S initialState(GameConfig config, int seed);

  /// The seat to move, or null when the game is over.
  int? currentSeat(S state);

  bool isLegal(S state, Move move);

  /// Every legal move of [seat] now (spec 8), a pass included where the game
  /// has one. Never empty while `currentSeat(state) == seat`; empty when it
  /// is not their turn. The framework falls back to these when an AI fails.
  List<Move> legalMoves(S state, int seat);

  /// Applies a legal move and returns the new state.
  S apply(S state, Move move);

  bool isOver(S state);

  GameResult result(S state);

  /// Score shown in the HUD for [seat].
  int score(S state, int seat);

  Map<String, Object?> stateToJson(S state);

  S stateFromJson(Map<String, Object?> json);
}

/// Rules where some moves may be made by a seat that is not on turn, e.g.
/// both players placing their fleet at the same time in Lodě. The framework
/// lets such a move through from any person of the device (and the host from
/// any device); [GameRules.isLegal] still decides whether it is legal.
abstract interface class OutOfTurnMoves<S> {
  bool outOfTurn(S state, Move move);
}
