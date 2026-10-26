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
class UpdateDownloader {
  UpdateDownloader({required this.client, required Directory directory}) : _directory = (() async => directory);

  /// Downloads into `cache/updates/`, the only place the installer accepts.
  UpdateDownloader.cache({required this.client})
    : _directory = (() async => Directory('${(await getApplicationCacheDirectory()).path}/updates').create(recursive: true));

  final http.Client client;
  final Future<Directory> Function() _directory;

  Future<File>? _running;

  Future<File> download(ReleaseInfo release, {void Function(double progress)? onProgress}) =>
      _running ??= _download(release, onProgress).whenComplete(() => _running = null);

  Future<File> _download(ReleaseInfo release, void Function(double)? onProgress) async {
    final directory = await _directory();
    final target = File('${directory.path}/deskovky-${release.version}.apk');
    final part = File('${target.path}.part');
    try {
      final response = await client.send(http.Request('GET', release.apkUrl));
      if (response.statusCode != 200) {
        throw http.ClientException('HTTP ${response.statusCode}', release.apkUrl);
      }
      final total = response.contentLength;
      var received = 0;
      final sink = part.openWrite();
      final digest = _DigestSink();
      final hasher = sha256.startChunkedConversion(digest);
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          hasher.add(chunk);
          received += chunk.length;
          if (total != null && total > 0) onProgress?.call(received / total);
        }
      } finally {
        await sink.close();
        hasher.close();
      }
      final actual = digest.value.toString();
      if (actual != release.sha256) throw UpdateIntegrityException(release.sha256, actual);
      onProgress?.call(1);
      if (target.existsSync()) await target.delete();
      return await part.rename(target.path);
    } catch (_) {
      if (part.existsSync()) await part.delete();
      rethrow;
    }
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
