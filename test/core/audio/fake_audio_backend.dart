import 'package:deskovky/core/audio/audio_backend.dart';

/// Records what the AudioService asks the platform to do.
class FakeAudioBackend implements AudioBackend {
  final Map<int, String?> loaded = {0: null, 1: null};
  final Map<int, double> volume = {0: 0, 1: 0};
  final Map<int, bool> playing = {0: false, 1: false};
  final List<(int slot, String asset, double volume)> sfx = [];
  bool failLoads = false;

  /// Tracks audible right now (volume above zero and playing).
  List<String> get audible => [
    for (final c in [0, 1])
      if (playing[c]! && volume[c]! > 0.001) loaded[c]!,
  ];

  double volumeOf(String asset) =>
      [for (final c in [0, 1]) if (loaded[c] == asset && playing[c]!) volume[c]!].fold(0, (a, b) => a > b ? a : b);

  @override
  Future<void> loadMusic(int channel, String asset) async {
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
