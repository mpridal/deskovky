import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/features/avatar_editor/avatar_editor_screen.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('Players tab opens the editor full screen and keeps the saved avatar', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    await tester.tap(find.text('Hráči'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upravit avatar'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarEditorScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing, reason: 'editor covers the navigation');

    await tester.tap(find.text('Vlasy'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.bySemanticsLabel('copánky'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('copánky'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uložit'));
    await tester.pumpAndSettle();

    expect(find.byType(AvatarEditorScreen), findsNothing);
    final shown = tester.widget<AvatarView>(find.byType(AvatarView).first).spec;
    expect(shown.hair, HairStyle.braids);
  });

  testWidgets('back from the editor keeps the previous avatar', (tester) async {
    await pumpApp(tester, size: const Size(360, 740));
    await tester.tap(find.text('Hráči'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upravit avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vlasy'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.bySemanticsLabel('kudrny'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('kudrny'));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedAvatarView>(find.byType(AnimatedAvatarView)).spec.hair, HairStyle.curly);
    await tester.tap(find.bySemanticsLabel('Zpět'));
    await tester.pumpAndSettle();

    expect(tester.widget<AvatarView>(find.byType(AvatarView).first).spec, AvatarSpec.defaults);
  });
}
