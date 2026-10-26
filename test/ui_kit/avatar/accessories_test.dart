import 'dart:ui';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/ui_kit/avatar/accessories/accessory_art.dart';
import 'package:deskovky/ui_kit/avatar/avatar_painter.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _mockupItems = ['crown', 'halo', 'top_hat', 'wizard_hat', 'glasses', 'sunglasses', 'hero_mask', 'magic_wand', 'phone'];

AvatarSpec _wearing(String id, {String? variant, FaceShape face = FaceShape.oval, HairStyle hair = HairStyle.short}) {
  final art = accessoryArts[id]!;
  return AvatarSpec.defaults.copyWith(face: face, hair: hair, equipped: {art.slot: EquippedItem(id, variant: variant)});
}

Future<void> _pump(WidgetTester tester, Widget child, {bool reduceMotion = false}) async {
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  await tester.pumpWidget(MaterialApp(home: Center(child: child)));
}

void main() {
  test('the nine mockup items have art in the right slots', () {
    for (final id in _mockupItems) {
      expect(accessoryArts[id], isNotNull, reason: id);
    }
    expect(accessoryArts['halo']!.slot, AccessorySlot.head);
    expect(accessoryArts['magic_wand']!.slot, AccessorySlot.hand);
  });

  testWidgets('every item draws on every face and hair style at 28, 64 and 160 dp', (tester) async {
    for (final id in accessoryArts.keys) {
      for (final face in FaceShape.values) {
        for (final hair in HairStyle.values) {
          for (final size in [28.0, 64.0, 160.0]) {
            await _pump(tester, AvatarView(spec: _wearing(id, face: face, hair: hair), size: size));
            expect(tester.takeException(), isNull, reason: '$id $face $hair $size');
          }
        }
      }
    }
  });

  test('small avatars leave out the pet and the effect (spec 5.6)', () {
    expect(AvatarPainter.visibleSlots(28), isNot(contains(AccessorySlot.pet)));
    expect(AvatarPainter.visibleSlots(28), isNot(contains(AccessorySlot.effect)));
    expect(AvatarPainter.visibleSlots(28), containsAll([AccessorySlot.head, AccessorySlot.face, AccessorySlot.hand]));
    expect(AvatarPainter.visibleSlots(64), AccessorySlot.values.toSet());
  });

  test('hats shorten the hair under them; a crown and glasses do not', () {
    expect(accessoryArts['top_hat']!.hairLine, isNotNull);
    expect(accessoryArts['wizard_hat']!.hairLine, isNotNull);
    expect(accessoryArts['crown']!.hairLine, isNull);
    expect(accessoryArts['glasses']!.hairLine, isNull);
  });

  testWidgets('an animated item animates at 64 dp and up only, and never with reduced motion', (tester) async {
    await _pump(tester, AvatarView(spec: _wearing('halo'), size: 64));
    expect(tester.binding.hasScheduledFrame, isTrue, reason: 'halo glows at 64 dp');
    await _pump(tester, AvatarView(spec: _wearing('halo'), size: 48));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse, reason: 'still below 64 dp');
    await _pump(tester, AvatarView(spec: _wearing('halo'), size: 120), reduceMotion: true);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse, reason: 'reduced motion');
  });

  testWidgets('an unknown upgrade id (a newer app wrote it) is simply not drawn', (tester) async {
    final spec = AvatarSpec.defaults.copyWith(equipped: const {AccessorySlot.head: EquippedItem('jetpack')});
    await _pump(tester, AvatarView(spec: spec, size: 120));
    expect(tester.takeException(), isNull);
  });

  testWidgets('crown colour variants paint differently', (tester) async {
    Future<List<int>> paint(String variant) async {
      final recorder = PictureRecorder();
      AvatarPainter(_wearing('crown', variant: variant)).paint(Canvas(recorder), const Size(100, 100));
      final image = await recorder.endRecording().toImage(100, 100);
      final bytes = await image.toByteData();
      return bytes!.buffer.asUint8List().toList();
    }

    final gold = await tester.runAsync(() => paint('gold'));
    final silver = await tester.runAsync(() => paint('silver'));
    expect(gold, isNot(silver));
  });
}
