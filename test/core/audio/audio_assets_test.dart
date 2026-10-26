import 'dart:convert';
import 'dart:io';

import 'package:deskovky/core/audio/audio_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const _fields = ['file', 'title', 'author', 'source_url', 'license', 'attribution_text'];

void main() {
  final credits = (jsonDecode(File('assets/audio/CREDITS.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final catalog = AudioCatalog.standard;
  final files = [...catalog.music.values, ...catalog.sfx.values];

  test('every catalog sound exists and is a non-empty audio file', () {
    for (final path in files) {
      final file = File('assets/audio/$path');
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
      expect(File('assets/audio/${c['file']}').existsSync(), isTrue, reason: '${c['file']}');
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
  });
}
