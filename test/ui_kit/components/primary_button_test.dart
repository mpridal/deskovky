import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

Offset _offset(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(of: find.byType(PrimaryButton), matching: find.byType(Transform)).first,
  );
  final t = transform.transform.getTranslation();
  return Offset(t.x, t.y);
}

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(uiHost(PrimaryButton(label: 'Uložit', onPressed: () => taps++)));
    await tester.tap(find.text('Uložit'));
    expect(taps, 1);
  });

  testWidgets('moves 3 dp down while pressed', (tester) async {
    await tester.pumpWidget(uiHost(PrimaryButton(label: 'Uložit', onPressed: () {})));
    expect(_offset(tester), Offset.zero);
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PrimaryButton)));
    await tester.pump();
    expect(_offset(tester), const Offset(0, 3));
    await gesture.up();
    await tester.pump();
    expect(_offset(tester), Offset.zero);
  });

  testWidgets('disabled button is dimmed and ignores taps', (tester) async {
    await tester.pumpWidget(uiHost(const PrimaryButton(label: 'Uložit', onPressed: null)));
    final gesture = await tester.startGesture(tester.getCenter(find.byType(PrimaryButton)));
    await tester.pump();
    expect(_offset(tester), Offset.zero);
    await gesture.up();
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(PrimaryButton), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 0.5);
  });

  testWidgets('is at least 52 dp tall', (tester) async {
    await tester.pumpWidget(uiHost(PrimaryButton(label: 'Uložit', onPressed: () {})));
    expect(tester.getSize(find.byType(PrimaryButton)).height, greaterThanOrEqualTo(52));
  });
}
