import 'package:deskovky/core/l10n/locale_resolution.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supported locales are cs, en, es', () {
    expect(supportedAppLocales, const [Locale('cs'), Locale('en'), Locale('es')]);
  });

  group('resolveAppLocale', () {
    final cases = <List<Locale>?, Locale>{
      [const Locale('cs', 'CZ')]: const Locale('cs'),
      [const Locale('cs')]: const Locale('cs'),
      [const Locale('es', 'MX')]: const Locale('es'),
      [const Locale('es', '419')]: const Locale('es'),
      [const Locale('sk', 'SK')]: const Locale('en'),
      [const Locale('de'), const Locale('cs')]: const Locale('en'),
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
