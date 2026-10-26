import 'dart:math';

import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/move.dart';
import '../../core/game/seeded_random.dart';
import 'ludo_rules.dart';

/// Robots of Člověče (spec 13.8): Lehká moves a random piece, Střední follows
/// priorities, Těžká weighs danger and progress one roll ahead (expectimax).
class LudoAi implements AiPlayer<LudoState> {
  const LudoAi();

  static const _rules = LudoRules();

  @override
  Move chooseMove(LudoState state, int seat, Difficulty difficulty, SeededRandom random) {
    if (state.phase == LudoPhase.roll) return Move(seat: seat, type: 'roll');
    final options = LudoRules.currentSteps(state);
    final step = switch (difficulty) {
      _ when options.length == 1 => options.single,
      Difficulty.easy => options[random.nextInt(options.length)],
      Difficulty.medium => _byPriority(state, seat, options),
      Difficulty.hard => _expectimax(state, seat, options, random),
    };
    return Move(seat: seat, type: 'move', data: {'piece': step.piece});
  }

  /// Capture → into the home → escape a threat → move the foremost piece
  /// that stays safe → enter. Spec 13.8 lists "enter" second and "the
  /// rearmost" last, but measured that way Střední lost to Lehká (22 %):
  /// with three tries to roll a six, an early piece on the ring only costs.
  static LudoStep _byPriority(LudoState s, int seat, List<LudoStep> options) {
    final capture = options.where((m) => m.captures != null).firstOrNull;
    if (capture != null) return capture;
    final home = options.where((m) => LudoPos.inHome(m.to) && !LudoPos.inHome(m.from)).firstOrNull;
    if (home != null) return home;
    final escape = options.where((m) => threatened(s, seat, m.from) && !_threatenedAfter(s, seat, m)).firstOrNull;
    if (escape != null) return escape;
    final ring = options.where((m) => LudoPos.onRing(m.from)).toList()..sort((a, b) => b.from.compareTo(a.from));
    return ring.where((m) => !_threatenedAfter(s, seat, m)).firstOrNull ?? ring.firstOrNull ?? options.first;
  }

  static bool _threatenedAfter(LudoState s, int seat, LudoStep m) {
    final pieces = [for (final p in s.pieces) [...p]];
    pieces[seat][m.piece] = m.to;
    return threatened(s.copyWith(pieces: pieces), seat, m.to);
  }

  /// How many opponent pieces could land on [seat]'s piece at [pos] with
  /// their next roll (a piece in the corner enters on its start field).
  static int threats(LudoState s, int seat, int pos) {
    final field = LudoRules.ringField(s, seat, pos);
    if (field == null) return 0;
    var n = 0;
    for (var other = 0; other < s.seats; other++) {
      if (other == seat) continue;
      for (final p in s.pieces[other]) {
        if (p == LudoPos.base) {
          if (LudoRules.ringField(s, other, 0) == field) n++;
          continue;
        }
        if (!LudoPos.onRing(p)) continue;
        for (var d = 1; d <= 6 && p + d < LudoPos.ringLength; d++) {
          if (LudoRules.ringField(s, other, p + d) == field) n++;
        }
      }
    }
    return n;
  }

  static bool threatened(LudoState s, int seat, int pos) => threats(s, seat, pos) > 0;

  /// The value of [s] for [seat]: progress of the pieces minus what danger
  /// may cost, against the best opponent.
  static double evaluate(LudoState s, int seat) {
    double own(int who) {
      if (s.finished.contains(who)) return 1000.0 - s.finished.indexOf(who);
      var v = 0.0;
      for (final p in s.pieces[who]) {
        if (p == LudoPos.base) continue;
        if (LudoPos.inHome(p)) {
          v += 70 + (p - LudoPos.ringLength) * 2;
          continue;
        }
        final worth = 12.0 + p;
        v += worth - worth * min(1, threats(s, who, p) / 6);
      }
      return v;
    }

    var best = 0.0;
    for (var other = 0; other < s.seats; other++) {
      if (other != seat) best = max(best, own(other));
    }
    return own(seat) - 0.6 * best;
  }

  static LudoStep _expectimax(LudoState s, int seat, List<LudoStep> options, SeededRandom random) {
    LudoStep? choice;
    var best = double.negativeInfinity;
    for (final m in options) {
      final after = _rules.apply(s, Move(seat: seat, type: 'move', data: {'piece': m.piece}));
      // A tiny random tie-break keeps equal moves from always picking piece 0.
      final value = _chance(after, seat) + random.nextDouble() * 1e-6;
      if (value > best) {
        best = value;
        choice = m;
      }
    }
    return choice!;
  }

  /// Averages over the next roll: whoever is to move picks their best piece.
  static double _chance(LudoState s, int seat) {
    if (_rules.isOver(s)) return evaluate(s, seat);
    var sum = 0.0;
    for (var d = 1; d <= 6; d++) {
      final rolled = _rules.rollWith(s, d);
      if (rolled.phase != LudoPhase.move || rolled.current != s.current) {
        sum += evaluate(rolled, seat);
        continue;
      }
      final mover = rolled.current;
      LudoState? pick;
      var pickValue = double.negativeInfinity;
      for (final m in LudoRules.currentSteps(rolled)) {
        final next = _rules.apply(rolled, Move(seat: mover, type: 'move', data: {'piece': m.piece}));
        final v = evaluate(next, mover);
        if (v > pickValue) {
          pickValue = v;
          pick = next;
        }
      }
      sum += evaluate(pick!, seat);
    }
    return sum / 6;
  }
}
