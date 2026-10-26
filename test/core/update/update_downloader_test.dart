import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deskovky/core/update/release_info.dart';
import 'package:deskovky/core/update/semver.dart';
import 'package:deskovky/core/update/update_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ReleaseInfo _release(List<int> bytes, {String? sha}) => ReleaseInfo(
  version: Semver(0, 1, 1),
  versionCode: 101,
  sha256: sha ?? sha256.convert(bytes).toString(),
  minSupportedVersion: Semver(0, 0, 0),
  apkUrl: Uri.parse('https://github.com/x/deskovky-0.1.1.apk'),
  notes: const {},
);

void main() {
  late Directory dir;
  final apk = List<int>.generate(300000, (i) => i % 251);

  setUp(() async => dir = await Directory.systemTemp.createTemp('deskovky_update'));
  tearDown(() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  });

  test('downloads the APK, reports progress and verifies SHA-256', () async {
    final progress = <double>[];
    final downloader = UpdateDownloader(client: MockClient((_) async => http.Response.bytes(apk, 200)), directory: dir);
    final file = await downloader.download(_release(apk), onProgress: progress.add);
    expect(await file.readAsBytes(), apk);
    expect(file.path, endsWith('deskovky-0.1.1.apk'));
    expect(progress.last, 1.0);
  });

  test('a file with a different hash is deleted and never offered for installation', () async {
    final downloader = UpdateDownloader(client: MockClient((_) async => http.Response.bytes(apk, 200)), directory: dir);
    await expectLater(downloader.download(_release(apk, sha: '00' * 32)), throwsA(isA<UpdateIntegrityException>()));
    expect(dir.listSync(), isEmpty);
  });

  test('asking twice while downloading starts only one download', () async {
    var requests = 0;
    final gate = Completer<void>();
    final downloader = UpdateDownloader(
      client: MockClient((_) async {
        requests++;
        await gate.future;
        return http.Response.bytes(apk, 200);
      }),
      directory: dir,
    );
    final first = downloader.download(_release(apk));
    final second = downloader.download(_release(apk));
    gate.complete();
    expect(await first, (await second));
    expect(requests, 1);
  });

  test('an HTTP error fails without leaving a file', () async {
    final downloader = UpdateDownloader(client: MockClient((_) async => http.Response('nope', 500)), directory: dir);
    await expectLater(downloader.download(_release(apk)), throwsA(isA<http.ClientException>()));
    expect(dir.listSync(), isEmpty);
  });
}
