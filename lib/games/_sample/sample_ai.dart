import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'sample_rules.dart';

/// Hard halves the remaining range, medium aims near the middle, easy
/// guesses anywhere still possible (so children can beat it).
class SampleAi implements AiPlayer<SampleState> {
  const SampleAi();

  @override
  Move chooseMove(SampleState state, int seat, Difficulty difficulty, SeededRandom random) {
    final span = state.high - state.low;
    final middle = (state.low + state.high) ~/ 2;
    final value = switch (difficulty) {
      Difficulty.hard => middle,
      Difficulty.medium => (middle + _jitter(span ~/ 4, random)).clamp(state.low, state.high),
      Difficulty.easy => state.low + random.nextInt(span + 1),
    };
    return Move(seat: seat, type: 'guess', data: {'value': value});
  }

  static int _jitter(int max, SeededRandom random) => max == 0 ? 0 : random.nextInt(2 * max + 1) - max;
}
