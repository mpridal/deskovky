import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'game_config.dart';

/// Remembered setup per game and saved games in progress.
class GameStore {
  GameStore(this._db);

  final AppDatabase _db;

  Future<void> saveLastConfig(GameConfig config) => _db.transaction(() async {
    final stamp = await _nextStamp(_db.gameSettingsLast, _db.gameSettingsLast.updatedAt);
    await _db
        .into(_db.gameSettingsLast)
        .insertOnConflictUpdate(
          GameSettingsLastCompanion.insert(
            gameId: config.gameId,
            configJson: jsonEncode(config.toJson()),
            updatedAt: stamp,
          ),
        );
  });

  Future<GameConfig?> lastConfig(String gameId) async {
    final row = await (_db.select(_db.gameSettingsLast)..where((t) => t.gameId.equals(gameId))).getSingleOrNull();
    return row == null ? null : GameConfig.fromJson(_decode(row.configJson));
  }

  /// The most recently played game's setup (for "Pokračovat" on the home screen).
  Stream<GameConfig?> watchLastPlayed() =>
      (_db.select(_db.gameSettingsLast)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row == null ? null : GameConfig.fromJson(_decode(row.configJson)));

  Future<void> saveSession(SavedGame save) => _db.transaction(() async {
    final stamp = await _nextStamp(_db.savedSessions, _db.savedSessions.updatedAt);
    await _db
        .into(_db.savedSessions)
        .insertOnConflictUpdate(
          SavedSessionsCompanion.insert(gameId: save.config.gameId, saveJson: jsonEncode(save.toJson()), updatedAt: stamp),
        );
  });

  Future<SavedGame?> savedSession(String gameId) async {
    final row = await (_db.select(_db.savedSessions)..where((t) => t.gameId.equals(gameId))).getSingleOrNull();
    return row == null ? null : SavedGame.fromJson(_decode(row.saveJson));
  }

  /// The most recently saved game in progress, if any.
  Stream<SavedGame?> watchLastSaved() =>
      (_db.select(_db.savedSessions)
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row == null ? null : SavedGame.fromJson(_decode(row.saveJson)));

  Future<void> deleteSession(String gameId) =>
      (_db.delete(_db.savedSessions)..where((t) => t.gameId.equals(gameId))).go();

  /// Now in ms, but always above the newest stamp, so two saves within the
  /// same millisecond still keep their order.
  Future<int> _nextStamp(TableInfo<Table, Object?> table, Expression<int> column) async {
    final newest = column.max();
    final row = await (_db.selectOnly(table)..addColumns([newest])).getSingle();
    final now = DateTime.now().millisecondsSinceEpoch;
    final previous = row.read(newest) ?? 0;
    return now > previous ? now : previous + 1;
  }

  static Object? _decode(String json) {
    try {
      return jsonDecode(json);
    } on FormatException {
      return null;
    }
  }
}
