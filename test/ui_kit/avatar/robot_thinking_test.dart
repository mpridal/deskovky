import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:deskovky/ui_kit/components/thinking_dots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {bool reduceMotion = false}) async {
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: child))));
}

double _eyes(WidgetTester tester) =>
    (tester.widget<CustomPaint>(find.descendant(of: find.byType(RobotAvatar), matching: find.byType(CustomPaint)).first).painter!
            as RobotPainter)
        .eyeLevel;

List<double> _dots(WidgetTester tester) => [
  for (final o in tester.widgetList<Opacity>(find.descendant(of: find.byType(ThinkingDots), matching: find.byType(Opacity))))
    o.opacity,
];

void main() {
  testWidgets('a thinking robot blinks its LED eyes', (tester) async {
    await _pump(tester, const RobotAvatar(color: Colors.blue, size: 64, blinking: true));
    final levels = <double>{};
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
      levels.add(_eyes(tester));
    }
    expect(levels.length, greaterThan(2), reason: 'the eyes change over time');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('with reduced motion the eyes stay lit', (tester) async {
    await _pump(tester, const RobotAvatar(color: Colors.blue, size: 64, blinking: true), reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 600));
    expect(_eyes(tester), 1);
    expect(tester.binding.hasScheduledFrame, isFalse, reason: 'nothing animates');
  });

  testWidgets('three dots take turns; static with reduced motion', (tester) async {
    await _pump(tester, const ThinkingDots(color: Colors.white));
    final first = _dots(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_dots(tester), isNot(first));
    expect(first, hasLength(3));
    await tester.pumpWidget(const SizedBox());

    await _pump(tester, const ThinkingDots(color: Colors.white), reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 300));
    expect(_dots(tester), [1, 1, 1]);
  });
}
