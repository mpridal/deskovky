import 'package:flutter/foundation.dart';

/// Game-specific setup choices, declared as a schema and rendered by the
/// framework with shared components (spec 5.7).
@immutable
sealed class GameOption {
  const GameOption({required this.id, required this.labelKey});

  final String id;
  final String labelKey;

  Object get defaultValue;

  bool accepts(Object? value);
}

class ChoiceOption extends GameOption {
  const ChoiceOption({required super.id, required super.labelKey, required this.choices, required this.defaultValue});

  final List<(Object value, String labelKey)> choices;

  @override
  final Object defaultValue;

  @override
  bool accepts(Object? value) => choices.any((c) => c.$1 == value);
}

class ToggleOption extends GameOption {
  const ToggleOption({required super.id, required super.labelKey, required this.defaultValue});

  @override
  final bool defaultValue;

  @override
  bool accepts(Object? value) => value is bool;
}

/// Options for [schema] from saved [raw] values: defaults for missing or
/// invalid values, unknown keys dropped.
Map<String, Object?> normalizeOptions(List<GameOption> schema, Map<String, Object?>? raw) => {
  for (final option in schema) option.id: option.accepts(raw?[option.id]) ? raw![option.id] : option.defaultValue,
};
