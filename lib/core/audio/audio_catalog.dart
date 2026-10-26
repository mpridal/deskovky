import 'package:flutter/foundation.dart';

/// Maps music and effect ids (spec 7.2, 7.3) to asset paths. The one place
/// to change when Miloš's real recordings replace the placeholders.
@immutable
class AudioCatalog {
  const AudioCatalog({required this.music, required this.sfx});

  /// Paths are relative to `assets/audio/`. The WAV files are generated
  /// placeholders (tool/generate_placeholder_audio.py) until the real OGG
  /// recordings arrive.
  static const standard = AudioCatalog(
    music: {
      'menu': 'music/menu.wav',
      'sample': 'music/sample.wav',
      'tictactoe': 'music/tictactoe.wav',
      'memory': 'music/memory.wav',
      'minesweeper': 'music/minesweeper.wav',
      'ludo': 'music/ludo.wav',
      'checkers': 'music/checkers.wav',
    },
    sfx: {
      'tap': 'sfx/tap.wav',
      'back': 'sfx/back.wav',
      'toggle': 'sfx/toggle.wav',
      'card_flip': 'sfx/card_flip.wav',
      'piece_place': 'sfx/piece_place.wav',
      'dice_roll': 'sfx/dice_roll.wav',
      'coin': 'sfx/coin.wav',
      'achievement': 'sfx/achievement.wav',
      'error': 'sfx/error.wav',
      'turn': 'sfx/turn.wav',
      'purchase': 'sfx/purchase.wav',
      'equip': 'sfx/equip.wav',
      'level_up': 'sfx/level_up.wav',
      'jingle_win': 'sfx/jingle_win.wav',
      'jingle_lose': 'sfx/jingle_lose.wav',
    },
  );

  final Map<String, String> music;
  final Map<String, String> sfx;
}
