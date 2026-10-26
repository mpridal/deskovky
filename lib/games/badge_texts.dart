import '../l10n/app_localizations.dart';
import 'game_texts.dart';

/// Translates a badge's title or description key: framework badges from the
/// shared ARB files, game badges from each game's own texts.
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
  'badgeWins50Title' => l10n.badgeWins50Title,
  'badgeWins50Description' => l10n.badgeWins50Description,
  'badgeAllHardTitle' => l10n.badgeAllHardTitle,
  'badgeAllHardDescription' => l10n.badgeAllHardDescription,
  'badgeCollectorTitle' => l10n.badgeCollectorTitle,
  'badgeCollectorDescription' => l10n.badgeCollectorDescription,
  _ => gameText(l10n, key),
};
