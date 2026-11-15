import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';

Future<void> _openDonations(WidgetTester tester) async {
  await tester.tap(find.text('Dary'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the Dary tab says why the game deserves support and offers 2/5/10/25 €, with no donors list', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(412, 915));
    await _openDonations(tester);
    expect(GoRouter.of(tester.element(find.byType(NavigationBar))).state.uri.path, '/donations');
    expect(find.text('Žádné reklamy'), findsOneWidget);
    for (final amount in ['2 €', '5 €', '10 €', '25 €']) {
      expect(find.byKey(ValueKey('donate_$amount')), findsOneWidget, reason: amount);
    }
    expect(find.textContaining('dárc'), findsNothing, reason: 'no list of donors: it would need their consent');
  });

  testWidgets('a donate button does not take money yet: it says it comes with Google Play', (tester) async {
    await pumpApp(tester, size: const Size(412, 915));
    await _openDonations(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('donate_5 €')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('donate_5 €')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Přispívat půjde, až bude hra na Google Play. Děkujeme!'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  for (final (size, locale) in const [
    (Size(360, 740), Locale('cs')),
    (Size(360, 740), Locale('fr')),
    (Size(740, 360), Locale('en')),
    (Size(1280, 800), Locale('cs')),
  ]) {
    testWidgets('everything fits and the buttons can be reached ${size.width.toInt()}×${size.height.toInt()} $locale at 130 %', (
      tester,
    ) async {
      await pumpApp(tester, size: size, locale: locale, textScale: 1.3);
      await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('donate_25 €')));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const ValueKey('donate_25 €'))).bottom, lessThanOrEqualTo(size.height));
    });
  }

  testWidgets('golden: the Dary tab on a phone and on its side', (tester) async {
    await loadAppFonts();
    for (final (size, name) in const [(Size(412, 915), 'phone'), (Size(915, 412), 'landscape')]) {
      await pumpApp(tester, size: size);
      await _openDonations(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/donations_$name.png'));
    }
  }, skip: !Platform.isWindows);
}
