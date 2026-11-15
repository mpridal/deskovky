import 'package:deskovky/features/settings/share_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers/pump_app.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

void main() {
  test('the QR code leads to the latest release on GitHub, where the APK is', () {
    expect(appDownloadUrl, 'https://github.com/mpridal/deskovky/releases/latest');
  });

  testWidgets('Settings show a QR code another device scans to download the game', (tester) async {
    await pumpApp(tester, size: const Size(412, 915));
    await tester.tap(find.text('Nastavení'));
    await _settle(tester);
    final share = find.byKey(const ValueKey('settingsShareApp'));
    await tester.scrollUntilVisible(share, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(share);
    await tester.pumpAndSettle();
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(find.byType(QrImageView), findsOneWidget);
    expect(qr, isNotNull);
    expect(find.textContaining('github.com/mpridal/deskovky'), findsOneWidget);
    expect(find.textContaining('fotoaparát'), findsOneWidget);
  });

  testWidgets('the QR dialog fits a small phone at 130 %', (tester) async {
    await pumpApp(tester, size: const Size(360, 640), textScale: 1.3);
    await tester.tap(find.text('Nastavení'));
    await _settle(tester);
    final share = find.byKey(const ValueKey('settingsShareApp'));
    await tester.scrollUntilVisible(share, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(share);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
