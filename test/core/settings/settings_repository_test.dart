import 'dart:io';
import 'dart:ui';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/active_player.dart';
import 'package:deskovky/core/players/player_profile.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late PlayerRepository players;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
    players = PlayerRepository(db);
  });
  tearDown(() => db.close());

  test('defaults: no active player, system language', () async {
    expect(await settings.watchActivePlayerId().first, isNull);
    expect(await settings.watchLocale().first, isNull);
  });

  test('values survive reopening a file database', () async {
    final dir = await Directory.systemTemp.createTemp('deskovky_settings');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/s.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    await SettingsRepository(first).setActivePlayerId(3);
    await SettingsRepository(first).setLocale(const Locale('es'));
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect(await SettingsRepository(second).watchActivePlayerId().first, 3);
    expect(await SettingsRepository(second).watchLocale().first, const Locale('es'));
  });

  test('setLocale(null) returns to the system language', () async {
    await settings.setLocale(const Locale('en'));
    await settings.setLocale(null);
    expect(await settings.watchLocale().first, isNull);
  });

  test('unknown stored language is ignored', () async {
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: 'locale', value: 'de'));
    expect(await settings.watchLocale().first, isNull);
  });

  test('sound defaults: music 0.7, effects 0.9, vibration on (spec 5.10)', () async {
    expect(await settings.watchMusicVolume().first, 0.7);
    expect(await settings.watchSfxVolume().first, 0.9);
    expect(await settings.watchVibrationOn().first, isTrue);
  });

  test('sound settings are stored; volumes are clamped to 0–1', () async {
    await settings.setMusicVolume(0.25);
    await settings.setSfxVolume(1.7);
    await settings.setVibrationOn(false);
    expect(await settings.watchMusicVolume().first, 0.25);
    expect(await settings.watchSfxVolume().first, 1.0);
    expect(await settings.watchVibrationOn().first, isFalse);
  });

  test('a broken stored volume falls back to the default', () async {
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: 'musicVolume', value: 'x'));
    expect(await settings.watchMusicVolume().first, 0.7);
  });

  group('active player', () {
    Future<PlayerProfile?> active() => watchActivePlayer(players, settings).first;

    test('none without profiles', () async {
      expect(await active(), isNull);
    });

    test('first profile becomes active and is remembered', () async {
      final tereza = await players.create(name: 'Tereza', avatar: AvatarSpec.defaults);
      expect((await active())?.id, tereza.id);
      expect(await settings.watchActivePlayerId().first, tereza.id);
    });

    test('chosen profile stays active', () async {
      await players.create(name: 'Tereza', avatar: AvatarSpec.defaults);
      final kuba = await players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
      await settings.setActivePlayerId(kuba.id);
      expect((await active())?.id, kuba.id);
    });

    test('deleting the active player falls back to the oldest one', () async {
      final tereza = await players.create(name: 'Tereza', avatar: AvatarSpec.defaults);
      final kuba = await players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
      final babi = await players.create(name: 'Babi', avatar: AvatarSpec.defaults);
      await settings.setActivePlayerId(kuba.id);
      await players.delete(kuba.id);
      expect((await active())?.id, tereza.id);
      await players.delete(tereza.id);
      expect((await active())?.id, babi.id);
      await players.delete(babi.id);
      expect(await active(), isNull);
    });

    test('stream follows changes', () async {
      final seen = <String?>[];
      final sub = watchActivePlayer(players, settings).listen((p) => seen.add(p?.name));
      addTearDown(sub.cancel);
      await pumpEventQueue();
      await players.create(name: 'Tereza', avatar: AvatarSpec.defaults);
      await pumpEventQueue();
      final kuba = await players.create(name: 'Kuba', avatar: AvatarSpec.defaults);
      await pumpEventQueue();
      await settings.setActivePlayerId(kuba.id);
      await pumpEventQueue();
      expect(seen.where((n) => n != null).toList().last, 'Kuba');
      expect(seen.first, isNull);
      expect(seen, contains('Tereza'));
    });
  });
}
