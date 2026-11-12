import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';

/// Option `size`: the 8 × 8 sea (fleet 4 3 3 2) or the classic 10 × 10
/// (fleet 5 4 3 3 2).
abstract final class ShipsSize {
  static const small = '8';
  static const big = '10';

  static (int, List<int>) of(Object? value) => value == big ? (10, const [5, 4, 3, 3, 2]) : (8, const [4, 3, 3, 2]);
}

/// Option `bonus`: after a hit the shooter goes again, or the turn passes
/// after every shot.
abstract final class ShipsBonus {
  static const again = 'again';
  static const alternate = 'alternate';
}

/// A straight ship: its first cell at column [x], row [y], running right
/// ([horizontal]) or down.
@immutable
class Ship {
  const Ship(this.x, this.y, this.length, this.horizontal);

  final int x;
  final int y;
  final int length;
  final bool horizontal;

  /// Its cells as `(column, row)`.
  List<(int, int)> get points => [
    for (var i = 0; i < length; i++) horizontal ? (x + i, y) : (x, y + i),
  ];

  /// Its cells as indexes `row * size + column`.
  List<int> cells(int size) => [for (final (c, r) in points) r * size + c];

  Ship moved(int x, int y) => Ship(x, y, length, horizontal);
  Ship turned() => Ship(x, y, length, !horizontal);

  @override
  bool operator ==(Object other) =>
      other is Ship && other.x == x && other.y == y && other.length == length && other.horizontal == horizontal;

  @override
  int get hashCode => Object.hash(x, y, length, horizontal);

  @override
  String toString() => 'Ship($x, $y, $length, ${horizontal ? 'h' : 'v'})';
}

/// One game of Lodě: two seas of [size] × [size]. Each seat first places
/// its fleet ([ships], null until placed), then the seats shoot at each
/// other's sea; [shots] are the cells a seat has shot at on the other sea.
@immutable
class ShipsState {
  const ShipsState({
    required this.size,
    required this.fleet,
    required this.again,
    required this.ships,
    required this.shots,
    required this.turn,
  });

  final int size;
  final List<int> fleet;

  /// A hit shoots again.
  final bool again;
  final List<List<Ship>?> ships;
  final List<List<int>> shots;

  /// The seat to shoot once both fleets are placed.
  final int turn;

  int get seats => 2;
  bool get placing => ships.any((f) => f == null);

  static int other(int seat) => 1 - seat;

  /// The fleet [seat] shoots at.
  List<Ship> target(int seat) => ships[other(seat)]!;

  bool isHit(int seat, int cell) => !placing && target(seat).any((ship) => ship.cells(size).contains(cell));

  /// Cells [seat] has hit.
  List<int> hits(int seat) => [
    for (final c in shots[seat])
      if (isHit(seat, c)) c,
  ];

  /// Indexes of [seat]'s ships the other seat has sunk.
  List<int> sunkShips(int seat) {
    final fleetOf = ships[seat];
    if (fleetOf == null) return const [];
    final shot = shots[other(seat)].toSet();
    return [
      for (final (i, ship) in fleetOf.indexed)
        if (ship.cells(size).every(shot.contains)) i,
    ];
  }

  /// Cells next to the ships [seat] has sunk that it has not shot: there
  /// can be no ship there.
  Set<int> knownWater(int seat) {
    if (placing) return const {};
    final enemy = other(seat);
    final shot = shots[seat].toSet();
    final water = <int>{};
    for (final i in sunkShips(enemy)) {
      for (final (c, r) in ships[enemy]![i].points) {
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final x = c + dx, y = r + dy;
            if (x < 0 || y < 0 || x >= size || y >= size) continue;
            final cell = y * size + x;
            if (!shot.contains(cell)) water.add(cell);
          }
        }
      }
    }
    return water;
  }

  int get shipCells => fleet.fold(0, (a, b) => a + b);

  /// The seat that sank the whole other fleet, if any.
  int? get winner {
    if (placing) return null;
    for (var seat = 0; seat < 2; seat++) {
      if (hits(seat).length == shipCells) return seat;
    }
    return null;
  }

  bool get over => winner != null;

  ShipsState copyWith({List<List<Ship>?>? ships, List<List<int>>? shots, int? turn}) => ShipsState(
    size: size,
    fleet: fleet,
    again: again,
    ships: ships ?? this.ships,
    shots: shots ?? this.shots,
    turn: turn ?? this.turn,
  );
}

/// Rules of Lodě (design `docs/superpowers/specs/2026-11-12-lode-design.md`).
class ShipsRules implements GameRules<ShipsState> {
  const ShipsRules();

  /// Places [seat]'s fleet; the ships travel as text `x,y,h;…` in fleet order.
  static Move place(int seat, List<Ship> ships) =>
      Move(seat: seat, type: 'place', data: {'ships': [for (final s in ships) '${s.x},${s.y},${s.horizontal ? 'h' : 'v'}'].join(';')});

  static Move shoot(int seat, int cell) => Move(seat: seat, type: 'shoot', data: {'cell': cell});

  /// The ships of a `place` move's text, or null when it is not one fleet.
  static List<Ship>? parseFleet(Object? text, List<int> fleet) {
    if (text is! String) return null;
    final parts = text.split(';');
    if (parts.length != fleet.length) return null;
    final ships = <Ship>[];
    for (final (i, part) in parts.indexed) {
      final f = part.split(',');
      if (f.length != 3 || (f[2] != 'h' && f[2] != 'v')) return null;
      final x = int.tryParse(f[0]), y = int.tryParse(f[1]);
      if (x == null || y == null) return null;
      ships.add(Ship(x, y, fleet[i], f[2] == 'h'));
    }
    return ships;
  }

  /// The ships fit the fleet's lengths, lie at sea and never touch, not
  /// even by a corner.
  static bool validFleet(int size, List<int> fleet, List<Ship> ships) {
    if (ships.length != fleet.length) return false;
    final taken = <(int, int)>{};
    for (final (i, ship) in ships.indexed) {
      if (ship.length != fleet[i]) return false;
      for (final (c, r) in ship.points) {
        if (c < 0 || r < 0 || c >= size || r >= size) return false;
      }
    }
    for (final ship in ships) {
      for (final (c, r) in ship.points) {
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (taken.contains((c + dx, r + dy))) return false;
          }
        }
      }
      taken.addAll(ship.points);
    }
    return true;
  }

  /// A random legal fleet: the longest ships first, each at a random free
  /// spot; on a dead end it starts again.
  static List<Ship> randomFleet(int size, List<int> fleet, SeededRandom random) {
    while (true) {
      final ships = <Ship>[];
      for (final length in fleet) {
        Ship? found;
        for (var attempt = 0; attempt < 200 && found == null; attempt++) {
          final horizontal = random.nextInt(2) == 0;
          final span = size - length + 1;
          final ship = horizontal
              ? Ship(random.nextInt(span), random.nextInt(size), length, true)
              : Ship(random.nextInt(size), random.nextInt(span), length, false);
          if (validFleet(size, fleet.sublist(0, ships.length + 1), [...ships, ship])) found = ship;
        }
        if (found == null) break;
        ships.add(found);
      }
      if (ships.length == fleet.length) return ships;
    }
  }

  @override
  ShipsState initialState(GameConfig config, int seed) {
    final (size, fleet) = ShipsSize.of(config.options['size']);
    return ShipsState(
      size: size,
      fleet: fleet,
      again: config.options['bonus'] != ShipsBonus.alternate,
      ships: const [null, null],
      shots: const [[], []],
      turn: 0,
    );
  }

  @override
  int? currentSeat(ShipsState state) {
    if (state.ships[0] == null) return 0;
    if (state.ships[1] == null) return 1;
    return state.over ? null : state.turn;
  }

  /// Cells [seat] may still shoot at.
  static List<int> openCells(ShipsState s, int seat) {
    final shot = s.shots[seat].toSet();
    final water = s.knownWater(seat);
    return [
      for (var c = 0; c < s.size * s.size; c++)
        if (!shot.contains(c) && !water.contains(c)) c,
    ];
  }

  @override
  List<Move> legalMoves(ShipsState state, int seat) {
    if (currentSeat(state) != seat) return const [];
    // Placing: one ready fleet stands for all the fleets a seat could place.
    if (state.ships[seat] == null) return [place(seat, randomFleet(state.size, state.fleet, SeededRandom(seat + 1)))];
    return [for (final c in openCells(state, seat)) shoot(seat, c)];
  }

  @override
  bool isLegal(ShipsState state, Move move) {
    if (currentSeat(state) != move.seat) return false;
    if (state.ships[move.seat] == null) {
      if (move.type != 'place') return false;
      final ships = parseFleet(move.data['ships'], state.fleet);
      return ships != null && validFleet(state.size, state.fleet, ships);
    }
    final cell = move.data['cell'];
    return move.type == 'shoot' && cell is int && openCells(state, move.seat).contains(cell);
  }

  @override
  ShipsState apply(ShipsState state, Move move) {
    final seat = move.seat;
    if (move.type == 'place') {
      return state.copyWith(ships: List.of(state.ships)..[seat] = parseFleet(move.data['ships'], state.fleet));
    }
    final cell = move.data['cell']! as int;
    final next = state.copyWith(shots: List.of(state.shots)..[seat] = [...state.shots[seat], cell]);
    final hit = next.isHit(seat, cell);
    return next.copyWith(turn: hit && state.again ? seat : ShipsState.other(seat));
  }

  @override
  bool isOver(ShipsState state) => state.over;

  /// Cells hit so far.
  @override
  int score(ShipsState state, int seat) => state.placing ? 0 : state.hits(seat).length;

  /// ★★★ the winner; ★★ a loser who hit at least half the ship cells; ★ else.
  static int stars(ShipsState s, int seat) {
    if (s.winner == seat) return 3;
    return s.hits(seat).length * 2 >= s.shipCells ? 2 : 1;
  }

  @override
  GameResult result(ShipsState state) {
    final winner = state.winner;
    return GameResult(
      places: [for (var s = 0; s < 2; s++) winner == null || winner == s ? 1 : 2],
      scores: [for (var s = 0; s < 2; s++) score(state, s)],
      stars: [for (var s = 0; s < 2; s++) stars(state, s)],
      stats: {
        'shots': [for (var s = 0; s < 2; s++) state.shots[s].length],
        'hits': [for (var s = 0; s < 2; s++) score(state, s)],
      },
    );
  }

  @override
  Map<String, Object?> stateToJson(ShipsState s) => {
    'size': s.size,
    'fleet': s.fleet,
    'again': s.again,
    'ships': [for (var seat = 0; seat < 2; seat++) s.ships[seat] == null ? null : place(seat, s.ships[seat]!).data['ships']],
    'shots': s.shots,
    'turn': s.turn,
  };

  static List<int> _ints(Object? list) => [for (final v in list! as List) v as int];

  @override
  ShipsState stateFromJson(Map<String, Object?> j) {
    final fleet = _ints(j['fleet']);
    return ShipsState(
      size: j['size']! as int,
      fleet: fleet,
      again: j['again'] == true,
      ships: [for (final f in j['ships']! as List) f == null ? null : parseFleet(f, fleet)],
      shots: [for (final s in j['shots']! as List) _ints(s)],
      turn: j['turn']! as int,
    );
  }
}
