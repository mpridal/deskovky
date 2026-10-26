import 'package:flutter/foundation.dart';

/// A release version `major.minor.patch` (spec 4: tags `v1.3.0`).
@immutable
class Semver implements Comparable<Semver> {
  const Semver(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  /// Accepts `v1.2.3`, `1.2.3` and `1.2.3+45` (pubspec); null otherwise.
  static Semver? parse(String text) {
    final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(\+\d+)?$').firstMatch(text.trim());
    if (m == null) return null;
    return Semver(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  }

  /// Android versionCode derived from the tag (spec 4).
  int get versionCode => major * 10000 + minor * 100 + patch;

  @override
  int compareTo(Semver other) => versionCode.compareTo(other.versionCode);

  bool operator >(Semver other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) => other is Semver && other.versionCode == versionCode;

  @override
  int get hashCode => versionCode;

  @override
  String toString() => '$major.$minor.$patch';
}
