import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';

/// Option `deck`: 32 cards (7 to ace) or 52 (2 to ace).
abstract final class WarDeck {
  static const small = '32';
  static const full = '52';
}

/// Option `length`: how many battles a game lasts.
abstract final class WarLength {
  static const short = 'short';
  static const long = 'long';
  static const full = 'full';

  /// A game "to the end" still stops after [cap] battles, so it always ends.
  static const cap = 400;

  static int rounds(Object? value) => switch (value) {
    long => 100,
    full => cap,
    _ => 30,
  };
}

/// A card is `rank * 4 + suit`: rank 2–14 (J 11, Q 12, K 13, A 14), suit
/// 0–3 (♠ ♥ ♦ ♣).
abstract final class WarCard {
  static int rank(int card) => card ~/ 4;
  static int suit(int card) => card % 4;
  static int of(int rank, int suit) => rank * 4 + suit;
}

/// One game of Válka.
///
/// Every seat has a face-down pile ([decks], top card first) and the cards
/// it has put on the table in this battle ([table], each with whether it
/// lies face up). In a battle every seat in [contenders] turns its top card,
/// in seat order, and the highest card wins. A tie of the highest cards is a
/// war: the tied seats each put one card face down and one face up, and so
/// on. Once the battle has a [battleWinner], that seat collects every card
/// on the table under its pile.
@immutable
class WarState {
  const WarState({
    required this.decks,
    required this.table,
    required this.contenders,
    required this.flipped,
    required this.warDepth,
    required this.battleWinner,
    required this.round,
    required this.maxRounds,
    required this.out,
    required this.lowest,
    required this.doubleWar,
    required this.wars,
    required this.over,
  });

  final List<List<int>> decks;
  final List<List<(int, bool)>> table;

  /// Seats still fighting this battle: every seat still in at its start;
  /// in a war only the tied ones.
  final List<int> contenders;

  /// Contenders that have put their cards down in this step.
  final List<int> flipped;

  /// 0 in a plain battle, 1 in a war, 2 in a war after a war, …
  final int warDepth;
  final int? battleWinner;

  /// Battles finished so far.
  final int round;
  final int maxRounds;

  /// Seats that ran out of cards, in the order they went out. Seats going
  /// out in the same battle share a group.
  final List<List<int>> out;

  /// The fewest cards each seat had after a battle (badge `war.comeback`).
  final List<int> lowest;

  /// The seat has won a war after a war (badge `war.doubleWar`).
  final List<bool> doubleWar;

  /// Wars so far (statistics).
  final int wars;
  final bool over;

  int get seats => decks.length;
  bool isOut(int seat) => out.any((g) => g.contains(seat));
  List<int> get alive => [
    for (var s = 0; s < seats; s++)
      if (!isOut(s)) s,
  ];

  /// Cards of [seat]: its pile plus what it has on the table.
  int cardsOf(int seat) => decks[seat].length + table[seat].length;

  /// The face-up card [seat] shows in the current step, if any.
  int? shown(int seat) => table[seat].isEmpty || !table[seat].last.$2 ? null : table[seat].last.$1;

  WarState copyWith({
    List<List<int>>? decks,
    List<List<(int, bool)>>? table,
    List<int>? contenders,
    List<int>? flipped,
    int? warDepth,
    int? Function()? battleWinner,
    int? round,
    List<List<int>>? out,
    List<int>? lowest,
    List<bool>? doubleWar,
    int? wars,
    bool? over,
  }) => WarState(
    decks: decks ?? this.decks,
    table: table ?? this.table,
    contenders: contenders ?? this.contenders,
    flipped: flipped ?? this.flipped,
    warDepth: warDepth ?? this.warDepth,
    battleWinner: battleWinner == null ? this.battleWinner : battleWinner(),
    round: round ?? this.round,
    maxRounds: maxRounds,
    out: out ?? this.out,
    lowest: lowest ?? this.lowest,
    doubleWar: doubleWar ?? this.doubleWar,
    wars: wars ?? this.wars,
    over: over ?? this.over,
  );
}

/// Rules of Válka (design `docs/superpowers/specs/2026-11-12-valka-design.md`).
class WarRules implements GameRules<WarState> {
  const WarRules();

  static Move flip(int seat) => Move(seat: seat, type: 'flip');
  static Move collect(int seat) => Move(seat: seat, type: 'collect');

  /// The deck of [config], shuffled from [seed].
  static List<int> shuffled(GameConfig config, int seed) {
    final low = config.options['deck'] == WarDeck.full ? 2 : 7;
    final cards = [
      for (var rank = low; rank <= 14; rank++)
        for (var suit = 0; suit < 4; suit++) WarCard.of(rank, suit),
    ];
    final random = SeededRandom(seed);
    for (var i = cards.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final card = cards[i];
      cards[i] = cards[j];
      cards[j] = card;
    }
    return cards;
  }

  @override
  WarState initialState(GameConfig config, int seed) {
    final n = config.seats.length;
    final cards = shuffled(config, seed);
    // Everybody gets the same number; cards left over stay in the box.
    final each = cards.length ~/ n;
    return WarState(
      decks: [
        for (var s = 0; s < n; s++) [for (var i = 0; i < each; i++) cards[i * n + s]],
      ],
      table: [for (var s = 0; s < n; s++) const []],
      contenders: [for (var s = 0; s < n; s++) s],
      flipped: const [],
      warDepth: 0,
      battleWinner: null,
      round: 0,
      maxRounds: WarLength.rounds(config.options['length']),
      out: const [],
      lowest: [for (var s = 0; s < n; s++) each],
      doubleWar: [for (var s = 0; s < n; s++) false],
      wars: 0,
      over: false,
    );
  }

  @override
  int? currentSeat(WarState state) {
    if (state.over) return null;
    if (state.battleWinner != null) return state.battleWinner;
    for (final s in state.contenders) {
      if (!state.flipped.contains(s)) return s;
    }
    return null;
  }

  @override
  List<Move> legalMoves(WarState state, int seat) {
    if (currentSeat(state) != seat) return const [];
    return [state.battleWinner == null ? flip(seat) : collect(seat)];
  }

  @override
  bool isLegal(WarState state, Move move) =>
      currentSeat(state) == move.seat && move.type == (state.battleWinner == null ? 'flip' : 'collect');

  @override
  WarState apply(WarState state, Move move) => move.type == 'flip' ? _flip(state, move.seat) : _collect(state);

  WarState _flip(WarState s, int seat) {
    final deck = List.of(s.decks[seat]);
    final put = <(int, bool)>[
      // In a war one card face down first – unless it is the last one.
      if (s.warDepth > 0 && deck.length >= 2) (deck.removeAt(0), false),
      (deck.removeAt(0), true),
    ];
    final next = s.copyWith(
      decks: List.of(s.decks)..[seat] = deck,
      table: List.of(s.table)..[seat] = [...s.table[seat], ...put],
      flipped: [...s.flipped, seat],
    );
    return next.flipped.length == next.contenders.length ? _resolve(next) : next;
  }

  /// Every contender shows a card: the highest wins, a tie is a war.
  WarState _resolve(WarState s) {
    var top = 0;
    for (final c in s.contenders) {
      final r = WarCard.rank(s.shown(c)!);
      if (r > top) top = r;
    }
    final best = [
      for (final c in s.contenders)
        if (WarCard.rank(s.shown(c)!) == top) c,
    ];
    if (best.length == 1) return s.copyWith(battleWinner: () => best.single);
    // A war: the tied seats that still have cards go on. A single one left
    // wins; when none has a card left, the first of them takes the table.
    final going = [
      for (final c in best)
        if (s.decks[c].isNotEmpty) c,
    ];
    final depth = s.warDepth + 1;
    if (going.length <= 1) {
      final winner = going.isEmpty ? best.first : going.single;
      return s.copyWith(battleWinner: () => winner, warDepth: depth, wars: s.wars + 1);
    }
    return s.copyWith(contenders: going, flipped: const [], warDepth: depth, wars: s.wars + 1);
  }

  WarState _collect(WarState s) {
    final winner = s.battleWinner!;
    final pot = [
      for (final cards in s.table)
        for (final (card, _) in cards) card,
    ];
    final decks = List.of(s.decks)..[winner] = [...s.decks[winner], ...pot];
    final gone = [
      for (final a in s.alive)
        if (decks[a].isEmpty) a,
    ];
    final alive = [
      for (final a in s.alive)
        if (!gone.contains(a)) a,
    ];
    final round = s.round + 1;
    return s.copyWith(
      decks: decks,
      table: [for (var i = 0; i < s.seats; i++) const []],
      contenders: alive,
      flipped: const [],
      warDepth: 0,
      battleWinner: () => null,
      round: round,
      out: gone.isEmpty ? s.out : [...s.out, gone],
      lowest: [for (var i = 0; i < s.seats; i++) decks[i].length < s.lowest[i] ? decks[i].length : s.lowest[i]],
      doubleWar: [for (var i = 0; i < s.seats; i++) s.doubleWar[i] || (i == winner && s.warDepth >= 2)],
      over: alive.length <= 1 || round >= s.maxRounds,
    );
  }

  @override
  bool isOver(WarState state) => state.over;

  /// The cards a seat holds – in the HUD as in the results.
  @override
  int score(WarState state, int seat) => state.cardsOf(seat);

  /// Places: seats still in by their cards (equal cards share a place), then
  /// the seats that went out, the last one out first.
  static List<int> places(WarState s) {
    int strength(int seat) {
      final group = s.out.indexWhere((g) => g.contains(seat));
      return group < 0 ? 1000000 + s.cardsOf(seat) : group;
    }

    return [
      for (var seat = 0; seat < s.seats; seat++)
        1 +
            [
              for (var o = 0; o < s.seats; o++)
                if (strength(o) > strength(seat)) o,
            ].length,
    ];
  }

  /// ★★★ first place, ★★ still in at the end, ★ out of cards.
  static int stars(WarState s, int seat, List<int> places) => places[seat] == 1 ? 3 : (s.isOut(seat) ? 1 : 2);

  @override
  GameResult result(WarState state) {
    final p = places(state);
    return GameResult(
      places: p,
      scores: [for (var s = 0; s < state.seats; s++) score(state, s)],
      stars: [for (var s = 0; s < state.seats; s++) stars(state, s, p)],
      stats: {'rounds': state.round, 'wars': state.wars},
    );
  }

  @override
  Map<String, Object?> stateToJson(WarState s) => {
    'decks': s.decks,
    'table': [
      for (final cards in s.table) [for (final (card, up) in cards) [card, up]],
    ],
    'contenders': s.contenders,
    'flipped': s.flipped,
    'warDepth': s.warDepth,
    'battleWinner': s.battleWinner,
    'round': s.round,
    'maxRounds': s.maxRounds,
    'out': s.out,
    'lowest': s.lowest,
    'doubleWar': s.doubleWar,
    'wars': s.wars,
    'over': s.over,
  };

  static List<int> _ints(Object? list) => [for (final v in list! as List) v as int];

  @override
  WarState stateFromJson(Map<String, Object?> j) => WarState(
    decks: [for (final d in j['decks']! as List) _ints(d)],
    table: [
      for (final cards in j['table']! as List) [for (final c in cards as List) ((c as List)[0] as int, c[1] == true)],
    ],
    contenders: _ints(j['contenders']),
    flipped: _ints(j['flipped']),
    warDepth: j['warDepth']! as int,
    battleWinner: j['battleWinner'] as int?,
    round: j['round']! as int,
    maxRounds: j['maxRounds']! as int,
    out: [for (final g in j['out']! as List) _ints(g)],
    lowest: _ints(j['lowest']),
    doubleWar: [for (final b in j['doubleWar']! as List) b == true],
    wars: j['wars']! as int,
    over: j['over'] == true,
  );
}
