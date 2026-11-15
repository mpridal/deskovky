import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/games/registry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fingerprints of one fixed game of every game (robots, default options,
/// seed 2026). They change only when a game's rules change – and then devices
/// with the old rules must not play with the new ones (review R-002).
///
/// When this test fails after a rules change: raise `rulesVersion` in
/// lib/core/multiplayer/protocol.dart, then put the new fingerprints here
/// (run with REPRINT=1 to print them) together with the new version.
const fingerprintsForRulesVersion = 3;
const fingerprints = <String, String>{
  'sample': 'd7635cae',
  'tictactoe': '975a454a',
  'memory': 'af2e4c79',
  'minesweeper': '26468d1d',
  'ludo': '428c42d4',
  'matches': 'ef51b0dc',
  'checkers': '93a91e64',
  'war': 'efcedaf2',
  'ships': '357fd5d7',
};

String fingerprint<S>(GameModule<S> m) {
  final config = GameConfig(
    gameId: m.id,
    seats: [for (var s = 0; s < m.maxPlayers.clamp(1, 2); s++) const RobotSeat()],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: {for (final o in m.options) o.id: o.defaultValue},
  );
  final session = GameSession<S>.start(m.rules, config, 2026);
  final random = SeededRandom(7);
  for (var i = 0; i < 3000 && !m.rules.isOver(session.state); i++) {
    final seat = m.rules.currentSeat(session.state)!;
    final legal = m.rules.legalMoves(session.state, seat);
    session.apply(legal[random.nextInt(legal.length)]);
  }
  return session.hash;
}

void main() {
  test('the fingerprints belong to the current rules version', () {
    expect(fingerprintsForRulesVersion, rulesVersion, reason: 'update the fingerprints with the version');
  });

  for (final m in gameModules) {
    test('${m.id}: same rules as rules version $rulesVersion', () {
      final now = m.withType(<T>(typed) => fingerprint<T>(typed));
      if (Platform.environment['REPRINT'] == '1') {
        // ignore: avoid_print
        print("  '${m.id}': '$now',");
        return;
      }
      expect(
        now,
        fingerprints[m.id],
        reason: 'The rules of ${m.id} changed: raise rulesVersion in protocol.dart and update the fingerprints.',
      );
    });
  }
}
