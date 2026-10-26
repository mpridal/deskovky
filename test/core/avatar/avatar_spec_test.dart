import 'dart:math';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('variant counts (spec 5.3)', () {
    test('layers have at least the required variants', () {
      expect(FaceShape.values, hasLength(4));
      expect(AvatarPalette.skin, hasLength(6));
      expect(HairStyle.values, hasLength(10));
      expect(AvatarPalette.hair, hasLength(8));
      expect(EyeStyle.values, hasLength(6));
      expect(MouthStyle.values, hasLength(6));
      expect(AvatarPalette.background, hasLength(8));
    });

    test('palette colors match the mockup', () {
      expect(AvatarPalette.skin.first, const Color(0xFFF6D7C3));
      expect(AvatarPalette.hair[7], const Color(0xFF3B7DD8));
    });
  });

  group('JSON', () {
    test('round-trips random avatars', () {
      for (var i = 0; i < 50; i++) {
        final spec = AvatarSpec.random(Random(i));
        expect(AvatarSpec.fromJson(spec.toJson()), spec, reason: 'seed $i');
      }
    });

    test('carries a format version', () {
      expect(AvatarSpec.defaults.toJson()['v'], 1);
    });

    test('missing or empty JSON gives defaults', () {
      expect(AvatarSpec.fromJson(null), AvatarSpec.defaults);
      expect(AvatarSpec.fromJson(const {}), AvatarSpec.defaults);
    });

    test('invalid fields fall back to defaults one by one', () {
      expect(AvatarSpec.fromJson(const {'hair': 'mohawk'}).hair, AvatarSpec.defaults.hair);
      expect(AvatarSpec.fromJson(const {'skin': 99}).skin, AvatarSpec.defaults.skin);
      expect(AvatarSpec.fromJson(const {'skin': -1}).skin, AvatarSpec.defaults.skin);
      expect(AvatarSpec.fromJson(const {'skin': '2'}).skin, AvatarSpec.defaults.skin);
      expect(AvatarSpec.fromJson(const {'bg': 8}).background, AvatarSpec.defaults.background);
    });

    test('unknown keys are ignored', () {
      expect(AvatarSpec.fromJson(const {'eyes': 'wink', 'extra': true}).eyes, EyeStyle.wink);
    });
  });

  group('random', () {
    test('is deterministic for a seed', () {
      expect(AvatarSpec.random(Random(7)), AvatarSpec.random(Random(7)));
    });

    test('covers every hair style', () {
      final rnd = Random(3);
      final styles = {for (var i = 0; i < 200; i++) AvatarSpec.random(rnd).hair};
      expect(styles, HairStyle.values.toSet());
    });
  });

  test('copyWith changes only the given field', () {
    final changed = AvatarSpec.defaults.copyWith(hair: HairStyle.bob);
    expect(changed.hair, HairStyle.bob);
    expect(changed.copyWith(hair: AvatarSpec.defaults.hair), AvatarSpec.defaults);
  });

  group('equipped upgrades (milestone 7b)', () {
    test('survive a JSON round trip with their colour variant', () {
      final spec = AvatarSpec.defaults.copyWith(
        equipped: const {
          AccessorySlot.head: EquippedItem('crown', variant: 'silver'),
          AccessorySlot.pet: EquippedItem('kitten'),
        },
      );
      final back = AvatarSpec.fromJson(spec.toJson());
      expect(back, spec);
      expect(back.equipped[AccessorySlot.head], const EquippedItem('crown', variant: 'silver'));
    });

    test('an avatar without upgrades (milestone 2 JSON) has none; unknown slots are ignored', () {
      expect(AvatarSpec.fromJson({'face': 'oval'}).equipped, isEmpty);
      final spec = AvatarSpec.fromJson({
        'eq': {
          'tail': {'id': 'x'},
          'face': {'id': 'glasses', 'v': 'red'},
          'hand': 'broken',
        },
      });
      expect(spec.equipped.keys, [AccessorySlot.face]);
    });

    test('equality and copyWith include the upgrades', () {
      final a = AvatarSpec.defaults.copyWith(equipped: const {AccessorySlot.face: EquippedItem('glasses')});
      expect(a == AvatarSpec.defaults, isFalse);
      expect(a.copyWith(equipped: const {}), AvatarSpec.defaults);
    });
  });
}
