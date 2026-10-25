import 'package:deskovky/core/audio/audio_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the standard catalog has the menu music and a track for every game (spec 7.2)', () {
    expect(
      AudioCatalog.standard.music.keys,
      containsAll(['menu', 'sample', 'tictactoe', 'memory', 'minesweeper', 'ludo', 'checkers']),
    );
    for (final path in AudioCatalog.standard.music.values) {
      expect(path, startsWith('music/'));
    }
  });

  test('the standard catalog has every shared effect and both jingles (spec 7.2, 7.3)', () {
    expect(AudioCatalog.standard.sfx.keys, {
      'tap', 'back', 'toggle', 'card_flip', 'piece_place', 'dice_roll', 'coin', 'achievement', //
      'error', 'turn', 'purchase', 'equip', 'level_up', 'jingle_win', 'jingle_lose',
    });
    for (final path in AudioCatalog.standard.sfx.values) {
      expect(path, startsWith('sfx/'));
    }
  });
}
