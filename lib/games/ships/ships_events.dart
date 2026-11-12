import 'ships_rules.dart';

/// Badge events of Lodě, derived from the state alone, so every device of a
/// network game and a resumed game report them too. Both describe a won
/// game, so they appear with the shot that ends it.
abstract final class ShipsEvents {
  /// Won with at least 60 % of the shots hitting.
  static const sharp = 'ships.sharp';

  /// Won without losing a single ship.
  static const untouched = 'ships.untouched';

  /// Every event [s] deserves so far, keyed so each is reported once.
  static Map<String, Map<String, Object?>> of(ShipsState s) {
    final winner = s.winner;
    if (winner == null) return const {};
    return {
      if (s.hits(winner).length * 10 >= s.shots[winner].length * 6) '$sharp#$winner': {'seat': winner},
      if (s.sunkShips(winner).isEmpty) '$untouched#$winner': {'seat': winner},
    };
  }

  /// The event id of a key from [of].
  static String idOf(String key) => key.split('#').first;
}
