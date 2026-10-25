import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';

Widget _host(Widget child) => Directionality(textDirection: TextDirection.ltr, child: Center(child: child));

void main() {
  setUpAll(loadAppFonts);

  testWidgets('small robot shows the AI badge', (tester) async {
    await tester.pumpWidget(_host(RobotAvatar(color: AppColors.players[2], size: 40)));
    expect(find.text('AI'), findsOneWidget);
    expect(tester.getSize(find.byType(RobotAvatar)), const Size(40, 40));
  });

  testWidgets('robot of 64 dp and more has no badge', (tester) async {
    for (final size in [64.0, 160.0]) {
      await tester.pumpWidget(_host(RobotAvatar(color: AppColors.players[0], size: size)));
      expect(find.text('AI'), findsNothing, reason: '$size');
      expect(tester.getSize(find.byType(RobotAvatar)), Size(size, size));
    }
  });

  testWidgets('semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(RobotAvatar(color: AppColors.players[1], size: 64, semanticLabel: 'Čipík')));
    expect(find.bySemanticsLabel('Čipík'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('golden: robot sheet', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(Align(
      alignment: Alignment.topLeft,
      child: ColoredBox(
        color: AppColors.felt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final color in AppColors.players)
              Row(children: [
                for (final size in [28.0, 40.0, 64.0, 160.0])
                  Padding(padding: const EdgeInsets.all(4), child: RobotAvatar(color: color, size: size)),
              ]),
          ],
        ),
      ),
    )));
    await expectLater(find.byType(ColoredBox).first, matchesGoldenFile('goldens/robot_sheet.png'));
  });
}
