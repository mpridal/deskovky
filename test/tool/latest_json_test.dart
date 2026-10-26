import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/release/latest_json.dart';

const _changelog = '''
# Změny / Changes / Cambios

## 0.1.1
Minimální verze: 0.1.0

### cs
- Opravy
### en
- Fixes
### es
- Arreglos

## 0.1.0

### cs
První verze.
### en
First version.
### es
Primera versión.
''';

void main() {
  test('builds latest.json for a version from CHANGELOG.md and the APK hash', () {
    final json = buildLatestJson(version: '0.1.1', apkBytes: [1, 2, 3], changelog: _changelog);
    expect(json['version'], '0.1.1');
    expect(json['versionCode'], 101);
    expect(json['sha256'], '039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81');
    expect(json['minSupportedVersion'], '0.1.0');
    expect(json['notes_cs'], '- Opravy');
    expect(json['notes_es'], '- Arreglos');
  });

  test('without a minimum line nothing is mandatory', () {
    expect(buildLatestJson(version: '0.1.0', apkBytes: [], changelog: _changelog)['minSupportedVersion'], '0.0.0');
  });

  test('a version missing from CHANGELOG.md stops the release', () {
    expect(() => buildLatestJson(version: '0.2.0', apkBytes: [], changelog: _changelog), throwsStateError);
  });

  test('the version in pubspec.yaml has a CHANGELOG.md entry and the matching build number', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version: (\d+)\.(\d+)\.(\d+)\+(\d+)$', multiLine: true).firstMatch(pubspec)!;
    final version = '${match[1]}.${match[2]}.${match[3]}';
    expect(
      int.parse(match[4]!),
      int.parse(match[1]!) * 10000 + int.parse(match[2]!) * 100 + int.parse(match[3]!),
      reason: 'build number = versionCode',
    );
    expect(
      () => buildLatestJson(version: version, apkBytes: [], changelog: File('CHANGELOG.md').readAsStringSync()),
      returnsNormally,
    );
  });
}
