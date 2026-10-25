import 'package:deskovky/ui_kit/components/player_slot.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/ui_host.dart';

void main() {
  testWidgets('left stripe in the seat color, name and tag', (tester) async {
    await tester.pumpWidget(uiHost(const SizedBox(
      width: 320,
      child: PlayerSlot(seat: 2, avatar: SizedBox.square(dimension: 40), name: 'Šroubek', tag: 'Robot'),
    )));
    final stripe = tester.widget<ColoredBox>(find.byKey(const Key('playerSlotStripe')));
    expect(stripe.color, AppColors.players[2]);
    expect(find.text('Šroubek'), findsOneWidget);
    expect(find.text('Robot'), findsOneWidget);
  });
}
