import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/app/generated/schema.dart';
import 'generated/app/generated/schema_v1.dart' as v1;

/// Every schema version must have a snapshot in drift_schemas/app and a step
/// here that migrates from each older version (see CLAUDE.md).
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('a fresh v1 database migrates to v2', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });

  test('v1 → v2 keeps players and settings', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old.customStatement(
      "INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) "
      "VALUES ('Tereza', 'tereza', '{\"hair\":\"bob\"}', 2, 1761400000)",
    );
    await old.customStatement("INSERT INTO app_settings (key, value) VALUES ('activePlayerId', '1')");
    await old.customStatement("INSERT INTO app_settings (key, value) VALUES ('locale', 'es')");
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);

    final players = await PlayerRepository(db).all();
    expect(players.single.name, 'Tereza');
    expect(players.single.favoriteSeat, 2);
    expect(await SettingsRepository(db).watchActivePlayerId().first, players.single.id);
    expect((await SettingsRepository(db).watchLocale().first)?.languageCode, 'es');
  });
}
