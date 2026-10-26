import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'memory_rules.dart';

/// Robot of Pexeso with a child-like memory (spec 13.6): of every card it has
/// seen it keeps easy 25 % for 3 turns, medium 60 % for 8 turns, hard 95 %
/// for good. What it keeps is derived from the state (which seat, which
/// flip), so it is the same after a save and restore and needs no own state.
class MemoryAi implements AiPlayer<MemoryState> {
  const MemoryAi();

  static (int percent, int? turns) recall(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => (25, 3),
    Difficulty.medium => (60, 8),
    Difficulty.hard => (95, null),
  };

  /// Position → picture of the cards still in play that [seat] remembers.
  static Map<int, int> memory(MemoryState state, int seat, Difficulty difficulty) {
    final (percent, turns) = recall(difficulty);
    final now = state.reveals.length ~/ 2;
    final onTable = state.reveals.length - state.open.length;
    final known = <int, int>{};
    for (var k = 0; k < state.reveals.length; k++) {
      final card = state.reveals[k];
      if (state.owner[card] != null) continue;
      final fresh = turns == null || now - k ~/ 2 < turns;
      // A card turned up in this turn lies face up: everyone sees it.
      if (k >= onTable || (fresh && _chance(state.seed, seat, k) < percent)) known[card] = state.faces[card];
    }
    return known;
  }

  /// A stable 0–99 roll for "does [seat] remember flip number [k]".
  static int _chance(int seed, int seat, int k) {
    var x = (seed * 0x9E3779B1 + seat * 0x85EBCA6B + k * 0xC2B2AE35) & 0xFFFFFFFF;
    x ^= x >> 16;
    x = (x * 0x7FEB352D) & 0xFFFFFFFF;
    x ^= x >> 15;
    x = (x * 0x846CA68B) & 0xFFFFFFFF;
    x ^= x >> 16;
    return x % 100;
  }

  @override
  Move chooseMove(MemoryState state, int seat, Difficulty difficulty, SeededRandom random) {
    final known = memory(state, seat, difficulty);
    final inPlay = [
      for (var c = 0; c < state.cards; c++)
        if (state.owner[c] == null && !state.open.contains(c)) c,
    ];
    final unknown = [
      for (final c in inPlay)
        if (!known.containsKey(c)) c,
    ];
    int pick(List<int> from) => from[random.nextInt(from.length)];

    if (state.open.isEmpty) {
      // Start with a remembered pair, else learn something new.
      final pairs = [
        for (final MapEntry(key: c, value: face) in known.entries)
          if (known.entries.any((e) => e.key > c && e.value == face)) c,
      ];
      final card = pairs.isNotEmpty ? pick(pairs) : pick(unknown.isNotEmpty ? unknown : inPlay);
      return MemoryRules.flip(seat, card);
    }
    final first = state.open.single;
    final face = state.faces[first];
    final partner = [
      for (final MapEntry(key: c, value: f) in known.entries)
        if (c != first && f == face) c,
    ];
    final card = partner.isNotEmpty ? partner.first : pick(unknown.isNotEmpty ? unknown : inPlay);
    return MemoryRules.flip(seat, card);
  }
}
