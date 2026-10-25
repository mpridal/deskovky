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
}
