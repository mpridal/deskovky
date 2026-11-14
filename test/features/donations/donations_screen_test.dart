import 'dart:io';

import 'package:deskovky/core/donations/donors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

class _Source implements DonorsSource {
  _Source(this.result);

  List<Donor>? result;
  var offline = false;

  @override
  Future<List<Donor>?> fetch() async {
    if (offline) throw http.ClientException('offline');
    return result;
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

Future<void> _openDonations(WidgetTester tester) async {
  await tester.tap(find.text('Dary'));
  await _settle(tester);
}

final _many = [
  for (var i = 0; i < 40; i++)
    Donor(name: 'Dárce $i', amount: i.isEven ? 5 : 10, currency: 'EUR', date: DateTime(2026, 11, 1 + i % 28)),
];

void main() {
  testWidgets('the Dary tab says why the game deserves support, offers 2/5/10/25 € and thanks the donors', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(412, 915),
      donors: _Source([
        Donor(name: 'Babička Jana', amount: 25, currency: 'EUR', date: DateTime(2026, 11, 2)),
        Donor(name: 'Rodina Novákových', amount: 5, currency: 'EUR', date: DateTime(2026, 11, 10)),
      ]),
    );
    await _openDonations(tester);
    expect(GoRouter.of(tester.element(find.byType(NavigationBar))).state.uri.path, '/donations');
    expect(find.text('Žádné reklamy'), findsOneWidget);
    for (final amount in ['2 €', '5 €', '10 €', '25 €']) {
      expect(find.byKey(ValueKey('donate_$amount')), findsOneWidget, reason: amount);
    }
    expect(find.text('Srdečně děkujeme dárcům:'), findsOneWidget);
    expect(find.text('Rodina Novákových'), findsOneWidget);
    expect(find.text('25 €'), findsWidgets);
    // Newest first.
    expect(
      tester.getTopLeft(find.text('Rodina Novákových')).dy,
      lessThan(tester.getTopLeft(find.text('Babička Jana')).dy),
    );
  });

  testWidgets('a donate button does not take money yet: it says it comes with Google Play', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), donors: _Source(const []));
    await _openDonations(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('donate_5 €')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('donate_5 €')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Přispívat půjde, až bude hra na Google Play. Děkujeme!'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('nobody yet: an invitation to be the first', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), donors: _Source(const []));
    await _openDonations(tester);
    expect(find.text('Zatím tu nikdo není. Budete první?'), findsOneWidget);
  });

  testWidgets('offline the last known donors stay', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    final source = _Source([Donor(name: 'Babička Jana', amount: 25, currency: 'EUR', date: DateTime(2026, 11, 2))]);
    await pumpApp(tester, size: const Size(412, 915), db: db, donors: source);
    await _openDonations(tester);
    expect(find.text('Babička Jana'), findsOneWidget);
    source.offline = true;
    await pumpApp(tester, size: const Size(412, 915), db: db, donors: source);
    await _openDonations(tester);
    expect(find.text('Babička Jana'), findsOneWidget);
  });

  for (final (size, locale) in const [
    (Size(360, 740), Locale('cs')),
    (Size(360, 740), Locale('es')),
    (Size(740, 360), Locale('en')),
    (Size(1280, 800), Locale('cs')),
  ]) {
    testWidgets(
      'a long list scrolls in its own box and everything fits ${size.width.toInt()}×${size.height.toInt()} $locale at 130 %',
      (tester) async {
        await pumpApp(tester, size: size, locale: locale, textScale: 1.3, donors: _Source(_many));
        await tester.tap(find.byIcon(Icons.volunteer_activism_outlined));
        await _settle(tester);
        expect(tester.takeException(), isNull);
        final list = find.byKey(const ValueKey('donorsList'));
        expect(list, findsOneWidget);
        final box = tester.getRect(list);
        expect(box.bottom, lessThanOrEqualTo(size.height));
        expect(box.height, greaterThan(60), reason: 'a few donors always show');
        expect(find.text('Dárce 39'), findsNothing, reason: 'the long list does not all fit: it scrolls');
        await tester.drag(list, const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('golden: the Dary tab on a phone and on its side', (tester) async {
    await loadAppFonts();
    final donors = [
      Donor(name: 'Rodina Novákových', amount: 5, currency: 'EUR', date: DateTime(2026, 11, 10)),
      Donor(name: 'Babička Jana', amount: 25, currency: 'EUR', date: DateTime(2026, 11, 2)),
      Donor(name: 'Strýc Pepa', amount: 10, currency: 'EUR', date: DateTime(2026, 10, 28)),
      Donor(name: 'Anonym', amount: 2, currency: 'EUR', date: DateTime(2026, 10, 20)),
    ];
    for (final (size, name) in const [(Size(412, 915), 'phone'), (Size(915, 412), 'landscape')]) {
      await pumpApp(tester, size: size, donors: _Source(donors));
      await _openDonations(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/donations_$name.png'));
    }
  }, skip: !Platform.isWindows);
}
