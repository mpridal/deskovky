import 'dart:convert';
import 'dart:io';

import 'package:deskovky/core/audio/audio_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const _fields = ['file', 'title', 'author', 'source_url', 'license', 'attribution_text'];

void main() {
  List<Map<String, dynamic>> read(File f) => (jsonDecode(f.readAsStringSync()) as List).cast<Map<String, dynamic>>();
  final gameCredits = Directory('assets/games').existsSync()
      ? [
          for (final d in Directory('assets/games').listSync().whereType<Directory>())
            if (File('${d.path}/CREDITS.json').existsSync()) ...read(File('${d.path}/CREDITS.json')),
        ]
      : <Map<String, dynamic>>[];
  final credits = [...read(File('assets/audio/CREDITS.json')), ...gameCredits];
  String assetOf(String path) => path.startsWith('games/') ? 'assets/$path' : 'assets/audio/$path';
  final catalog = AudioCatalog.standard;
  final files = [...catalog.music.values, ...catalog.sfx.values];

  test('every catalog sound exists and is a non-empty audio file', () {
    for (final path in files) {
      final file = File(assetOf(path));
      expect(file.existsSync(), isTrue, reason: path);
      expect(file.lengthSync(), greaterThan(1000), reason: path);
    }
  });

  test('every catalog sound has a complete CREDITS.json entry (spec 7.4)', () {
    final byFile = {for (final c in credits) c['file']: c};
    for (final path in files) {
      final entry = byFile[path];
      expect(entry, isNotNull, reason: path);
      for (final field in _fields) {
        expect(entry![field], isA<String>(), reason: '$path.$field');
      }
      expect((entry!['title'] as String).isNotEmpty && (entry['license'] as String).isNotEmpty, isTrue);
    }
  });

  test('the menu and Hádej číslo play real music, each its own track', () {
    final byFile = {for (final c in credits) c['file']: c};
    final menu = catalog.music['menu']!, sample = catalog.music['sample']!;
    expect(menu, isNot(sample));
    for (final path in [menu, sample]) {
      expect(byFile[path]!['author'], 'Kevin MacLeod', reason: path);
      expect(byFile[path]!['license'], 'CC BY 4.0', reason: path);
      expect(byFile[path]!['attribution_text'], contains('Kevin MacLeod (incompetech.com)'), reason: path);
    }
  });

  test('CREDITS.json lists only files that exist', () {
    for (final c in credits) {
      expect(File(assetOf(c['file'] as String)).existsSync(), isTrue, reason: '${c['file']}');
    }
  });

  test('the four new games play their Kevin MacLeod tracks (spec 7.2)', () {
    final byFile = {for (final c in credits) c['file']: c};
    for (final (id, title) in [
      ('tictactoe', 'Local Forecast - Elevator'),
      ('memory', 'Monkeys Spinning Monkeys'),
      ('minesweeper', 'Sneaky Snitch'),
      ('ludo', 'Fluffing a Duck'),
    ]) {
      final entry = byFile['music/$id.ogg'];
      expect(entry, isNotNull, reason: id);
      expect((entry!['title'], entry['author'], entry['license']), (title, 'Kevin MacLeod', 'CC BY 4.0'), reason: id);
    }
  });

  test('every game effect from spec 13.5–13.8 exists as a credited placeholder', () {
    final byFile = {for (final c in credits) c['file']: c};
    for (final path in [
      'games/tictactoe/sfx/draw.ogg', 'games/tictactoe/sfx/line.ogg', //
      'games/memory/sfx/match.ogg', 'games/memory/sfx/miss.ogg',
      'games/minesweeper/sfx/dig.ogg', 'games/minesweeper/sfx/flag.ogg', 'games/minesweeper/sfx/puff.ogg',
      'games/ludo/sfx/hop.ogg', 'games/ludo/sfx/boing.ogg', 'games/ludo/sfx/home.ogg',
    ]) {
      expect(File(assetOf(path)).existsSync(), isTrue, reason: path);
      expect(byFile[path], isNotNull, reason: path);
    }
  });

  test('music fits the 15 MB budget (spec 7.1)', () {
    final bytes = Directory(
      'assets/audio/music',
    ).listSync().whereType<File>().fold<int>(0, (sum, f) => sum + f.lengthSync());
    expect(bytes, lessThanOrEqualTo(15 * 1024 * 1024));
  });

  test('pubspec bundles the audio folders and credits', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('- assets/audio/music/'));
    expect(pubspec, contains('- assets/audio/sfx/'));
    expect(pubspec, contains('- assets/audio/CREDITS.json'));
    for (final id in ['tictactoe', 'memory', 'minesweeper', 'ludo', 'checkers']) {
      expect(pubspec, contains('- assets/games/$id/'), reason: id);
      expect(pubspec, contains('- assets/games/$id/sfx/'), reason: id);
    }
    for (final set in ['animals', 'food', 'transport', 'space']) {
      expect(pubspec, contains('- assets/games/memory/cards/$set/'), reason: set);
    }
  });
}
