import 'package:crypto/crypto.dart';

/// `latest.json` for a release (spec 4): version, versionCode, SHA-256 of the
/// APK, minimum supported version and notes in cs/en/es, all taken from the
/// version's section in CHANGELOG.md:
///
/// ```
/// ## 0.1.1
/// Minimální verze: 0.1.0      (optional – makes older versions update)
/// ### cs
/// …
/// ### en
/// …
/// ### es
/// …
/// ```
Map<String, Object?> buildLatestJson({
  required String version,
  required List<int> apkBytes,
  required String changelog,
}) {
  final parts = RegExp(r'^(\d+)\.(\d+)\.(\d+)$').firstMatch(version);
  if (parts == null) throw ArgumentError.value(version, 'version', 'expected major.minor.patch');
  if (int.parse(parts[2]!) > 99 || int.parse(parts[3]!) > 99) {
    throw ArgumentError.value(version, 'version', 'minor and patch must be 0–99 (versionCode)');
  }
  final sections = changelog.split(RegExp(r'^## ', multiLine: true));
  final section = sections.where((s) => s.split('\n').first.trim() == version).firstOrNull;
  if (section == null) throw StateError('CHANGELOG.md has no "## $version" section');
  final minimum = RegExp(r'^Minimální verze: (\d+\.\d+\.\d+)', multiLine: true).firstMatch(section)?[1];
  String notes(String lang) {
    // Lines after "### <lang>" up to the next "### " heading or the end.
    final lines = section.split('\n');
    final start = lines.indexWhere((l) => l.trim() == '### $lang');
    if (start < 0) throw StateError('CHANGELOG.md $version has no "### $lang" notes');
    return lines.skip(start + 1).takeWhile((l) => !l.startsWith('### ')).join('\n').trim();
  }

  return {
    'version': version,
    'versionCode': int.parse(parts[1]!) * 10000 + int.parse(parts[2]!) * 100 + int.parse(parts[3]!),
    'sha256': sha256.convert(apkBytes).toString(),
    'minSupportedVersion': minimum ?? '0.0.0',
    'notes_cs': notes('cs'),
    'notes_en': notes('en'),
    'notes_es': notes('es'),
  };
}
