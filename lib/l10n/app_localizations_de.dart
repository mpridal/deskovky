// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Spiele';

  @override
  String get navPlayers => 'Spieler';

  @override
  String get navLeaderboards => 'Rangliste';

  @override
  String get navSettings => 'Optionen';

  @override
  String get comingSoon => 'Bald';

  @override
  String get panelPlayersOnDevice => 'Spieler auf diesem Gerät';

  @override
  String get panelLeaderboardWeek => 'Rangliste dieser Woche';

  @override
  String get panelLastReward => 'Neueste Belohnung';

  @override
  String get screenEmpty => 'Hier ist noch nichts.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spieler',
      one: '$count Spieler',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Mein Avatar';

  @override
  String get avatarSave => 'Speichern';

  @override
  String get avatarRandom => 'Zufall';

  @override
  String get back => 'Zurück';

  @override
  String get avatarTabFace => 'Gesicht';

  @override
  String get avatarTabSkin => 'Haut';

  @override
  String get avatarTabHair => 'Haare';

  @override
  String get avatarTabEyes => 'Augen';

  @override
  String get avatarTabMouth => 'Mund';

  @override
  String get avatarTabBackground => 'Hintergrund';

  @override
  String get avatarHairColor => 'Haarfarbe';

  @override
  String get faceOval => 'oval';

  @override
  String get faceRound => 'rund';

  @override
  String get faceWide => 'breit';

  @override
  String get faceSquare => 'eckig';

  @override
  String get hairShort => 'kurz';

  @override
  String get hairLong => 'lang';

  @override
  String get hairCurly => 'lockig';

  @override
  String get hairBun => 'Dutt';

  @override
  String get hairSpiky => 'stachelig';

  @override
  String get hairPigtails => 'Zöpfchen';

  @override
  String get hairBob => 'Bob';

  @override
  String get hairBraids => 'Zöpfe';

  @override
  String get hairCap => 'Mütze';

  @override
  String get hairBald => 'Glatze';

  @override
  String get eyesRound => 'rund';

  @override
  String get eyesHappy => 'fröhlich';

  @override
  String get eyesWink => 'zwinkernd';

  @override
  String get eyesSleepy => 'müde';

  @override
  String get eyesWide => 'weit offen';

  @override
  String get eyesLashes => 'mit Wimpern';

  @override
  String get mouthSmile => 'Lächeln';

  @override
  String get mouthOpen => 'offen';

  @override
  String get mouthFlat => 'gerade';

  @override
  String get mouthGrin => 'Grinsen';

  @override
  String get mouthTongue => 'Zunge raus';

  @override
  String get mouthSurprised => 'überrascht';

  @override
  String get hairColorBlack => 'schwarz';

  @override
  String get hairColorBrown => 'braun';

  @override
  String get hairColorChestnut => 'kastanienbraun';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platinblond';

  @override
  String get hairColorRed => 'rot';

  @override
  String get hairColorGrey => 'grau';

  @override
  String get hairColorBlue => 'blau';

  @override
  String skinTone(int n) {
    return 'Hautton $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Hintergrund $n';
  }

  @override
  String get playersNew => 'Neuer Spieler';

  @override
  String get playersLimit => 'Auf diesem Gerät gibt es höchstens 8 Spieler.';

  @override
  String get playersEmpty => 'Noch niemand da. Leg den ersten Spieler an!';

  @override
  String playersNowPlaying(String name) {
    return '$name spielt gerade';
  }

  @override
  String get playerActiveTag => 'Spielt';

  @override
  String playerEdit(String name) {
    return '$name bearbeiten';
  }

  @override
  String playerDelete(String name) {
    return '$name löschen';
  }

  @override
  String get profileName => 'Name';

  @override
  String get profileErrorEmpty => 'Gib einen Namen ein.';

  @override
  String get profileErrorTooLong => 'Höchstens 16 Zeichen.';

  @override
  String get profileErrorTaken => 'Diesen Namen hat schon ein anderer Spieler.';

  @override
  String get profileErrorLimit =>
      'Auf diesem Gerät gibt es höchstens 8 Spieler.';

  @override
  String deleteTitle(String name) {
    return 'Spieler $name löschen?';
  }

  @override
  String get deleteMessage =>
      'Auch die Ergebnisse werden gelöscht. Das kann man nicht rückgängig machen.';

  @override
  String get deleteConfirm => 'Löschen';

  @override
  String get discardTitle => 'Änderungen verwerfen?';

  @override
  String get discardMessage =>
      'Die Änderungen an Avatar und Name werden nicht gespeichert.';

  @override
  String get discardConfirm => 'Verwerfen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get homeHello => 'Hallo,';

  @override
  String get homeSwitchPlayer => 'Spieler wechseln';

  @override
  String get homeCreatePlayer => 'Spieler anlegen';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Wie am Handy';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max Spieler';
  }

  @override
  String continueTitle(String game) {
    return 'Weiterspielen: $game';
  }

  @override
  String get continueSaved => 'Laufendes Spiel';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Spielen ▸';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get setupPlayers => 'Anzahl Spieler';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Menschen',
      one: '$count Mensch',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Roboter',
      one: '$count Roboter',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Roboter-Stärke';

  @override
  String get setupSpeed => 'Roboter-Tempo';

  @override
  String get speedSlow => 'Langsam';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Schnell';

  @override
  String get seatHuman => 'Mensch';

  @override
  String get seatRobot => '🤖 Roboter';

  @override
  String get setupLoaded => '↺ Einstellungen aus deinem letzten Spiel';

  @override
  String get setupFilled => 'freie Plätze mit Robotern gefüllt';

  @override
  String get setupNoFreeProfile => 'Alle Spieler sitzen schon am Tisch.';

  @override
  String get seatMoveUp => 'Nach oben';

  @override
  String get seatMoveDown => 'Nach unten';

  @override
  String get setupPlay => 'Los!';

  @override
  String get setupNeedPlayer => 'Leg zuerst einen Spieler an.';

  @override
  String get robotName0 => 'Robo';

  @override
  String get robotName1 => 'Chip';

  @override
  String get robotName2 => 'Bolt';

  @override
  String get robotName3 => 'Buzz';

  @override
  String get hudExit => 'Beenden';

  @override
  String get hudPause => 'Pause';

  @override
  String get hudMusic => 'Musik';

  @override
  String get hudSfx => 'Geräusche';

  @override
  String get exitTitle => 'Wirklich aufhören?';

  @override
  String get exitSaved => 'Das laufende Spiel wird gespeichert.';

  @override
  String get exitNotSaved => 'Das laufende Spiel wird nicht gespeichert.';

  @override
  String get exitConfirm => 'Aufhören';

  @override
  String get pauseResume => 'Weiter';

  @override
  String get pauseRestart => 'Neu starten';

  @override
  String get pauseRules => 'Regeln';

  @override
  String get close => 'Schließen';

  @override
  String turnOf(String name) {
    return '$name ist dran';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name denkt nach…';
  }

  @override
  String get resumeFailed =>
      'Das gespeicherte Spiel kann nicht fortgesetzt werden.';

  @override
  String resultWins(String name) {
    return '$name gewinnt!';
  }

  @override
  String get resultDraw => 'Unentschieden!';

  @override
  String get resultPlayAgain => 'Nochmal';

  @override
  String get resultChangeSettings => 'Einstellungen ändern';

  @override
  String get resultHome => 'Start';

  @override
  String get resultRobotTag => 'Roboter';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot =>
      'Fehlende Spieler wurden durch Roboter ersetzt.';

  @override
  String get settingsSound => 'Ton';

  @override
  String get settingsMusic => 'Musik';

  @override
  String get settingsMusicVolume => 'Musik-Lautstärke';

  @override
  String get settingsSfx => 'Geräusche';

  @override
  String get settingsSfxVolume => 'Geräusch-Lautstärke';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsCredits => 'Mitwirkende und Lizenzen';

  @override
  String get creditsSounds => 'Musik und Geräusche';

  @override
  String get creditsFonts => 'Schriften';

  @override
  String get creditsLibraries => 'Bibliothek-Lizenzen';

  @override
  String creditsLicense(String license) {
    return 'Lizenz: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Erster Sieg';

  @override
  String get badgeFirstWinDescription => 'Gewinne dein erstes Spiel.';

  @override
  String get badgeStreak5Title => 'Fünf am Stück';

  @override
  String get badgeStreak5Description => 'Gewinne 5 Spiele hintereinander.';

  @override
  String get badgeGames10Title => 'Zehn Spiele';

  @override
  String get badgeGames10Description => 'Spiele 10 Spiele.';

  @override
  String get badgeHardWinTitle => 'Roboter-Bändiger';

  @override
  String get badgeHardWinDescription => 'Besiege die Roboter auf Schwer.';

  @override
  String get badgeAllGamesTitle => 'Entdecker';

  @override
  String get badgeAllGamesDescription => 'Spiele jedes Spiel.';

  @override
  String get resultNewBadges => 'Neue Abzeichen';

  @override
  String get leaderboardWeek => 'Woche';

  @override
  String get leaderboardMonth => 'Monat';

  @override
  String get leaderboardAllTime => 'Immer';

  @override
  String get leaderboardAllGames => 'Alle Spiele';

  @override
  String get leaderboardAnyDifficulty => 'Jede Stufe';

  @override
  String get leaderboardEmpty => 'Noch niemand da. Spiel ein Spiel zu Ende!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Siege',
      one: '$count Sieg',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played Spiele',
      one: '$played Spiel',
    );
    return '$_temp0 · $rate %';
  }

  @override
  String playerStats(String name) {
    return 'Statistik: $name';
  }

  @override
  String get statsPlayed => 'Gespielt';

  @override
  String get statsWins => 'Siege';

  @override
  String get statsWinRate => 'Siegquote';

  @override
  String get statsBestStreak => 'Beste Serie';

  @override
  String get statsCurrentStreak => 'Aktuelle Serie';

  @override
  String get statsByGame => 'Nach Spiel';

  @override
  String statsBestScore(int score) {
    return 'Bestes Ergebnis: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Schnellster Sieg: $time';
  }

  @override
  String get statsBadges => 'Abzeichen';

  @override
  String statsBadgeEarned(String date) {
    return 'Erhalten am $date';
  }

  @override
  String get statsNoGames => 'Noch keine beendeten Spiele.';

  @override
  String homeBestStars(int stars) {
    return 'Beste Wertung: $stars von 3 Sternen';
  }

  @override
  String get resultPoints => 'Punkte';

  @override
  String get pointsWin => 'Sieg';

  @override
  String get pointsDraw => 'Unentschieden';

  @override
  String get pointsSecond => '2. Platz';

  @override
  String get pointsParticipation => 'Mitgespielt';

  @override
  String pointsStars(int count) {
    return 'Wertung $count ★';
  }

  @override
  String pointsStreak(int count) {
    return '$count Siege hintereinander';
  }

  @override
  String get pointsFirstToday => 'Erstes Spiel heute';

  @override
  String get pointsRecord => 'Neuer eigener Rekord';

  @override
  String pointsBadge(String name) {
    return 'Abzeichen: $name';
  }

  @override
  String get pointsCapped => 'Heute schon viele Siege auf Leicht';

  @override
  String get pointsGift => 'Geschenk von den Eltern';

  @override
  String get pointsPurchase => 'Einkauf';

  @override
  String pointsTotal(int points) {
    return 'Gesamt +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Neues Level $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Punkte: $points';
  }

  @override
  String levelShort(int level) {
    return 'Lv $level';
  }

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● bis zum nächsten Level';
  }

  @override
  String get levelMax => 'Höchstes Level!';

  @override
  String get statsBalance => 'Kontostand';

  @override
  String get statsTotalEarned => 'Insgesamt verdient';

  @override
  String get statsPointsHistory => 'Punkte-Verlauf';

  @override
  String get settingsParents => 'Elternbereich';

  @override
  String get parentsGateTitle => 'Nur für Eltern';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Wie viel ist $a × $b?';
  }

  @override
  String get parentsGateWrong => 'Das stimmt nicht.';

  @override
  String get parentsGateOpen => 'Öffnen';

  @override
  String get parentsGiftTitle => 'Punkte schenken';

  @override
  String parentsGiftConfirm(int points, String name) {
    return '$points ● an $name schenken?';
  }

  @override
  String get parentsGiftAction => 'Schenken';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Geschenkt: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Neue Version $version ist da';
  }

  @override
  String get updateNow => 'Aktualisieren';

  @override
  String get updateLater => 'Später';

  @override
  String updateDownloading(int percent) {
    return 'Wird geladen… $percent %';
  }

  @override
  String get updateMandatory =>
      'Diese Version ist zu alt – bitte aktualisieren.';

  @override
  String get updateFailed =>
      'Der Download hat nicht geklappt. Versuch es später noch einmal.';

  @override
  String get updatePermissionTitle => 'Noch eine Erlaubnis';

  @override
  String get updatePermissionText =>
      'Android fragt, ob Deskovky Apps installieren darf. Das ist nur für die neue Deskovky-Version. Bitte einen Erwachsenen, den Schalter einzuschalten, und komm dann hierher zurück.';

  @override
  String get updatePermissionOpen => 'Einstellungen öffnen';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsCheckNow => 'Jetzt nach Updates suchen';

  @override
  String get settingsAutoUpdate => 'Automatisch suchen';

  @override
  String get updateUpToDate => 'Du hast die neueste Version.';

  @override
  String get updateCheckFailed =>
      'Die Suche hat nicht geklappt – ist das Gerät online?';

  @override
  String get itemCap => 'Kappe';

  @override
  String get itemEarsHeadband => 'Ohren-Haarreif';

  @override
  String get itemFlowerWreath => 'Blumenkranz';

  @override
  String get itemTopHat => 'Zylinder';

  @override
  String get itemVikingHelmet => 'Wikingerhelm';

  @override
  String get itemPirateBandana => 'Piratentuch';

  @override
  String get itemWizardHat => 'Zauberhut';

  @override
  String get itemCrown => 'Krone';

  @override
  String get itemHalo => 'Heiligenschein';

  @override
  String get itemGlasses => 'Brille';

  @override
  String get itemMustache => 'Schnurrbart';

  @override
  String get itemFacePaintStar => 'Stern-Schminke';

  @override
  String get itemSunglasses => 'Sonnenbrille';

  @override
  String get itemHeroMask => 'Heldenmaske';

  @override
  String get itemMonocle => 'Monokel';

  @override
  String get itemCarnivalMask => 'Faschingsmaske';

  @override
  String get itemLollipop => 'Lutscher';

  @override
  String get itemBalloon => 'Luftballon';

  @override
  String get itemIceCream => 'Eis';

  @override
  String get itemPhone => 'Handy';

  @override
  String get itemMicrophone => 'Mikrofon';

  @override
  String get itemMagicWand => 'Zauberstab';

  @override
  String get itemTrophy => 'Pokal';

  @override
  String get itemKitten => 'Kätzchen';

  @override
  String get itemChick => 'Küken';

  @override
  String get itemPuppy => 'Welpe';

  @override
  String get itemParrot => 'Papagei';

  @override
  String get itemDragon => 'Kleiner Drache';

  @override
  String get itemWoodFrame => 'Holzrahmen';

  @override
  String get itemGoldFrame => 'Goldrahmen';

  @override
  String get itemRainbowFrame => 'Regenbogenrahmen';

  @override
  String get itemFlameFrame => 'Flammenrahmen';

  @override
  String get itemStarFrame => 'Sternenrahmen';

  @override
  String get itemSparkles => 'Funkeln';

  @override
  String get itemBubbles => 'Seifenblasen';

  @override
  String get itemSnow => 'Schneefall';

  @override
  String get pointsReset => 'Ein Elternteil hat die Punkte zurückgesetzt';

  @override
  String get badgeWins50Title => 'Fünfzig';

  @override
  String get badgeWins50Description =>
      'Gewinne 50 Spiele. Belohnung: ein Pokal für die Hand.';

  @override
  String get badgeAllHardTitle => 'Meister aller Spiele';

  @override
  String get badgeAllHardDescription =>
      'Besiege die Roboter auf Schwer in jedem Spiel. Belohnung: ein Sternenrahmen.';

  @override
  String get badgeCollectorTitle => 'Sammler';

  @override
  String get badgeCollectorDescription => 'Kauf 10 Avatar-Extras.';

  @override
  String get shopTitle => 'Laden';

  @override
  String shopTryOn(String name) {
    return 'Anprobe: $name';
  }

  @override
  String get shopAll => 'Alle';

  @override
  String get slotHead => 'Kopf';

  @override
  String get slotFace => 'Gesicht';

  @override
  String get slotHand => 'Hand';

  @override
  String get slotPet => 'Tier';

  @override
  String get slotFrame => 'Rahmen';

  @override
  String get slotEffect => 'Effekt';

  @override
  String shopBuy(int price) {
    return 'Kaufen für $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return '$name für $price ● kaufen?';
  }

  @override
  String get shopBuyAction => 'Kaufen';

  @override
  String shopMissing(int points) {
    return 'Dir fehlen noch $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Level $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Abzeichen: $name';
  }

  @override
  String get shopOwned => 'Gekauft';

  @override
  String get shopEquipped => 'Trägst du';

  @override
  String get shopEquipNow => 'Gleich anziehen?';

  @override
  String get shopEquip => 'Anziehen';

  @override
  String get shopUnequip => 'Ausziehen';

  @override
  String get shopNotNow => 'Jetzt nicht';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Level $level → $next · noch $points Punkte';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Level $level';
  }

  @override
  String get wardrobeTitle => 'Kleiderschrank';

  @override
  String get wardrobeEmpty => 'Hier ist noch nichts. Kauf Extras im Laden.';

  @override
  String get wardrobeToShop => 'Zum Laden';

  @override
  String wardrobeColour(String name) {
    return 'Farbe: $name';
  }

  @override
  String get colourGold => 'gold';

  @override
  String get colourSilver => 'silber';

  @override
  String get colourRed => 'rot';

  @override
  String get colourBlue => 'blau';

  @override
  String get colourGreen => 'grün';

  @override
  String get colourYellow => 'gelb';

  @override
  String get colourBrown => 'braun';

  @override
  String get parentsResetTitle => 'Punkte und Extras zurücksetzen';

  @override
  String get parentsReset => 'Zurücksetzen';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name verliert $points ● und alle gekauften Extras. Level und Abzeichen bleiben.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: Punkte und Extras zurückgesetzt.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, jetzt kannst du kaufen: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Einkauf: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Neues Abzeichen: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Belohnung +$points ●.';
  }

  @override
  String get shopHooray => 'Hurra!';

  @override
  String get shopNotEnough => 'Dafür hast du gerade nicht genug Punkte.';

  @override
  String get shopFailed => 'Das hat nicht geklappt. Versuch es noch einmal.';

  @override
  String get updatePreparing => 'Update wird vorbereitet…';

  @override
  String get setupDifficultySolo => 'Schwierigkeit';

  @override
  String get whereLabel => 'Wo spielen';

  @override
  String get whereHere => 'Auf diesem Gerät';

  @override
  String get whereWifi => 'Jeder an seinem (WLAN)';

  @override
  String get trialTag => 'Test';

  @override
  String get noWifi =>
      'Du bist nicht im WLAN. Verbinde dich mit demselben WLAN wie die anderen.';

  @override
  String get setupOpenRoom => 'Raum öffnen';

  @override
  String get roomTitle => 'Raum';

  @override
  String get roomCode => 'Raumcode';

  @override
  String get roomJoinHint =>
      'Die anderen scannen den QR-Code mit der Kamera oder tippen auf Spiel beitreten.';

  @override
  String get slotOpen => 'Freier Platz';

  @override
  String get slotHere => '🏠 Hier';

  @override
  String get slotOwnDevice => '📱 Eigenes Gerät';

  @override
  String get slotReady => 'Bereit';

  @override
  String get slotWaiting => 'Wartet';

  @override
  String get slotDisconnected => 'Getrennt';

  @override
  String get slotMakeRobot => 'Roboter dazu';

  @override
  String get slotAddLocal => 'Spieler von diesem Gerät dazu';

  @override
  String get slotLeaveOpen => 'Frei lassen';

  @override
  String get roomRemove => 'Spieler entfernen';

  @override
  String get roomStart => 'Spiel starten';

  @override
  String get roomWaitReady => 'Warten, bis alle bereit sind.';

  @override
  String get roomNoServer => 'Der Raum konnte nicht geöffnet werden.';

  @override
  String get homeJoin => 'Spiel beitreten';

  @override
  String get joinWho => 'Wer spielt auf diesem Gerät';

  @override
  String get joinRooms => 'Räume im Netzwerk';

  @override
  String get joinSearching => 'Suche Räume…';

  @override
  String get joinByCode => 'Raumcode (4 Ziffern)';

  @override
  String get joinCodeNotFound => 'Kein Raum mit diesem Code im Netzwerk.';

  @override
  String get joinAdvanced => 'Erweitert';

  @override
  String get joinAddress => 'Adresse (IP:Port)';

  @override
  String get joinConnect => 'Verbinden';

  @override
  String get joinFailed => 'Verbindung fehlgeschlagen.';

  @override
  String get joinPickSomeone => 'Wähle mindestens einen Spieler.';

  @override
  String get joinScanQr => 'QR scannen';

  @override
  String get joinQrRoom => 'Raum aus dem QR-Code';

  @override
  String get joinOtherRoom => 'Anderen Raum wählen';

  @override
  String get qrNotRoom =>
      'Das ist kein Deskovky-QR-Code. Scanne den Code auf dem Raum-Bildschirm.';

  @override
  String get qrCameraDenied =>
      'Ohne Kamera kann ich den QR-Code nicht lesen. Erlaube sie in den Handy-Einstellungen oder tippe den Raumcode ein.';

  @override
  String get qrScanTitle => 'Richte die Kamera auf den QR-Code';

  @override
  String get byeVersion =>
      'Der Gastgeber hat eine andere Version der App. Aktualisiert alle auf dieselbe.';

  @override
  String get byeCode => 'Falscher Raumcode.';

  @override
  String get byeFull => 'Der Raum ist voll.';

  @override
  String get byeStarted => 'Das Spiel hat schon begonnen.';

  @override
  String get byeKicked => 'Der Gastgeber hat dich aus dem Raum entfernt.';

  @override
  String get byeLost => 'Die Verbindung zum Gastgeber ist abgebrochen.';

  @override
  String get lobbyReady => 'Ich bin bereit';

  @override
  String get lobbyNotReady => 'Noch nicht';

  @override
  String get lobbySettings => 'Spieleinstellungen (wählt der Gastgeber)';

  @override
  String get lobbyWaitStart => 'Warten, bis der Gastgeber startet.';

  @override
  String get leaveRoom => 'Raum verlassen';

  @override
  String joinFree(int count) {
    return 'Freie Plätze: $count';
  }

  @override
  String get netDecideTitle => 'Ein Spieler ist nicht zurückgekommen';

  @override
  String get netWaitMore => 'Länger warten';

  @override
  String get netReplaceRobot => 'Durch Roboter ersetzen';

  @override
  String get netEndGame => 'Spiel beenden';

  @override
  String get netLeave => 'Spiel verlassen';

  @override
  String get netRematch => 'Revanche';

  @override
  String get netWaitHost => 'Warten auf den Gastgeber…';

  @override
  String get byeEnded => 'Der Gastgeber hat das Spiel beendet.';

  @override
  String netYourTurn(String name) {
    return '$name, du bist dran!';
  }

  @override
  String netTurnRemote(String name) {
    return '$name ist dran (auf dem eigenen Gerät)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: getrennt – warte ($time)';
  }

  @override
  String get netReconnect => 'Neu verbinden';

  @override
  String resultNotThisTime(String name) {
    return '$name, diesmal nicht';
  }

  @override
  String get joinLinkBusy =>
      'Du spielst schon. Verlass zuerst das Spiel oder den Raum.';

  @override
  String get familyTitle => 'Familie';

  @override
  String get familyIntro =>
      'Verbinde die Geräte deiner Familie: Profile, Punkte, Belohnungen und Spielverlauf sind dann auf allen gleich. Das WLAN zu Hause reicht, Internet ist nicht nötig.';

  @override
  String get familyCreate => 'Familie gründen';

  @override
  String get familyJoin => 'Familie beitreten';

  @override
  String get familyJoinOther => 'Anderer Familie beitreten';

  @override
  String get familyJoinOtherWarning =>
      'Dieses Gerät ist schon in einer Familie. Wenn du einer anderen beitrittst, verlässt es die jetzige Familie; die Profile auf diesem Gerät werden zum Zusammenführen angeboten.';

  @override
  String get familyJoinOtherConfirm => 'Trotzdem beitreten';

  @override
  String get familyAddDevice => 'Gerät hinzufügen';

  @override
  String get familyQrHint =>
      'Öffne auf dem neuen Gerät Optionen → Elternbereich → Familie → Familie beitreten und scanne diesen Code. Beide Geräte müssen im selben WLAN sein.';

  @override
  String get familyDevices => 'Geräte in der Familie';

  @override
  String get familyThisDevice => 'dieses Gerät';

  @override
  String get familyNeverSynced => 'noch nicht abgeglichen';

  @override
  String get familyRemove => 'Aus der Familie entfernen';

  @override
  String get familyRemoveMessage =>
      'Das Gerät bekommt dann keine Profile und Punkte mehr. Die Daten, die schon darauf sind, bleiben dort.';

  @override
  String get familyRemoved => 'entfernt';

  @override
  String get familyJoined => 'Fertig – du bist in der Familie!';

  @override
  String get familyJoinFailed =>
      'Der Beitritt zur Familie hat nicht geklappt. Sind beide Geräte im selben WLAN und ist auf dem anderen Familie geöffnet?';

  @override
  String get familyNotACode => 'Das ist kein Familien-Code.';

  @override
  String get familyUpdateApps =>
      'Ein Gerät hat eine andere Version der App. Aktualisiere die App auf allen Geräten.';

  @override
  String get familyCodeInJoin =>
      'Das ist ein Familien-Code. Füge das Gerät unter Optionen → Elternbereich → Familie hinzu.';

  @override
  String get familySynced => 'Mit der Familie abgeglichen';

  @override
  String get deviceTablet => 'Tablet';

  @override
  String get devicePhone => 'Handy';

  @override
  String familyLastSync(String time) {
    return 'zuletzt abgeglichen $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return '$name aus der Familie entfernen?';
  }

  @override
  String get pairTitle => 'Profile zusammenführen';

  @override
  String get pairQuestion => 'Ist das dieselbe Person?';

  @override
  String get pairMerge => 'Ja, zusammenführen';

  @override
  String get pairKeep => 'Nein, zwei Personen';

  @override
  String get pairLook => 'Aussehen danach';

  @override
  String get pairManual => 'Von Hand zuordnen';

  @override
  String get pairFirst => 'Profil';

  @override
  String get pairSecond => 'gehört zu';

  @override
  String get pairNone => 'Keine weiteren Paare.';

  @override
  String get refundTitle => 'Punkte sind zurück';

  @override
  String get refundOk => 'Verstanden';

  @override
  String familyPairs(int count) {
    return 'Mögliche Paare ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Deine Punkte für $item sind zurück – es waren nicht genug Punkte für beides da.';
  }

  @override
  String get inviteFamily => 'Aus der Familie einladen';

  @override
  String get inviteSent => 'Einladung gesendet.';

  @override
  String get inviteNoDevice => 'Kein Familiengerät im Netzwerk gefunden.';

  @override
  String get invitePlay => 'Spielen';

  @override
  String get inviteLater => 'Jetzt nicht';

  @override
  String inviteTitle(String host, String game) {
    return '$host lädt dich zu $game ein – mitspielen?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Erstattet: $item – doppelt gekauft';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Erstattet: $item – zu wenig Punkte';
  }

  @override
  String get setupElsewhere => 'Auf einem anderen Gerät';

  @override
  String get setupBusyTag => 'In einem anderen Spiel';

  @override
  String get setupInvitePlay => 'Einladen und spielen';

  @override
  String get slotInvited => 'Eingeladen, warte';

  @override
  String inviteFailed(String name) {
    return 'Die Einladung an $name kam nicht an.';
  }

  @override
  String get inviteNotHere => 'Nicht im WLAN';

  @override
  String get navDonations => 'Spenden';

  @override
  String get donationsTitle => 'Deskovky unterstützen';

  @override
  String get donationsIntro =>
      'Deskovky entsteht zu Hause, für Familien mit Kindern. Es ist kostenlos und bleibt kostenlos. Wenn es dir Freude macht, kannst du freiwillig etwas zur Entwicklung beitragen.';

  @override
  String get donationsFreeTitle => 'Das ganze Spiel ist kostenlos';

  @override
  String get donationsFreeText =>
      'Keine bezahlten Level, nichts wird für Geld freigeschaltet.';

  @override
  String get donationsNoAdsTitle => 'Keine Werbung';

  @override
  String get donationsNoAdsText =>
      'Nichts lenkt Kinder ab und nichts verleitet sie zum Kaufen.';

  @override
  String get donationsNoDataTitle => 'Keine Datensammlung';

  @override
  String get donationsNoDataText =>
      'Keine Konten, keine Anmeldung. Profile und Ergebnisse bleiben auf deinen Geräten.';

  @override
  String get donationsOfflineTitle => 'Sicher ohne Internet';

  @override
  String get donationsOfflineText =>
      'Es läuft offline und sendet nichts über dich irgendwohin. Das Internet nutzt es nur, um eine neue Version und die Liste der Spender zu laden.';

  @override
  String get donationsFamilyTitle => 'Die ganze Familie spielt';

  @override
  String get donationsFamilyText =>
      'An einem Tisch oder jeder an seinem Gerät im WLAN zu Hause. Familiengeräte teilen Daten nur untereinander.';

  @override
  String get donationsKidsTitle => 'Auch für die Kleinsten';

  @override
  String get donationsKidsText =>
      'Roboter in drei Stufen, Regeln mit Bildern, große Knöpfe und ein Elternbereich.';

  @override
  String get donationsEveryoneTitle => 'Für alle';

  @override
  String get donationsEveryoneText =>
      'Funktioniert mit Screenreader, hat Zeichen für Farbenblinde und spricht zehn Sprachen.';

  @override
  String get donationsGrowingTitle => 'Neue Spiele kommen dazu';

  @override
  String get donationsGrowingText =>
      'Neun Spiele und weitere sind unterwegs – manche haben sich Kinder gewünscht.';

  @override
  String get donationsWhy =>
      'Ein Beitrag hilft, die Zeit für neue Spiele und die Google-Play-Gebühren zu bezahlen.';

  @override
  String get donationsSoon =>
      'Spenden geht, sobald das Spiel bei Google Play ist. Danke!';

  @override
  String get donationsThanks => 'Herzlichen Dank an unsere Spender:';

  @override
  String get donationsNobody => 'Noch niemand da. Bist du der Erste?';

  @override
  String get familyRename => 'Gerät umbenennen';

  @override
  String get familyOnline => 'Deskovky läuft';

  @override
  String get familyOffline => 'Nicht erreichbar';

  @override
  String familyPlaysNow(String name) {
    return '$name spielt gerade';
  }

  @override
  String get settingsShareApp => 'Auf anderes Gerät laden';

  @override
  String get shareAppTitle => 'Deskovky auf einem anderen Gerät';

  @override
  String get shareAppHint =>
      'Scanne den Code mit der Kamera des anderen Handys oder Tablets. Die Seite mit der neuesten Version öffnet sich: Lade die Datei deskovky-….apk herunter und öffne sie.';

  @override
  String get inviteToAllDevices => 'Die Einladung geht an alle Geräte im WLAN';

  @override
  String get parentsReportBug => 'Fehler melden';

  @override
  String get parentsReportBugHint =>
      'Öffnet ein Formular auf GitHub, in dem du den Fehler beschreibst. Meldungen sind öffentlich: Schreib keine Namen von Kindern oder andere persönliche Daten hinein.';

  @override
  String get bugReportNoBrowser =>
      'Der Browser konnte nicht geöffnet werden. Du kannst den Fehler hier melden:';
}
