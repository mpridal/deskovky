import 'dart:ui' show Tristate;

import 'package:deskovky/core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _openSettings(WidgetTester tester, AppDatabase db, {double textScale = 1.0}) async {
  await pumpApp(tester, size: const Size(360, 740), locale: const Locale('cs'), textScale: textScale, db: db);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('choosing Español switches the app and survives a restart', (tester) async {
    await _openSettings(tester, db);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Ajustes'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(360, 740), locale: const Locale('cs'), db: db);
    expect(find.text('Ajustes'), findsOneWidget);
  });

  testWidgets('"phone setting" returns to the system language', (tester) async {
    await _openSettings(tester, db);
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    await tester.tap(find.text('Phone setting'));
    await tester.pumpAndSettle();
    expect(find.text('Nastavení'), findsWidgets);
  });

  testWidgets('the current choice is marked selected', (tester) async {
    final handle = tester.ensureSemantics();
    await _openSettings(tester, db);
    expect(tester.getSemantics(find.bySemanticsLabel('Podle telefonu')).flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });

  group('fit', () {
    setUpAll(loadAppFonts);

    testWidgets('language choices do not wrap on a 360 dp phone at 130 %', (tester) async {
      await _openSettings(tester, db, textScale: 1.3);
      for (final label in ['Podle telefonu', 'Čeština', 'English', 'Español']) {
        final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
        expect(paragraph.getMaxIntrinsicWidth(double.infinity) <= paragraph.size.width + 0.5, isTrue, reason: label);
        expect(paragraph.size.height, lessThan(40), reason: '$label is on one line');
      }
    });
  });
}
