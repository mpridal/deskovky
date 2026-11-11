import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/game/game_store.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/app/generated/schema.dart';
import 'generated/app/generated/schema_v1.dart' as v1;
import 'generated/app/generated/schema_v2.dart' as v2;
import 'generated/app/generated/schema_v3.dart' as v3;
import 'generated/app/generated/schema_v4.dart' as v4;
import 'generated/app/generated/schema_v5.dart' as v5;

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

  for (final from in [1, 2, 3, 4, 5]) {
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
    await verifier.migrateAndValidate(db, db.schemaVersion);

    expect((await PlayerRepository(db).all()).single.name, 'Kuba');
    expect((await GameStore(db).lastConfig('sample'))?.seats.length, 2);
    expect(await StatsRepository(db).allMatches(), isEmpty);
  });

  test('v3 → v4 keeps matches and badges; the points ledger starts empty', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await old.customStatement(
      "INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) VALUES ('Kuba', 'kuba', '{}', NULL, 1761400000)",
    );
    await old.customStatement(
      "INSERT INTO matches (game_id, played_at, duration_ms, difficulty) VALUES ('sample', 1761400000000, 30000, 'hard')",
    );
    await old.customStatement(
      'INSERT INTO match_participants (match_id, seat, player_id, robot, place, score, stars) VALUES (1, 0, 1, 0, 1, 5, 3)',
    );
    await old.customStatement("INSERT INTO earned_badges (player_id, badge_id, earned_at) VALUES (1, 'first_win', 5)");
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, db.schemaVersion);

    final stats = StatsRepository(db);
    expect((await stats.allMatches()).single.participants.single.playerId, 1);
    expect((await stats.earnedBadges(1)).keys, ['first_win']);
    expect(await PointsRepository(db).balance(1), 0);
  });

  test('v4 → v5 keeps points and avatars; the inventory starts empty', () async {
    final schema = await verifier.schemaAt(4);
    final old = v4.DatabaseAtV4(schema.newConnection());
    await old.customStatement(
      "INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) "
      "VALUES ('Kuba', 'kuba', '{\"hair\":\"bob\"}', NULL, 1761400000)",
    );
    await old.customStatement(
      "INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, 120, 'gift', NULL, NULL, 5)",
    );
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 5);

    expect(await PointsRepository(db).balance(1), 120);
    final kuba = (await PlayerRepository(db).all()).single;
    expect(kuba.avatar.equipped, isEmpty);
    expect(await db.select(db.playerItems).get(), isEmpty);
  });

  test('v5 → v6 keeps everything a family needs and gives it ids and ops; a rebuild changes nothing', () async {
    final schema = await verifier.schemaAt(5);
    final old = v5.DatabaseAtV5(schema.newConnection());
    Future<void> sql(String q) => old.customStatement(q);
    await sql("INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) VALUES ('Viky', 'viky', '{\"eq\":{\"head\":{\"id\":\"cap\"}}}', 1, 1761400000)");
    await sql("INSERT INTO players (name, name_key, avatar_json, favorite_seat, created_at) VALUES ('Kuba', 'kuba', '{}', NULL, 1761400100)");
    await sql("INSERT INTO matches (game_id, played_at, duration_ms, difficulty) VALUES ('memory', 1761500000000, 60000, 'easy')");
    await sql("INSERT INTO match_participants (match_id, seat, player_id, robot, place, score, stars) VALUES (1, 0, 1, 0, 1, 5, 3)");
    await sql("INSERT INTO match_participants (match_id, seat, player_id, robot, place, score, stars) VALUES (1, 1, NULL, 1, 2, 3, 1)");
    await sql("INSERT INTO matches (game_id, played_at, duration_ms, difficulty) VALUES ('tictactoe', 1761500100000, 30000, NULL)");
    await sql("INSERT INTO match_participants (match_id, seat, player_id, robot, place, score, stars) VALUES (2, 0, 1, 0, 2, 0, 1)");
    await sql("INSERT INTO match_participants (match_id, seat, player_id, robot, place, score, stars) VALUES (2, 1, 2, 0, 1, 1, 3)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, 30, 'win', NULL, 1, 1761500000000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, 50, 'badge', 'first_win', 1, 1761500000000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, 100, 'gift', NULL, NULL, 1761500050000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, -40, 'purchase', 'hat', NULL, 1761500060000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (1, -60, 'purchase', 'cap', NULL, 1761500070000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (2, 25, 'win', NULL, 2, 1761500100000)");
    await sql("INSERT INTO points_ledger (player_id, amount, reason, detail, match_id, at) VALUES (2, -25, 'reset', NULL, NULL, 1761500200000)");
    // The hat was reset away later; only the cap is still owned.
    await sql("INSERT INTO player_items (player_id, item_id, acquired_at) VALUES (1, 'cap', 1761500070000)");
    await sql("INSERT INTO earned_badges (player_id, badge_id, earned_at) VALUES (1, 'first_win', 1761500000000)");
    await sql("INSERT INTO player_counters (player_id, key, value) VALUES (1, 'memory.pairs', 6)");
    await sql("INSERT INTO app_settings (key, value) VALUES ('activePlayerId', '2')");
    await sql("INSERT INTO saved_sessions (game_id, save_json, updated_at) VALUES ('sample', "
        "'{\"config\":{\"gameId\":\"sample\",\"seats\":[{\"type\":\"human\",\"profileId\":1},{\"type\":\"robot\"}],"
        "\"difficulty\":\"easy\",\"robotSpeed\":\"fast\",\"options\":{}},\"seed\":3,\"moves\":[]}', 9)");
    await old.close();

    final db = AppDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 6);

    Future<String> tables() async => [
      for (final t in ['players', 'matches', 'match_participants', 'points_ledger', 'player_items', 'earned_badges', 'player_counters', 'app_settings', 'saved_sessions'])
        '$t: ${(await db.customSelect('SELECT * FROM $t ORDER BY 1, 2').get()).map((r) => {...r.data}..remove('uid')).toList()}',
    ].join('\n');
    final points = PointsRepository(db);
    expect(await points.balance(1), 30 + 50 + 100 - 40 - 60);
    expect(await points.totalEarned(1), 180);
    expect(await points.balance(2), 0);
    expect((await db.select(db.playerItems).get()).map((i) => (i.playerId, i.itemId)), [(1, 'cap')]);
    final stats = StatsRepository(db);
    expect((await stats.earnedBadges(1)).keys, ['first_win']);
    expect(await stats.counter(1, 'memory.pairs'), 6);
    expect((await stats.allMatches()).map((m) => m.gameId), ['memory', 'tictactoe']);
    expect(await SettingsRepository(db).watchActivePlayerId().first, 2);
    expect((await GameStore(db).savedSession('sample'))?.config.seats.length, 2);
    for (final t in ['players', 'matches', 'points_ledger']) {
      expect((await db.customSelect('SELECT COUNT(*) AS n FROM $t WHERE uid IS NULL').getSingle()).data['n'], 0, reason: t);
    }
    expect(await db.select(db.syncOps).get(), isNotEmpty);

    final before = await tables();
    await FamilyStore(db).rebuild();
    expect(await tables(), before, reason: 'the ops say exactly what the tables held');
  });
}
