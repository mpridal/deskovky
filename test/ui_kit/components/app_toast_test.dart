import 'package:deskovky/ui_kit/components/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('shows the message and hides it after about 2.5 s', (tester) async {
    await tester.pumpWidget(uiHost(Builder(
      builder: (context) => TextButton(onPressed: () => showAppToast(context, 'Uloženo'), child: const Text('go')),
    )));
    await tester.tap(find.text('go'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Uloženo'), findsOneWidget);
    // Advance in small steps: the scaffold starts the hide timer on a frame
    // after the entry animation, so one long pump would skip it.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Uloženo'), findsOneWidget, reason: 'still visible after 2.3 s');
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.text('Uloženo'), findsNothing);
  });
}
