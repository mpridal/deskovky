import 'package:deskovky/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pump_app.dart';

void main() {
  testWidgets('DeskovkyApp starts on the Games tab', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    expect(find.byType(DeskovkyApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
