import 'package:flutter_test/flutter_test.dart';

import '../../tool/scope/scope.dart';

void main() {
  group('game branches may only touch their own game (spec 13.2)', () {
    test('own folders and own music pass', () {
      expect(
        outOfScope('game/memory', [
          'lib/games/memory/memory_rules.dart',
          'assets/games/memory/cards/animals/cat.png',
          'test/games/memory/rules_test.dart',
          'assets/audio/music/memory.ogg',
        ]),
        isEmpty,
      );
    });

    test('another game, the framework or shared files fail', () {
      expect(
        outOfScope('game/memory', [
          'lib/games/memory/memory_rules.dart',
          'lib/games/ludo/ludo_rules.dart',
          'lib/core/game/game_module.dart',
          'lib/l10n/app_cs.arb',
          'pubspec.yaml',
          'assets/audio/music/ludo.ogg',
          'lib/games/registry.dart',
        ]),
        [
          'lib/games/ludo/ludo_rules.dart',
          'lib/core/game/game_module.dart',
          'lib/l10n/app_cs.arb',
          'pubspec.yaml',
          'assets/audio/music/ludo.ogg',
          'lib/games/registry.dart',
        ],
      );
    });

    test('a folder that merely starts with the game id is someone else\'s', () {
      expect(outOfScope('game/memory', ['lib/games/memoryx/a.dart']), ['lib/games/memoryx/a.dart']);
    });

    test('other branches are not limited', () {
      expect(outOfScope('main', ['lib/core/game/game_module.dart']), isEmpty);
      expect(outOfScope('framework/texts', ['lib/core/game/game_module.dart']), isEmpty);
      expect(outOfScope('refs/heads/game/ludo', ['lib/games/ludo/a.dart', 'lib/main.dart']), ['lib/main.dart']);
    });
  });
}
