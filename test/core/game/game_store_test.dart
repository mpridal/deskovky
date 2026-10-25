import 'dart:io';

import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

GameConfig _config(String gameId, {int seats = 2}) => GameConfig(
  gameId: gameId,
  seats: [for (var i = 0; i < seats; i++) i == 0 ? const HumanSeat(1) : const RobotSeat()],
  difficulty: Difficulty.hard,
  robotSpeed: RobotSpeed.slow,
  options: const {'range': 20},
);

void main() {
  late AppDatabase db;
  late GameStore store;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    store = GameStore(db);
  });
  tearDown(() => db.close());

  test('last config per game is saved and replaced', () async {
    expect(await store.lastConfig('sample'), isNull);
    await store.saveLastConfig(_config('sample'));
    expect(await store.lastConfig('sample'), _config('sample'));
    await store.saveLastConfig(_config('sample', seats: 4));
    expect((await store.lastConfig('sample'))!.seats, hasLength(4));
  });

  test('watchLastPlayed follows the most recently saved game', () async {
    final seen = <String?>[];
    final sub = store.watchLastPlayed().listen((c) => seen.add(c?.gameId));
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await store.saveLastConfig(_config('a'));
    await pumpEventQueue();
    await store.saveLastConfig(_config('b'));
    await pumpEventQueue();
    await store.saveLastConfig(_config('a'));
    await pumpEventQueue();
    expect(seen.first, isNull);
    expect(seen.last, 'a');
    expect(seen, contains('b'));
  });

  test('corrupted JSON reads as nothing', () async {
    await store.saveLastConfig(_config('sample'));
    await db.customStatement("UPDATE game_settings_last SET config_json = '{broken'");
    expect(await store.lastConfig('sample'), isNull);
  });

  test('saved session round-trips and can be deleted', () async {
    final save = SavedGame(config: _config('sample'), seed: 4, moves: const [Move(seat: 0, type: 'guess', data: {'value': 7})]);
    await store.saveSession(save);
    expect(await store.savedSession('sample'), save);
    expect(await store.watchLastSaved().first, save);
    await store.deleteSession('sample');
    expect(await store.savedSession('sample'), isNull);
    expect(await store.watchLastSaved().first, isNull);
  });

  test('music and effects default on and are remembered across reopen', () async {
    final dir = await Directory.systemTemp.createTemp('deskovky_audio');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/a.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    final settings = SettingsRepository(first);
    expect(await settings.watchMusicOn().first, isTrue);
    expect(await settings.watchSfxOn().first, isTrue);
    await settings.setMusicOn(false);
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(await SettingsRepository(second).watchMusicOn().first, isFalse);
    expect(await SettingsRepository(second).watchSfxOn().first, isTrue);
  });
}
