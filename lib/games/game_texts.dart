import '../core/game/difficulty.dart';
import '../l10n/app_localizations.dart';

/// Translates a game's text key. Milestone 9 replaces this switch by merging
/// ARB files from each game's own folder.
String gameText(AppLocalizations l10n, String key) => switch (key) {
  'sampleTitle' => l10n.sampleTitle,
  'sampleDescription' => l10n.sampleDescription,
  'sampleRules' => l10n.sampleRules,
  'sampleOptionRange' => l10n.sampleOptionRange,
  _ => key,
};

String difficultyLabel(AppLocalizations l10n, Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => l10n.difficultyEasy,
  Difficulty.medium => l10n.difficultyMedium,
  Difficulty.hard => l10n.difficultyHard,
};
