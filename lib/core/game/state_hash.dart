import 'dart:convert';

/// FNV-1a (32 bit) of the canonical JSON (map keys sorted) of [json]. Used to
/// check that two devices or a replay reached the same game state.
String stateHash(Object? json) {
  var hash = 0x811C9DC5;
  for (final byte in utf8.encode(jsonEncode(_canonical(json)))) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

Object? _canonical(Object? value) => switch (value) {
  Map() => {for (final key in value.keys.map((k) => '$k').toList()..sort()) key: _canonical(value[key])},
  List() => [for (final item in value) _canonical(item)],
  _ => value,
};
