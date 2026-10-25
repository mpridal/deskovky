import 'dart:math';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(textDirection: TextDirection.ltr, child: Center(child: child)),
    );

double _scaleOf(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(of: find.byType(AnimatedAvatarView), matching: find.byType(Transform)).first,
  );
  return transform.transform.getMaxScaleOnAxis();
}

void main() {
  testWidgets('renders every hair style and face shape at 28, 64 and 160 dp', (tester) async {
    for (final size in [28.0, 64.0, 160.0]) {
      for (final hair in HairStyle.values) {
        for (final face in FaceShape.values) {
          final spec = AvatarSpec.defaults.copyWith(hair: hair, face: face);
          await tester.pumpWidget(_host(AvatarView(spec: spec, size: size)));
          expect(tester.takeException(), isNull, reason: '$hair $face $size');
          expect(tester.getSize(find.byType(AvatarView)), Size(size, size));
        }
      }
    }
  });

  testWidgets('ring in player color', (tester) async {
    await tester.pumpWidget(
      _host(AvatarView(spec: AvatarSpec.defaults, size: 64, ringColor: AppColors.players[1])),
    );
    final boxes = tester.widgetList<DecoratedBox>(find.descendant(of: find.byType(AvatarView), matching: find.byType(DecoratedBox)));
    expect(
      boxes.any((b) => (b.decoration as BoxDecoration).border?.top.color == AppColors.players[1]),
      isTrue,
    );
  });

  testWidgets('semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_host(const AvatarView(spec: AvatarSpec.defaults, size: 64, semanticLabel: 'Tereza')));
    expect(find.bySemanticsLabel('Tereza'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('AnimatedAvatarView bounces for 200 ms on change', (tester) async {
    await tester.pumpWidget(_host(const AnimatedAvatarView(spec: AvatarSpec.defaults, size: 150)));
    await tester.pumpWidget(
      _host(AnimatedAvatarView(spec: AvatarSpec.defaults.copyWith(hair: HairStyle.bob), size: 150)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_scaleOf(tester), greaterThan(1.0));
    await tester.pump(const Duration(milliseconds: 150));
    expect(_scaleOf(tester), 1.0);
  });

  testWidgets('AnimatedAvatarView does not bounce with reduced motion', (tester) async {
    await tester.pumpWidget(_host(const AnimatedAvatarView(spec: AvatarSpec.defaults, size: 150), disableAnimations: true));
    await tester.pumpWidget(_host(
      AnimatedAvatarView(spec: AvatarSpec.defaults.copyWith(hair: HairStyle.bob), size: 150),
      disableAnimations: true,
    ));
    await tester.pump(const Duration(milliseconds: 100));
    expect(_scaleOf(tester), 1.0);
  });

  testWidgets('golden: avatar sheet', (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(700, 1400);
    addTearDown(tester.view.reset);

    Widget cell(AvatarSpec spec, double size) =>
        Padding(padding: const EdgeInsets.all(4), child: AvatarView(spec: spec, size: size));
    final rnd = Random(11);
    final sheet = ColoredBox(
      color: AppColors.felt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final hair in HairStyle.values)
            Row(children: [
              for (final face in FaceShape.values)
                cell(AvatarSpec.defaults.copyWith(hair: hair, face: face, hairColor: hair.index % 8, background: face.index), 64),
            ]),
          Row(children: [
            for (final eyes in EyeStyle.values) cell(AvatarSpec.defaults.copyWith(eyes: eyes, background: 5), 64),
          ]),
          Row(children: [
            for (final mouth in MouthStyle.values) cell(AvatarSpec.defaults.copyWith(mouth: mouth, background: 6), 64),
          ]),
          // Darkest skin tones: eyes and mouth must stay visible.
          Row(children: [
            for (final eyes in EyeStyle.values) cell(AvatarSpec.defaults.copyWith(eyes: eyes, skin: 5, background: 1), 64),
          ]),
          Row(children: [
            for (final mouth in MouthStyle.values) cell(AvatarSpec.defaults.copyWith(mouth: mouth, skin: 4, background: 3), 64),
          ]),
          Row(children: [for (var skin = 0; skin < 6; skin++) cell(AvatarSpec.defaults.copyWith(skin: skin), 28)]),
          Row(children: [for (var i = 0; i < 8; i++) cell(AvatarSpec.random(rnd), 28)]),
          Row(children: [for (var i = 0; i < 3; i++) cell(AvatarSpec.random(rnd), 160)]),
        ],
      ),
    );
    await tester.pumpWidget(_host(Align(alignment: Alignment.topLeft, child: sheet)));
    await expectLater(find.byType(ColoredBox).first, matchesGoldenFile('goldens/avatar_sheet.png'));
  });
}
