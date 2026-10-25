import 'package:deskovky/ui_kit/components/round_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('48 dp target, screen-reader label and tap', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      uiHost(RoundIconButton(icon: Icons.volume_up, tooltip: 'Zvuk', onPressed: () => taps++)),
    );
    final size = tester.getSize(find.byType(RoundIconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.bySemanticsLabel('Zvuk'), findsOneWidget);
    await tester.tap(find.byType(RoundIconButton));
    expect(taps, 1);
    tester.semantics.tap(find.semantics.byLabel('Zvuk'));
    expect(taps, 2, reason: 'screen readers can activate it');
    handle.dispose();
  });
}
