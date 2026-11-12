import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'ships_rules.dart';

/// What a seat knows about the sea it shoots at: its misses and hits, and
/// the ships it has sunk (shown whole). Never where the other ships lie.
class ShipsSight {
  ShipsSight(ShipsState s, int seat) : size = s.size, open = ShipsRules.openCells(s, seat).toSet() {
    final enemy = ShipsState.other(seat);
    final sunk = s.sunkShips(enemy);
    for (final i in sunk) {
      sunkCells.addAll(s.ships[enemy]![i].cells(size));
    }
    for (final c in s.shots[seat]) {
      if (!s.isHit(seat, c)) {
        blocked.add(c);
      } else if (!sunkCells.contains(c)) {
        hits.add(c);
      }
    }
    blocked
      ..addAll(sunkCells)
      ..addAll(s.knownWater(seat));
    remaining = [
      for (final (i, length) in s.fleet.indexed)
        if (!sunk.contains(i)) length,
    ];
  }

  final int size;

  /// Cells it may shoot.
  final Set<int> open;

  /// Hits on ships not yet sunk.
  final Set<int> hits = {};

  /// Cells no unsunk ship can use: misses, known water, sunk ships.
  final Set<int> blocked = {};
  final Set<int> sunkCells = {};
  late final List<int> remaining;

  List<int> neighbours(int cell) {
    final x = cell % size, y = cell ~/ size;
    return [
      if (y > 0) cell - size,
      if (x > 0) cell - 1,
      if (x < size - 1) cell + 1,
      if (y < size - 1) cell + size,
    ];
  }
}

/// The robot of Lodě (design `docs/superpowers/specs/2026-11-12-lode-design.md`):
/// Lehká shoots at random and only half the time follows up a hit, Střední
/// hunts on a chequerboard and finishes ships it has hit, Těžká shoots
/// where the remaining ships most likely lie.
class ShipsAi implements AiPlayer<ShipsState> {
  const ShipsAi();

  @override
  Move chooseMove(ShipsState state, int seat, Difficulty difficulty, SeededRandom random) {
    if (state.ships[seat] == null) return ShipsRules.place(seat, ShipsRules.randomFleet(state.size, state.fleet, random));
    final sight = ShipsSight(state, seat);
    final cell = switch (difficulty) {
      Difficulty.easy => _easy(sight, random),
      Difficulty.medium => _medium(sight, random),
      Difficulty.hard => _hard(sight, random),
    };
    return ShipsRules.shoot(seat, cell);
  }

  static int _pick(Iterable<int> cells, SeededRandom random) {
    final list = cells.toList()..sort();
    return list[random.nextInt(list.length)];
  }

  /// Open cells next to unsunk hits; along the line when two or more of
  /// them lie in a row.
  static List<int> _targets(ShipsSight s) {
    final next = {
      for (final h in s.hits)
        for (final n in s.neighbours(h))
          if (s.open.contains(n)) n,
    };
    final size = s.size;
    for (final h in s.hits) {
      for (final step in [1, size]) {
        if (!s.hits.contains(h + step) || (step == 1 && (h + 1) % size == 0)) continue;
        // A line of hits through h: shoot at its ends.
        var a = h, b = h + step;
        while (s.hits.contains(a - step) && (step == size || a % size != 0)) {
          a -= step;
        }
        while (s.hits.contains(b + step) && (step == size || (b + 1) % size != 0)) {
          b += step;
        }
        final ends = [
          if (step == size || a % size != 0) a - step,
          if (step == size || (b + 1) % size != 0) b + step,
        ].where(s.open.contains).toList();
        if (ends.isNotEmpty) return ends;
      }
    }
    return next.toList();
  }

  int _easy(ShipsSight s, SeededRandom random) {
    if (s.hits.isNotEmpty && random.nextInt(2) == 0) {
      final near = {
        for (final h in s.hits)
          for (final n in s.neighbours(h))
            if (s.open.contains(n)) n,
      };
      if (near.isNotEmpty) return _pick(near, random);
    }
    return _pick(s.open, random);
  }

  int _medium(ShipsSight s, SeededRandom random) {
    final targets = _targets(s);
    if (targets.isNotEmpty) return _pick(targets, random);
    final even = [
      for (final c in s.open)
        if ((c % s.size + c ~/ s.size).isEven) c,
    ];
    return _pick(even.isEmpty ? s.open : even, random);
  }

  /// Counts for every open cell the ways a remaining ship can cover it;
  /// with hits waiting, only ships through them count, the more hits the more.
  int _hard(ShipsSight s, SeededRandom random) {
    final size = s.size;
    final weight = <int, int>{};
    final hunting = s.hits.isNotEmpty;
    for (final length in s.remaining) {
      for (var y = 0; y < size; y++) {
        for (var x = 0; x < size; x++) {
          for (final horizontal in [true, false]) {
            if ((horizontal ? x : y) + length > size) continue;
            final cells = [for (var i = 0; i < length; i++) horizontal ? y * size + x + i : (y + i) * size + x];
            if (cells.any(s.blocked.contains)) continue;
            final covered = cells.where(s.hits.contains).length;
            if (hunting && covered == 0) continue;
            final w = hunting ? covered * covered : 1;
            for (final c in cells) {
              if (s.open.contains(c)) weight[c] = (weight[c] ?? 0) + w;
            }
          }
        }
      }
    }
    if (weight.isEmpty) return _medium(s, random);
    final best = weight.values.reduce((a, b) => a > b ? a : b);
    return _pick([
      for (final MapEntry(:key, :value) in weight.entries)
        if (value == best) key,
    ], random);
  }
}
