import 'dart:isolate';

import 'difficulty.dart';
import 'move.dart';
import 'seeded_random.dart';

/// A game's computer player (spec 9). Pure and synchronous, so it can run in
/// another isolate; all randomness comes from [random].
abstract class AiPlayer<S> {
  Move chooseMove(S state, int seat, Difficulty difficulty, SeededRandom random);
}

/// Runs AI off the UI thread in the app; inline in widget tests.
abstract class AiRunner {
  const AiRunner();

  Future<Move> run<S>(AiPlayer<S> ai, S state, int seat, Difficulty difficulty, int seed);
}

class IsolateAiRunner extends AiRunner {
  const IsolateAiRunner();

  @override
  Future<Move> run<S>(AiPlayer<S> ai, S state, int seat, Difficulty difficulty, int seed) =>
      Isolate.run(() => ai.chooseMove(state, seat, difficulty, SeededRandom(seed)));
}

class InlineAiRunner extends AiRunner {
  const InlineAiRunner();

  @override
  Future<Move> run<S>(AiPlayer<S> ai, S state, int seat, Difficulty difficulty, int seed) async =>
      ai.chooseMove(state, seat, difficulty, SeededRandom(seed));
}
