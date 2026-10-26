import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/ui_kit/avatar/accessories/accessory_art.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pattern book of all upgrades (spec 5.6): every item on two looks at
/// 120 dp plus 28 dp, so Miloš can review the art in one picture.
void main() {
  const looks = [
    AvatarSpec(face: FaceShape.oval, skin: 1, hair: HairStyle.long, hairColor: 3, eyes: EyeStyle.round, mouth: MouthStyle.smile, background: 1),
    AvatarSpec(face: FaceShape.square, skin: 4, hair: HairStyle.curly, hairColor: 0, eyes: EyeStyle.happy, mouth: MouthStyle.grin, background: 3),
  ];

  testWidgets('pattern book of all upgrades', (tester) async {
    final ids = accessoryArts.keys.toList();
    const columns = 6;
    final rows = (ids.length / columns).ceil();
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(columns * 300.0, rows * 160.0);
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ColoredBox(
          color: const Color(0xFF2E5E4E),
          child: Wrap(
            children: [
              for (final id in ids)
                SizedBox(
                  width: 300,
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final look in looks)
                        AvatarView(
                          spec: look.copyWith(equipped: {accessoryArts[id]!.slot: EquippedItem(id)}),
                          size: 120,
                        ),
                      AvatarView(spec: looks.first.copyWith(equipped: {accessoryArts[id]!.slot: EquippedItem(id)}), size: 28),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await expectLater(find.byType(Wrap), matchesGoldenFile('goldens/accessories_book.png'));
  });
}
