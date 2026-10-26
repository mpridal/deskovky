import 'dart:math';
import 'dart:ui' show Tristate;

import 'dart:io';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/shop/random_look.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/features/avatar_editor/avatar_editor_screen.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:deskovky/ui_kit/components/paper_card.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the editor from a host page so the popped result can be checked.
class _Harness {
  AvatarSpec? result;
  bool popped = false;
}

Future<_Harness> _pumpEditor(
  WidgetTester tester, {
  Size size = const Size(360, 740),
  Random? random,
  AvatarSpec initial = AvatarSpec.defaults,
  List<ShopItem> ownedItems = const [],
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final harness = _Harness();
  await tester.pumpWidget(MaterialApp(
    theme: buildAppTheme(),
    locale: const Locale('cs'),
    supportedLocales: const [Locale('cs'), Locale('en'), Locale('es')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () async {
            harness.result = await Navigator.of(context).push<AvatarSpec>(
              MaterialPageRoute(builder: (_) => AvatarEditorScreen(initial: initial, random: random, ownedItems: ownedItems)),
            );
            harness.popped = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return harness;
}

AvatarSpec _preview(WidgetTester tester) => tester.widget<AnimatedAvatarView>(find.byType(AnimatedAvatarView)).spec;

Future<void> _tapTab(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> _tapLabel(WidgetTester tester, String semanticsLabel) async {
  final target = find.bySemanticsLabel(semanticsLabel);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  late SemanticsHandle semantics;
  setUp(() => semantics = TestWidgetsFlutterBinding.instance.ensureSemantics());
  tearDown(() => semantics.dispose());

  testWidgets('hair style and hair color', (tester) async {
    await _pumpEditor(tester);
    await _tapTab(tester, 'Vlasy');
    await _tapLabel(tester, 'mikádo');
    expect(_preview(tester).hair, HairStyle.bob);
    await _tapLabel(tester, 'zrzavá');
    expect(_preview(tester).hairColor, 5);
  });

  testWidgets('skin tone and background', (tester) async {
    await _pumpEditor(tester);
    await _tapTab(tester, 'Pleť');
    await _tapLabel(tester, 'Pleť 4');
    expect(_preview(tester).skin, 3);
    await _tapTab(tester, 'Pozadí');
    await _tapLabel(tester, 'Pozadí 6');
    expect(_preview(tester).background, 5);
  });

  testWidgets('face, eyes and mouth', (tester) async {
    await _pumpEditor(tester);
    await _tapTab(tester, 'Obličej');
    await _tapLabel(tester, 'hranatý');
    await _tapTab(tester, 'Oči');
    await _tapLabel(tester, 'mrkající');
    await _tapTab(tester, 'Ústa');
    await _tapLabel(tester, 'jazyk');
    final spec = _preview(tester);
    expect((spec.face, spec.eyes, spec.mouth), (FaceShape.square, EyeStyle.wink, MouthStyle.tongue));
  });

  testWidgets('random uses the injected generator', (tester) async {
    await _pumpEditor(tester, random: Random(1));
    await tester.tap(find.bySemanticsLabel('Náhodně'));
    await tester.pumpAndSettle();
    expect(_preview(tester), AvatarSpec.random(Random(1)));
  });

  testWidgets('random also puts on owned upgrades', (tester) async {
    final catalog = ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync());
    final owned = [catalog.byId('cap')!, catalog.byId('glasses')!];
    await _pumpEditor(tester, random: Random(3), ownedItems: owned);
    await tester.tap(find.bySemanticsLabel('Náhodně'));
    await tester.pumpAndSettle();
    expect(_preview(tester), randomLook(Random(3), owned));
  });

  testWidgets('rapid taps during the bounce keep the last choice', (tester) async {
    await _pumpEditor(tester);
    await _tapTab(tester, 'Vlasy');
    await tester.ensureVisible(find.bySemanticsLabel('culíky'));
    await tester.pumpAndSettle();
    for (final label in ['dlouhé', 'kudrny', 'drdol', 'ježek', 'culíky']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(_preview(tester).hair, HairStyle.pigtails);
  });

  testWidgets('save returns the edited avatar', (tester) async {
    final harness = await _pumpEditor(tester);
    await _tapTab(tester, 'Vlasy');
    await _tapLabel(tester, 'copánky');
    await tester.tap(find.text('Uložit'));
    await tester.pumpAndSettle();
    expect(harness.popped, isTrue);
    expect(harness.result?.hair, HairStyle.braids);
  });

  testWidgets('back returns null', (tester) async {
    final harness = await _pumpEditor(tester);
    await tester.tap(find.bySemanticsLabel('Zpět'));
    await tester.pumpAndSettle();
    expect(harness.popped, isTrue);
    expect(harness.result, isNull);
  });

  testWidgets('variants have labels and the chosen one is selected', (tester) async {
    await _pumpEditor(tester);
    await _tapTab(tester, 'Vlasy');
    for (final label in ['krátké', 'dlouhé', 'kudrny', 'drdol', 'ježek', 'culíky', 'mikádo', 'copánky', 'kšiltovka', 'bez vlasů']) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    expect(tester.getSemantics(find.bySemanticsLabel('krátké')).flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.getSemantics(find.bySemanticsLabel('dlouhé')).flagsCollection.isSelected, isNot(Tristate.isTrue));
  });

  testWidgets('screen-reader double tap activates variants, swatches, Random and Back', (tester) async {
    final harness = await _pumpEditor(tester, random: Random(1));
    await _tapTab(tester, 'Vlasy');

    tester.semantics.tap(find.semantics.byLabel('dlouhé'));
    await tester.pumpAndSettle();
    expect(_preview(tester).hair, HairStyle.long);

    tester.semantics.tap(find.semantics.byLabel('zrzavá'));
    await tester.pumpAndSettle();
    expect(_preview(tester).hairColor, 5);

    tester.semantics.tap(find.semantics.byLabel('Náhodně'));
    await tester.pumpAndSettle();
    expect(_preview(tester), AvatarSpec.random(Random(1)));

    tester.semantics.tap(find.semantics.byLabel('Zpět'));
    await tester.pumpAndSettle();
    // Changes were made, so Back asks before discarding them.
    tester.semantics.tap(find.semantics.byLabel('Zahodit'));
    await tester.pumpAndSettle();
    expect(harness.popped, isTrue);
  });

  testWidgets('all touch targets are at least 48 dp on a 360 dp phone', (tester) async {
    await _pumpEditor(tester);
    for (final tab in ['Obličej', 'Pleť', 'Vlasy', 'Oči', 'Ústa', 'Pozadí']) {
      await _tapTab(tester, tab);
      // Measure the laid-out widgets, not semantics rects: those are clipped
      // for targets that are partly scrolled out of view.
      final buttons = find.byWidgetPredicate((w) => w is Semantics && w.properties.button == true);
      expect(buttons, findsWidgets);
      for (final element in buttons.evaluate()) {
        final size = (element.renderObject! as RenderBox).size;
        final label = (element.widget as Semantics).properties.label;
        expect(size.width >= 48 && size.height >= 48, isTrue, reason: '$tab: "$label" is $size');
      }
    }
  });

  testWidgets('layer tabs are compact pills, at most two rows on a 360 dp phone', (tester) async {
    await _pumpEditor(tester);
    final tabs = ['Obličej', 'Pleť', 'Vlasy', 'Oči', 'Ústa', 'Pozadí'];
    final rows = {for (final t in tabs) tester.getTopLeft(find.text(t)).dy.round()};
    expect(rows.length, lessThanOrEqualTo(2), reason: 'tab rows at $rows');
    for (final t in tabs) {
      final pill = find.ancestor(of: find.text(t), matching: find.byType(Container)).first;
      expect(tester.getSize(pill).width, lessThan(160), reason: '$t pill is ${tester.getSize(pill)}');
    }
  });

  testWidgets('options card keeps the same width and tabs start at the left on every tab', (tester) async {
    await _pumpEditor(tester);
    final widths = <double>{};
    for (final tab in ['Obličej', 'Pleť', 'Vlasy', 'Oči', 'Ústa', 'Pozadí']) {
      await _tapTab(tester, tab);
      widths.add(tester.getSize(find.byType(PaperCard)).width);
    }
    expect(widths, hasLength(1), reason: 'card widths $widths');
    expect(tester.getTopLeft(find.text('Obličej')).dx, lessThan(48));
  });

  testWidgets('tablet shows preview and options side by side', (tester) async {
    await _pumpEditor(tester, size: const Size(1280, 800));
    final preview = tester.getCenter(find.byType(AnimatedAvatarView));
    final options = tester.getCenter(find.text('Vlasy'));
    expect(preview.dx, lessThan(options.dx));

    final tile = tester.getSize(find.byKey(const ValueKey('variant0')));
    expect(tile.width, lessThanOrEqualTo(112), reason: 'variant tiles stay compact on wide screens');
    final avatar = tester.getSize(find.descendant(of: find.byKey(const ValueKey('variant0')), matching: find.byType(AvatarView)));
    expect(avatar.width / tile.width, greaterThan(0.6), reason: 'avatar fills its tile');
  });
  group('unsaved changes', () {
    testWidgets('back without changes closes at once', (tester) async {
      final harness = await _pumpEditor(tester);
      await tester.tap(find.bySemanticsLabel('Zpět'));
      await tester.pumpAndSettle();
      expect(harness.popped, isTrue);
    });

    testWidgets('back after a change asks; cancel stays, discard closes without saving', (tester) async {
      final harness = await _pumpEditor(tester);
      await _tapTab(tester, 'Vlasy');
      await _tapLabel(tester, 'kudrny');
      await tester.tap(find.bySemanticsLabel('Zpět'));
      await tester.pumpAndSettle();
      expect(find.text('Zahodit změny?'), findsOneWidget);

      await tester.tap(find.text('Zrušit'));
      await tester.pumpAndSettle();
      expect(harness.popped, isFalse);
      expect(find.byType(AvatarEditorScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Zpět'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zahodit'));
      await tester.pumpAndSettle();
      expect(harness.popped, isTrue);
      expect(harness.result, isNull);
    });

    testWidgets('system back after a change also asks', (tester) async {
      await _pumpEditor(tester);
      await _tapTab(tester, 'Vlasy');
      await _tapLabel(tester, 'kudrny');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Zahodit změny?'), findsOneWidget);
    });
  });
}
