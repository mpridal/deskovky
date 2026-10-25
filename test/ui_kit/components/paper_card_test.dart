import 'package:deskovky/ui_kit/components/paper_card.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('paper color, radius 18, 5 dp physical shadow, tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(uiHost(PaperCard(onTap: () => taps++, child: const Text('karta'))));
    final box = tester.widget<DecoratedBox>(
      find.ancestor(of: find.text('karta'), matching: find.byType(DecoratedBox)).first,
    );
    final deco = box.decoration as BoxDecoration;
    expect(deco.color, AppColors.paper);
    expect(deco.borderRadius, BorderRadius.circular(18));
    expect(deco.boxShadow!.first.offset, const Offset(0, 5));
    await tester.tap(find.text('karta'));
    expect(taps, 1);
  });
}
