import 'package:deskovky/app/audio_director.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/features/game_play/game_outcome.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_play/seat_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/fake_audio_backend.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

const _fade = Duration(milliseconds: 700);

GameConfig _config(List<SeatConfig> seats) => GameConfig(
  gameId: 'sample',
  seats: seats,
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.slow,
  options: const {'range': 20},
);

GoRouter _router(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Navigator).first));

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(_fade);
}

Future<void> _activePlayer(WidgetTester tester, AppDatabase db) => tester.runAsync(() async {
  final p = await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults);
  await SettingsRepository(db).setActivePlayerId(p.id);
});

void main() {
  late AppDatabase db;
  late FakeAudioBackend audio;
  setUp(() {
    db = testDatabase();
    audio = FakeAudioBackend();
  });
  tearDown(() => db.close());

  test('music follows the route: menu everywhere, the game track in the game and its results', () {
    expect(musicForLocation('/games'), 'menu');
    expect(musicForLocation('/players/new'), 'menu');
    expect(musicForLocation('/settings'), 'menu');
    expect(musicForLocation('/play/sample/setup'), 'menu');
    expect(musicForLocation('/play/sample'), 'sample');
    expect(musicForLocation('/play/sample/results'), 'sample');
    expect(musicForLocation('/play/nonexistent'), 'menu');
  });

  testWidgets('menu music at start, the sample game has its own track, home brings the menu back', (tester) async {
    final t = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!;
    await pumpApp(tester, size: const Size(800, 1280), db: db, audio: audio, disableAnimations: true);
    await _settle(tester);
    expect(audio.audible, ['music/menu.wav']);

    _router(tester).push('/play/sample', extra: _config([HumanSeat(t.id), const RobotSeat()]));
    await _settle(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    expect(audio.audible, ['music/sample.wav']);

    _router(tester).go('/games');
    await _settle(tester);
    expect(audio.audible, ['music/menu.wav']);
  });

  testWidgets('music switched off in settings stays silent from the start', (tester) async {
    await tester.runAsync(() => SettingsRepository(db).setMusicOn(false));
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    await _settle(tester);
    expect(audio.audible, isEmpty);
    await tester.runAsync(() => SettingsRepository(db).setMusicOn(true));
    await _settle(tester);
    expect(audio.audible, ['music/menu.wav']);
  });

  testWidgets('music volume from settings is applied', (tester) async {
    await tester.runAsync(() => SettingsRepository(db).setMusicVolume(0.3));
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    await _settle(tester);
    expect(audio.volumeOf('music/menu.wav'), closeTo(0.3, 0.01));
  });

  testWidgets('a tip in the sample game sounds piece_place, the next player turn', (tester) async {
    final t = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)))!;
    final k = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)))!;
    await pumpApp(tester, size: const Size(800, 1280), db: db, audio: audio, disableAnimations: true);
    _router(tester).push('/play/sample', extra: _config([HumanSeat(t.id), HumanSeat(k.id)]));
    await _settle(tester);
    audio.sfx.clear();
    final tile = find.byKey(const ValueKey('number1'));
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump(const Duration(milliseconds: 50));
    final played = [for (final s in audio.sfx) s.$2];
    expect(played, contains('sfx/piece_place.wav'));
    expect(played, contains('sfx/turn.wav'));
  });

  testWidgets('results: a human winner hears jingle_win with the music ducked', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    await _settle(tester);
    final outcome = GameOutcomeView(
      config: _config(const [HumanSeat(1), RobotSeat()]),
      result: const GameResult(places: [1, 2], scores: [4, 3], stars: [3, 1]),
      seats: const [
        SeatIdentity(seat: 0, name: 'Tereza', profile: null, difficulty: null),
        SeatIdentity(seat: 1, name: 'Čipík', profile: null, difficulty: Difficulty.easy),
      ],
    );
    audio.sfx.clear();
    _router(tester).push('/play/sample/results', extra: outcome);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    expect([for (final s in audio.sfx) s.$2], contains('sfx/jingle_win.wav'));
    expect(audio.volumeOf('music/sample.wav'), lessThan(0.7 * 0.5));
  });

  testWidgets('results: when only robots win, jingle_lose plays', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    final outcome = GameOutcomeView(
      config: _config(const [HumanSeat(1), RobotSeat()]),
      result: const GameResult(places: [2, 1], scores: [3, 4], stars: [1, 3]),
      seats: const [
        SeatIdentity(seat: 0, name: 'Tereza', profile: null, difficulty: null),
        SeatIdentity(seat: 1, name: 'Čipík', profile: null, difficulty: Difficulty.easy),
      ],
    );
    _router(tester).push('/play/sample/results', extra: outcome);
    await tester.pumpAndSettle();
    final played = [for (final s in audio.sfx) s.$2];
    expect(played, contains('sfx/jingle_lose.wav'));
    expect(played, isNot(contains('sfx/jingle_win.wav')));
  });

  testWidgets('buttons click: a primary button plays tap', (tester) async {
    await _activePlayer(tester, db);
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    audio.sfx.clear();
    await tester.tap(find.text('Hádej číslo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hrát!'));
    await tester.pump(const Duration(milliseconds: 50));
    expect([for (final s in audio.sfx) s.$2], contains('sfx/tap.wav'));
    await tester.pumpAndSettle();
  });

  testWidgets('effects switched off: no clicks', (tester) async {
    await tester.runAsync(() => SettingsRepository(db).setSfxOn(false));
    await _activePlayer(tester, db);
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    await tester.tap(find.text('Hádej číslo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hrát!'));
    await tester.pumpAndSettle();
    expect(audio.sfx, isEmpty);
  });

  testWidgets('the app in the background pauses the music', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db, audio: audio, disableAnimations: true);
    await _settle(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(audio.audible, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(audio.audible, ['music/menu.wav']);
  });
}
