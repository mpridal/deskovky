import 'dart:io';

import 'package:deskovky/core/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

PlayersCompanion _player(String name) => PlayersCompanion.insert(
      name: name,
      nameKey: name.trim().toLowerCase(),
      avatarJson: '{}',
      createdAt: DateTime.utc(2026, 10, 25),
    );

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('stores and reads a player', () async {
    final id = await db.into(db.players).insert(_player('Tereza'));
    final row = await (db.select(db.players)..where((p) => p.id.equals(id))).getSingle();
    expect(row.name, 'Tereza');
    expect(row.favoriteSeat, isNull);
  });

  test('name key is unique', () async {
    await db.into(db.players).insert(_player('Tereza'));
    expect(() => db.into(db.players).insert(_player('tereza')), throwsA(isA<SqliteException>()));
  });

  test('app settings upsert by key', () async {
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: 'locale', value: 'cs'));
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: 'locale', value: 'es'));
    final rows = await db.select(db.appSettings).get();
    expect(rows.single.value, 'es');
  });

  test('data survives closing and reopening a file database', () async {
    final dir = await Directory.systemTemp.createTemp('deskovky_db');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/test.sqlite');

    final first = AppDatabase(NativeDatabase(file));
    await first.into(first.players).insert(_player('Kuba'));
    await first.close();

    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    expect((await second.select(second.players).get()).single.name, 'Kuba');
  });
}
