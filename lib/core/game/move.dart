import 'package:flutter/foundation.dart';

/// One player action as a small JSON message (spec 8): placing a piece,
/// flipping a card, rolling a die… The UI never changes game state directly.
@immutable
class Move {
  const Move({required this.seat, required this.type, this.data = const {}});

  final int seat;
  final String type;
  final Map<String, Object?> data;

  Map<String, Object?> toJson() => {'seat': seat, 'type': type, 'data': data};

  static Move? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final seat = json['seat'];
    final type = json['type'];
    final data = json['data'];
    if (seat is! int || type is! String || data is! Map<String, Object?>) return null;
    return Move(seat: seat, type: type, data: data);
  }

  @override
  bool operator ==(Object other) =>
      other is Move && other.seat == seat && other.type == type && mapEquals(other.data, data);

  @override
  int get hashCode =>
      Object.hash(seat, type, Object.hashAllUnordered(data.entries.map((e) => Object.hash(e.key, e.value))));

  @override
  String toString() => 'Move($seat, $type, $data)';
}
