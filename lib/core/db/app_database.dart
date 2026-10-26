import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// Local SQLite database. Every schema change bumps [schemaVersion], adds a
/// migration step and a schema snapshot in `drift_schemas/` (see CLAUDE.md).
@DriftDatabase(
  tables: [Players, AppSettings, GameSettingsLast, SavedSessions, Matches, MatchParticipants, PlayerCounters, EarnedBadges, PointsLedger, PlayerItems],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Database file name and directory. Both are pinned on purpose: an APK
  /// update keeps the app documents directory (`app_flutter/`), and the
  /// location must never follow a library default that could change.
  static const fileName = 'deskovky';
  static const databaseDirectory = getApplicationDocumentsDirectory;

  factory AppDatabase.open() => AppDatabase(
        driftDatabase(
          name: fileName,
          native: const DriftNativeOptions(databaseDirectory: databaseDirectory),
        ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v2: remembered game setup and saved games in progress.
          if (from < 2) {
            await m.createTable(gameSettingsLast);
            await m.createTable(savedSessions);
          }
          // v3: finished games, event counters and badges (milestone 6).
          if (from < 3) {
            await m.createTable(matches);
            await m.createTable(matchParticipants);
            await m.createTable(playerCounters);
            await m.createTable(earnedBadges);
          }
          // v4: points ledger (milestone 7).
          if (from < 4) await m.createTable(pointsLedger);
          // v5: bought avatar upgrades (milestone 7b).
          if (from < 5) await m.createTable(playerItems);
        },
        beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
      );
}
