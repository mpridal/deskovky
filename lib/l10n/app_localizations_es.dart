// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Juegos';

  @override
  String get navPlayers => 'Jugadores';

  @override
  String get navLeaderboards => 'Clasificaciones';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get panelPlayersOnDevice => 'Jugadores en este dispositivo';

  @override
  String get panelLeaderboardWeek => 'Clasificación de esta semana';

  @override
  String get panelLastReward => 'Última recompensa';

  @override
  String get screenEmpty => 'Aquí todavía no hay nada.';

  @override
  String get fontSample => '¿Pingüino? ¡Ñandú! Pequeño café';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadores',
      one: '$count jugador',
    );
    return '$_temp0';
  }
}
