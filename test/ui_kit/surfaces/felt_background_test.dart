import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  for (final size in const [Size(360, 740), Size(1280, 800)]) {
    testWidgets('paints at $size and shows its child', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(const FeltBackground(child: Center(child: Text('obsah')))));
      expect(tester.takeException(), isNull);
      expect(find.text('obsah'), findsOneWidget);
    });
  }

  testWidgets('painter never repaints by itself', (tester) async {
    await tester.pumpWidget(_host(const FeltBackground(child: SizedBox())));
    final paint = tester.widget<CustomPaint>(
      find.descendant(of: find.byType(FeltBackground), matching: find.byType(CustomPaint)).first,
    );
    expect(paint.painter!.shouldRepaint(paint.painter!), isFalse);
  });
}
