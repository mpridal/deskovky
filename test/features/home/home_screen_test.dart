import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';

final _card = find.byWidgetPredicate(
  (w) => w.key is ValueKey<String> && (w.key! as ValueKey<String>).value.startsWith('gameCard'),
);

List<double> _rowTops(WidgetTester tester) =>
    tester.widgetList(_card).map((w) => tester.getTopLeft(find.byWidget(w)).dy).toList();

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

  testWidgets('the sample game comes first and is playable, the other five say "Brzy"', (tester) async {
    await pumpApp(tester, size: const Size(1280, 800));
    expect(_card, findsNWidgets(6));
    final first = _card.at(0);
    expect(find.descendant(of: first, matching: find.text('Hádej číslo')), findsOneWidget);
    expect(find.descendant(of: first, matching: find.text('1–4 hráči')), findsOneWidget);
    expect(find.descendant(of: first, matching: find.text('Brzy')), findsNothing);
    for (var i = 1; i < 6; i++) {
      expect(find.descendant(of: _card.at(i), matching: find.text('Brzy')), findsOneWidget);
    }
  });

  testWidgets('tapping the sample game opens its setup', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    await tester.tap(find.text('Hádej číslo'));
    await tester.pumpAndSettle();
    final router = GoRouter.of(tester.element(find.byType(Navigator).last));
    expect(router.state.uri.path, '/play/sample/setup');
  });
}
