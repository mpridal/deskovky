import 'dart:async';
import 'dart:io';

import 'package:deskovky/core/update/apk_installer.dart';
import 'package:deskovky/core/update/release_info.dart';
import 'package:deskovky/core/update/semver.dart';
import 'package:deskovky/core/update/update_downloader.dart';
import 'package:deskovky/core/update/update_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ReleaseInfo fakeRelease(String version, {String minSupported = '0.0.0'}) => ReleaseInfo(
  version: Semver.parse(version)!,
  versionCode: Semver.parse(version)!.versionCode,
  sha256: 'ab' * 32,
  minSupportedVersion: Semver.parse(minSupported)!,
  apkUrl: Uri.parse('https://example.org/deskovky-$version.apk'),
  notes: const {'cs': 'Nové piškvorky!', 'en': 'New tic-tac-toe!', 'es': '¡Tres en raya nuevo!'},
);

/// Answers [release]; null means nothing usable was published.
class FakeReleaseSource implements ReleaseSource {
  FakeReleaseSource([this.release]);

  ReleaseInfo? release;

  @override
  Future<ReleaseInfo?> latest() async => release;
}

class FakeApkInstaller implements ApkInstaller {
  FakeApkInstaller({this.version = '0.1.0', this.allowed = true, this.canInstallGate});

  /// When set, `canInstall` waits for it (a slow platform answer).
  Completer<void>? canInstallGate;

  final String version;
  bool allowed;
  final installed = <String>[];
  var settingsOpened = 0;

  @override
  Future<String> appVersion() async => version;

  @override
  Future<bool> canInstall() async {
    await canInstallGate?.future;
    return allowed;
  }

  @override
  Future<void> openInstallSettings() async => settingsOpened++;

  @override
  Future<void> install(String path) async => installed.add(path);
}

/// Pretends to download: no network, no files.
class FakeUpdateDownloader extends UpdateDownloader {
  FakeUpdateDownloader({this.fail = false})
    : super(client: MockClient((_) async => http.Response('', 500)), directory: Directory.systemTemp);

  bool fail;
  var downloads = 0;

  @override
  Future<File> download(ReleaseInfo release, {void Function(double progress)? onProgress}) async {
    downloads++;
    if (fail) throw const UpdateIntegrityException('a', 'b');
    onProgress?.call(0.5);
    onProgress?.call(1);
    return File('${Directory.systemTemp.path}/updates/deskovky-${release.version}.apk');
  }
}
