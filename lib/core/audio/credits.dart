import 'dart:convert';

import 'package:flutter/services.dart';

/// One entry of `assets/audio/CREDITS.json` (spec 7.4).
class Credit {
  const Credit({
    required this.file,
    required this.title,
    required this.author,
    required this.sourceUrl,
    required this.license,
    required this.attribution,
  });

  final String file;
  final String title;
  final String author;
  final String sourceUrl;
  final String license;

  /// The text CC BY asks to show, e.g. "Wallpaper" Kevin MacLeod (incompetech.com).
  final String attribution;
}

List<Credit> parseCredits(String json) => [
  for (final e in (jsonDecode(json) as List).cast<Map<String, dynamic>>())
    Credit(
      file: e['file'] as String,
      title: e['title'] as String,
      author: e['author'] as String,
      sourceUrl: e['source_url'] as String,
      license: e['license'] as String,
      attribution: e['attribution_text'] as String,
    ),
];

/// The shared credits plus each game's optional `assets/games/<id>/CREDITS.json`
/// (only files the app actually bundles are read).
Future<List<Credit>> loadCredits(AssetBundle bundle, {Iterable<String> games = const []}) async {
  final bundled = games.isEmpty ? const <String>{} : (await AssetManifest.loadFromAssetBundle(bundle)).listAssets().toSet();
  return [
    ...parseCredits(await bundle.loadString('assets/audio/CREDITS.json')),
    for (final id in games)
      if (bundled.contains('assets/games/$id/CREDITS.json'))
        ...parseCredits(await bundle.loadString('assets/games/$id/CREDITS.json')),
  ];
}
