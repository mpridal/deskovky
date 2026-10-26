import 'package:flutter/foundation.dart';

import 'semver.dart';

/// The newest release on GitHub with its `latest.json` (spec 4).
@immutable
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.versionCode,
    required this.sha256,
    required this.minSupportedVersion,
    required this.apkUrl,
    required this.notes,
  });

  final Semver version;
  final int versionCode;

  /// Lower-case hex SHA-256 of the APK.
  final String sha256;
  final Semver minSupportedVersion;
  final Uri apkUrl;

  /// Release notes by language code.
  final Map<String, String> notes;

  String notesFor(String languageCode) => notes[languageCode] ?? notes['en'] ?? '';

  /// Builds from the GitHub API release and its `latest.json`; null when
  /// anything is missing or inconsistent (then no update is offered).
  static ReleaseInfo? fromGitHub({required Map<String, Object?> release, required Map<String, Object?> latestJson}) {
    final tag = Semver.parse('${release['tag_name']}');
    final version = Semver.parse('${latestJson['version']}');
    final minSupported = Semver.parse('${latestJson['minSupportedVersion'] ?? '0.0.0'}');
    final sha = '${latestJson['sha256']}'.toLowerCase();
    final versionCode = latestJson['versionCode'];
    if (tag == null || version == null || minSupported == null || tag != version) return null;
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha) || versionCode != version.versionCode) return null;
    final assets = release['assets'];
    final apk = assets is List
        ? assets.whereType<Map<String, Object?>>().where((a) => a['name'] == 'deskovky-$version.apk').firstOrNull
        : null;
    final url = Uri.tryParse('${apk?['browser_download_url']}');
    if (apk == null || url == null || !url.hasScheme) return null;
    return ReleaseInfo(
      version: version,
      versionCode: version.versionCode,
      sha256: sha,
      minSupportedVersion: minSupported,
      apkUrl: url,
      notes: {
        for (final lang in ['cs', 'en', 'es'])
          if (latestJson['notes_$lang'] case final String text) lang: text,
      },
    );
  }
}
