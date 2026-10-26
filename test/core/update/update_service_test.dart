import 'dart:async';

import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/update/release_info.dart';
import 'package:deskovky/core/update/semver.dart';
import 'package:deskovky/core/update/update_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Source implements ReleaseSource {
  _Source(this.answer);

  FutureOr<ReleaseInfo?> Function() answer;
  int calls = 0;

  @override
  Future<ReleaseInfo?> latest() async {
    calls++;
    return answer();
  }
}

ReleaseInfo _release(String version, {String minSupported = '0.0.0'}) => ReleaseInfo(
  version: Semver.parse(version)!,
  versionCode: Semver.parse(version)!.versionCode,
  sha256: 'ab' * 32,
  minSupportedVersion: Semver.parse(minSupported)!,
  apkUrl: Uri.parse('https://example.org/deskovky-$version.apk'),
  notes: const {'cs': 'Novinky', 'en': 'News', 'es': 'Novedades'},
);

void main() {
  group('semver', () {
    test('parses tags and pubspec versions; compares numerically', () {
      expect(Semver.parse('v1.3.0'), Semver(1, 3, 0));
      expect(Semver.parse('0.1.2+7'), Semver(0, 1, 2));
      expect(Semver.parse('1.10.0')! > Semver.parse('1.9.9')!, isTrue);
      expect(Semver.parse('banana'), isNull);
      expect(Semver.parse('v1.2'), isNull);
    });

    test('versionCode = major·10000 + minor·100 + patch', () {
      expect(Semver(1, 3, 7).versionCode, 10307);
    });
  });

  group('latest.json', () {
    test('a GitHub release with latest.json and the APK asset becomes ReleaseInfo', () {
      final info = ReleaseInfo.fromGitHub(
        release: {
          'tag_name': 'v0.1.1',
          'assets': [
            {'name': 'deskovky-0.1.1.apk', 'browser_download_url': 'https://x/deskovky-0.1.1.apk'},
            {'name': 'latest.json', 'browser_download_url': 'https://x/latest.json'},
          ],
        },
        latestJson: {
          'version': '0.1.1',
          'versionCode': 101,
          'sha256': 'cd' * 32,
          'minSupportedVersion': '0.1.0',
          'notes_cs': 'Opravy',
          'notes_en': 'Fixes',
          'notes_es': 'Arreglos',
        },
      );
      expect(info!.version, Semver(0, 1, 1));
      expect(info.apkUrl.toString(), 'https://x/deskovky-0.1.1.apk');
      expect(info.notesFor('es'), 'Arreglos');
      expect(info.notesFor('de'), 'Fixes', reason: 'English for other languages');
    });

    test('a release without the APK, a bad hash or a tag that disagrees is rejected', () {
      Map<String, Object?> json({String sha = '', String version = '0.1.1'}) => {
        'version': version,
        'versionCode': 101,
        'sha256': sha.isEmpty ? 'cd' * 32 : sha,
        'minSupportedVersion': '0.1.0',
      };
      final release = {
        'tag_name': 'v0.1.1',
        'assets': [
          {'name': 'deskovky-0.1.1.apk', 'browser_download_url': 'https://x/a.apk'},
        ],
      };
      expect(ReleaseInfo.fromGitHub(release: {'tag_name': 'v0.1.1', 'assets': []}, latestJson: json()), isNull);
      expect(ReleaseInfo.fromGitHub(release: release, latestJson: json(sha: 'xyz')), isNull);
      expect(ReleaseInfo.fromGitHub(release: release, latestJson: json(version: '0.1.2')), isNull);
      expect(ReleaseInfo.fromGitHub(release: release, latestJson: {'nonsense': true}), isNull);
    });
  });

  group('checking', () {
    late AppDatabase db;
    late SettingsRepository settings;
    var now = DateTime(2026, 10, 26, 12);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      settings = SettingsRepository(db);
      now = DateTime(2026, 10, 26, 12);
    });
    tearDown(() => db.close());

    UpdateService service(_Source source, {String current = '0.1.0'}) => UpdateService(
      source: source,
      settings: settings,
      currentVersion: Semver.parse(current)!,
      now: () => now,
    );

    test('a newer release is offered; the same or older is not', () async {
      expect(await service(_Source(() => _release('0.1.1'))).check(), isA<UpdateAvailable>());
      now = now.add(const Duration(hours: 7));
      expect(await service(_Source(() => _release('0.1.0'))).check(), isA<UpToDate>());
    });

    test('at most once in 6 hours unless forced; auto-check can be switched off', () async {
      final source = _Source(() => _release('0.1.1'));
      await service(source).check();
      now = now.add(const Duration(hours: 5));
      expect(await service(source).check(), isA<NotChecked>());
      expect(source.calls, 1);
      expect(await service(source).check(force: true), isA<UpdateAvailable>());
      expect(source.calls, 2);
      await settings.setAutoCheckUpdates(false);
      now = now.add(const Duration(days: 1));
      expect(await service(source).check(), isA<NotChecked>());
      expect(await service(source).check(force: true), isA<UpdateAvailable>(), reason: '"Zkontrolovat teď" still works');
    });

    test('errors, garbage and a slow network are silent and never take longer than 4 s', () async {
      expect(await service(_Source(() => throw Exception('403 rate limit'))).check(), isA<CheckFailed>());
      expect(await service(_Source(() => null)).check(force: true), isA<CheckFailed>());
      final slow = Completer<ReleaseInfo?>();
      final started = DateTime.now();
      final result = await service(_Source(() => slow.future)).check(force: true, timeout: const Duration(milliseconds: 50));
      expect(result, isA<CheckFailed>());
      expect(DateTime.now().difference(started), lessThan(const Duration(seconds: 2)));
    });

    test('an update is mandatory only when the minimum supported version is newer than ours', () async {
      final optional = await service(_Source(() => _release('0.2.0', minSupported: '0.1.0'))).check();
      expect((optional as UpdateAvailable).mandatory, isFalse);
      now = now.add(const Duration(hours: 7));
      final mandatory = await service(_Source(() => _release('0.2.0', minSupported: '0.1.5'))).check();
      expect((mandatory as UpdateAvailable).mandatory, isTrue);
    });
  });
}
