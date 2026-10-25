import 'dart:ui' show Tristate;

import 'package:deskovky/ui_kit/components/color_swatch_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('tap, selection semantics and 48 dp targets', (tester) async {
    final handle = tester.ensureSemantics();
    int? picked;
    await tester.pumpWidget(uiHost(ColorSwatchPicker(
      colors: const [Colors.red, Colors.green, Colors.blue],
      selected: 0,
      onSelected: (i) => picked = i,
      semanticLabels: const ['červená', 'zelená', 'modrá'],
    )));
    await tester.tap(find.bySemanticsLabel('modrá'));
    expect(picked, 2);
    tester.semantics.tap(find.semantics.byLabel('zelená'));
    expect(picked, 1, reason: 'screen readers can activate a swatch');
    expect(tester.getSemantics(find.bySemanticsLabel('červená')).flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.getSemantics(find.bySemanticsLabel('zelená')).flagsCollection.isSelected, isNot(Tristate.isTrue));
    for (final label in ['červená', 'zelená', 'modrá']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.width >= 48 && size.height >= 48, isTrue, reason: '$label is $size');
    }
    handle.dispose();
  });
}
