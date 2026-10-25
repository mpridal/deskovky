import 'package:deskovky/ui_kit/components/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  for (final (action, expected) in [('Smazat', true), ('Zrušit', false), ('barrier', false)]) {
    testWidgets('$action returns $expected', (tester) async {
      bool? result;
      await tester.pumpWidget(uiHost(Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showAppConfirmDialog(
            context,
            title: 'Smazat hráče?',
            message: 'Opravdu?',
            confirmLabel: 'Smazat',
            cancelLabel: 'Zrušit',
          ),
          child: const Text('open'),
        ),
      )));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Opravdu?'), findsOneWidget);

      if (action == 'barrier') {
        await tester.tapAt(const Offset(5, 5));
      } else {
        await tester.tap(find.text(action));
      }
      await tester.pumpAndSettle();
      expect(find.text('Opravdu?'), findsNothing);
      expect(result, expected);
    });
  }
}
