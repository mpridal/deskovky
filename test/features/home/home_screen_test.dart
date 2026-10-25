import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

const _card = Key('gamePlaceholder');

List<double> _rowTops(WidgetTester tester) =>
    tester.widgetList(find.byKey(_card)).map((w) => tester.getTopLeft(find.byWidget(w)).dy).toList();

void main() {
  testWidgets('phone 360x740: 2 columns', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    final tops = _rowTops(tester);
    expect(tops[0], tops[1]);
    expect(tops[2], greaterThan(tops[0]));
  });

  testWidgets('tablet portrait 800x1280: 3 columns', (tester) async {
    await pumpApp(tester, size: const Size(800, 1280));
    final tops = _rowTops(tester);
    expect([tops[1], tops[2]], everyElement(tops[0]));
    expect(tops[3], greaterThan(tops[0]));
  });

  testWidgets('tablet landscape 1280x800: 4 columns', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    final tops = _rowTops(tester);
    expect([tops[1], tops[2], tops[3]], everyElement(tops[0]));
    expect(tops[4], greaterThan(tops[0]));
  });

  testWidgets('every placeholder card is labelled "Brzy"', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    final cards = find.byKey(_card);
    expect(cards, findsNWidgets(6));
    for (var i = 0; i < 6; i++) {
      expect(find.descendant(of: cards.at(i), matching: find.text('Brzy')), findsOneWidget);
    }
  });
}
