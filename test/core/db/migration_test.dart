import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/app/generated/schema.dart';
import 'generated/app/generated/schema_v1.dart' as v1;
import 'generated/app/generated/schema_v2.dart' as v2;

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

  for (final from in [1, 2]) {
    test('a fresh v$from database migrates to the current version', () async {
      final connection = await verifier.startAt(from);
      final db = AppDatabase(connection);
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, db.schemaVersion);
    });
  }

  test('v2 → v3 keeps players, remembered setups and saved games; stats start empty', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    await old.customStatement(
      "INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) "
      "VALUES ('Kuba', 'kuba', '{}', NULL, 1761400000)",
    );
    await old.customStatement(
      "INSERT INTO game_settings_last (game_id, config_json, updated_at) VALUES ('sample', "
      "'{\"gameId\":\"sample\",\"seats\":[{\"type\":\"human\",\"profileId\":1},{\"type\":\"robot\"}],"
      "\"difficulty\":\"hard\",\"robotSpeed\":\"fast\",\"options\":{\"range\":20}}', 5)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 3);

    expect((await PlayerRepository(db).all()).single.name, 'Kuba');
    expect((await GameStore(db).lastConfig('sample'))?.seats.length, 2);
    expect(await StatsRepository(db).allMatches(), isEmpty);
  });
}
