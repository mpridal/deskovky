import 'dart:ui';

import '../db/app_database.dart';
import '../l10n/locale_resolution.dart';

/// App-wide settings persisted in the `app_settings` key–value table.
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// Also written by [PlayerRepository] inside its transactions.
  static const activePlayerKey = 'activePlayerId';
  static const _localeKey = 'locale';
  static const _musicKey = 'musicOn';
  static const _sfxKey = 'sfxOn';

  Stream<int?> watchActivePlayerId() => _watch(activePlayerKey).map((v) => v == null ? null : int.tryParse(v));

  Future<void> setActivePlayerId(int? id) => _set(activePlayerKey, id?.toString());

  /// The chosen language, or null to follow the system (spec 1).
  Stream<Locale?> watchLocale() => _watch(_localeKey).map(
        (code) => supportedAppLocales.where((l) => l.languageCode == code).firstOrNull,
      );

  Future<void> setLocale(Locale? locale) => _set(_localeKey, locale?.languageCode);

  /// Music and sound effects are on unless switched off (spec 5.8, 7.1).
  Stream<bool> watchMusicOn() => _watch(_musicKey).map((v) => v != 'false');

  Future<void> setMusicOn(bool on) => _set(_musicKey, '$on');

  Stream<bool> watchSfxOn() => _watch(_sfxKey).map((v) => v != 'false');

  Future<void> setSfxOn(bool on) => _set(_sfxKey, '$on');

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
