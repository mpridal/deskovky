import 'package:drift/drift.dart';

/// Player profiles (spec 5.2). [nameKey] is the trimmed, lower-cased name that
/// enforces uniqueness regardless of letter case.
class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
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
