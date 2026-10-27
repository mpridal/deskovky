import 'ludo_rules.dart';

/// Badge events of Člověče (spec 13.8). The board reports them from the
/// totals in the state, so a resumed game reports them again to the new host.
abstract final class LudoEvents {
  /// The seat's pieces were sent back three times (with a win: `ludo.calm`).
  static const captured3 = 'ludo.captured3';
  static const hunter = 'ludo.hunter';
  static const sixes = 'ludo.sixes';

  /// Four people at the table – no seat, so it concerns everybody. Reported
  /// only once the game is well under way (a piece home), not at the start.
  static const family = 'ludo.family';

  /// Every event [s] deserves so far, keyed so each is reported once.
  static Map<String, Map<String, Object?>> of(LudoState s) => {
    if (s.seats == 4 && !s.robots.contains(true) && LudoRules.canStop(s)) family: const {},
    for (var seat = 0; seat < s.seats; seat++) ...{
      if (s.stats[seat].captured >= 3) '$captured3#$seat': {'seat': seat},
      if (s.stats[seat].captures >= 5) '$hunter#$seat': {'seat': seat},
      if (s.stats[seat].bestSixRun >= 3) '$sixes#$seat': {'seat': seat},
    },
  };

  /// The event id of a key from [of].
  static String idOf(String key) => key.split('#').first;
}
