import 'package:deskovky/games/registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every available game for 2+ players can be played each on their own device (spec 14.1)', () {
    expect(
      [for (final m in gameModules) if (m.playableOnNetwork) m.id],
      ['sample', 'tictactoe', 'memory', 'minesweeper', 'ludo', 'matches', 'checkers', 'war', 'ships'],
    );
  });

  test('a game that is not available yet ("Brzy") is never offered over the network', () {
    for (final m in gameModules.where((m) => !m.available)) {
      expect(m.playableOnNetwork, isFalse, reason: m.id);
    }
  });
}
