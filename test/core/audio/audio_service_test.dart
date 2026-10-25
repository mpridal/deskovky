import 'package:deskovky/core/audio/audio_catalog.dart';
import 'package:deskovky/core/audio/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_audio_backend.dart';

const _catalog = AudioCatalog(
  music: {'menu': 'music/menu.wav', 'sample': 'music/sample.wav', 'ludo': 'music/ludo.wav'},
  sfx: {'tap': 'sfx/tap.wav', 'coin': 'sfx/coin.wav', 'jingle_win': 'sfx/jingle_win.wav'},
);

const _settings = AudioSettings(musicOn: true, musicVolume: 0.5, sfxOn: true, sfxVolume: 0.8);

(AudioService, FakeAudioBackend) _service({AudioSettings settings = _settings}) {
  final backend = FakeAudioBackend();
  final service = AudioService(backend: backend, catalog: _catalog)..applySettings(settings);
  return (service, backend);
}

Future<void> _wait(WidgetTester tester, int ms) => tester.pump(Duration(milliseconds: ms));

void main() {
  testWidgets('first track fades in to the music volume', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 10);
    expect(backend.audible, isEmpty, reason: 'starts silent');
    await _wait(tester, 650);
    expect(backend.audible, ['music/menu.wav']);
    expect(backend.volumeOf('music/menu.wav'), closeTo(0.5, 0.01));
  });

  testWidgets('a new track cross-fades in 600 ms', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 700);
    service.playMusic('sample');
    await _wait(tester, 300);
    expect(backend.audible.toSet(), {'music/menu.wav', 'music/sample.wav'}, reason: 'mid-fade both are heard');
    await _wait(tester, 400);
    expect(backend.audible, ['music/sample.wav']);
    expect(backend.volumeOf('music/sample.wav'), closeTo(0.5, 0.01));
  });

  testWidgets('the same track does not restart', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 700);
    final channels = Map.of(backend.loaded);
    service.playMusic('menu');
    await _wait(tester, 700);
    expect(backend.loaded, channels);
    expect(backend.audible, ['music/menu.wav']);
  });

  testWidgets('rapid switching ends with only the last requested track', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 100);
    service.playMusic('sample');
    await _wait(tester, 100);
    service.playMusic('ludo');
    await _wait(tester, 50);
    service.playMusic('menu');
    await _wait(tester, 800);
    expect(backend.audible, ['music/menu.wav']);
    expect(backend.volumeOf('music/menu.wav'), closeTo(0.5, 0.01));
  });

  testWidgets('null music fades out to silence', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 700);
    service.playMusic(null);
    await _wait(tester, 700);
    expect(backend.audible, isEmpty);
  });

  testWidgets('effects use a pool of 6 slots, round robin', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    for (var i = 0; i < 8; i++) {
      service.playSfx('tap');
    }
    await _wait(tester, 10);
    expect([for (final s in backend.sfx) s.$1], [0, 1, 2, 3, 4, 5, 0, 1]);
    expect(backend.sfx.first.$3, closeTo(0.8, 0.001));
    expect(backend.sfx.first.$2, 'sfx/tap.wav');
  });

  testWidgets('effects off or volume 0 play nothing; unknown ids are ignored', (tester) async {
    final (service, backend) = _service(settings: _settings.copyWith(sfxOn: false));
    addTearDown(service.dispose);
    service.playSfx('tap');
    service.applySettings(_settings.copyWith(sfxVolume: 0));
    service.playSfx('tap');
    service.applySettings(_settings);
    service.playSfx('nonexistent');
    await _wait(tester, 10);
    expect(backend.sfx, isEmpty);
  });

  testWidgets('ducking lowers music by 8 dB and comes back', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 700);
    service.duck(const Duration(seconds: 2));
    await _wait(tester, 100);
    expect(backend.volumeOf('music/menu.wav'), closeTo(0.5 * 0.398, 0.01));
    await _wait(tester, 2400);
    expect(backend.volumeOf('music/menu.wav'), closeTo(0.5, 0.01));
  });

  testWidgets('music pauses in the background and resumes without stuck ducking', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    service.playMusic('menu');
    await _wait(tester, 700);
    service.duck(const Duration(milliseconds: 500));
    service.onLifecycle(AppLifecycleState.paused);
    await _wait(tester, 10);
    expect(backend.audible, isEmpty);
    await _wait(tester, 2000);
    service.onLifecycle(AppLifecycleState.resumed);
    await _wait(tester, 400);
    expect(backend.audible, ['music/menu.wav']);
    expect(backend.volumeOf('music/menu.wav'), closeTo(0.5, 0.01));
  });

  testWidgets('switching music off silences it; on again plays the current track', (tester) async {
    final (service, backend) = _service(settings: _settings.copyWith(musicOn: false));
    addTearDown(service.dispose);
    service.playMusic('sample');
    await _wait(tester, 700);
    expect(backend.audible, isEmpty);
    service.applySettings(_settings);
    await _wait(tester, 700);
    expect(backend.audible, ['music/sample.wav']);
    service.applySettings(_settings.copyWith(musicVolume: 0.2));
    await _wait(tester, 50);
    expect(backend.volumeOf('music/sample.wav'), closeTo(0.2, 0.01));
  });

  testWidgets('a broken file does not throw', (tester) async {
    final (service, backend) = _service();
    addTearDown(service.dispose);
    backend.failLoads = true;
    service.playMusic('menu');
    service.playSfx('tap');
    await _wait(tester, 700);
    expect(tester.takeException(), isNull);
    expect(backend.audible, isEmpty);
  });
}
