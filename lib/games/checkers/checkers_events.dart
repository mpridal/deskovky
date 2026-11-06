import '../../core/game/move.dart';
import 'checkers_rules.dart';

/// Badge events of Dáma (spec 13.9), keyed so each is reported once by a
/// board (`<id>#<seat>`).
abstract final class CheckersEvents {
  /// The seat crowned a piece (`checkers.queen`, „Dámou!“).
  static const queen = 'checkers.queen';

  /// The seat took 3 or more pieces with one move (`checkers.combo`).
  static const combo = 'checkers.combo';

  /// The game is played on the international board – with a win, the badge
  /// `checkers.international`. It concerns everybody, so it is reported at
  /// the start: the framework reads the events right after the last move.
  static const international = 'checkers.international';

  /// Every event [s] deserves so far.
  static Map<String, Map<String, Object?>> of(CheckersState s) => {
    if (s.variant == CheckersVariant.international) international: const {},
    for (var seat = 0; seat < 2; seat++) ...{
      if (s.stats[seat].promotions > 0) '$queen#$seat': {'seat': seat},
      if (s.stats[seat].bestCombo >= 3) '$combo#$seat': {'seat': seat},
    },
  };

  /// The events [move] earns in [s], reported with the move itself, so the
  /// one that ends the game counts too.
  static Map<String, Map<String, Object?>> ofMove(CheckersState s, Move move) {
    const rules = CheckersRules();
    if (move.type != CheckersRules.move || !rules.isLegal(s, move)) return const {};
    final after = of(rules.apply(s, move));
    return {
      for (final MapEntry(:key, :value) in after.entries)
        if (key.endsWith('#${move.seat}')) key: value,
    };
  }

  /// The event id of a key from [of].
  static String idOf(String key) => key.split('#').first;
}
