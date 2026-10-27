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
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played partidas',
      one: '$played partida',
    );
    return '$_temp0 · $rate %';
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

  @override
  String homeBestStars(int stars) {
    return 'Mejor valoración: $stars de 3 estrellas';
  }

  @override
  String get resultPoints => 'Puntos';

  @override
  String get pointsWin => 'Victoria';

  @override
  String get pointsDraw => 'Empate';

  @override
  String get pointsSecond => '2.º puesto';

  @override
  String get pointsParticipation => 'Participación';

  @override
  String pointsStars(int count) {
    return 'Valoración $count ★';
  }

  @override
  String pointsStreak(int count) {
    return 'Racha de $count victorias';
  }

  @override
  String get pointsFirstToday => 'Primera partida del día';

  @override
  String get pointsRecord => 'Nuevo récord personal';

  @override
  String pointsBadge(String name) {
    return 'Insignia: $name';
  }

  @override
  String get pointsCapped => 'Muchas victorias en Fácil hoy';

  @override
  String get pointsGift => 'Regalo de un padre';

  @override
  String get pointsPurchase => 'Compra';

  @override
  String pointsTotal(int points) {
    return 'Total +$points ●';
  }

  @override
  String levelUp(int level) {
    return '¡Nuevo nivel $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Puntos: $points';
  }

  @override
  String levelShort(int level) {
    return 'Nv. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Nivel $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● para el siguiente nivel';
  }

  @override
  String get levelMax => '¡Nivel máximo!';

  @override
  String get statsBalance => 'Saldo';

  @override
  String get statsTotalEarned => 'Total ganado';

  @override
  String get statsPointsHistory => 'Historial de puntos';

  @override
  String get settingsParents => 'Zona de padres';

  @override
  String get parentsGateTitle => 'Solo para padres';

  @override
  String parentsGateQuestion(int a, int b) {
    return '¿Cuánto es $a × $b?';
  }

  @override
  String get parentsGateWrong => 'No es correcto.';

  @override
  String get parentsGateOpen => 'Abrir';

  @override
  String get parentsGiftTitle => 'Regalar puntos';

  @override
  String parentsGiftConfirm(int points, String name) {
    return '¿Regalar $points ● a $name?';
  }

  @override
  String get parentsGiftAction => 'Regalar';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Regalado: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Hay una versión nueva $version';
  }

  @override
  String get updateNow => 'Actualizar';

  @override
  String get updateLater => 'Más tarde';

  @override
  String updateDownloading(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String get updateMandatory =>
      'Esta versión es demasiado antigua – actualiza, por favor.';

  @override
  String get updateFailed => 'La descarga falló. Inténtalo más tarde.';

  @override
  String get updatePermissionTitle => 'Un permiso más';

  @override
  String get updatePermissionText =>
      'Android preguntará si Deskovky puede instalar aplicaciones. Es solo para la nueva versión de Deskovky. Pide a un adulto que active el interruptor y luego vuelve aquí.';

  @override
  String get updatePermissionOpen => 'Abrir ajustes';

  @override
  String get settingsApp => 'Aplicación';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsCheckNow => 'Buscar actualizaciones ahora';

  @override
  String get settingsAutoUpdate => 'Buscar automáticamente';

  @override
  String get updateUpToDate => 'Tienes la versión más nueva.';

  @override
  String get updateCheckFailed =>
      'La búsqueda falló – ¿está el dispositivo conectado?';

  @override
  String get itemCap => 'Gorra';

  @override
  String get itemEarsHeadband => 'Diadema con orejas';

  @override
  String get itemFlowerWreath => 'Corona de flores';

  @override
  String get itemTopHat => 'Sombrero de copa';

  @override
  String get itemVikingHelmet => 'Casco vikingo';

  @override
  String get itemPirateBandana => 'Pañuelo pirata';

  @override
  String get itemWizardHat => 'Sombrero de mago';

  @override
  String get itemCrown => 'Corona';

  @override
  String get itemHalo => 'Aureola';

  @override
  String get itemGlasses => 'Gafas';

  @override
  String get itemMustache => 'Bigote';

  @override
  String get itemFacePaintStar => 'Estrella pintada';

  @override
  String get itemSunglasses => 'Gafas de sol';

  @override
  String get itemHeroMask => 'Máscara de héroe';

  @override
  String get itemMonocle => 'Monóculo';

  @override
  String get itemCarnivalMask => 'Máscara de carnaval';

  @override
  String get itemLollipop => 'Piruleta';

  @override
  String get itemBalloon => 'Globo';

  @override
  String get itemIceCream => 'Helado';

  @override
  String get itemPhone => 'Móvil';

  @override
  String get itemMicrophone => 'Micrófono';

  @override
  String get itemMagicWand => 'Varita mágica';

  @override
  String get itemTrophy => 'Trofeo';

  @override
  String get itemKitten => 'Gatito';

  @override
  String get itemChick => 'Pollito';

  @override
  String get itemPuppy => 'Perrito';

  @override
  String get itemParrot => 'Loro';

  @override
  String get itemDragon => 'Dragoncito';

  @override
  String get itemWoodFrame => 'Marco de madera';

  @override
  String get itemGoldFrame => 'Marco dorado';

  @override
  String get itemRainbowFrame => 'Marco arcoíris';

  @override
  String get itemFlameFrame => 'Marco de llamas';

  @override
  String get itemStarFrame => 'Marco de estrellas';

  @override
  String get itemSparkles => 'Destellos';

  @override
  String get itemBubbles => 'Burbujas';

  @override
  String get itemSnow => 'Nevada';

  @override
  String get pointsReset => 'Un padre reinició los puntos';

  @override
  String get badgeWins50Title => 'Cincuenta';

  @override
  String get badgeWins50Description => 'Gana 50 partidas. Premio: un trofeo.';

  @override
  String get badgeAllHardTitle => 'Maestro de todos los juegos';

  @override
  String get badgeAllHardDescription =>
      'Vence a los robots en Difícil en todos los juegos. Premio: marco de estrellas.';

  @override
  String get badgeCollectorTitle => 'Coleccionista';

  @override
  String get badgeCollectorDescription => 'Compra 10 mejoras para tu avatar.';

  @override
  String get shopTitle => 'Tienda';

  @override
  String shopTryOn(String name) {
    return 'Probando: $name';
  }

  @override
  String get shopAll => 'Todo';

  @override
  String get slotHead => 'Cabeza';

  @override
  String get slotFace => 'Cara';

  @override
  String get slotHand => 'Mano';

  @override
  String get slotPet => 'Mascota';

  @override
  String get slotFrame => 'Marco';

  @override
  String get slotEffect => 'Efecto';

  @override
  String shopBuy(int price) {
    return 'Comprar por $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return '¿Comprar $name por $price ●?';
  }

  @override
  String get shopBuyAction => 'Comprar';

  @override
  String shopMissing(int points) {
    return 'Te faltan $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Nivel $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Insignia: $name';
  }

  @override
  String get shopOwned => 'Tuyo';

  @override
  String get shopEquipped => 'Puesto';

  @override
  String get shopEquipNow => '¿Ponértelo ya?';

  @override
  String get shopEquip => 'Ponerse';

  @override
  String get shopUnequip => 'Quitarse';

  @override
  String get shopNotNow => 'Ahora no';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Nivel $level → $next · faltan $points puntos';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Nivel $level';
  }

  @override
  String get wardrobeTitle => 'Armario';

  @override
  String get wardrobeEmpty => 'Aún no hay nada. Compra mejoras en la tienda.';

  @override
  String get wardrobeToShop => 'A la tienda';

  @override
  String wardrobeColour(String name) {
    return 'Color: $name';
  }

  @override
  String get colourGold => 'dorado';

  @override
  String get colourSilver => 'plateado';

  @override
  String get colourRed => 'rojo';

  @override
  String get colourBlue => 'azul';

  @override
  String get colourGreen => 'verde';

  @override
  String get colourYellow => 'amarillo';

  @override
  String get colourBrown => 'marrón';

  @override
  String get parentsResetTitle => 'Reiniciar puntos y mejoras';

  @override
  String get parentsReset => 'Reiniciar';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name perderá $points ● y todas las mejoras compradas. El nivel y las insignias se quedan.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: puntos y mejoras reiniciados.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, ¡ya puedes comprar: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Compra: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return '¡Nueva insignia: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Premio +$points ●.';
  }

  @override
  String get shopHooray => '¡Bien!';

  @override
  String get shopNotEnough => 'Ahora no tienes puntos suficientes.';

  @override
  String get shopFailed => 'No ha funcionado. Inténtalo otra vez.';

  @override
  String get updatePreparing => 'Preparando la actualización…';

  @override
  String get setupDifficultySolo => 'Dificultad';

  @override
  String get whereLabel => 'Dónde se juega';

  @override
  String get whereHere => 'En este dispositivo';

  @override
  String get whereWifi => 'Cada uno en el suyo (Wi-Fi)';

  @override
  String get trialTag => 'De prueba';

  @override
  String get noWifi =>
      'No estás en una red Wi-Fi. Conéctate a la misma Wi-Fi que los demás.';

  @override
  String get setupOpenRoom => 'Abrir la sala';

  @override
  String get roomTitle => 'Sala';

  @override
  String get roomCode => 'Código de sala';

  @override
  String get roomJoinHint =>
      'Los demás pulsan Unirse a una partida o escanean el código QR.';

  @override
  String get slotOpen => 'Plaza libre';

  @override
  String get slotHere => '🏠 Aquí';

  @override
  String get slotOwnDevice => '📱 En el suyo';

  @override
  String get slotReady => 'Listo';

  @override
  String get slotWaiting => 'Esperando';

  @override
  String get slotDisconnected => 'Desconectado';

  @override
  String get slotMakeRobot => 'Añadir un robot';

  @override
  String get slotAddLocal => 'Añadir un jugador de este dispositivo';

  @override
  String get slotLeaveOpen => 'Dejarla libre';

  @override
  String get roomRemove => 'Quitar jugador';

  @override
  String get roomStart => 'Empezar la partida';

  @override
  String get roomWaitReady => 'Esperando a que todos estén listos.';

  @override
  String get roomNoServer => 'No se pudo abrir la sala.';

  @override
  String get homeJoin => 'Unirse a una partida';

  @override
  String get joinWho => 'Quién juega en este dispositivo';

  @override
  String get joinRooms => 'Salas en la red';

  @override
  String get joinSearching => 'Buscando salas…';

  @override
  String get joinByCode => 'Código de sala (4 cifras)';

  @override
  String get joinCodeNotFound =>
      'No hay ninguna sala con este código en la red.';

  @override
  String get joinAdvanced => 'Avanzado';

  @override
  String get joinAddress => 'Dirección (IP:puerto)';

  @override
  String get joinConnect => 'Conectar';

  @override
  String get joinFailed => 'No se pudo conectar.';

  @override
  String get joinPickSomeone => 'Elige al menos un jugador.';

  @override
  String get byeVersion =>
      'El anfitrión tiene otra versión de la app. Actualizad todos a la misma.';

  @override
  String get byeCode => 'Código de sala incorrecto.';

  @override
  String get byeFull => 'La sala está llena.';

  @override
  String get byeStarted => 'La partida ya ha empezado.';

  @override
  String get byeKicked => 'El anfitrión te ha quitado de la sala.';

  @override
  String get byeLost => 'Se perdió la conexión con el anfitrión.';

  @override
  String get lobbyReady => 'Estoy listo';

  @override
  String get lobbyNotReady => 'Todavía no';

  @override
  String get lobbySettings => 'Ajustes (los elige el anfitrión)';

  @override
  String get lobbyWaitStart => 'Esperando a que el anfitrión empiece.';

  @override
  String get leaveRoom => 'Salir de la sala';

  @override
  String joinFree(int count) {
    return 'Plazas libres: $count';
  }

  @override
  String get netDecideTitle => 'Un jugador no ha vuelto';

  @override
  String get netWaitMore => 'Esperar más';

  @override
  String get netReplaceRobot => 'Sustituir por un robot';

  @override
  String get netEndGame => 'Terminar la partida';

  @override
  String get netLeave => 'Salir de la partida';

  @override
  String get netRematch => 'Revancha';

  @override
  String get netWaitHost => 'Esperando al anfitrión…';

  @override
  String get byeEnded => 'El anfitrión terminó la partida.';

  @override
  String netYourTurn(String name) {
    return '¡$name, te toca!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Turno de $name (en su dispositivo)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: desconectado – esperando ($time)';
  }

  @override
  String get netReconnect => 'Reconectar';
}
