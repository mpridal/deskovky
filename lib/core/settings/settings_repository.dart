import 'dart:ui';

import '../db/app_database.dart';
import '../l10n/locale_resolution.dart';

/// App-wide settings persisted in the `app_settings` key–value table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _activePlayerKey = 'activePlayerId';
  static const _localeKey = 'locale';

  Stream<int?> watchActivePlayerId() => _watch(_activePlayerKey).map((v) => v == null ? null : int.tryParse(v));

  Future<void> setActivePlayerId(int? id) => _set(_activePlayerKey, id?.toString());

  /// The chosen language, or null to follow the system (spec 1).
  Stream<Locale?> watchLocale() => _watch(_localeKey).map(
        (code) => supportedAppLocales.where((l) => l.languageCode == code).firstOrNull,
      );

  Future<void> setLocale(Locale? locale) => _set(_localeKey, locale?.languageCode);

  Stream<String?> _watch(String key) => (_db.select(_db.appSettings)..where((s) => s.key.equals(key)))
      .watchSingleOrNull()
      .map((row) => row?.value)
      .distinct();

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.appSettings)..where((s) => s.key.equals(key))).go();
    } else {
      await _db.into(_db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
    }
  }
}
