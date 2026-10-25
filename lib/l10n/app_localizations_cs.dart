// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Hry';

  @override
  String get navPlayers => 'Hráči';

  @override
  String get navLeaderboards => 'Žebříčky';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get comingSoon => 'Brzy';

  @override
  String get panelPlayersOnDevice => 'Hráči na zařízení';

  @override
  String get panelLeaderboardWeek => 'Žebříček tento týden';

  @override
  String get panelLastReward => 'Poslední odměna';

  @override
  String get screenEmpty => 'Tady zatím nic není.';

  @override
  String get fontSample => 'Příliš žluťoučký kůň úpěl ďábelské ódy';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hráčů',
      few: '$count hráči',
      one: '$count hráč',
    );
    return '$_temp0';
  }
}
