import 'package:deskovky/core/l10n/locale_resolution.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ten languages: cs, en, es, sk, de, pl, pt, fr, it, uk', () {
    expect([for (final l in supportedAppLocales) l.languageCode], ['cs', 'en', 'es', 'sk', 'de', 'pl', 'pt', 'fr', 'it', 'uk']);
  });

  group('resolveAppLocale', () {
    final cases = <List<Locale>?, Locale>{
      [const Locale('cs', 'CZ')]: const Locale('cs'),
      [const Locale('cs')]: const Locale('cs'),
      [const Locale('es', 'MX')]: const Locale('es'),
      [const Locale('es', '419')]: const Locale('es'),
      [const Locale('sk', 'SK')]: const Locale('sk'),
      [const Locale('de'), const Locale('cs')]: const Locale('de'),
      [const Locale('pt', 'BR')]: const Locale('pt'),
      [const Locale('uk', 'UA')]: const Locale('uk'),
      [const Locale('ja'), const Locale('cs')]: const Locale('en'),
      <Locale>[]: const Locale('en'),
      null: const Locale('en'),
    };
    cases.forEach((input, expected) {
      test('$input -> $expected', () {
        expect(resolveAppLocale(input), expected);
      });
    });
  });
}
