import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'release_info.dart';

/// The downloaded file does not match `latest.json` (damaged or forged).
class UpdateIntegrityException implements Exception {
  const UpdateIntegrityException(this.expected, this.actual);

  final String expected;
  final String actual;

  @override
  String toString() => 'UpdateIntegrityException: expected $expected, got $actual';
}

/// Downloads a release APK into [directory] and verifies its SHA-256
/// (spec 4.6). One download at a time; a second request joins the first.
///
/// On mobile data the line often drops (screen locked, weak signal): the
/// unfinished `.part` file is kept and every next attempt – a retry after
/// [retryDelay], or the next tap on Aktualizovat – continues where it
/// stopped (HTTP Range). Only a file with the right hash becomes the APK.
class UpdateDownloader {
  UpdateDownloader({
    required this.client,
    required Directory directory,
    this.idleTimeout = defaultIdleTimeout,
    this.attempts = defaultAttempts,
    this.retryDelay = defaultRetryDelay,
  }) : _directory = (() async => directory);

  /// Downloads into `cache/updates/`, the only place the installer accepts.
  UpdateDownloader.cache({required this.client})
    : idleTimeout = defaultIdleTimeout,
      attempts = defaultAttempts,
      retryDelay = defaultRetryDelay,
      _directory = (() async => Directory('${(await getApplicationCacheDirectory()).path}/updates').create(recursive: true));

  static const defaultIdleTimeout = Duration(seconds: 60);
  static const defaultAttempts = 5;
  static const defaultRetryDelay = Duration(seconds: 3);

  final http.Client client;

  /// An attempt that receives nothing for this long gives up (Wi-Fi gone).
  final Duration idleTimeout;

  /// Attempts per download before it fails; each continues the last one.
  final int attempts;
  final Duration retryDelay;
  final Future<Directory> Function() _directory;

  Future<File>? _running;

  Future<File> download(ReleaseInfo release, {void Function(double progress)? onProgress}) =>
      _running ??= _download(release, onProgress).whenComplete(() => _running = null);

  Future<File> _download(ReleaseInfo release, void Function(double)? onProgress) async {
    final directory = await _directory();
    final target = File('${directory.path}/deskovky-${release.version}.apk');
    final part = File('${target.path}.part');
    for (var attempt = 1; ; attempt++) {
      try {
        await _fetch(release, part, onProgress);
        break;
      } on UpdateIntegrityException {
        // Damaged or forged: never kept, never continued.
        if (part.existsSync()) await part.delete();
        rethrow;
      } catch (_) {
        if (attempt >= attempts) rethrow;
        await Future<void>.delayed(retryDelay);
      }
    }
    final actual = await _hashOf(part);
    if (actual != release.sha256) {
      await part.delete();
      throw UpdateIntegrityException(release.sha256, actual);
    }
    onProgress?.call(1);
    if (target.existsSync()) await target.delete();
    final done = await part.rename(target.path);
    // Older downloads would only take space (~37 MB each).
    String name(File f) => f.uri.pathSegments.last;
    for (final old in directory.listSync().whereType<File>()) {
      if (name(old) != name(done)) await old.delete();
    }
    return done;
  }

  /// One attempt: continues [part] from its length; throws when the line
  /// fails or ends before the whole file arrived.
  Future<void> _fetch(ReleaseInfo release, File part, void Function(double)? onProgress) async {
    final have = part.existsSync() ? part.lengthSync() : 0;
    final request = http.Request('GET', release.apkUrl);
    if (have > 0) request.headers['range'] = 'bytes=$have-';
    final response = await client.send(request).timeout(idleTimeout);
    final int start;
    if (response.statusCode == 206 && have > 0) {
      start = have;
    } else if (response.statusCode == 200) {
      // The server ignored the range: the whole file again, from the start.
      start = 0;
    } else {
      await response.stream.drain<void>().catchError((Object _) {});
      if (response.statusCode == 416) {
        // The part is not a prefix of this file (or already whole): start over.
        await part.delete();
      }
      throw http.ClientException('HTTP ${response.statusCode}', release.apkUrl);
    }
    final length = response.contentLength;
    final total = length == null || length <= 0 ? null : start + length;
    var received = start;
    final sink = part.openWrite(mode: start == 0 ? FileMode.write : FileMode.append);
    try {
      await for (final chunk in response.stream.timeout(idleTimeout)) {
        sink.add(chunk);
        received += chunk.length;
        if (total != null) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }
    if (total != null && received < total) {
      throw http.ClientException('Download ended at $received of $total bytes', release.apkUrl);
    }
  }

  static Future<String> _hashOf(File file) async => (await sha256.bind(file.openRead()).first).toString();
}
