import 'package:deskovky/features/settings/ui_kit_catalog_screen.dart';
import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/ui_host.dart';

void main() {
  for (final size in const [Size(360, 740), Size(1280, 800)]) {
    testWidgets('catalog renders at $size', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(uiHost(const UiKitCatalogScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(RobotAvatar, skipOffstage: false), findsWidgets);
    });
  }

  testWidgets('debug builds reach the catalog from Settings', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    await tester.tap(find.text('Nastavení'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('UI kit'), 200);
    await tester.tap(find.text('UI kit'));
    await tester.pumpAndSettle();
    expect(find.byType(UiKitCatalogScreen), findsOneWidget);
  });
}
