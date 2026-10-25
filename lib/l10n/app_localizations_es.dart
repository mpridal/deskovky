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
  String get navLeaderboards => 'Ranking';

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

  @override
  String get avatarEditorTitle => 'Mi avatar';

  @override
  String get avatarSave => 'Guardar';

  @override
  String get avatarRandom => 'Al azar';

  @override
  String get back => 'Atrás';

  @override
  String get avatarTabFace => 'Cara';

  @override
  String get avatarTabSkin => 'Piel';

  @override
  String get avatarTabHair => 'Pelo';

  @override
  String get avatarTabEyes => 'Ojos';

  @override
  String get avatarTabMouth => 'Boca';

  @override
  String get avatarTabBackground => 'Fondo';

  @override
  String get avatarHairColor => 'Color de pelo';

  @override
  String get faceOval => 'ovalada';

  @override
  String get faceRound => 'redonda';

  @override
  String get faceWide => 'ancha';

  @override
  String get faceSquare => 'cuadrada';

  @override
  String get hairShort => 'corto';

  @override
  String get hairLong => 'largo';

  @override
  String get hairCurly => 'rizado';

  @override
  String get hairBun => 'moño';

  @override
  String get hairSpiky => 'de punta';

  @override
  String get hairPigtails => 'coletas';

  @override
  String get hairBob => 'melena corta';

  @override
  String get hairBraids => 'trenzas';

  @override
  String get hairCap => 'gorra';

  @override
  String get hairBald => 'sin pelo';

  @override
  String get eyesRound => 'redondos';

  @override
  String get eyesHappy => 'alegres';

  @override
  String get eyesWink => 'guiño';

  @override
  String get eyesSleepy => 'dormilones';

  @override
  String get eyesWide => 'muy abiertos';

  @override
  String get eyesLashes => 'con pestañas';

  @override
  String get mouthSmile => 'sonrisa';

  @override
  String get mouthOpen => 'abierta';

  @override
  String get mouthFlat => 'recta';

  @override
  String get mouthGrin => 'sonrisa con dientes';

  @override
  String get mouthTongue => 'lengua fuera';

  @override
  String get mouthSurprised => 'sorprendida';

  @override
  String get hairColorBlack => 'negro';

  @override
  String get hairColorBrown => 'castaño';

  @override
  String get hairColorChestnut => 'caoba';

  @override
  String get hairColorBlond => 'rubio';

  @override
  String get hairColorPlatinum => 'platino';

  @override
  String get hairColorRed => 'pelirrojo';

  @override
  String get hairColorGrey => 'gris';

  @override
  String get hairColorBlue => 'azul';

  @override
  String skinTone(int n) {
    return 'Tono $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Fondo $n';
  }

  @override
  String get playersNew => 'Nuevo jugador';

  @override
  String get playersLimit => 'Este dispositivo admite como máximo 8 jugadores.';

  @override
  String get playersEmpty => 'Aún no hay nadie. ¡Crea el primer jugador!';

  @override
  String playersNowPlaying(String name) {
    return 'Ahora juega $name';
  }

  @override
  String get playerActiveTag => 'Jugando';

  @override
  String playerEdit(String name) {
    return 'Editar a $name';
  }

  @override
  String playerDelete(String name) {
    return 'Eliminar a $name';
  }

  @override
  String get profileName => 'Nombre';

  @override
  String get profileErrorEmpty => 'Escribe un nombre.';

  @override
  String get profileErrorTooLong => 'Máximo 16 caracteres.';

  @override
  String get profileErrorTaken => 'Otro jugador ya tiene este nombre.';

  @override
  String get profileErrorLimit =>
      'Este dispositivo admite como máximo 8 jugadores.';

  @override
  String deleteTitle(String name) {
    return '¿Eliminar al jugador $name?';
  }

  @override
  String get deleteMessage =>
      'También se borrarán sus resultados. No se puede deshacer.';

  @override
  String get deleteConfirm => 'Eliminar';

  @override
  String get discardTitle => '¿Descartar cambios?';

  @override
  String get discardMessage =>
      'Los cambios del avatar y del nombre no se guardarán.';

  @override
  String get discardConfirm => 'Descartar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get homeHello => '¡Hola,';

  @override
  String get homeSwitchPlayer => 'Cambiar de jugador';

  @override
  String get homeCreatePlayer => 'Crear un jugador';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Según el teléfono';

  @override
  String get sampleTitle => 'Adivina el número';

  @override
  String get sampleDescription => '¿Quién adivina primero el número secreto?';

  @override
  String get sampleRules =>
      'El juego esconde un número. Los jugadores adivinan por turnos. Después de cada intento sabréis si el número secreto es mayor o menor. ¡Gana quien lo acierte!';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max jugadores';
  }

  @override
  String continueTitle(String game) {
    return 'Continuar: $game';
  }

  @override
  String get continueSaved => 'Partida en curso';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Jugar ▸';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get sampleOptionRange => 'Rango de números';

  @override
  String get setupPlayers => 'Número de jugadores';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '$count persona',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robots',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Dificultad de los robots';

  @override
  String get setupSpeed => 'Velocidad de los robots';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rápida';

  @override
  String get seatHuman => 'Humano';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Ajustes cargados de la última partida';

  @override
  String get setupFilled => 'asientos libres ocupados por robots';

  @override
  String get setupNoFreeProfile => 'Todos los jugadores ya están en la mesa.';

  @override
  String get seatMoveUp => 'Subir';

  @override
  String get seatMoveDown => 'Bajar';

  @override
  String get setupPlay => '¡Jugar!';

  @override
  String get setupNeedPlayer => 'Primero crea un jugador.';

  @override
  String get robotName0 => 'Robi';

  @override
  String get robotName1 => 'Chispa';

  @override
  String get robotName2 => 'Tornillo';

  @override
  String get robotName3 => 'Zumbi';

  @override
  String get hudExit => 'Salir';

  @override
  String get hudPause => 'Pausa';

  @override
  String get hudMusic => 'Música';

  @override
  String get hudSfx => 'Efectos';

  @override
  String get exitTitle => '¿Seguro que quieres salir?';

  @override
  String get exitSaved => 'La partida en curso se guardará.';

  @override
  String get exitNotSaved => 'La partida en curso no se guardará.';

  @override
  String get exitConfirm => 'Salir';

  @override
  String get pauseResume => 'Continuar';

  @override
  String get pauseRestart => 'Empezar de nuevo';

  @override
  String get pauseRules => 'Reglas';

  @override
  String get close => 'Cerrar';

  @override
  String turnOf(String name) {
    return 'Turno de $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name está pensando…';
  }

  @override
  String get resumeFailed => 'No se puede continuar la partida guardada.';

  @override
  String resultWins(String name) {
    return '¡Gana $name!';
  }

  @override
  String get resultDraw => '¡Empate!';

  @override
  String get resultPlayAgain => 'Jugar otra vez';

  @override
  String get resultChangeSettings => 'Cambiar ajustes';

  @override
  String get resultHome => 'Inicio';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get sampleHigher => '¡Más!';

  @override
  String get sampleLower => '¡Menos!';

  @override
  String sampleTurnHint(String name, int low, int high) {
    return '$name, adivina un número del $low al $high';
  }

  @override
  String get seatReplacedByRobot =>
      'Los jugadores que faltan han sido sustituidos por robots.';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsMusicVolume => 'Volumen de la música';

  @override
  String get settingsSfx => 'Efectos';

  @override
  String get settingsSfxVolume => 'Volumen de los efectos';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsCredits => 'Créditos y licencias';

  @override
  String get creditsSounds => 'Música y sonidos';

  @override
  String get creditsFonts => 'Fuentes';

  @override
  String get creditsLibraries => 'Licencias de bibliotecas';

  @override
  String creditsLicense(String license) {
    return 'Licencia: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Primera victoria';

  @override
  String get badgeFirstWinDescription => 'Gana tu primera partida.';

  @override
  String get badgeStreak5Title => 'Cinco seguidas';

  @override
  String get badgeStreak5Description => 'Gana 5 partidas seguidas.';

  @override
  String get badgeGames10Title => 'Diez partidas';

  @override
  String get badgeGames10Description => 'Juega 10 partidas.';

  @override
  String get badgeHardWinTitle => 'Domador de robots';

  @override
  String get badgeHardWinDescription => 'Vence a los robots en Difícil.';

  @override
  String get badgeAllGamesTitle => 'Explorador';

  @override
  String get badgeAllGamesDescription => 'Juega a todos los juegos.';

  @override
  String get sampleBadgeBullseyeTitle => '¡En el blanco!';

  @override
  String get sampleBadgeBullseyeDescription =>
      'Adivina el número a la primera.';

  @override
  String get resultNewBadges => 'Insignias nuevas';

  @override
  String get leaderboardWeek => 'Semana';

  @override
  String get leaderboardMonth => 'Mes';

  @override
  String get leaderboardAllTime => 'Siempre';

  @override
  String get leaderboardAllGames => 'Todos los juegos';

  @override
  String get leaderboardAnyDifficulty => 'Cualquier dificultad';

  @override
  String get leaderboardEmpty => 'Todavía no hay nadie. ¡Terminad una partida!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count victorias',
      one: '$count victoria',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    return '$played partidas · $rate %';
  }

  @override
  String playerStats(String name) {
    return 'Estadísticas: $name';
  }

  @override
  String get statsPlayed => 'Jugadas';

  @override
  String get statsWins => 'Victorias';

  @override
  String get statsWinRate => 'Éxito';

  @override
  String get statsBestStreak => 'Mejor racha';

  @override
  String get statsCurrentStreak => 'Racha actual';

  @override
  String get statsByGame => 'Por juego';

  @override
  String statsBestScore(int score) {
    return 'Mejor puntuación: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Victoria más rápida: $time';
  }

  @override
  String get statsBadges => 'Insignias';

  @override
  String statsBadgeEarned(String date) {
    return 'Conseguida el $date';
  }

  @override
  String get statsNoGames => 'Aún no hay partidas terminadas.';
}
