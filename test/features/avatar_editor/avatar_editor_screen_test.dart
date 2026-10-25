import 'dart:math';
import 'dart:ui' show Tristate;

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/features/avatar_editor/avatar_editor_screen.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
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
              MaterialPageRoute(builder: (_) => AvatarEditorScreen(initial: initial, random: random)),
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

  testWidgets('tablet shows preview and options side by side', (tester) async {
    await _pumpEditor(tester, size: const Size(1280, 800));
    final preview = tester.getCenter(find.byType(AnimatedAvatarView));
    final options = tester.getCenter(find.text('Vlasy'));
    expect(preview.dx, lessThan(options.dx));
  });
}
