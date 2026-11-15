// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Giochi';

  @override
  String get navPlayers => 'Giocatori';

  @override
  String get navLeaderboards => 'Podio';

  @override
  String get navSettings => 'Opzioni';

  @override
  String get comingSoon => 'Presto';

  @override
  String get panelPlayersOnDevice => 'Giocatori su questo dispositivo';

  @override
  String get panelLeaderboardWeek => 'Classifica della settimana';

  @override
  String get panelLastReward => 'Ultimo premio';

  @override
  String get screenEmpty => 'Qui non c\'è ancora niente.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocatori',
      one: '$count giocatore',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Il mio avatar';

  @override
  String get avatarSave => 'Salva';

  @override
  String get avatarRandom => 'A caso';

  @override
  String get back => 'Indietro';

  @override
  String get avatarTabFace => 'Viso';

  @override
  String get avatarTabSkin => 'Pelle';

  @override
  String get avatarTabHair => 'Capelli';

  @override
  String get avatarTabEyes => 'Occhi';

  @override
  String get avatarTabMouth => 'Bocca';

  @override
  String get avatarTabBackground => 'Sfondo';

  @override
  String get avatarHairColor => 'Colore capelli';

  @override
  String get faceOval => 'ovale';

  @override
  String get faceRound => 'tondo';

  @override
  String get faceWide => 'largo';

  @override
  String get faceSquare => 'squadrato';

  @override
  String get hairShort => 'corti';

  @override
  String get hairLong => 'lunghi';

  @override
  String get hairCurly => 'ricci';

  @override
  String get hairBun => 'chignon';

  @override
  String get hairSpiky => 'a punta';

  @override
  String get hairPigtails => 'codini';

  @override
  String get hairBob => 'caschetto';

  @override
  String get hairBraids => 'trecce';

  @override
  String get hairCap => 'cappellino';

  @override
  String get hairBald => 'calvo';

  @override
  String get eyesRound => 'tondi';

  @override
  String get eyesHappy => 'felici';

  @override
  String get eyesWink => 'occhiolino';

  @override
  String get eyesSleepy => 'assonnati';

  @override
  String get eyesWide => 'spalancati';

  @override
  String get eyesLashes => 'con le ciglia';

  @override
  String get mouthSmile => 'sorriso';

  @override
  String get mouthOpen => 'aperta';

  @override
  String get mouthFlat => 'dritta';

  @override
  String get mouthGrin => 'sorrisone';

  @override
  String get mouthTongue => 'linguaccia';

  @override
  String get mouthSurprised => 'sorpresa';

  @override
  String get hairColorBlack => 'neri';

  @override
  String get hairColorBrown => 'castani';

  @override
  String get hairColorChestnut => 'ramati';

  @override
  String get hairColorBlond => 'biondi';

  @override
  String get hairColorPlatinum => 'platino';

  @override
  String get hairColorRed => 'rossi';

  @override
  String get hairColorGrey => 'grigi';

  @override
  String get hairColorBlue => 'blu';

  @override
  String skinTone(int n) {
    return 'Carnagione $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Sfondo $n';
  }

  @override
  String get playersNew => 'Nuovo giocatore';

  @override
  String get playersLimit =>
      'Su questo dispositivo ci possono essere al massimo 8 giocatori.';

  @override
  String get playersEmpty =>
      'Qui non c\'è ancora nessuno. Crea il primo giocatore!';

  @override
  String playersNowPlaying(String name) {
    return 'Ora gioca $name';
  }

  @override
  String get playerActiveTag => 'Gioca';

  @override
  String playerEdit(String name) {
    return 'Modifica $name';
  }

  @override
  String playerDelete(String name) {
    return 'Elimina $name';
  }

  @override
  String get profileName => 'Nome';

  @override
  String get profileErrorEmpty => 'Scrivi un nome.';

  @override
  String get profileErrorTooLong => 'Al massimo 16 caratteri.';

  @override
  String get profileErrorTaken => 'Un altro giocatore ha già questo nome.';

  @override
  String get profileErrorLimit =>
      'Su questo dispositivo ci possono essere al massimo 8 giocatori.';

  @override
  String deleteTitle(String name) {
    return 'Eliminare il giocatore $name?';
  }

  @override
  String get deleteMessage =>
      'Verranno eliminati anche i suoi risultati. Non si può annullare.';

  @override
  String get deleteConfirm => 'Elimina';

  @override
  String get discardTitle => 'Scartare le modifiche?';

  @override
  String get discardMessage =>
      'Le modifiche all\'avatar e al nome non verranno salvate.';

  @override
  String get discardConfirm => 'Scarta';

  @override
  String get cancel => 'Annulla';

  @override
  String get homeHello => 'Ciao,';

  @override
  String get homeSwitchPlayer => 'Cambia giocatore';

  @override
  String get homeCreatePlayer => 'Crea un giocatore';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Come il telefono';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max giocatori';
  }

  @override
  String continueTitle(String game) {
    return 'Continua: $game';
  }

  @override
  String get continueSaved => 'Partita in corso';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Gioca ▸';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get setupPlayers => 'Numero di giocatori';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '$count persona',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robot',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Livello dei robot';

  @override
  String get setupSpeed => 'Velocità dei robot';

  @override
  String get speedSlow => 'Lenta';

  @override
  String get speedNormal => 'Normale';

  @override
  String get speedFast => 'Veloce';

  @override
  String get seatHuman => 'Persona';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Impostazioni dell\'ultima partita';

  @override
  String get setupFilled => 'posti liberi occupati dai robot';

  @override
  String get setupNoFreeProfile => 'Tutti i giocatori sono già al tavolo.';

  @override
  String get seatMoveUp => 'Sposta su';

  @override
  String get seatMoveDown => 'Sposta giù';

  @override
  String get setupPlay => 'Gioca!';

  @override
  String get setupNeedPlayer => 'Prima crea un giocatore.';

  @override
  String get robotName0 => 'Robo';

  @override
  String get robotName1 => 'Chip';

  @override
  String get robotName2 => 'Bolt';

  @override
  String get robotName3 => 'Buzz';

  @override
  String get hudExit => 'Esci';

  @override
  String get hudPause => 'Pausa';

  @override
  String get hudMusic => 'Musica';

  @override
  String get hudSfx => 'Effetti sonori';

  @override
  String get exitTitle => 'Vuoi davvero uscire?';

  @override
  String get exitSaved => 'La partita in corso verrà salvata.';

  @override
  String get exitNotSaved => 'La partita in corso non verrà salvata.';

  @override
  String get exitConfirm => 'Esci';

  @override
  String get pauseResume => 'Continua';

  @override
  String get pauseRestart => 'Ricomincia';

  @override
  String get pauseRules => 'Regole';

  @override
  String get close => 'Chiudi';

  @override
  String turnOf(String name) {
    return 'Tocca a $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name sta pensando…';
  }

  @override
  String get resumeFailed => 'Non si può continuare la partita salvata.';

  @override
  String resultWins(String name) {
    return 'Vince $name!';
  }

  @override
  String get resultDraw => 'Pareggio!';

  @override
  String get resultPlayAgain => 'Gioca ancora';

  @override
  String get resultChangeSettings => 'Cambia impostazioni';

  @override
  String get resultHome => 'Home';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot =>
      'I giocatori mancanti sono stati sostituiti dai robot.';

  @override
  String get settingsSound => 'Audio';

  @override
  String get settingsMusic => 'Musica';

  @override
  String get settingsMusicVolume => 'Volume musica';

  @override
  String get settingsSfx => 'Effetti sonori';

  @override
  String get settingsSfxVolume => 'Volume effetti';

  @override
  String get settingsVibration => 'Vibrazione';

  @override
  String get settingsCredits => 'Crediti e licenze';

  @override
  String get creditsSounds => 'Musica e suoni';

  @override
  String get creditsFonts => 'Caratteri';

  @override
  String get creditsLibraries => 'Licenze delle librerie';

  @override
  String creditsLicense(String license) {
    return 'Licenza: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Prima vittoria';

  @override
  String get badgeFirstWinDescription => 'Vinci la tua prima partita.';

  @override
  String get badgeStreak5Title => 'Cinque di fila';

  @override
  String get badgeStreak5Description => 'Vinci 5 partite di fila.';

  @override
  String get badgeGames10Title => 'Dieci partite';

  @override
  String get badgeGames10Description => 'Gioca 10 partite.';

  @override
  String get badgeHardWinTitle => 'Domatore di robot';

  @override
  String get badgeHardWinDescription => 'Batti i robot a livello Difficile.';

  @override
  String get badgeAllGamesTitle => 'Esploratore';

  @override
  String get badgeAllGamesDescription => 'Gioca a tutti i giochi.';

  @override
  String get resultNewBadges => 'Nuove medaglie';

  @override
  String get leaderboardWeek => 'Settimana';

  @override
  String get leaderboardMonth => 'Mese';

  @override
  String get leaderboardAllTime => 'Sempre';

  @override
  String get leaderboardAllGames => 'Tutti i giochi';

  @override
  String get leaderboardAnyDifficulty => 'Ogni livello';

  @override
  String get leaderboardEmpty =>
      'Qui non c\'è ancora nessuno. Finisci una partita!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vittorie',
      one: '$count vittoria',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played partite',
      one: '$played partita',
    );
    return '$_temp0 · $rate%';
  }

  @override
  String playerStats(String name) {
    return 'Statistiche: $name';
  }

  @override
  String get statsPlayed => 'Giocate';

  @override
  String get statsWins => 'Vittorie';

  @override
  String get statsWinRate => '% vittorie';

  @override
  String get statsBestStreak => 'Serie migliore';

  @override
  String get statsCurrentStreak => 'Serie attuale';

  @override
  String get statsByGame => 'Per gioco';

  @override
  String statsBestScore(int score) {
    return 'Miglior punteggio: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Vittoria più veloce: $time';
  }

  @override
  String get statsBadges => 'Medaglie';

  @override
  String statsBadgeEarned(String date) {
    return 'Ottenuta il $date';
  }

  @override
  String get statsNoGames => 'Ancora nessuna partita finita.';

  @override
  String homeBestStars(int stars) {
    return 'Miglior voto: $stars stelle su 3';
  }

  @override
  String get resultPoints => 'Punti';

  @override
  String get pointsWin => 'Vittoria';

  @override
  String get pointsDraw => 'Pareggio';

  @override
  String get pointsSecond => '2° posto';

  @override
  String get pointsParticipation => 'Partecipazione';

  @override
  String pointsStars(int count) {
    return 'Voto $count ★';
  }

  @override
  String pointsStreak(int count) {
    return '$count vittorie di fila';
  }

  @override
  String get pointsFirstToday => 'Prima partita di oggi';

  @override
  String get pointsRecord => 'Nuovo record personale';

  @override
  String pointsBadge(String name) {
    return 'Medaglia: $name';
  }

  @override
  String get pointsCapped => 'Tante vittorie facili oggi';

  @override
  String get pointsGift => 'Regalo da un genitore';

  @override
  String get pointsPurchase => 'Acquisto';

  @override
  String pointsTotal(int points) {
    return 'Totale +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Nuovo livello $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Punti: $points';
  }

  @override
  String levelShort(int level) {
    return 'Liv. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Livello $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● al prossimo livello';
  }

  @override
  String get levelMax => 'Livello massimo!';

  @override
  String get statsBalance => 'Saldo';

  @override
  String get statsTotalEarned => 'Guadagnati in tutto';

  @override
  String get statsPointsHistory => 'Storia dei punti';

  @override
  String get settingsParents => 'Angolo dei genitori';

  @override
  String get parentsGateTitle => 'Solo per genitori';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Quanto fa $a × $b?';
  }

  @override
  String get parentsGateWrong => 'Non è giusto.';

  @override
  String get parentsGateLocked => 'Troppi tentativi. Riprova tra un minuto.';

  @override
  String get parentsGateOpen => 'Apri';

  @override
  String get parentsGiftTitle => 'Regala punti';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Regalare $points ● a $name?';
  }

  @override
  String get parentsGiftAction => 'Regala';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Regalati: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'È arrivata la nuova versione $version';
  }

  @override
  String get updateNow => 'Aggiorna';

  @override
  String get updateLater => 'Più tardi';

  @override
  String updateDownloading(int percent) {
    return 'Download… $percent%';
  }

  @override
  String get updateMandatory =>
      'Questa versione è troppo vecchia: aggiorna, per favore.';

  @override
  String get updateFailed => 'Il download non è riuscito. Riprova più tardi.';

  @override
  String get updatePermissionTitle => 'Ancora un permesso';

  @override
  String get updatePermissionText =>
      'Android chiederà se Deskovky può installare app. Serve solo per la nuova versione di Deskovky. Chiedi a un adulto di attivare l\'interruttore, poi torna qui.';

  @override
  String get updatePermissionOpen => 'Apri impostazioni';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsCheckNow => 'Cerca aggiornamenti ora';

  @override
  String get settingsAutoUpdate => 'Controlla da solo';

  @override
  String get updateUpToDate => 'Hai la versione più nuova.';

  @override
  String get updateCheckFailed =>
      'Controllo non riuscito: il dispositivo è connesso?';

  @override
  String get itemCap => 'Cappellino';

  @override
  String get itemEarsHeadband => 'Cerchietto con orecchie';

  @override
  String get itemFlowerWreath => 'Corona di fiori';

  @override
  String get itemTopHat => 'Cilindro';

  @override
  String get itemVikingHelmet => 'Elmo vichingo';

  @override
  String get itemPirateBandana => 'Bandana da pirata';

  @override
  String get itemWizardHat => 'Cappello da mago';

  @override
  String get itemCrown => 'Corona';

  @override
  String get itemHalo => 'Aureola';

  @override
  String get itemGlasses => 'Occhiali';

  @override
  String get itemMustache => 'Baffi';

  @override
  String get itemFacePaintStar => 'Stella dipinta';

  @override
  String get itemSunglasses => 'Occhiali da sole';

  @override
  String get itemHeroMask => 'Maschera da eroe';

  @override
  String get itemMonocle => 'Monocolo';

  @override
  String get itemCarnivalMask => 'Maschera di Carnevale';

  @override
  String get itemLollipop => 'Lecca-lecca';

  @override
  String get itemBalloon => 'Palloncino';

  @override
  String get itemIceCream => 'Gelato';

  @override
  String get itemPhone => 'Telefono';

  @override
  String get itemMicrophone => 'Microfono';

  @override
  String get itemMagicWand => 'Bacchetta magica';

  @override
  String get itemTrophy => 'Coppa';

  @override
  String get itemKitten => 'Gattino';

  @override
  String get itemChick => 'Pulcino';

  @override
  String get itemPuppy => 'Cagnolino';

  @override
  String get itemParrot => 'Pappagallo';

  @override
  String get itemDragon => 'Draghetto';

  @override
  String get itemWoodFrame => 'Cornice di legno';

  @override
  String get itemGoldFrame => 'Cornice d\'oro';

  @override
  String get itemRainbowFrame => 'Cornice arcobaleno';

  @override
  String get itemFlameFrame => 'Cornice di fiamme';

  @override
  String get itemStarFrame => 'Cornice di stelle';

  @override
  String get itemSparkles => 'Scintille';

  @override
  String get itemBubbles => 'Bolle';

  @override
  String get itemSnow => 'Neve';

  @override
  String get pointsReset => 'Un genitore ha azzerato i punti';

  @override
  String get badgeWins50Title => 'Cinquanta';

  @override
  String get badgeWins50Description =>
      'Vinci 50 partite. Premio: una coppa da tenere in mano.';

  @override
  String get badgeAllHardTitle => 'Maestro di tutti i giochi';

  @override
  String get badgeAllHardDescription =>
      'Batti i robot a livello Difficile in ogni gioco. Premio: una cornice di stelle.';

  @override
  String get badgeCollectorTitle => 'Collezionista';

  @override
  String get badgeCollectorDescription => 'Compra 10 accessori per l\'avatar.';

  @override
  String get shopTitle => 'Negozio';

  @override
  String shopTryOn(String name) {
    return 'Stai provando: $name';
  }

  @override
  String get shopAll => 'Tutto';

  @override
  String get slotHead => 'Testa';

  @override
  String get slotFace => 'Viso';

  @override
  String get slotHand => 'Mano';

  @override
  String get slotPet => 'Animale';

  @override
  String get slotFrame => 'Cornice';

  @override
  String get slotEffect => 'Effetto';

  @override
  String shopBuy(int price) {
    return 'Compra per $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Comprare $name per $price ●?';
  }

  @override
  String get shopBuyAction => 'Compra';

  @override
  String shopMissing(int points) {
    return 'Ti mancano $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Livello $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Medaglia: $name';
  }

  @override
  String get shopOwned => 'Tuo';

  @override
  String get shopEquipped => 'Indossato';

  @override
  String get shopEquipNow => 'Lo indossi subito?';

  @override
  String get shopEquip => 'Indossa';

  @override
  String get shopUnequip => 'Togli';

  @override
  String get shopNotNow => 'Non ora';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Livello $level → $next · mancano $points punti';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Livello $level';
  }

  @override
  String get wardrobeTitle => 'Armadio';

  @override
  String get wardrobeEmpty =>
      'Qui non c\'è ancora niente. Compra accessori nel negozio.';

  @override
  String get wardrobeToShop => 'Al negozio';

  @override
  String wardrobeColour(String name) {
    return 'Colore: $name';
  }

  @override
  String get colourGold => 'oro';

  @override
  String get colourSilver => 'argento';

  @override
  String get colourRed => 'rosso';

  @override
  String get colourBlue => 'blu';

  @override
  String get colourGreen => 'verde';

  @override
  String get colourYellow => 'giallo';

  @override
  String get colourBrown => 'marrone';

  @override
  String get parentsResetTitle => 'Azzera punti e accessori';

  @override
  String get parentsReset => 'Azzera';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name perderà $points ● e tutti gli accessori comprati. Livello e medaglie restano.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: punti e accessori azzerati.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, ora puoi comprare: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Acquisto: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Nuova medaglia: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Premio +$points ●.';
  }

  @override
  String get shopHooray => 'Evviva!';

  @override
  String get shopNotEnough => 'Ora non hai abbastanza punti.';

  @override
  String get shopFailed => 'Non ha funzionato. Riprova.';

  @override
  String get updatePreparing => 'Preparo l\'aggiornamento…';

  @override
  String get setupDifficultySolo => 'Livello';

  @override
  String get whereLabel => 'Dove giocare';

  @override
  String get whereHere => 'Su questo dispositivo';

  @override
  String get whereWifi => 'Ognuno sul suo (Wi-Fi)';

  @override
  String get trialTag => 'Prova';

  @override
  String get noWifi =>
      'Non sei connesso al Wi-Fi. Connettiti allo stesso Wi-Fi degli altri.';

  @override
  String get setupOpenRoom => 'Apri la stanza';

  @override
  String get roomTitle => 'Stanza';

  @override
  String get roomCode => 'Codice stanza';

  @override
  String get roomJoinHint =>
      'Gli altri inquadrano il codice QR con la fotocamera, oppure toccano Entra in una partita.';

  @override
  String get slotOpen => 'Posto libero';

  @override
  String get slotHere => '🏠 Qui';

  @override
  String get slotOwnDevice => '📱 Suo dispositivo';

  @override
  String get slotReady => 'Pronto';

  @override
  String get slotWaiting => 'In attesa';

  @override
  String get slotDisconnected => 'Disconnesso';

  @override
  String get slotMakeRobot => 'Aggiungi un robot';

  @override
  String get slotAddLocal => 'Aggiungi un giocatore di questo dispositivo';

  @override
  String get slotLeaveOpen => 'Lascia libero';

  @override
  String get roomRemove => 'Togli giocatore';

  @override
  String get roomStart => 'Inizia la partita';

  @override
  String get roomWaitReady => 'Aspettiamo che tutti siano pronti.';

  @override
  String get roomNoServer => 'Non è stato possibile aprire la stanza.';

  @override
  String get homeJoin => 'Entra in una partita';

  @override
  String get joinWho => 'Chi gioca su questo dispositivo';

  @override
  String get joinRooms => 'Stanze nella rete';

  @override
  String get joinSearching => 'Cerco le stanze…';

  @override
  String get joinByCode => 'Codice stanza (4 cifre)';

  @override
  String get joinCodeNotFound =>
      'Nella rete non c\'è nessuna stanza con questo codice.';

  @override
  String get joinAdvanced => 'Avanzate';

  @override
  String get joinAddress => 'Indirizzo (IP:porta)';

  @override
  String get joinConnect => 'Connetti';

  @override
  String get joinFailed => 'Connessione non riuscita.';

  @override
  String get joinPickSomeone => 'Scegli almeno un giocatore.';

  @override
  String get joinScanQr => 'Leggi QR';

  @override
  String get joinQrRoom => 'Stanza dal codice QR';

  @override
  String get joinOtherRoom => 'Scegli un\'altra stanza';

  @override
  String get qrNotRoom =>
      'Questo non è un codice QR di Deskovky. Inquadra il codice nella schermata Stanza.';

  @override
  String get qrCameraDenied =>
      'Senza fotocamera non posso leggere il codice QR. Permettilo nelle impostazioni del telefono, oppure scrivi il codice della stanza.';

  @override
  String get qrScanTitle => 'Inquadra il codice QR';

  @override
  String get byeVersion =>
      'Chi ospita ha un\'altra versione dell\'app. Aggiornate tutti alla stessa.';

  @override
  String get byeCode => 'Codice stanza sbagliato.';

  @override
  String get byeFull => 'La stanza è piena.';

  @override
  String get byeStarted => 'La partita è già iniziata.';

  @override
  String get byeKicked => 'Chi ospita ti ha tolto dalla stanza.';

  @override
  String get byeLost => 'Persa la connessione con chi ospita.';

  @override
  String get lobbyReady => 'Sono pronto';

  @override
  String get lobbyNotReady => 'Non ancora';

  @override
  String get lobbySettings => 'Impostazioni (sceglie chi ospita)';

  @override
  String get lobbyWaitStart => 'Aspettiamo che chi ospita inizi.';

  @override
  String get leaveRoom => 'Esci dalla stanza';

  @override
  String joinFree(int count) {
    return 'Posti liberi: $count';
  }

  @override
  String get netDecideTitle => 'Un giocatore non è tornato';

  @override
  String get netWaitMore => 'Aspetta ancora';

  @override
  String get netReplaceRobot => 'Sostituisci con un robot';

  @override
  String get netEndGame => 'Termina la partita';

  @override
  String get netLeave => 'Esci dalla partita';

  @override
  String get netRematch => 'Rivincita';

  @override
  String get netWaitHost => 'Aspettiamo chi ospita…';

  @override
  String get byeEnded => 'Chi ospita ha terminato la partita.';

  @override
  String netYourTurn(String name) {
    return '$name, tocca a te!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Tocca a $name (sul suo dispositivo)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: disconnesso – aspettiamo ($time)';
  }

  @override
  String get netReconnect => 'Riconnetti';

  @override
  String resultNotThisTime(String name) {
    return '$name, non stavolta';
  }

  @override
  String get joinLinkBusy =>
      'Stai già giocando. Prima esci dalla partita o dalla stanza.';

  @override
  String get familyTitle => 'Famiglia';

  @override
  String get familyIntro =>
      'Collega i dispositivi della famiglia: profili, punti, premi e storia delle partite saranno uguali su tutti. Basta il Wi-Fi di casa, non serve internet.';

  @override
  String get familyCreate => 'Crea una famiglia';

  @override
  String get familyJoin => 'Entra in una famiglia';

  @override
  String get familyJoinOther => 'Entra in un\'altra famiglia';

  @override
  String get familyJoinOtherWarning =>
      'Questo dispositivo è già in una famiglia. Entrando in un\'altra lasci quella attuale; i profili di questo dispositivo verranno proposti per l\'abbinamento.';

  @override
  String get familyJoinOtherConfirm => 'Entra comunque';

  @override
  String get familyAddDevice => 'Aggiungi un dispositivo';

  @override
  String get familyQrHint =>
      'Sul nuovo dispositivo apri Opzioni → Angolo dei genitori → Famiglia → Entra in una famiglia e inquadra questo codice. I due dispositivi devono essere sullo stesso Wi-Fi.';

  @override
  String get familyDevices => 'Dispositivi della famiglia';

  @override
  String get familyThisDevice => 'questo dispositivo';

  @override
  String get familyNeverSynced => 'non ancora sincronizzato';

  @override
  String get familyRemove => 'Togli dalla famiglia';

  @override
  String get familyRemoveMessage =>
      'Il dispositivo esce dall’elenco e non riceve più profili e punti. I dati che ha già gli restano. Serve solo a fare ordine: chi conosce il codice QR della famiglia può rientrare. Solo una nuova famiglia lo separa del tutto.';

  @override
  String get familyRemoved => 'tolto';

  @override
  String get familyJoined => 'Fatto: sei nella famiglia!';

  @override
  String get familyJoinFailed =>
      'Non è stato possibile entrare nella famiglia. I due dispositivi sono sullo stesso Wi-Fi, con Famiglia aperta sull\'altro?';

  @override
  String get familyNotACode => 'Questo non è un codice famiglia.';

  @override
  String get familyUpdateApps =>
      'Un dispositivo ha un\'altra versione dell\'app. Aggiorna l\'app su tutti i dispositivi.';

  @override
  String get familyCodeInJoin =>
      'Questo è un codice famiglia. Aggiungi il dispositivo in Opzioni → Angolo dei genitori → Famiglia.';

  @override
  String get familySynced => 'Sincronizzato con la famiglia';

  @override
  String get deviceTablet => 'Tablet';

  @override
  String get devicePhone => 'Telefono';

  @override
  String familyLastSync(String time) {
    return 'ultima sincronizzazione $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Togliere $name dalla famiglia?';
  }

  @override
  String get pairTitle => 'Abbina profili';

  @override
  String get pairQuestion => 'È la stessa persona?';

  @override
  String get pairMerge => 'Sì, uniscili';

  @override
  String get pairKeep => 'No, sono due';

  @override
  String get pairLook => 'Guarda dopo l\'unione';

  @override
  String get pairManual => 'Abbina a mano';

  @override
  String get pairFirst => 'Profilo';

  @override
  String get pairSecond => 'va con';

  @override
  String get pairNone => 'Nessun\'altra coppia.';

  @override
  String get refundTitle => 'I punti sono tornati';

  @override
  String get refundOk => 'Ho capito';

  @override
  String familyPairs(int count) {
    return 'Coppie possibili ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'I tuoi punti per $item sono tornati: non bastavano per tutti e due.';
  }

  @override
  String get inviteFamily => 'Invita dalla famiglia';

  @override
  String get inviteSent => 'Invito inviato.';

  @override
  String get inviteNoDevice =>
      'Nessun dispositivo della famiglia trovato nella rete.';

  @override
  String get invitePlay => 'Gioca';

  @override
  String get inviteLater => 'Non ora';

  @override
  String inviteTitle(String host, String game) {
    return '$host ti invita a $game: giochi?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Rimborso: $item – comprato due volte';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Rimborso: $item – punti insufficienti';
  }

  @override
  String get setupElsewhere => 'Su un altro dispositivo';

  @override
  String get setupBusyTag => 'In un\'altra partita';

  @override
  String get setupInvitePlay => 'Invita e gioca';

  @override
  String get slotInvited => 'Invitato, in attesa';

  @override
  String inviteFailed(String name) {
    return 'Non è stato possibile inviare l\'invito a $name.';
  }

  @override
  String get inviteNotHere => 'Non è sul Wi-Fi';

  @override
  String get navDonations => 'Dona';

  @override
  String get donationsTitle => 'Sostieni Deskovky';

  @override
  String get donationsIntro =>
      'Deskovky è fatto in casa, per le famiglie con bambini. È gratis e resterà gratis. Se ti fa divertire, puoi dare un contributo volontario al suo sviluppo.';

  @override
  String get donationsFreeTitle => 'Tutto il gioco è gratis';

  @override
  String get donationsFreeText =>
      'Nessun livello a pagamento, niente si sblocca con i soldi.';

  @override
  String get donationsNoAdsTitle => 'Niente pubblicità';

  @override
  String get donationsNoAdsText =>
      'Niente distrae i bambini e niente li spinge a comprare.';

  @override
  String get donationsNoDataTitle => 'Nessuna raccolta di dati';

  @override
  String get donationsNoDataText =>
      'Niente account, niente login. Profili e risultati restano sui tuoi dispositivi.';

  @override
  String get donationsOfflineTitle => 'Sicuro senza internet';

  @override
  String get donationsOfflineText =>
      'Funziona offline e non manda niente su di te da nessuna parte. Usa internet solo per scaricare una nuova versione.';

  @override
  String get donationsFamilyTitle => 'Gioca tutta la famiglia';

  @override
  String get donationsFamilyText =>
      'Intorno a un tavolo, oppure ognuno sul suo con il Wi-Fi di casa. I dispositivi della famiglia condividono i dati solo tra loro.';

  @override
  String get donationsKidsTitle => 'Anche per i più piccoli';

  @override
  String get donationsKidsText =>
      'Robot su tre livelli, regole con le immagini, pulsanti grandi e un angolo dei genitori.';

  @override
  String get donationsEveryoneTitle => 'Per tutti';

  @override
  String get donationsEveryoneText =>
      'Funziona con lo screen reader, ha segni per i daltonici e parla dieci lingue.';

  @override
  String get donationsGrowingTitle => 'Arrivano nuovi giochi';

  @override
  String get donationsGrowingText =>
      'Nove giochi e altri in arrivo, alcuni desiderati dai bambini.';

  @override
  String get donationsWhy =>
      'Un contributo aiuta a pagare il tempo per creare nuovi giochi e le spese di Google Play.';

  @override
  String get donationsSoon =>
      'Si potrà donare quando il gioco sarà su Google Play. Grazie!';

  @override
  String get familyRename => 'Rinomina dispositivo';

  @override
  String get familyOnline => 'Deskovky è aperto';

  @override
  String get familyOffline => 'Non disponibile';

  @override
  String familyPlaysNow(String name) {
    return 'Ora gioca $name';
  }

  @override
  String get settingsShareApp => 'Scarica su un altro dispositivo';

  @override
  String get shareAppTitle => 'Deskovky su un altro dispositivo';

  @override
  String get shareAppHint =>
      'Inquadra il codice con la fotocamera dell\'altro telefono o tablet. Si apre la pagina con la versione più nuova: scarica il file deskovky-….apk e aprilo.';

  @override
  String get inviteToAllDevices =>
      'L’invito arriva a tutti i dispositivi della rete';

  @override
  String get saveFailed => 'Non è stato possibile salvare la partita.';
}
