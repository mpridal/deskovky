import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/game_kit/game_search.dart';
import 'package:flutter_test/flutter_test.dart';

/// 3×3 tic-tac-toe: 9 cells (-1 empty, 0 or 1 a player), seat 0 starts.
typedef _Board = List<int>;

const _lines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6], //
];

int? _winner(_Board b) {
  for (final l in _lines) {
    if (b[l[0]] >= 0 && b[l[0]] == b[l[1]] && b[l[1]] == b[l[2]]) return b[l[0]];
  }
  return null;
}

int _toMove(_Board b) => b.where((c) => c >= 0).length.isEven ? 0 : 1;
bool _over(_Board b) => _winner(b) != null || !b.contains(-1);

final _ttt = GameSearch<_Board>(
  moves: (b) => _over(b) ? const [] : [for (var i = 0; i < 9; i++) if (b[i] < 0) Move(seat: _toMove(b), type: 'place', data: {'i': i})],
  apply: (b, m) => [...b]..[m.data['i']! as int] = m.seat,
  currentSeat: (b) => _over(b) ? null : _toMove(b),
  evaluate: (b, seat) => switch (_winner(b)) {
    null => 0,
    final w => w == seat ? 1000 : -1000,
  },
);

_Board _parse(String s) => [for (final ch in s.split('')) ch == 'x' ? 0 : (ch == 'o' ? 1 : -1)];

/// A game where every position has 10 moves and nothing ever ends: only
/// the time limit stops the search.
final _endless = GameSearch<int>(
  moves: (n) => [for (var i = 0; i < 10; i++) Move(seat: n.isEven ? 0 : 1, type: 'step', data: {'i': i})],
  apply: (n, m) => n + 1,
  currentSeat: (n) => n.isEven ? 0 : 1,
  evaluate: (n, seat) => 0,
);

void main() {
  test('takes a win in one move', () {
    // x x .
    // o o .
    // . . .
    final move = _ttt.best(_parse('xx.oo....'), 0, maxDepth: 4);
    expect(move!.data['i'], 2);
  });

  test('blocks the opponent when it cannot win itself', () {
    // x . .
    // o o .
    // x . .   – x to move must block at 5
    final move = _ttt.best(_parse('x..oo.x..'), 0, maxDepth: 4);
    expect(move!.data['i'], 5);
  });

  test('perfect play from the empty board never loses (draw value 0)', () {
    var board = _parse('.........');
    while (!_over(board)) {
      board = _ttt.apply(board, _ttt.best(board, _toMove(board), maxDepth: 9, timeLimit: const Duration(seconds: 10))!);
    }
    expect(_winner(board), isNull);
  });

  test('keeps the time limit even when asked for depth 20', () {
    final watch = Stopwatch()..start();
    final move = _endless.best(0, 0, maxDepth: 20, timeLimit: const Duration(milliseconds: 50));
    expect(move, isNotNull);
    expect(watch.elapsedMilliseconds, lessThan(250));
  });

  test('a position without moves gives null', () {
    expect(_ttt.best(_parse('xoxxoooxx'), 0), isNull);
  });

  test('equal moves are broken by the seeded random, deterministically', () {
    final a = _endless.best(0, 0, maxDepth: 1, tieBreak: SeededRandom(7));
    final b = _endless.best(0, 0, maxDepth: 1, tieBreak: SeededRandom(7));
    final others = {for (var s = 0; s < 20; s++) _endless.best(0, 0, maxDepth: 1, tieBreak: SeededRandom(s))!.data['i']};
    expect(a, b);
    expect(others.length, greaterThan(1));
  });
}
