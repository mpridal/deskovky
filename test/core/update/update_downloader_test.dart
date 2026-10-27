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

/// Finished APKs in [dir] (a `.part` of an unfinished download may stay).
List<String> _apks(Directory dir) => [
  for (final f in dir.listSync()) if (f.path.endsWith('.apk')) f.uri.pathSegments.last,
];

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

  test('an HTTP error is tried again a few times, then fails without an APK to install', () async {
    var requests = 0;
    final downloader = UpdateDownloader(
      client: MockClient((_) async {
        requests++;
        return http.Response('nope', 500);
      }),
      directory: dir,
      attempts: 3,
      retryDelay: Duration.zero,
    );
    await expectLater(downloader.download(_release(apk)), throwsA(isA<http.ClientException>()));
    expect(requests, 3);
    expect(_apks(dir), isEmpty);
  });

  test('a download that stalls fails after the idle timeout instead of hanging forever', () async {
    final downloader = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        final stalled = StreamController<List<int>>();
        stalled.add([1, 2, 3]);
        return http.StreamedResponse(stalled.stream, 200, contentLength: 10);
      }),
      directory: dir,
      idleTimeout: const Duration(milliseconds: 100),
      attempts: 2,
      retryDelay: Duration.zero,
    );
    await expectLater(downloader.download(_release(apk)), throwsA(isA<TimeoutException>()));
    expect(_apks(dir), isEmpty);
  });

  test('a broken download continues where it stopped instead of starting over', () async {
    final ranges = <String?>[];
    final downloader = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        ranges.add(request.headers['range']);
        if (ranges.length == 1) {
          // The line drops after the first 100 kB (screen locked, signal lost).
          final broken = StreamController<List<int>>();
          broken.add(apk.sublist(0, 100000));
          broken.addError(const SocketException('Connection reset'));
          broken.close();
          return http.StreamedResponse(broken.stream, 200, contentLength: apk.length);
        }
        final from = int.parse(RegExp(r'bytes=(\d+)-').firstMatch(request.headers['range']!)!.group(1)!);
        return http.StreamedResponse(
          Stream.value(apk.sublist(from)),
          206,
          contentLength: apk.length - from,
          headers: {'content-range': 'bytes $from-${apk.length - 1}/${apk.length}'},
        );
      }),
      directory: dir,
      retryDelay: Duration.zero,
    );
    final file = await downloader.download(_release(apk));
    expect(ranges, [null, 'bytes=100000-']);
    expect(await file.readAsBytes(), apk);
  });

  test('a download that ended short is continued too', () async {
    final ranges = <String?>[];
    final downloader = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        ranges.add(request.headers['range']);
        if (ranges.length == 1) {
          return http.StreamedResponse(Stream.value(apk.sublist(0, 5000)), 200, contentLength: apk.length);
        }
        return http.StreamedResponse(Stream.value(apk.sublist(5000)), 206, contentLength: apk.length - 5000);
      }),
      directory: dir,
      retryDelay: Duration.zero,
    );
    final file = await downloader.download(_release(apk));
    expect(ranges, [null, 'bytes=5000-']);
    expect(await file.readAsBytes(), apk);
  });

  test('after a failed download the next tap continues from the part already downloaded', () async {
    final failing = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        final stalled = StreamController<List<int>>();
        stalled.add(apk.sublist(0, 7000));
        return http.StreamedResponse(stalled.stream, 200, contentLength: apk.length);
      }),
      directory: dir,
      idleTimeout: const Duration(milliseconds: 100),
      attempts: 1,
      retryDelay: Duration.zero,
    );
    await expectLater(failing.download(_release(apk)), throwsA(isA<TimeoutException>()));
    String? range;
    final later = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        range = request.headers['range'];
        return http.StreamedResponse(Stream.value(apk.sublist(7000)), 206, contentLength: apk.length - 7000);
      }),
      directory: dir,
    );
    final file = await later.download(_release(apk));
    expect(range, 'bytes=7000-');
    expect(await file.readAsBytes(), apk);
  });

  test('a server that ignores the range sends the whole file again, and it is used from the start', () async {
    var requests = 0;
    final downloader = UpdateDownloader(
      client: MockClient.streaming((request, _) async {
        requests++;
        if (requests == 1) {
          return http.StreamedResponse(Stream.value(apk.sublist(0, 9000)), 200, contentLength: apk.length);
        }
        return http.StreamedResponse(Stream.value(apk), 200, contentLength: apk.length);
      }),
      directory: dir,
      retryDelay: Duration.zero,
    );
    final file = await downloader.download(_release(apk));
    expect(await file.readAsBytes(), apk);
  });

  test('patience: a minute without data, five attempts', () {
    expect(UpdateDownloader.defaultIdleTimeout, const Duration(seconds: 60));
    expect(UpdateDownloader.defaultAttempts, 5);
  });

  test('older downloads are cleaned up when a new one completes', () async {
    File('${dir.path}/deskovky-0.0.9.apk').writeAsBytesSync([1]);
    final downloader = UpdateDownloader(client: MockClient((_) async => http.Response.bytes(apk, 200)), directory: dir);
    await downloader.download(_release(apk));
    expect(dir.listSync().map((f) => f.path.split(RegExp(r'[\\/]')).last), ['deskovky-0.1.1.apk']);
  });
}
