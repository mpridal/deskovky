import 'dart:math';

final _random = Random.secure();

/// A random id for a family record (profile, match, points entry…): 32 hex
/// characters, unique across all the family's devices in practice.
String newUid() {
  final buffer = StringBuffer();
  for (var i = 0; i < 16; i++) {
    buffer.write(_random.nextInt(256).toRadixString(16).padLeft(2, '0'));
  }
  return buffer.toString();
}
