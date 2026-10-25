import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/ui_kit/avatar/avatar_painter.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (var skin = 0; skin < AvatarPalette.skin.length; skin++) {
    test('eyes and mouth stand out on skin tone $skin (contrast >= 3:1)', () {
      final features = AvatarPainter.featureColors(skin);
      final skinColor = AvatarPalette.skin[skin];
      expect(_contrast(features.eyes, skinColor), greaterThanOrEqualTo(3), reason: 'eyes');
      expect(_contrast(features.mouth, skinColor), greaterThanOrEqualTo(3), reason: 'mouth');
    });
  }
}
