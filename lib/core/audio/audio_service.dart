import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'audio_backend.dart';
import 'audio_catalog.dart';

/// Volumes and switches of music and effects (spec 5.10, 7.1).
@immutable
class AudioSettings {
  const AudioSettings({required this.musicOn, required this.musicVolume, required this.sfxOn, required this.sfxVolume});

  static const defaults = AudioSettings(musicOn: true, musicVolume: 0.7, sfxOn: true, sfxVolume: 0.9);

  final bool musicOn;
  final double musicVolume;
  final bool sfxOn;
  final double sfxVolume;

  AudioSettings copyWith({bool? musicOn, double? musicVolume, bool? sfxOn, double? sfxVolume}) => AudioSettings(
    musicOn: musicOn ?? this.musicOn,
    musicVolume: musicVolume ?? this.musicVolume,
    sfxOn: sfxOn ?? this.sfxOn,
    sfxVolume: sfxVolume ?? this.sfxVolume,
  );
}

/// Music and sound effects (spec 7.1): one looping music channel that
/// cross-fades in 600 ms, a pool of [sfxSlots] effects, ducking by 8 dB for
/// jingles, paused while the app is in the background. Never throws: a
/// broken file is only logged.
class AudioService {
  AudioService({required this._backend, required this._catalog});

  final AudioBackend _backend;
  final AudioCatalog _catalog;

  static const fade = Duration(milliseconds: 600);
  static const _tick = Duration(milliseconds: 25);
  static const sfxSlots = 6;

  /// −8 dB as a linear factor.
  static final duckFactor = pow(10, -8 / 20).toDouble();

  AudioSettings _settings = AudioSettings.defaults;
  String? _track;
  int _active = 0;
  final List<double> _gain = [0, 0];
  final List<bool> _playing = [false, false];
  final Set<int> _pausedChannels = {};
  Timer? _fadeTimer;
  Timer? _duckTimer;
  Timer? _duckRestore;
  double _duck = 1;
  int _nextSlot = 0;
  int _generation = 0;
  bool _disposed = false;

  String? get currentTrack => _track;

  void applySettings(AudioSettings settings) {
    _settings = settings;
    _applyVolumes();
  }

  /// Plays music [id] (looping), cross-fading from the current track; null
  /// fades out. The same track keeps playing.
  void playMusic(String? id) {
    if (_disposed || id == _track) return;
    _track = id;
    unawaited(_switchTo(id, ++_generation));
  }

  Future<void> _switchTo(String? id, int generation) async {
    _fadeTimer?.cancel();
    final from = _active;
    final to = 1 - from;
    // Whatever was still fading out on the other channel stops now, so two
    // tracks are never left playing.
    await _safe(() => _backend.stopMusic(to));
    _playing[to] = false;
    _gain[to] = 0;
    final asset = id == null ? null : _catalog.music[id];
    if (asset != null) {
      try {
        await _backend.loadMusic(to, asset);
        if (generation != _generation || _disposed) return;
        await _backend.setMusicVolume(to, 0);
        await _backend.playMusic(to);
        _playing[to] = true;
      } catch (e) {
        debugPrint('AudioService: cannot play $asset: $e');
      }
    }
    if (generation != _generation || _disposed) return;
    _active = to;
    final steps = fade.inMilliseconds ~/ _tick.inMilliseconds;
    var step = 0;
    final fromStart = _gain[from];
    _fadeTimer = Timer.periodic(_tick, (timer) {
      step++;
      final t = step / steps;
      _gain[from] = fromStart * (1 - t);
      if (_playing[to]) _gain[to] = t;
      _applyVolumes();
      if (step >= steps) {
        timer.cancel();
        _gain[from] = 0;
        _playing[from] = false;
        unawaited(_safe(() => _backend.stopMusic(from)));
      }
    });
  }

  void playSfx(String id) {
    final asset = _catalog.sfx[id];
    if (_disposed || asset == null || !_settings.sfxOn || _settings.sfxVolume <= 0) return;
    final slot = _nextSlot;
    _nextSlot = (_nextSlot + 1) % sfxSlots;
    unawaited(_safe(() => _backend.playSfx(slot, asset, _settings.sfxVolume)));
  }

  /// Lowers the music by 8 dB for [duration] (jingles, achievements), then
  /// brings it back over 300 ms.
  void duck(Duration duration) {
    _duckTimer?.cancel();
    _duckRestore?.cancel();
    _duck = duckFactor;
    _applyVolumes();
    _duckTimer = Timer(duration, () {
      var step = 0;
      _duckRestore = Timer.periodic(_tick, (timer) {
        step++;
        _duck = duckFactor + (1 - duckFactor) * (step / 12).clamp(0, 1);
        _applyVolumes();
        if (step >= 12) timer.cancel();
      });
    });
  }

  void onLifecycle(AppLifecycleState state) {
    if (_disposed) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      for (final c in [0, 1]) {
        if (_playing[c] && _pausedChannels.add(c)) unawaited(_safe(() => _backend.pauseMusic(c)));
      }
    } else if (state == AppLifecycleState.resumed) {
      for (final c in _pausedChannels.toList()) {
        if (_playing[c]) unawaited(_safe(() => _backend.playMusic(c)));
      }
      _pausedChannels.clear();
      _applyVolumes();
    }
  }

  void _applyVolumes() {
    if (_disposed) return;
    final target = _settings.musicOn ? _settings.musicVolume * _duck : 0.0;
    for (final c in [0, 1]) {
      unawaited(_safe(() => _backend.setMusicVolume(c, _gain[c] * target)));
    }
  }

  Future<void> _safe(Future<void> Function() call) async {
    try {
      await call();
    } catch (e) {
      debugPrint('AudioService: $e');
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _fadeTimer?.cancel();
    _duckTimer?.cancel();
    _duckRestore?.cancel();
    await _safe(_backend.dispose);
  }
}
