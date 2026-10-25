import 'package:flutter/foundation.dart';

import '../avatar/avatar_spec.dart';

/// A player profile on this device (spec 5.2). No personal data besides the
/// nickname.
@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.favoriteSeat,
    required this.createdAt,
  });

  final int id;
  final String name;
  final AvatarSpec avatar;

  /// Preferred seat color 0–3, or null.
  final int? favoriteSeat;
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      other is PlayerProfile &&
      other.id == id &&
      other.name == name &&
      other.avatar == avatar &&
      other.favoriteSeat == favoriteSeat &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, name, avatar, favoriteSeat, createdAt);

  @override
  String toString() => 'PlayerProfile($id, $name)';
}

enum ProfileError { nameEmpty, nameTooLong, nameTaken, limitReached, notFound }

class ProfileException implements Exception {
  const ProfileException(this.error);

  final ProfileError error;

  @override
  String toString() => 'ProfileException($error)';
}
