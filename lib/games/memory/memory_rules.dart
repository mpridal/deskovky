import 'package:flutter/foundation.dart';

import '../../core/game/difficulty.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'memory_cards.dart';

/// A running game of Pexeso. Cards are positions 0..n-1 in reading order;
/// [faces] holds the motif at each position, [owner] the seat that found it.
@immutable
class MemoryState {
  const MemoryState({
    required this.seed,
    required this.set,
    required this.difficulty,
    required this.faces,
    required this.owner,
    required this.open,
    required this.current,
    required this.reveals,
    required this.turns,
    required this.misses,
    required this.mistakes,
    required this.bestStreak,
    required this.streak,
    required this.miss,
    required this.swap,
    required this.swaps,
    required this.known,
    required this.timeMs,
  });

  final int seed;
  final String set;

  /// Robot memory with robots; preview / plain / swaps for one player.
  final Difficulty difficulty;
  final List<int> faces;
  final List<int?> owner;

  /// The card turned up in this turn so far (empty or one).
  final List<int> open;
  final int current;

  /// Every card ever turned up, in order (two per turn): what robots may
  /// remember (spec 13.6) and the turn count.
  final List<int> reveals;

  /// Per seat: finished turns, misses, memory mistakes, most pairs in one turn.
  final List<int> turns;
  final List<int> misses;
  final List<int> mistakes;
  final List<int> bestStreak;

  /// Pairs found by the current player in this turn.
  final int streak;

  /// The two cards of the last miss, shown for a moment before they turn
  /// back (empty after the next flip).
  final List<int> miss;

  /// The two face-down cards swapped after the last fourth miss (one player,
  /// hard) and how many swaps there were, so the board animates each once.
  final List<int> swap;
  final int swaps;

  /// Positions whose picture was seen since they last moved (for mistakes).
  final List<bool> known;

  /// Playing time when the last move was made (the board sends it).
  final int timeMs;

  int get seats => turns.length;
  int get cards => faces.length;
  int get pairs => faces.length ~/ 2;
  bool get solo => seats == 1;
  int get pairsLeft => owner.where((o) => o == null).length ~/ 2;
  int pairsOf(int seat) => owner.where((o) => o == seat).length ~/ 2;

  /// Easy game for one player: all cards are shown for 2 s at the start.
  bool get preview => solo && difficulty == Difficulty.easy;

  /// Hard game for one player: two cards swap after every fourth miss.
  bool get swapping => solo && difficulty == Difficulty.hard;

  MemoryState copyWith({
    List<int>? faces,
    List<int?>? owner,
    List<int>? open,
    int? current,
    List<int>? reveals,
    List<int>? turns,
    List<int>? misses,
    List<int>? mistakes,
    List<int>? bestStreak,
    int? streak,
    List<int>? miss,
    List<int>? swap,
    int? swaps,
    List<bool>? known,
    int? timeMs,
  }) => MemoryState(
    seed: seed,
    set: set,
    difficulty: difficulty,
    faces: faces ?? this.faces,
    owner: owner ?? this.owner,
    open: open ?? this.open,
    current: current ?? this.current,
    reveals: reveals ?? this.reveals,
    turns: turns ?? this.turns,
    misses: misses ?? this.misses,
    mistakes: mistakes ?? this.mistakes,
    bestStreak: bestStreak ?? this.bestStreak,
    streak: streak ?? this.streak,
    miss: miss ?? this.miss,
    swap: swap ?? this.swap,
    swaps: swaps ?? this.swaps,
    known: known ?? this.known,
    timeMs: timeMs ?? this.timeMs,
  );
}

/// Pexeso (spec 13.6): turn over two cards; a pair stays with you and you go
/// again, a miss passes the turn. Most pairs wins; alone, as few turns as you can.
class MemoryRules implements GameRules<MemoryState> {
  const MemoryRules();

  static const cardCounts = [12, 16, 24, 36, 48];
  static const defaultCards = 16;

  /// One player on hard: two cards swap after every this many misses.
  static const swapEvery = 4;

  @override
  MemoryState initialState(GameConfig config, int seed) {
    final rawCards = config.options['cards'];
    final cards = cardCounts.contains(rawCards) ? rawCards! as int : defaultCards;
    final rawSet = config.options['set'];
    final set = memorySets.containsKey(rawSet) ? rawSet! as String : memoryDefaultSet;
    final random = SeededRandom(seed);
    final motifs = _shuffled(List.generate(memoryMotifs, (i) => i), random).take(cards ~/ 2);
    final faces = _shuffled([...motifs, ...motifs], random);
    final seats = config.seats.length;
    return MemoryState(
      seed: seed,
      set: set,
      difficulty: config.difficulty,
      faces: faces,
      owner: List.filled(cards, null),
      open: const [],
      current: 0,
      reveals: const [],
      turns: List.filled(seats, 0),
      misses: List.filled(seats, 0),
      mistakes: List.filled(seats, 0),
      bestStreak: List.filled(seats, 0),
      streak: 0,
      miss: const [],
      swap: const [],
      swaps: 0,
      known: List.filled(cards, false),
      timeMs: 0,
    );
  }

  static List<int> _shuffled(List<int> list, SeededRandom random) {
    final out = List.of(list);
    for (var i = out.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = out[i];
      out[i] = out[j];
      out[j] = t;
    }
    return out;
  }

  static Move flip(int seat, int card, {int? timeMs}) =>
      Move(seat: seat, type: 'flip', data: {'card': card, 't': ?timeMs});

  @override
  int? currentSeat(MemoryState state) => isOver(state) ? null : state.current;

  @override
  List<Move> legalMoves(MemoryState state, int seat) => [
    if (!isOver(state) && seat == state.current)
      for (var c = 0; c < state.cards; c++)
        if (state.owner[c] == null && !state.open.contains(c)) flip(seat, c),
  ];

  @override
  bool isLegal(MemoryState state, Move move) {
    final card = move.data['card'];
    final t = move.data['t'];
    return !isOver(state) &&
        move.type == 'flip' &&
        move.seat == state.current &&
        card is int &&
        card >= 0 &&
        card < state.cards &&
        state.owner[card] == null &&
        !state.open.contains(card) &&
        (t == null || (t is int && t >= 0));
  }

  @override
  MemoryState apply(MemoryState state, Move move) {
    final card = move.data['card']! as int;
    final t = move.data['t'];
    final s = state.copyWith(reveals: [...state.reveals, card], miss: const [], timeMs: t is int ? t : null);
    if (s.open.isEmpty) return s.copyWith(open: [card]);

    final a = s.open.single;
    final seat = s.current;
    final turns = _inc(s.turns, seat);
    final known = List.of(s.known);
    if (s.faces[a] == s.faces[card]) {
      final owner = List.of(s.owner)
        ..[a] = seat
        ..[card] = seat;
      final streak = s.streak + 1;
      return s.copyWith(
        owner: owner,
        open: const [],
        turns: turns,
        streak: streak,
        bestStreak: [
          for (var i = 0; i < s.seats; i++) i == seat && streak > s.bestStreak[i] ? streak : s.bestStreak[i],
        ],
        known: known
          ..[a] = true
          ..[card] = true,
      );
    }

    // A memory mistake: the partner of the first card was seen already, or
    // the second card was a known one that cannot match.
    final partner = _partner(s, a);
    final mistake = (partner != null && s.known[partner]) || s.known[card];
    known
      ..[a] = true
      ..[card] = true;
    var next = s.copyWith(
      open: const [],
      current: (seat + 1) % s.seats,
      turns: turns,
      misses: _inc(s.misses, seat),
      mistakes: mistake ? _inc(s.mistakes, seat) : null,
      streak: 0,
      miss: [a, card],
      known: known,
    );
    if (next.swapping && next.misses[seat] % swapEvery == 0) next = _swap(next, a, card);
    return next;
  }

  /// Swaps two face-down cards other than the miss just shown, with
  /// different pictures (spec 13.6, one player on hard).
  static MemoryState _swap(MemoryState s, int a, int b) {
    final candidates = [
      for (var c = 0; c < s.cards; c++)
        if (s.owner[c] == null && c != a && c != b) c,
    ];
    final random = SeededRandom(s.seed ^ (s.misses.first * 7919 + 13));
    if (candidates.length < 2) return s;
    final i = candidates[random.nextInt(candidates.length)];
    final others = [
      for (final c in candidates)
        if (s.faces[c] != s.faces[i]) c,
    ];
    if (others.isEmpty) return s;
    final j = others[random.nextInt(others.length)];
    final faces = List.of(s.faces)
      ..[i] = s.faces[j]
      ..[j] = s.faces[i];
    final known = List.of(s.known)
      ..[i] = false
      ..[j] = false;
    return s.copyWith(faces: faces, known: known, swap: [i, j], swaps: s.swaps + 1);
  }

  static int? _partner(MemoryState s, int card) {
    for (var c = 0; c < s.cards; c++) {
      if (c != card && s.owner[c] == null && s.faces[c] == s.faces[card]) return c;
    }
    return null;
  }

  static List<int> _inc(List<int> list, int i) => [
    for (var k = 0; k < list.length; k++) k == i ? list[k] + 1 : list[k],
  ];

  @override
  bool isOver(MemoryState state) => state.owner.every((o) => o != null);

  @override
  int score(MemoryState state, int seat) => state.pairsOf(seat);

  /// Stars of one player (spec 13.6): turns ≤ 1.5 × pairs ★★★, ≤ 2 × ★★, else ★.
  static int soloStars(int turns, int pairs) => turns * 2 <= pairs * 3 ? 3 : (turns <= pairs * 2 ? 2 : 1);

  @override
  GameResult result(MemoryState state) {
    final n = state.seats;
    final pairs = [for (var s = 0; s < n; s++) state.pairsOf(s)];
    // Equal pairs share a place (1, 1, 3, …).
    final places = [for (var s = 0; s < n; s++) 1 + pairs.where((p) => p > pairs[s]).length];
    return GameResult(
      places: places,
      scores: pairs,
      stars: [
        for (var s = 0; s < n; s++)
          if (state.solo)
            soloStars(state.turns[s], state.pairs)
          else
            switch (places[s]) {
              1 => 3,
              2 => 2,
              _ => 1,
            },
      ],
      stats: {
        'cards': state.cards,
        'turns': state.turns,
        'misses': state.misses,
        'mistakes': state.mistakes,
        'bestStreak': state.bestStreak,
        'timeMs': state.timeMs,
      },
    );
  }

  /// Badge events right after [move] turned [before] into [after]
  /// (spec 13.6); the board reports them before it submits a person's move.
  static List<(String, Map<String, Object?>)> eventsAfter(MemoryState before, Move move, MemoryState after) {
    final seat = move.seat;
    final matched = before.open.isNotEmpty && after.pairsOf(seat) > before.pairsOf(seat);
    return [
      if (matched) ('memory.pairs', {'seat': seat, 'count': 1}),
      if (matched && after.streak == streakBadge) ('memory.streak', {'seat': seat}),
      if (after.solo &&
          after.cards == speedCards &&
          const MemoryRules().isOver(after) &&
          after.timeMs > 0 &&
          after.timeMs < speedMs)
        ('memory.speed', {'seat': seat}),
    ];
  }

  static const streakBadge = 5;
  static const speedCards = 16;
  static const speedMs = 40000;
  static const elephantCards = 16;

  /// Seats that kept every picture in mind (no memory mistake) once the
  /// last pair is all that is left: then no more mistakes are possible.
  /// With others it also takes at least half of the game's pairs, so a
  /// lucky turn or two is not enough.
  static List<int> elephants(MemoryState state) => [
    if (state.cards >= elephantCards && state.pairsLeft <= 1)
      for (var s = 0; s < state.seats; s++)
        if (state.mistakes[s] == 0 && state.turns[s] > 0 && (state.solo || state.pairsOf(s) * 2 >= state.pairs)) s,
  ];

  @override
  Map<String, Object?> stateToJson(MemoryState s) => {
    'seed': s.seed,
    'set': s.set,
    'difficulty': s.difficulty.name,
    'faces': s.faces,
    'owner': s.owner,
    'open': s.open,
    'current': s.current,
    'reveals': s.reveals,
    'turns': s.turns,
    'misses': s.misses,
    'mistakes': s.mistakes,
    'bestStreak': s.bestStreak,
    'streak': s.streak,
    'miss': s.miss,
    'swap': s.swap,
    'swaps': s.swaps,
    'known': s.known,
    'timeMs': s.timeMs,
  };

  @override
  MemoryState stateFromJson(Map<String, Object?> j) {
    List<int> ints(String key) => [for (final v in j[key]! as List) v as int];
    return MemoryState(
      seed: j['seed']! as int,
      set: j['set']! as String,
      difficulty: Difficulty.values.byName(j['difficulty']! as String),
      faces: ints('faces'),
      owner: [for (final v in j['owner']! as List) v as int?],
      open: ints('open'),
      current: j['current']! as int,
      reveals: ints('reveals'),
      turns: ints('turns'),
      misses: ints('misses'),
      mistakes: ints('mistakes'),
      bestStreak: ints('bestStreak'),
      streak: j['streak']! as int,
      miss: ints('miss'),
      swap: ints('swap'),
      swaps: j['swaps']! as int,
      known: [for (final v in j['known']! as List) v as bool],
      timeMs: j['timeMs']! as int,
    );
  }
}
