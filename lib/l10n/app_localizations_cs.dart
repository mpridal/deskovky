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

  @override
  String get avatarEditorTitle => 'Můj avatar';

  @override
  String get avatarSave => 'Uložit';

  @override
  String get avatarRandom => 'Náhodně';

  @override
  String get back => 'Zpět';

  @override
  String get avatarTabFace => 'Obličej';

  @override
  String get avatarTabSkin => 'Pleť';

  @override
  String get avatarTabHair => 'Vlasy';

  @override
  String get avatarTabEyes => 'Oči';

  @override
  String get avatarTabMouth => 'Ústa';

  @override
  String get avatarTabBackground => 'Pozadí';

  @override
  String get avatarHairColor => 'Barva vlasů';

  @override
  String get faceOval => 'oválný';

  @override
  String get faceRound => 'kulatý';

  @override
  String get faceWide => 'široký';

  @override
  String get faceSquare => 'hranatý';

  @override
  String get hairShort => 'krátké';

  @override
  String get hairLong => 'dlouhé';

  @override
  String get hairCurly => 'kudrny';

  @override
  String get hairBun => 'drdol';

  @override
  String get hairSpiky => 'ježek';

  @override
  String get hairPigtails => 'culíky';

  @override
  String get hairBob => 'mikádo';

  @override
  String get hairBraids => 'copánky';

  @override
  String get hairCap => 'kšiltovka';

  @override
  String get hairBald => 'bez vlasů';

  @override
  String get eyesRound => 'kulaté';

  @override
  String get eyesHappy => 'veselé';

  @override
  String get eyesWink => 'mrkající';

  @override
  String get eyesSleepy => 'ospalé';

  @override
  String get eyesWide => 'vykulené';

  @override
  String get eyesLashes => 's řasami';

  @override
  String get mouthSmile => 'úsměv';

  @override
  String get mouthOpen => 'otevřená';

  @override
  String get mouthFlat => 'rovná';

  @override
  String get mouthGrin => 'úsměv se zuby';

  @override
  String get mouthTongue => 'jazyk';

  @override
  String get mouthSurprised => 'překvapená';

  @override
  String get hairColorBlack => 'černá';

  @override
  String get hairColorBrown => 'hnědá';

  @override
  String get hairColorChestnut => 'kaštanová';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platinová';

  @override
  String get hairColorRed => 'zrzavá';

  @override
  String get hairColorGrey => 'šedá';

  @override
  String get hairColorBlue => 'modrá';

  @override
  String skinTone(int n) {
    return 'Pleť $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Pozadí $n';
  }

  @override
  String get playersNew => 'Nový hráč';

  @override
  String get playersLimit => 'Na tomto zařízení může být nejvýš 8 hráčů.';

  @override
  String get playersEmpty => 'Zatím tu nikdo není. Vytvoř prvního hráče!';

  @override
  String playersNowPlaying(String name) {
    return 'Teď hraje $name';
  }

  @override
  String get playerActiveTag => 'Hraje teď';

  @override
  String playerEdit(String name) {
    return 'Upravit $name';
  }

  @override
  String playerDelete(String name) {
    return 'Smazat $name';
  }

  @override
  String get profileName => 'Jméno';

  @override
  String get profileErrorEmpty => 'Napiš jméno.';

  @override
  String get profileErrorTooLong => 'Nejvýš 16 znaků.';

  @override
  String get profileErrorTaken => 'Toto jméno už má jiný hráč.';

  @override
  String get profileErrorLimit => 'Na tomto zařízení může být nejvýš 8 hráčů.';

  @override
  String deleteTitle(String name) {
    return 'Smazat hráče $name?';
  }

  @override
  String get deleteMessage => 'Smažou se i jeho výsledky. Tohle nejde vrátit.';

  @override
  String get deleteConfirm => 'Smazat';

  @override
  String get discardTitle => 'Zahodit změny?';

  @override
  String get discardMessage => 'Úpravy avatara a jména se neuloží.';

  @override
  String get discardConfirm => 'Zahodit';

  @override
  String get cancel => 'Zrušit';

  @override
  String get homeHello => 'Ahoj,';

  @override
  String get homeSwitchPlayer => 'Přepnout hráče';

  @override
  String get homeCreatePlayer => 'Vytvořit hráče';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsLanguageSystem => 'Podle telefonu';

  @override
  String gamePlayersRange(int min, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$min–$max hráčů',
      few: '$min–$max hráči',
      one: '$min–$max hráč',
    );
    return '$_temp0';
  }

  @override
  String continueTitle(String game) {
    return 'Pokračovat: $game';
  }

  @override
  String get continueSaved => 'Rozehraná hra';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Hrát ▸';

  @override
  String get difficultyEasy => 'Lehká';

  @override
  String get difficultyMedium => 'Střední';

  @override
  String get difficultyHard => 'Těžká';

  @override
  String get setupPlayers => 'Počet hráčů';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lidí',
      few: '$count lidé',
      one: '$count člověk',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robotů',
      few: '$count roboti',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Obtížnost robotů';

  @override
  String get setupSpeed => 'Rychlost robotů';

  @override
  String get speedSlow => 'Pomalu';

  @override
  String get speedNormal => 'Normálně';

  @override
  String get speedFast => 'Rychle';

  @override
  String get seatHuman => 'Člověk';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Nastavení načteno z minulé hry';

  @override
  String get setupFilled => 'volné sloty doplněny roboty';

  @override
  String get setupNoFreeProfile => 'Všichni hráči už sedí u stolu.';

  @override
  String get seatMoveUp => 'Posunout výš';

  @override
  String get seatMoveDown => 'Posunout níž';

  @override
  String get setupPlay => 'Hrát!';

  @override
  String get setupNeedPlayer => 'Nejdřív vytvoř hráče.';

  @override
  String get robotName0 => 'Robík';

  @override
  String get robotName1 => 'Čipík';

  @override
  String get robotName2 => 'Šroubek';

  @override
  String get robotName3 => 'Bzučák';

  @override
  String get hudExit => 'Konec';

  @override
  String get hudPause => 'Pauza';

  @override
  String get hudMusic => 'Hudba';

  @override
  String get hudSfx => 'Efekty';

  @override
  String get exitTitle => 'Opravdu ukončit?';

  @override
  String get exitSaved => 'Rozehraná hra se uloží.';

  @override
  String get exitNotSaved => 'Rozehraná hra se neuloží.';

  @override
  String get exitConfirm => 'Ukončit';

  @override
  String get pauseResume => 'Pokračovat';

  @override
  String get pauseRestart => 'Začít znovu';

  @override
  String get pauseRules => 'Pravidla';

  @override
  String get close => 'Zavřít';

  @override
  String turnOf(String name) {
    return 'Na tahu: $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name přemýšlí…';
  }

  @override
  String get resumeFailed => 'Rozehranou hru nejde obnovit.';

  @override
  String resultWins(String name) {
    return '$name vyhrává!';
  }

  @override
  String get resultDraw => 'Remíza!';

  @override
  String get resultPlayAgain => 'Hrát znovu';

  @override
  String get resultChangeSettings => 'Změnit nastavení';

  @override
  String get resultHome => 'Domů';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot => 'Chybějící hráče nahradili roboti.';

  @override
  String get settingsSound => 'Zvuk';

  @override
  String get settingsMusic => 'Hudba';

  @override
  String get settingsMusicVolume => 'Hlasitost hudby';

  @override
  String get settingsSfx => 'Efekty';

  @override
  String get settingsSfxVolume => 'Hlasitost efektů';

  @override
  String get settingsVibration => 'Vibrace';

  @override
  String get settingsCredits => 'Autoři a licence';

  @override
  String get creditsSounds => 'Hudba a zvuky';

  @override
  String get creditsFonts => 'Písma';

  @override
  String get creditsLibraries => 'Licence knihoven';

  @override
  String creditsLicense(String license) {
    return 'Licence: $license';
  }

  @override
  String get badgeFirstWinTitle => 'První výhra';

  @override
  String get badgeFirstWinDescription => 'Vyhraj svou první hru.';

  @override
  String get badgeStreak5Title => 'Pět v řadě';

  @override
  String get badgeStreak5Description => 'Vyhraj 5 her za sebou.';

  @override
  String get badgeGames10Title => 'Desítka';

  @override
  String get badgeGames10Description => 'Odehraj 10 her.';

  @override
  String get badgeHardWinTitle => 'Přemožitel robotů';

  @override
  String get badgeHardWinDescription => 'Poraz roboty na Těžkou.';

  @override
  String get badgeAllGamesTitle => 'Průzkumník';

  @override
  String get badgeAllGamesDescription => 'Zahraj si každou hru.';

  @override
  String get resultNewBadges => 'Nové odznaky';

  @override
  String get leaderboardWeek => 'Týden';

  @override
  String get leaderboardMonth => 'Měsíc';

  @override
  String get leaderboardAllTime => 'Vše';

  @override
  String get leaderboardAllGames => 'Všechny hry';

  @override
  String get leaderboardAnyDifficulty => 'Každá obtížnost';

  @override
  String get leaderboardEmpty => 'Zatím tu nikdo není. Dohrajte hru!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výher',
      few: '$count výhry',
      one: '$count výhra',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played her',
      few: '$played hry',
      one: '$played hra',
    );
    return '$_temp0 · $rate %';
  }

  @override
  String playerStats(String name) {
    return 'Statistiky: $name';
  }

  @override
  String get statsPlayed => 'Odehráno';

  @override
  String get statsWins => 'Výhry';

  @override
  String get statsWinRate => 'Úspěšnost';

  @override
  String get statsBestStreak => 'Nejlepší série';

  @override
  String get statsCurrentStreak => 'Aktuální série';

  @override
  String get statsByGame => 'Podle her';

  @override
  String statsBestScore(int score) {
    return 'Nejlepší skóre: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Nejrychlejší výhra: $time';
  }

  @override
  String get statsBadges => 'Odznaky';

  @override
  String statsBadgeEarned(String date) {
    return 'Získáno $date';
  }

  @override
  String get statsNoGames => 'Zatím žádná dohraná hra.';

  @override
  String homeBestStars(int stars) {
    return 'Nejlepší hodnocení: $stars ze 3 hvězd';
  }

  @override
  String get resultPoints => 'Body';

  @override
  String get pointsWin => 'Výhra';

  @override
  String get pointsDraw => 'Remíza';

  @override
  String get pointsSecond => '2. místo';

  @override
  String get pointsParticipation => 'Účast';

  @override
  String pointsStars(int count) {
    return 'Hodnocení $count ★';
  }

  @override
  String pointsStreak(int count) {
    return 'Série $count výher';
  }

  @override
  String get pointsFirstToday => 'První hra dne';

  @override
  String get pointsRecord => 'Nový osobní rekord';

  @override
  String pointsBadge(String name) {
    return 'Odznak: $name';
  }

  @override
  String get pointsCapped => 'Dnes už hodně výher na Lehkou';

  @override
  String get pointsGift => 'Dárek od rodiče';

  @override
  String get pointsPurchase => 'Nákup';

  @override
  String pointsTotal(int points) {
    return 'Celkem +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Nová úroveň $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Body: $points';
  }

  @override
  String levelShort(int level) {
    return 'Úr. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Úroveň $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● do další úrovně';
  }

  @override
  String get levelMax => 'Nejvyšší úroveň!';

  @override
  String get statsBalance => 'Zůstatek';

  @override
  String get statsTotalEarned => 'Celkem získáno';

  @override
  String get statsPointsHistory => 'Historie bodů';

  @override
  String get settingsParents => 'Rodičovská zóna';

  @override
  String get parentsGateTitle => 'Jen pro rodiče';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Kolik je $a × $b?';
  }

  @override
  String get parentsGateWrong => 'To není správně.';

  @override
  String get parentsGateOpen => 'Otevřít';

  @override
  String get parentsGiftTitle => 'Darovat body';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Darovat $points ● hráči $name?';
  }

  @override
  String get parentsGiftAction => 'Darovat';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Darováno: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Je tu nová verze $version';
  }

  @override
  String get updateNow => 'Aktualizovat';

  @override
  String get updateLater => 'Později';

  @override
  String updateDownloading(int percent) {
    return 'Stahuji… $percent %';
  }

  @override
  String get updateMandatory =>
      'Tahle verze už je moc stará – aktualizuj prosím.';

  @override
  String get updateFailed => 'Stažení se nepovedlo. Zkus to později.';

  @override
  String get updatePermissionTitle => 'Ještě jedno povolení';

  @override
  String get updatePermissionText =>
      'Android se zeptá, jestli Deskovky smějí instalovat aplikace. Je to jen kvůli nové verzi Deskovek. Ať dospělý zapne přepínač a pak se vraťte sem.';

  @override
  String get updatePermissionOpen => 'Otevřít nastavení';

  @override
  String get settingsApp => 'Aplikace';

  @override
  String settingsVersion(String version) {
    return 'Verze $version';
  }

  @override
  String get settingsCheckNow => 'Zkontrolovat aktualizace teď';

  @override
  String get settingsAutoUpdate => 'Automaticky kontrolovat';

  @override
  String get updateUpToDate => 'Máš nejnovější verzi.';

  @override
  String get updateCheckFailed =>
      'Kontrola se nepovedla – je zařízení připojené k internetu?';

  @override
  String get itemCap => 'Kšiltovka';

  @override
  String get itemEarsHeadband => 'Čelenka s oušky';

  @override
  String get itemFlowerWreath => 'Věneček';

  @override
  String get itemTopHat => 'Cylindr';

  @override
  String get itemVikingHelmet => 'Vikinská helma';

  @override
  String get itemPirateBandana => 'Pirátský šátek';

  @override
  String get itemWizardHat => 'Čarodějnický klobouk';

  @override
  String get itemCrown => 'Korunka';

  @override
  String get itemHalo => 'Svatozář';

  @override
  String get itemGlasses => 'Brýle';

  @override
  String get itemMustache => 'Knírek';

  @override
  String get itemFacePaintStar => 'Malování hvězda';

  @override
  String get itemSunglasses => 'Sluneční brýle';

  @override
  String get itemHeroMask => 'Maska hrdiny';

  @override
  String get itemMonocle => 'Monokl';

  @override
  String get itemCarnivalMask => 'Karnevalová maska';

  @override
  String get itemLollipop => 'Lízátko';

  @override
  String get itemBalloon => 'Balónek';

  @override
  String get itemIceCream => 'Zmrzlina';

  @override
  String get itemPhone => 'Mobil';

  @override
  String get itemMicrophone => 'Mikrofon';

  @override
  String get itemMagicWand => 'Kouzelná hůlka';

  @override
  String get itemTrophy => 'Trofej';

  @override
  String get itemKitten => 'Kočka';

  @override
  String get itemChick => 'Kuřátko';

  @override
  String get itemPuppy => 'Pejsek';

  @override
  String get itemParrot => 'Papoušek';

  @override
  String get itemDragon => 'Dráček';

  @override
  String get itemWoodFrame => 'Dřevěný rámeček';

  @override
  String get itemGoldFrame => 'Zlatý rámeček';

  @override
  String get itemRainbowFrame => 'Duhový rámeček';

  @override
  String get itemFlameFrame => 'Plamenný rámeček';

  @override
  String get itemStarFrame => 'Hvězdný rámeček';

  @override
  String get itemSparkles => 'Třpytky';

  @override
  String get itemBubbles => 'Bublinky';

  @override
  String get itemSnow => 'Sněžení';

  @override
  String get pointsReset => 'Rodič vynuloval body';

  @override
  String get badgeWins50Title => 'Padesátka';

  @override
  String get badgeWins50Description => 'Vyhraj 50 her. Odměna: trofej do ruky.';

  @override
  String get badgeAllHardTitle => 'Mistr všech her';

  @override
  String get badgeAllHardDescription =>
      'Poraz roboty na Těžkou v každé hře. Odměna: hvězdný rámeček.';

  @override
  String get badgeCollectorTitle => 'Sběratel';

  @override
  String get badgeCollectorDescription => 'Kup si 10 vylepšení avatara.';

  @override
  String get shopTitle => 'Obchod';

  @override
  String shopTryOn(String name) {
    return 'Zkouška: $name';
  }

  @override
  String get shopAll => 'Vše';

  @override
  String get slotHead => 'Na hlavu';

  @override
  String get slotFace => 'Obličej';

  @override
  String get slotHand => 'Do ruky';

  @override
  String get slotPet => 'Mazlíček';

  @override
  String get slotFrame => 'Rámeček';

  @override
  String get slotEffect => 'Efekt';

  @override
  String shopBuy(int price) {
    return 'Koupit za $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Koupit $name za $price ●?';
  }

  @override
  String get shopBuyAction => 'Koupit';

  @override
  String shopMissing(int points) {
    return 'Chybí ti $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Úroveň $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Odznak: $name';
  }

  @override
  String get shopOwned => 'Máš';

  @override
  String get shopEquipped => 'Nasazeno';

  @override
  String get shopEquipNow => 'Nasadit hned?';

  @override
  String get shopEquip => 'Nasadit';

  @override
  String get shopUnequip => 'Sundat';

  @override
  String get shopNotNow => 'Teď ne';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Úroveň $level → $next · ještě $points bodů';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Úroveň $level';
  }

  @override
  String get wardrobeTitle => 'Šatník';

  @override
  String get wardrobeEmpty => 'Zatím tu nic není. Vylepšení koupíš v obchodě.';

  @override
  String get wardrobeToShop => 'Do obchodu';

  @override
  String wardrobeColour(String name) {
    return 'Barva: $name';
  }

  @override
  String get colourGold => 'zlatá';

  @override
  String get colourSilver => 'stříbrná';

  @override
  String get colourRed => 'červená';

  @override
  String get colourBlue => 'modrá';

  @override
  String get colourGreen => 'zelená';

  @override
  String get colourYellow => 'žlutá';

  @override
  String get colourBrown => 'hnědá';

  @override
  String get parentsResetTitle => 'Vynulovat body a vylepšení';

  @override
  String get parentsReset => 'Vynulovat';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name přijde o $points ● a o všechna koupená vylepšení. Úroveň a odznaky zůstanou.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: body a vylepšení vynulovány.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, teď si můžeš koupit: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Nákup: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Nový odznak: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Odměna +$points ●.';
  }

  @override
  String get shopHooray => 'Hurá!';

  @override
  String get shopNotEnough => 'Na to teď nemáš dost bodů.';

  @override
  String get shopFailed => 'To teď nejde. Zkus to znovu.';

  @override
  String get updatePreparing => 'Připravuji aktualizaci…';

  @override
  String get setupDifficultySolo => 'Obtížnost';

  @override
  String get whereLabel => 'Kde se hraje';

  @override
  String get whereHere => 'Na tomto zařízení';

  @override
  String get whereWifi => 'Každý na svém (Wi-Fi)';

  @override
  String get trialTag => 'Zkušební';

  @override
  String get noWifi =>
      'Nejsi ve Wi-Fi. Připoj zařízení ke stejné Wi-Fi jako ostatní.';

  @override
  String get setupOpenRoom => 'Otevřít místnost';

  @override
  String get roomTitle => 'Místnost';

  @override
  String get roomCode => 'Kód místnosti';

  @override
  String get roomJoinHint =>
      'Ostatní zvolí Připojit se ke hře, nebo naskenují QR kód.';

  @override
  String get slotOpen => 'Volné místo';

  @override
  String get slotHere => '🏠 Tady';

  @override
  String get slotOwnDevice => '📱 Na svém';

  @override
  String get slotReady => 'Připraven';

  @override
  String get slotWaiting => 'Čeká se';

  @override
  String get slotDisconnected => 'Odpojen';

  @override
  String get slotMakeRobot => 'Přidat robota';

  @override
  String get slotAddLocal => 'Přidat hráče z tohoto zařízení';

  @override
  String get slotLeaveOpen => 'Nechat volné';

  @override
  String get roomRemove => 'Odebrat hráče';

  @override
  String get roomStart => 'Spustit hru';

  @override
  String get roomWaitReady => 'Čeká se, až budou všichni připraveni.';

  @override
  String get roomNoServer => 'Místnost se nepodařilo otevřít.';

  @override
  String get homeJoin => 'Připojit se ke hře';

  @override
  String get joinWho => 'Kdo hraje na tomto zařízení';

  @override
  String get joinRooms => 'Místnosti v síti';

  @override
  String get joinSearching => 'Hledám místnosti…';

  @override
  String get joinByCode => 'Kód místnosti (4 číslice)';

  @override
  String get joinCodeNotFound => 'Místnost s tímto kódem jsem v síti nenašel.';

  @override
  String get joinAdvanced => 'Pokročilé';

  @override
  String get joinAddress => 'Adresa (IP:port)';

  @override
  String get joinConnect => 'Připojit';

  @override
  String get joinFailed => 'Nepodařilo se připojit.';

  @override
  String get joinPickSomeone => 'Vyber aspoň jednoho hráče.';

  @override
  String get byeVersion =>
      'Hostitel má jinou verzi aplikace. Aktualizujte všichni na stejnou.';

  @override
  String get byeCode => 'Špatný kód místnosti.';

  @override
  String get byeFull => 'Místnost je plná.';

  @override
  String get byeStarted => 'Hra už začala.';

  @override
  String get byeKicked => 'Hostitel tě odebral z místnosti.';

  @override
  String get byeLost => 'Spojení s hostitelem se přerušilo.';

  @override
  String get lobbyReady => 'Jsem připraven';

  @override
  String get lobbyNotReady => 'Ještě ne';

  @override
  String get lobbySettings => 'Nastavení hry (vybírá hostitel)';

  @override
  String get lobbyWaitStart => 'Čeká se, až hostitel spustí hru.';

  @override
  String get leaveRoom => 'Odejít z místnosti';

  @override
  String joinFree(int count) {
    return 'Volná místa: $count';
  }
}
