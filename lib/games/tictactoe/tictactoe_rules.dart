import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';

/// Skeleton rules (milestone 9): the game is not playable yet, so a new game
/// is over at once. The game's own session replaces this with the real rules
/// (spec 13.4) and a proper state type.
class TictactoeRules implements GameRules<Map<String, Object?>> {
  const TictactoeRules();

  @override
  Map<String, Object?> initialState(GameConfig config, int seed) => {'seats': config.seats.length};

  @override
  int? currentSeat(Map<String, Object?> state) => null;

  @override
  bool isLegal(Map<String, Object?> state, Move move) => false;

  @override
  List<Move> legalMoves(Map<String, Object?> state, int seat) => const [];

  @override
  Map<String, Object?> apply(Map<String, Object?> state, Move move) => state;

  @override
  bool isOver(Map<String, Object?> state) => true;

  @override
  GameResult result(Map<String, Object?> state) {
    final seats = state['seats']! as int;
    return GameResult(places: List.filled(seats, 1), scores: List.filled(seats, 0), stars: List.filled(seats, 0));
  }

  @override
  int score(Map<String, Object?> state, int seat) => 0;

  @override
  Map<String, Object?> stateToJson(Map<String, Object?> state) => state;

  @override
  Map<String, Object?> stateFromJson(Map<String, Object?> json) => json;
}
