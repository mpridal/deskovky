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

/// A finished game (spec 5.4). Times are int ms, see [GameSettingsLast.updatedAt].
@DataClassName('MatchRow')
class Matches extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gameId => text()();
  IntColumn get playedAt => integer()();
  IntColumn get durationMs => integer()();

  /// Robots' difficulty; null when only people played.
  TextColumn get difficulty => text().nullable()();
}

/// Everyone at the table of a [Matches] row, robots included (they rank in
/// results but never in leaderboards, spec 5.7.1).
@DataClassName('MatchParticipantRow')
class MatchParticipants extends Table {
  IntColumn get matchId => integer().references(Matches, #id, onDelete: KeyAction.cascade)();
  IntColumn get seat => integer()();

  /// Null for robots and for players deleted since.
  IntColumn get playerId => integer().nullable().references(Players, #id, onDelete: KeyAction.setNull)();
  BoolColumn get robot => boolean()();
  IntColumn get place => integer()();
  IntColumn get score => integer()();
  IntColumn get stars => integer()();

  @override
  Set<Column<Object>> get primaryKey => {matchId, seat};
}

/// Running totals of events reported by games (e.g. pairs found), for badges.
class PlayerCounters extends Table {
  IntColumn get playerId => integer().references(Players, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  IntColumn get value => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playerId, key};
}

/// Badges a player has earned (spec 5.5), each once.
class EarnedBadges extends Table {
  IntColumn get playerId => integer().references(Players, #id, onDelete: KeyAction.cascade)();
  TextColumn get badgeId => text()();
  IntColumn get earnedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playerId, badgeId};
}
