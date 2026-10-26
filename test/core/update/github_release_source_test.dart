import 'dart:convert';

import 'package:deskovky/core/update/github_release_source.dart';
import 'package:deskovky/core/update/semver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final release = {
    'tag_name': 'v0.1.1',
    'assets': [
      {'name': 'deskovky-0.1.1.apk', 'browser_download_url': 'https://github.com/x/deskovky-0.1.1.apk'},
      {'name': 'latest.json', 'browser_download_url': 'https://github.com/x/latest.json'},
    ],
  };
  final latest = {'version': '0.1.1', 'versionCode': 101, 'sha256': 'ab' * 32, 'minSupportedVersion': '0.1.0'};

  test('reads the latest release of mpridal/deskovky and its latest.json, without a token', () async {
    final requested = <Uri>[];
    final client = MockClient((request) async {
      requested.add(request.url);
      expect(request.headers.containsKey('Authorization'), isFalse);
      return switch (request.url.path) {
        '/repos/mpridal/deskovky/releases/latest' => http.Response(jsonEncode(release), 200),
        '/x/latest.json' => http.Response(jsonEncode(latest), 200),
        _ => http.Response('', 404),
      };
    });
    final info = await GitHubReleaseSource(client: client).latest();
    expect(info!.version, Semver(0, 1, 1));
    expect(requested.first.toString(), 'https://api.github.com/repos/mpridal/deskovky/releases/latest');
  });

  test('no release yet (404) or a release without latest.json gives null', () async {
    expect(await GitHubReleaseSource(client: MockClient((_) async => http.Response('', 404))).latest(), isNull);
    final noJson = {...release, 'assets': [(release['assets']! as List).first]};
    expect(
      await GitHubReleaseSource(client: MockClient((_) async => http.Response(jsonEncode(noJson), 200))).latest(),
      isNull,
    );
  });

  test('a 403 rate limit is an error the service turns into a silent failure', () async {
    final source = GitHubReleaseSource(client: MockClient((_) async => http.Response('rate limited', 403)));
    expect(source.latest(), throwsA(isA<http.ClientException>()));
  });

  test('latest.json is read as UTF-8 even without a charset header (GitHub asset downloads)', () async {
    final czech = {...latest, 'notes_cs': 'Zkouška aktualizace: hráči a body zůstávají.'};
    final client = MockClient((request) async {
      final body = request.url.path == '/x/latest.json' ? jsonEncode(czech) : jsonEncode(release);
      // Raw UTF-8 bytes, content type without a charset, as objects.githubusercontent.com sends it.
      return http.Response.bytes(utf8.encode(body), 200, headers: {'content-type': 'application/octet-stream'});
    });
    final info = await GitHubReleaseSource(client: client).latest();
    expect(info!.notesFor('cs'), 'Zkouška aktualizace: hráči a body zůstávají.');
  });
}
