import 'package:deskovky/core/l10n/locale_resolution.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

void main() {
  test('every app language has its own name, written in that language', () {
    for (final l in supportedAppLocales) {
      expect(appLanguageName(l.languageCode), isNotEmpty);
    }
    expect(appLanguageName('cs'), 'Čeština');
    expect(appLanguageName('es'), 'Español');
  });

  test('the phone language is used when the app has it, English otherwise', () {
    for (final l in supportedAppLocales) {
      expect(resolveAppLocale([Locale(l.languageCode, 'XX')]), Locale(l.languageCode));
    }
    expect(resolveAppLocale(const [Locale('ja')]), const Locale('en'));
  });

  testWidgets('Settings show the language as one row; a list picks another and it is remembered', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await pumpApp(tester, size: const Size(360, 740), db: db);
    await tester.tap(find.text('Nastavení'));
    await _settle(tester);
    final row = find.byKey(const ValueKey('settingsLanguageRow'));
    expect(row, findsOneWidget);
    expect(find.descendant(of: row, matching: find.textContaining('Podle telefonu')), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    final sheetList = find.descendant(of: find.byType(BottomSheet), matching: find.byType(Scrollable)).first;
    for (final l in supportedAppLocales) {
      await tester.scrollUntilVisible(find.byKey(ValueKey('language_${l.languageCode}')), 60, scrollable: sheetList);
      expect(find.byKey(ValueKey('language_${l.languageCode}')), findsOneWidget);
    }
    await tester.scrollUntilVisible(find.byKey(const ValueKey('language_es')), -60, scrollable: sheetList);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language_es')));
    await _settle(tester);
    expect(find.text('Ajustes'), findsWidgets);
    expect(await tester.runAsync(() => SettingsRepository(db).watchLocale().first), const Locale('es'));

    // Back to the phone's language.
    await tester.tap(find.byKey(const ValueKey('settingsLanguageRow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('language_system')));
    await _settle(tester);
    expect(find.text('Nastavení'), findsWidgets);
  });

  testWidgets('the list scrolls, so many languages fit a small phone at 130 %', (tester) async {
    await pumpApp(tester, size: const Size(360, 640), textScale: 1.3);
    await tester.tap(find.text('Nastavení'));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('settingsLanguageRow')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });
}
