import 'package:deskovky/games/registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every available game for 2+ players can be played each on their own device (spec 14.1)', () {
    expect(
      [for (final m in gameModules) if (m.playableOnNetwork) m.id],
      ['sample', 'tictactoe', 'memory', 'minesweeper', 'ludo'],
    );
  });

  test('Dáma is not offered over the network while it is not available', () {
    expect(gameModules.firstWhere((m) => m.id == 'checkers').playableOnNetwork, isFalse);
  });
}
