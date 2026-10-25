import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('tap selects a segment; selected is paper; 48 dp tall', (tester) async {
    int? changed;
    await tester.pumpWidget(uiHost(SizedBox(
      width: 300,
      child: SegmentedControl<int>(
        segments: const [(1, '1'), (2, '2'), (3, '3'), (4, '4')],
        selected: 4,
        onChanged: (v) => changed = v,
      ),
    )));
    await tester.tap(find.text('3'));
    expect(changed, 3);
    final selected = tester.widget<AnimatedContainer>(
      find.ancestor(of: find.text('4'), matching: find.byType(AnimatedContainer)).first,
    );
    expect((selected.decoration! as BoxDecoration).color, AppColors.paper);
    expect(tester.getSize(find.byType(SegmentedControl<int>)).height, greaterThanOrEqualTo(48));
  });
}
