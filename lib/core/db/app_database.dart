import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database. Every schema change bumps [schemaVersion], adds a
/// migration step and a schema snapshot in `drift_schemas/` (see CLAUDE.md).
@DriftDatabase(tables: [Players, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The app's database file in the application support directory, which an
  /// APK update keeps.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'deskovky'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
      );
}
