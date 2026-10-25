import '../l10n/app_localizations.dart';

/// Translates a badge's title or description key (framework and game
/// badges). Milestone 9 moves game keys into each game's own ARB files.
String badgeText(AppLocalizations l10n, String key) => switch (key) {
  'badgeFirstWinTitle' => l10n.badgeFirstWinTitle,
  'badgeFirstWinDescription' => l10n.badgeFirstWinDescription,
  'badgeStreak5Title' => l10n.badgeStreak5Title,
  'badgeStreak5Description' => l10n.badgeStreak5Description,
  'badgeGames10Title' => l10n.badgeGames10Title,
  'badgeGames10Description' => l10n.badgeGames10Description,
  'badgeHardWinTitle' => l10n.badgeHardWinTitle,
  'badgeHardWinDescription' => l10n.badgeHardWinDescription,
  'badgeAllGamesTitle' => l10n.badgeAllGamesTitle,
  'badgeAllGamesDescription' => l10n.badgeAllGamesDescription,
  'sampleBadgeBullseyeTitle' => l10n.sampleBadgeBullseyeTitle,
  'sampleBadgeBullseyeDescription' => l10n.sampleBadgeBullseyeDescription,
  _ => key,
};
