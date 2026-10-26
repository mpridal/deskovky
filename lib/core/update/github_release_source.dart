import 'dart:convert';

import 'package:http/http.dart' as http;

import 'release_info.dart';
import 'update_service.dart';

/// The newest release from the public GitHub repository (spec 4.2): no token,
/// so the repository with the releases must stay public.
class GitHubReleaseSource implements ReleaseSource {
  GitHubReleaseSource({http.Client? client, this.owner = 'mpridal', this.repo = 'deskovky'})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String owner;
  final String repo;

  @override
  Future<ReleaseInfo?> latest() async {
    final release = await _getJson(Uri.https('api.github.com', '/repos/$owner/$repo/releases/latest'));
    if (release == null) return null;
    final assets = release['assets'];
    final jsonAsset = assets is List
        ? assets.whereType<Map<String, Object?>>().where((a) => a['name'] == 'latest.json').firstOrNull
        : null;
    final url = Uri.tryParse('${jsonAsset?['browser_download_url']}');
    if (url == null || !url.hasScheme) return null;
    final latestJson = await _getJson(url);
    return latestJson == null ? null : ReleaseInfo.fromGitHub(release: release, latestJson: latestJson);
  }

  /// The decoded object; null for 404 (no release yet); throws on other errors.
  Future<Map<String, Object?>?> _getJson(Uri url) async {
    final response = await _client.get(url, headers: const {'Accept': 'application/vnd.github+json'});
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) throw http.ClientException('HTTP ${response.statusCode}', url);
    // Always UTF-8: asset downloads come without a charset, and `body` would
    // then decode as Latin-1 ("ZkouÅ¡ka").
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body is Map<String, Object?> ? body : null;
  }
}
