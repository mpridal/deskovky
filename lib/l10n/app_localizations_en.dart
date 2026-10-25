// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Games';

  @override
  String get navPlayers => 'Players';

  @override
  String get navLeaderboards => 'Rankings';

  @override
  String get navSettings => 'Settings';

  @override
  String get comingSoon => 'Soon';

  @override
  String get panelPlayersOnDevice => 'Players on this device';

  @override
  String get panelLeaderboardWeek => 'This week\'s leaderboard';

  @override
  String get panelLastReward => 'Latest reward';

  @override
  String get screenEmpty => 'Nothing here yet.';

  @override
  String get fontSample => 'The quick brown fox jumps over the lazy dog';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '$count player',
    );
    return '$_temp0';
  }
}
