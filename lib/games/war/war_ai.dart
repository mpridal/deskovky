import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'war_rules.dart';

/// The robot of Válka. The game is pure luck: there is always exactly one
/// thing to do – turn the top card, or collect a won battle.
class WarAi implements AiPlayer<WarState> {
  const WarAi();

  @override
  Move chooseMove(WarState state, int seat, Difficulty difficulty, SeededRandom random) =>
      const WarRules().legalMoves(state, seat).first;
}
