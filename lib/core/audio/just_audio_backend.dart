import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_backend.dart';

/// [AudioBackend] on just_audio: two looping music players for the
/// cross-fade and a fixed pool of effect players. Assets are relative to
/// `assets/audio/`.
class JustAudioBackend implements AudioBackend {
  JustAudioBackend({int sfxSlots = 6})
    : _music = [AudioPlayer(), AudioPlayer()],
      // Effects must not take the audio focus: a click would pause the
      // music of another app (a parent's podcast).
      _sfx = List.generate(sfxSlots, (_) => AudioPlayer(handleAudioSessionActivation: false)),
      _sfxAsset = List.filled(sfxSlots, null);

  static const _root = 'assets/audio/';

  final List<AudioPlayer> _music;
  final List<AudioPlayer> _sfx;
  final List<String?> _sfxAsset;

  @override
  Future<void> loadMusic(int channel, String asset) async {
    final player = _music[channel];
    await player.setAsset('$_root$asset');
    await player.setLoopMode(LoopMode.one);
  }

  // play() completes only when playback ends, so it is never awaited.
  @override
  Future<void> playMusic(int channel) async => _start(_music[channel]);

  @override
  Future<void> pauseMusic(int channel) => _music[channel].pause();

  @override
  Future<void> stopMusic(int channel) => _music[channel].stop();

  @override
  Future<void> setMusicVolume(int channel, double volume) => _music[channel].setVolume(volume.clamp(0, 1));

  @override
  Future<void> playSfx(int slot, String asset, double volume) async {
    final player = _sfx[slot];
    if (_sfxAsset[slot] != asset) {
      _sfxAsset[slot] = null;
      await player.setAsset('$_root$asset');
      _sfxAsset[slot] = asset;
    } else {
      await player.seek(Duration.zero);
    }
    await player.setVolume(volume.clamp(0, 1));
    _start(player);
  }

  void _start(AudioPlayer player) {
    unawaited(player.play().catchError((Object e) => debugPrint('JustAudioBackend: $e')));
  }

  @override
  Future<void> dispose() async {
    for (final player in [..._music, ..._sfx]) {
      await player.dispose();
    }
  }
}
