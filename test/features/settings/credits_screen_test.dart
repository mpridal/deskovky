import 'package:deskovky/app/licenses.dart';
import 'package:deskovky/core/audio/credits.dart';
import 'package:deskovky/features/settings/credits_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';

Future<void> _openCredits(WidgetTester tester, {Locale locale = const Locale('cs'), double textScale = 1.0}) async {
  await pumpApp(tester, size: const Size(360, 740), locale: locale, textScale: textScale);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  final link = find.byKey(const ValueKey('creditsLink'));
  await tester.scrollUntilVisible(link, 200);
  await tester.tap(link);
  await tester.pumpAndSettle();
  // CREDITS.json is read from the asset bundle with real file I/O.
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
  await tester.pumpAndSettle();
  expect(find.byType(CreditsScreen), findsOneWidget);
}

void main() {
  test('credits parse from JSON', () {
    final credits = parseCredits(
      '[{"file":"music/menu.ogg","title":"Wallpaper","author":"Kevin MacLeod","source_url":"https://incompetech.com",'
      '"license":"CC BY 4.0","attribution_text":"\\"Wallpaper\\" Kevin MacLeod (incompetech.com)"}]',
    );
    expect(credits.single.title, 'Wallpaper');
    expect(credits.single.author, 'Kevin MacLeod');
    expect(credits.single.license, 'CC BY 4.0');
    expect(credits.single.attribution, '"Wallpaper" Kevin MacLeod (incompetech.com)');
  });

  test('the bundled CREDITS.json loads', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final credits = await loadCredits(rootBundle);
    expect(credits, isNotEmpty);
    expect(credits.map((c) => c.file), contains('music/menu.wav'));
  });

  testWidgets('settings lead to credits with sounds, fonts and library licences', (tester) async {
    await _openCredits(tester);
    expect(find.text('Autoři a licence'), findsOneWidget);
    expect(find.text('Hudba a zvuky'), findsOneWidget);
    expect(find.text('Zástupná hudba menu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Baloo 2'), 300);
    await tester.scrollUntilVisible(find.text('Nunito'), 200);
    expect(find.textContaining('SIL Open Font License'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Licence knihoven'), 300);
    await tester.tap(find.text('Licence knihoven'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('fonts and sounds are registered for the library licence page', (tester) async {
    registerAppLicenses();
    await tester.runAsync(() async {
      final entries = await LicenseRegistry.licenses.toList();
      final packages = entries.expand((e) => e.packages).toSet();
      expect(packages, containsAll(['Baloo 2', 'Nunito']));
    });
  });

  testWidgets('back returns to settings', (tester) async {
    await _openCredits(tester);
    await tester.tap(find.byTooltip('Zpět'));
    await tester.pumpAndSettle();
    expect(find.byType(CreditsScreen), findsNothing);
    expect(find.byKey(const ValueKey('creditsLink')), findsOneWidget);
  });

  group('fit', () {
    setUpAll(loadAppFonts);

    for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
      testWidgets('credits fit a 360 dp phone at 130 % in ${locale.languageCode}', (tester) async {
        await _openCredits(tester, locale: locale, textScale: 1.3);
        final list = find.byType(Scrollable).first;
        for (var i = 0; i < 40; i++) {
          expect(tester.takeException(), isNull);
          await tester.drag(list, const Offset(0, -400));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
