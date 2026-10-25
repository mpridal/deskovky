import 'package:deskovky/ui_kit/components/tag_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('scales down inside a narrow parent instead of overflowing', (tester) async {
    await tester.pumpWidget(uiHost(const SizedBox(width: 40, child: TagPill(label: 'Próximamente'))));
    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.byType(TagPill)).width, lessThanOrEqualTo(40));
  });
}
