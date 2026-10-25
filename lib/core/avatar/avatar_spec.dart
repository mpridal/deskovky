import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

enum FaceShape { oval, round, wide, square }

enum HairStyle { short, long, curly, bun, spiky, pigtails, bob, braids, cap, bald }

enum EyeStyle { round, happy, wink, sleepy, wide, lashes }

enum MouthStyle { smile, open, flat, grin, tongue, surprised }

/// Color layers of the avatar (spec 5.3, mockup `SKIN` / `HAIR`).
abstract final class AvatarPalette {
  static const List<Color> skin = [
    Color(0xFFF6D7C3),
    Color(0xFFEEC1A0),
    Color(0xFFD9A07A),
    Color(0xFFB97A55),
    Color(0xFF8D5A3B),
    Color(0xFF5C3A26),
  ];

  /// Black, brown, chestnut, blond, platinum, red, grey, blue.
  static const List<Color> hair = [
    Color(0xFF2B1E16),
    Color(0xFF5A3825),
    Color(0xFFA0522D),
    Color(0xFFD8A657),
    Color(0xFFE8D9B5),
    Color(0xFFB03A2E),
    Color(0xFF7A7A7A),
    Color(0xFF3B7DD8),
  ];

  /// Player colors 1–4, gold, purple, pink, light wood.
  static const List<Color> background = [
    Color(0xFFD9534F),
    Color(0xFF3B7DD8),
    Color(0xFFE8B931),
    Color(0xFF4CAF6A),
    Color(0xFFE0A82E),
    Color(0xFF8E5BC8),
    Color(0xFFE88FB4),
    Color(0xFFC89B6D),
  ];
}

/// The base look of a human avatar, stored as a small JSON in the profile.
@immutable
class AvatarSpec {
  const AvatarSpec({
    required this.face,
    required this.skin,
    required this.hair,
    required this.hairColor,
    required this.eyes,
    required this.mouth,
    required this.background,
  });

  final FaceShape face;
  final int skin;
  final HairStyle hair;
  final int hairColor;
  final EyeStyle eyes;
  final MouthStyle mouth;
  final int background;

  static const int formatVersion = 1;

  static const AvatarSpec defaults = AvatarSpec(
    face: FaceShape.oval,
    skin: 1,
    hair: HairStyle.short,
    hairColor: 0,
    eyes: EyeStyle.round,
    mouth: MouthStyle.smile,
    background: 4,
  );

  factory AvatarSpec.random(Random random) {
    T pick<T>(List<T> values) => values[random.nextInt(values.length)];
    return AvatarSpec(
      face: pick(FaceShape.values),
      skin: random.nextInt(AvatarPalette.skin.length),
      hair: pick(HairStyle.values),
      hairColor: random.nextInt(AvatarPalette.hair.length),
      eyes: pick(EyeStyle.values),
      mouth: pick(MouthStyle.values),
      background: random.nextInt(AvatarPalette.background.length),
    );
  }

  /// Reads an avatar saved by any app version. Every invalid or missing field
  /// falls back to [defaults] on its own; unknown keys are ignored.
  factory AvatarSpec.fromJson(Map<String, Object?>? json) {
    final j = json ?? const {};
    const d = defaults;
    return AvatarSpec(
      face: _enum(FaceShape.values, j['face']) ?? d.face,
      skin: _index(j['skin'], AvatarPalette.skin.length) ?? d.skin,
      hair: _enum(HairStyle.values, j['hair']) ?? d.hair,
      hairColor: _index(j['hairColor'], AvatarPalette.hair.length) ?? d.hairColor,
      eyes: _enum(EyeStyle.values, j['eyes']) ?? d.eyes,
      mouth: _enum(MouthStyle.values, j['mouth']) ?? d.mouth,
      background: _index(j['bg'], AvatarPalette.background.length) ?? d.background,
    );
  }

  Map<String, Object?> toJson() => {
        'v': formatVersion,
        'face': face.name,
        'skin': skin,
        'hair': hair.name,
        'hairColor': hairColor,
        'eyes': eyes.name,
        'mouth': mouth.name,
        'bg': background,
      };

  AvatarSpec copyWith({
    FaceShape? face,
    int? skin,
    HairStyle? hair,
    int? hairColor,
    EyeStyle? eyes,
    MouthStyle? mouth,
    int? background,
  }) =>
      AvatarSpec(
        face: face ?? this.face,
        skin: skin ?? this.skin,
        hair: hair ?? this.hair,
        hairColor: hairColor ?? this.hairColor,
        eyes: eyes ?? this.eyes,
        mouth: mouth ?? this.mouth,
        background: background ?? this.background,
      );

  @override
  bool operator ==(Object other) =>
      other is AvatarSpec &&
      other.face == face &&
      other.skin == skin &&
      other.hair == hair &&
      other.hairColor == hairColor &&
      other.eyes == eyes &&
      other.mouth == mouth &&
      other.background == background;

  @override
  int get hashCode => Object.hash(face, skin, hair, hairColor, eyes, mouth, background);

  @override
  String toString() => 'AvatarSpec(${toJson()})';

  static T? _enum<T extends Enum>(List<T> values, Object? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }

  static int? _index(Object? value, int length) => value is int && value >= 0 && value < length ? value : null;
}
