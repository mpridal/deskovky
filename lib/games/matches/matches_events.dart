import 'matches_rules.dart';

/// Badge events of Sirky (design §7), derived from the state alone, so every
/// device of a network game and a resumed game report them too.
///
/// The winner is known as soon as one match is left – the other player must
/// take it – so the board reports the win before that forced last move, also
/// when it comes from a robot or another device (the game screen collects
/// events right when the game ends).
abstract final class MatchesEvents {
  /// A win (counted for `matches.first` and `matches.collector`).
  static const win = 'matches.win';

  /// A win in which every own move left the other player a losing position.
  static const flawless = 'matches.flawless';

  /// The winner once the game is decided: over, or a single match left.
  static int? decidedWinner(MatchesState s) {
    if (s.over) return s.winner;
    if (s.total == 1 && s.history.isNotEmpty) return 1 - s.current;
    return null;
  }

  /// Every event [s] deserves so far, keyed so each is reported once.
  static Map<String, Map<String, Object?>> of(MatchesState s) {
    final winner = decidedWinner(s);
    if (winner == null) return const {};
    return {
      '$win#$winner': {'seat': winner},
      if (s.flawless[winner]) '$flawless#$winner': {'seat': winner},
    };
  }

  /// The event id of a key from [of].
  static String idOf(String key) => key.split('#').first;
}
