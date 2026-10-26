import '../core/game/difficulty.dart';
import '../l10n/app_localizations.dart';
import 'registry.dart';

/// Translates a game's text key from the games' own texts (spec 8), in the
/// app's language with English as fallback; unknown keys stay as they are.
String gameText(AppLocalizations l10n, String key, [Map<String, Object?> args = const {}]) {
  for (final module in gameModules) {
    final text = module.texts.lookup(l10n.localeName, key, args);
    if (text != null) return text;
  }
  return key;
}

String difficultyLabel(AppLocalizations l10n, Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => l10n.difficultyEasy,
  Difficulty.medium => l10n.difficultyMedium,
  Difficulty.hard => l10n.difficultyHard,
};
