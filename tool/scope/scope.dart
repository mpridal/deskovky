/// The paths a `game/<id>` branch may change (spec 13.2 bod 2, with the game
/// code under `lib/` because that is where Flutter keeps it).
List<String> allowedPrefixes(String gameId) => [
  'lib/games/$gameId/',
  'assets/games/$gameId/',
  'test/games/$gameId/',
];

/// The changed [files] a [branch] must not touch: for `game/<id>` everything
/// outside its own folders and its music; other branches are not limited.
List<String> outOfScope(String branch, Iterable<String> files) {
  final match = RegExp(r'(?:^|/)game/([a-z_]+)$').firstMatch(branch);
  if (match == null) return const [];
  final id = match[1]!;
  final prefixes = allowedPrefixes(id);
  final music = 'assets/audio/music/$id.ogg';
  return [
    for (final raw in files)
      if (raw.trim().replaceAll(r'\', '/') case final file when file.isNotEmpty)
        if (file != music && !prefixes.any(file.startsWith)) file,
  ];
}
