import 'package:deskovky/ui_kit/components/choice_pills.dart';
import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:deskovky/ui_kit/components/round_icon_button.dart';
import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:deskovky/ui_kit/components/ui_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<UiSound>> _pump(WidgetTester tester, Widget child) async {
  final sounds = <UiSound>[];
  await tester.pumpWidget(
    MaterialApp(
      home: UiFeedback(
        onSound: sounds.add,
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
  return sounds;
}

void main() {
  testWidgets('primary button plays tap; disabled plays nothing', (tester) async {
    var sounds = await _pump(tester, PrimaryButton(label: 'Hrát', onPressed: () {}));
    await tester.tap(find.text('Hrát'));
    expect(sounds, [UiSound.tap]);

    sounds = await _pump(tester, const PrimaryButton(label: 'Hrát', onPressed: null));
    await tester.tap(find.text('Hrát'));
    expect(sounds, isEmpty);
  });

  testWidgets('round icon button plays its sound (back for closing)', (tester) async {
    final sounds = await _pump(
      tester,
      RoundIconButton(icon: Icons.arrow_back, tooltip: 'Zpět', sound: UiSound.back, onPressed: () {}),
    );
    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(sounds, [UiSound.back]);
  });

  testWidgets('choice pills and segmented control play toggle', (tester) async {
    final sounds = await _pump(
      tester,
      Column(
        children: [
          ChoicePills<int>(choices: const [(1, 'A'), (2, 'B')], selected: 1, onChanged: (_) {}),
          SegmentedControl<int>(segments: const [(1, 'X'), (2, 'Y')], selected: 1, onChanged: (_) {}),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.tap(find.text('Y'));
    expect(sounds, [UiSound.toggle, UiSound.toggle]);
  });

  testWidgets('without UiFeedback above, buttons still work silently', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PrimaryButton(label: 'Hrát', onPressed: () => pressed = true),
      ),
    );
    await tester.tap(find.text('Hrát'));
    expect(pressed, isTrue);
  });
}
