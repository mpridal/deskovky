import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../helpers/pump_app.dart';

const _rightPanel = Key('rightPanel');

void main() {
  testWidgets('phone 360x740: bottom navigation, no rail, no right panel', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(_rightPanel), findsNothing);
  });

  testWidgets('phone landscape 740x360: rail, no overflow', (tester) async {
    await pumpApp(tester, size: const Size(740, 360));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rotating phone and tablet keeps the current tab without errors', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    await tester.tap(find.text('Nastavení'));
    await tester.pumpAndSettle();

    for (final size in const [Size(740, 360), Size(1280, 800), Size(800, 1280), Size(360, 740)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'after resize to $size');
      // The language heading sits at the top of Settings at every size.
      expect(find.text('Jazyk'), findsOneWidget, reason: 'Settings tab kept at $size');
    }
  });

  testWidgets('tablet portrait 800x1280: rail, no right panel', (tester) async {
    await pumpApp(tester, size: const Size(800, 1280));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(_rightPanel), findsNothing);
  });

  testWidgets('tablet landscape 1280x800: rail and right panel', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byKey(_rightPanel), findsOneWidget);
    expect(find.descendant(of: find.byKey(_rightPanel), matching: find.text('Hráči na zařízení')), findsOneWidget);
  });

  testWidgets('tapping Settings and back to Games switches routes', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    GoRouter router() => GoRouter.of(tester.element(find.byType(NavigationBar)));

    expect(router().state.uri.path, '/games');
    await tester.tap(find.text('Nastavení'));
    await tester.pumpAndSettle();
    expect(router().state.uri.path, '/settings');
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 3);

    await tester.tap(find.text('Hry'));
    await tester.pumpAndSettle();
    expect(router().state.uri.path, '/games');
  });

  testWidgets('navigation items have screen-reader labels', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, size: const Size(360, 740));
    for (final label in ['Hry', 'Hráči', 'Žebříčky', 'Nastavení']) {
      expect(find.bySemanticsLabel(RegExp('^$label')), findsWidgets, reason: label);
    }
    handle.dispose();
  });

  testWidgets('app title is localized from system locale', (tester) async {
    await pumpApp(tester, size: const Size(360, 740), locale: const Locale('es', 'MX'));
    expect(find.text('Ajustes'), findsOneWidget);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).supportedLocales, hasLength(3));
  });
}
