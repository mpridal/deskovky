import 'war_rules.dart';

/// Badge events of Válka, derived from the state alone, so every device of
/// a network game and a resumed game report them too.
///
/// A battle's outcome is known before its collect move, and the game screen
/// takes the events the moment the game ends – so with a battle waiting to
/// be collected, the events are those of the state after the collect.
abstract final class WarEvents {
  /// Won a war after a war.
  static const doubleWar = 'war.doubleWar';

  /// Won the game after having three cards or fewer.
  static const comeback = 'war.comeback';

  /// Every event [s] deserves so far, keyed so each is reported once.
  static Map<String, Map<String, Object?>> of(WarState s) {
    const rules = WarRules();
    final winner = s.battleWinner;
    final next = winner == null || s.over ? s : rules.apply(s, WarRules.collect(winner));
    final places = next.over ? WarRules.places(next) : null;
    return {
      for (var seat = 0; seat < next.seats; seat++) ...{
        if (next.doubleWar[seat]) '$doubleWar#$seat': {'seat': seat},
        if (places != null && places[seat] == 1 && next.lowest[seat] <= 3) '$comeback#$seat': {'seat': seat},
      },
    };
  }

  /// The event id of a key from [of].
  static String idOf(String key) => key.split('#').first;
}
