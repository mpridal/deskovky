import 'dart:async';

import 'package:deskovky/core/audio/audio_backend.dart';

/// Records what the AudioService asks the platform to do.
class FakeAudioBackend implements AudioBackend {
  final Map<int, String?> loaded = {0: null, 1: null};
  final Map<int, double> volume = {0: 0, 1: 0};
  final Map<int, bool> playing = {0: false, 1: false};
  final List<(int slot, String asset, double volume)> sfx = [];
  bool failLoads = false;

  /// When true, loads wait until [releaseLoads] — to test calls that
  /// overlap a slow load on a real device.
  bool holdLoads = false;
  final List<Completer<void>> _held = [];

  void releaseLoads() {
    holdLoads = false;
    for (final c in _held) {
      c.complete();
    }
    _held.clear();
  }

  /// Channels playing at all, audible or not (an active channel holds the
  /// device's audio focus).
  List<int> get active => [for (final c in [0, 1]) if (playing[c]!) c];

  /// Tracks audible right now (volume above zero and playing).
  List<String> get audible => [
    for (final c in [0, 1])
      if (playing[c]! && volume[c]! > 0.001) loaded[c]!,
  ];

  double volumeOf(String asset) =>
      [for (final c in [0, 1]) if (loaded[c] == asset && playing[c]!) volume[c]!].fold(0, (a, b) => a > b ? a : b);

  @override
  Future<void> loadMusic(int channel, String asset) async {
    if (holdLoads) {
      final gate = Completer<void>();
      _held.add(gate);
      await gate.future;
    }
    if (failLoads) throw Exception('cannot load $asset');
    loaded[channel] = asset;
  }

  @override
  Future<void> playMusic(int channel) async => playing[channel] = true;

  @override
  Future<void> pauseMusic(int channel) async => playing[channel] = false;

  @override
  Future<void> stopMusic(int channel) async {
    playing[channel] = false;
    volume[channel] = 0;
  }

  @override
  Future<void> setMusicVolume(int channel, double v) async => volume[channel] = v;

  @override
  Future<void> playSfx(int slot, String asset, double v) async {
    if (failLoads) throw Exception('cannot load $asset');
    sfx.add((slot, asset, v));
  }

  @override
  Future<void> dispose() async {}
}
