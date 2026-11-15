import 'package:flutter/widgets.dart';

/// A game's own texts in every app language (spec 8, 13.2): they live
/// in the game's folder, so games never touch the shared ARB files. Keys are
/// prefixed with the game id (`memory.title`); `{name}` marks a placeholder.
@immutable
class GameTexts {
  const GameTexts({this.cs = const {}, this.en = const {}, this.es = const {}, this.more = const {}});

  final Map<String, String> cs;
  final Map<String, String> en;
  final Map<String, String> es;

  /// Further languages by code ('sk', 'de', …), each kept in its own file
  /// of the game (`l10n/<game>_<language>.dart`).
  final Map<String, Map<String, String>> more;

  static final _placeholder = RegExp(r'\{(\w+)\}');

  /// The text in [languageCode] (e.g. `cs` or `cs_CZ`), else in English, else null.
  String? lookup(String languageCode, String key, [Map<String, Object?> args = const {}]) {
    final text = _of(languageCode.split('_').first)[key] ?? en[key];
    if (text == null) return null;
    return text.replaceAllMapped(_placeholder, (m) => args.containsKey(m[1]) ? '${args[m[1]]}' : m[0]!);
  }

  /// Every key in any language (contract tests check all three have it).
  Set<String> get keys => {...cs.keys, ...en.keys, ...es.keys, for (final m in more.values) ...m.keys};

  /// The texts of [language] (`sk`, `de_AT` …); English when the game has none.
  Map<String, String> language(String language) => _of(language.split('_').first);

  Map<String, String> _of(String language) => switch (language) {
    'cs' => cs,
    'es' => es,
    'en' => en,
    _ => more[language] ?? en,
  };

  /// The text in the app's current language; the key itself when missing.
  String of(BuildContext context, String key, [Map<String, Object?> args = const {}]) =>
      lookup(Localizations.localeOf(context).languageCode, key, args) ?? key;
}
