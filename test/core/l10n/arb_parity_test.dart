import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) => arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  test('cs, en and es ARB files define the same keys', () {
    final en = _messageKeys(_readArb('en'));
    expect(en, isNotEmpty);
    expect(_messageKeys(_readArb('cs')), en);
    expect(_messageKeys(_readArb('es')), en);
  });

  test('no translation is empty', () {
    for (final lang in ['cs', 'en', 'es']) {
      final arb = _readArb(lang);
      for (final key in _messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: '$lang:$key');
      }
    }
  });
}
