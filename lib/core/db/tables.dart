import 'package:drift/drift.dart';

/// Player profiles (spec 5.2). [nameKey] is the trimmed, lower-cased name that
/// enforces uniqueness regardless of letter case.
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  // The 16-character rule counts visible characters in PlayerRepository; a
  // compound emoji is up to ~11 UTF-16 units, so the column limit is generous.
  TextColumn get name => text().withLength(min: 1, max: 256)();
  TextColumn get nameKey => text().unique()();
  TextColumn get avatarJson => text()();
  IntColumn get favoriteSeat => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Simple key–value store for app-wide settings (active player, language…).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Last setup per game (spec 5.7 "pamatování nastavení"); JSON of GameConfig.
class GameSettingsLast extends Table {
  TextColumn get gameId => text()();
  TextColumn get configJson => text()();

  /// Strictly increasing stamp (ms); DateTime columns only keep seconds.
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}

/// A game in progress per game (spec 5.8 auto-save); JSON of SavedGame.
class SavedSessions extends Table {
  TextColumn get gameId => text()();
  TextColumn get saveJson => text()();

  /// Strictly increasing stamp (ms), see [GameSettingsLast.updatedAt].
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {gameId};
}
