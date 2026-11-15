// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Hry';

  @override
  String get navPlayers => 'Hráči';

  @override
  String get navLeaderboards => 'Rebríčky';

  @override
  String get navSettings => 'Voľby';

  @override
  String get comingSoon => 'Čoskoro';

  @override
  String get panelPlayersOnDevice => 'Hráči v zariadení';

  @override
  String get panelLeaderboardWeek => 'Rebríček tento týždeň';

  @override
  String get panelLastReward => 'Posledná odmena';

  @override
  String get screenEmpty => 'Zatiaľ tu nič nie je.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hráčov',
      few: '$count hráči',
      one: '$count hráč',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Môj avatar';

  @override
  String get avatarSave => 'Uložiť';

  @override
  String get avatarRandom => 'Náhodne';

  @override
  String get back => 'Späť';

  @override
  String get avatarTabFace => 'Tvár';

  @override
  String get avatarTabSkin => 'Pleť';

  @override
  String get avatarTabHair => 'Vlasy';

  @override
  String get avatarTabEyes => 'Oči';

  @override
  String get avatarTabMouth => 'Ústa';

  @override
  String get avatarTabBackground => 'Pozadie';

  @override
  String get avatarHairColor => 'Farba vlasov';

  @override
  String get faceOval => 'oválna';

  @override
  String get faceRound => 'okrúhla';

  @override
  String get faceWide => 'široká';

  @override
  String get faceSquare => 'hranatá';

  @override
  String get hairShort => 'krátke';

  @override
  String get hairLong => 'dlhé';

  @override
  String get hairCurly => 'kučery';

  @override
  String get hairBun => 'drdol';

  @override
  String get hairSpiky => 'ježko';

  @override
  String get hairPigtails => 'chvostíky';

  @override
  String get hairBob => 'mikádo';

  @override
  String get hairBraids => 'vrkôčiky';

  @override
  String get hairCap => 'šiltovka';

  @override
  String get hairBald => 'bez vlasov';

  @override
  String get eyesRound => 'okrúhle';

  @override
  String get eyesHappy => 'veselé';

  @override
  String get eyesWink => 'žmurkajúce';

  @override
  String get eyesSleepy => 'ospalé';

  @override
  String get eyesWide => 'vyvalené';

  @override
  String get eyesLashes => 's mihalnicami';

  @override
  String get mouthSmile => 'úsmev';

  @override
  String get mouthOpen => 'otvorené';

  @override
  String get mouthFlat => 'rovné';

  @override
  String get mouthGrin => 'úsmev so zubami';

  @override
  String get mouthTongue => 'jazyk';

  @override
  String get mouthSurprised => 'prekvapené';

  @override
  String get hairColorBlack => 'čierna';

  @override
  String get hairColorBrown => 'hnedá';

  @override
  String get hairColorChestnut => 'gaštanová';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platinová';

  @override
  String get hairColorRed => 'ryšavá';

  @override
  String get hairColorGrey => 'sivá';

  @override
  String get hairColorBlue => 'modrá';

  @override
  String skinTone(int n) {
    return 'Pleť $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Pozadie $n';
  }

  @override
  String get playersNew => 'Nový hráč';

  @override
  String get playersLimit => 'V tomto zariadení môže byť najviac 8 hráčov.';

  @override
  String get playersEmpty => 'Zatiaľ tu nikto nie je. Vytvor prvého hráča!';

  @override
  String playersNowPlaying(String name) {
    return 'Teraz hrá $name';
  }

  @override
  String get playerActiveTag => 'Hrá teraz';

  @override
  String playerEdit(String name) {
    return 'Upraviť $name';
  }

  @override
  String playerDelete(String name) {
    return 'Zmazať $name';
  }

  @override
  String get profileName => 'Meno';

  @override
  String get profileErrorEmpty => 'Napíš meno.';

  @override
  String get profileErrorTooLong => 'Najviac 16 znakov.';

  @override
  String get profileErrorTaken => 'Toto meno už má iný hráč.';

  @override
  String get profileErrorLimit =>
      'V tomto zariadení môže byť najviac 8 hráčov.';

  @override
  String deleteTitle(String name) {
    return 'Zmazať hráča $name?';
  }

  @override
  String get deleteMessage => 'Zmažú sa aj jeho výsledky. Toto sa nedá vrátiť.';

  @override
  String get deleteConfirm => 'Zmazať';

  @override
  String get discardTitle => 'Zahodiť zmeny?';

  @override
  String get discardMessage => 'Úpravy avatara a mena sa neuložia.';

  @override
  String get discardConfirm => 'Zahodiť';

  @override
  String get cancel => 'Zrušiť';

  @override
  String get homeHello => 'Ahoj,';

  @override
  String get homeSwitchPlayer => 'Prepnúť hráča';

  @override
  String get homeCreatePlayer => 'Vytvoriť hráča';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsLanguageSystem => 'Podľa telefónu';

  @override
  String gamePlayersRange(int min, int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '$min–$max hráčov',
      few: '$min–$max hráči',
      one: '$min–$max hráč',
    );
    return '$_temp0';
  }

  @override
  String continueTitle(String game) {
    return 'Pokračovať: $game';
  }

  @override
  String get continueSaved => 'Rozohraná hra';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Hrať ▸';

  @override
  String get difficultyEasy => 'Ľahká';

  @override
  String get difficultyMedium => 'Stredná';

  @override
  String get difficultyHard => 'Ťažká';

  @override
  String get setupPlayers => 'Počet hráčov';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ľudí',
      few: '$count ľudia',
      one: '$count človek',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robotov',
      few: '$count roboti',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Obťažnosť robotov';

  @override
  String get setupSpeed => 'Rýchlosť robotov';

  @override
  String get speedSlow => 'Pomaly';

  @override
  String get speedNormal => 'Normálne';

  @override
  String get speedFast => 'Rýchlo';

  @override
  String get seatHuman => 'Človek';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Nastavenie načítané z minulej hry';

  @override
  String get setupFilled => 'voľné miesta doplnili roboti';

  @override
  String get setupNoFreeProfile => 'Všetci hráči už sedia pri stole.';

  @override
  String get seatMoveUp => 'Posunúť vyššie';

  @override
  String get seatMoveDown => 'Posunúť nižšie';

  @override
  String get setupPlay => 'Hrať!';

  @override
  String get setupNeedPlayer => 'Najprv vytvor hráča.';

  @override
  String get robotName0 => 'Robík';

  @override
  String get robotName1 => 'Čipík';

  @override
  String get robotName2 => 'Skrutka';

  @override
  String get robotName3 => 'Bzučo';

  @override
  String get hudExit => 'Koniec';

  @override
  String get hudPause => 'Pauza';

  @override
  String get hudMusic => 'Hudba';

  @override
  String get hudSfx => 'Efekty';

  @override
  String get exitTitle => 'Naozaj ukončiť?';

  @override
  String get exitSaved => 'Rozohraná hra sa uloží.';

  @override
  String get exitNotSaved => 'Rozohraná hra sa neuloží.';

  @override
  String get exitConfirm => 'Ukončiť';

  @override
  String get pauseResume => 'Pokračovať';

  @override
  String get pauseRestart => 'Začať znova';

  @override
  String get pauseRules => 'Pravidlá';

  @override
  String get close => 'Zavrieť';

  @override
  String turnOf(String name) {
    return 'Na ťahu: $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name premýšľa…';
  }

  @override
  String get resumeFailed => 'Rozohranú hru sa nedá obnoviť.';

  @override
  String resultWins(String name) {
    return '$name vyhráva!';
  }

  @override
  String get resultDraw => 'Remíza!';

  @override
  String get resultPlayAgain => 'Hrať znova';

  @override
  String get resultChangeSettings => 'Zmeniť nastavenie';

  @override
  String get resultHome => 'Domov';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot => 'Chýbajúcich hráčov nahradili roboti.';

  @override
  String get settingsSound => 'Zvuk';

  @override
  String get settingsMusic => 'Hudba';

  @override
  String get settingsMusicVolume => 'Hlasitosť hudby';

  @override
  String get settingsSfx => 'Efekty';

  @override
  String get settingsSfxVolume => 'Hlasitosť efektov';

  @override
  String get settingsVibration => 'Vibrácie';

  @override
  String get settingsCredits => 'Autori a licencie';

  @override
  String get creditsSounds => 'Hudba a zvuky';

  @override
  String get creditsFonts => 'Písma';

  @override
  String get creditsLibraries => 'Licencie knižníc';

  @override
  String creditsLicense(String license) {
    return 'Licencia: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Prvá výhra';

  @override
  String get badgeFirstWinDescription => 'Vyhraj svoju prvú hru.';

  @override
  String get badgeStreak5Title => 'Päť za sebou';

  @override
  String get badgeStreak5Description => 'Vyhraj 5 hier za sebou.';

  @override
  String get badgeGames10Title => 'Desiatka';

  @override
  String get badgeGames10Description => 'Odohraj 10 hier.';

  @override
  String get badgeHardWinTitle => 'Premožiteľ robotov';

  @override
  String get badgeHardWinDescription => 'Poraz robotov na Ťažkú.';

  @override
  String get badgeAllGamesTitle => 'Prieskumník';

  @override
  String get badgeAllGamesDescription => 'Zahraj si každú hru.';

  @override
  String get resultNewBadges => 'Nové odznaky';

  @override
  String get leaderboardWeek => 'Týždeň';

  @override
  String get leaderboardMonth => 'Mesiac';

  @override
  String get leaderboardAllTime => 'Všetko';

  @override
  String get leaderboardAllGames => 'Všetky hry';

  @override
  String get leaderboardAnyDifficulty => 'Každá obťažnosť';

  @override
  String get leaderboardEmpty => 'Zatiaľ tu nikto nie je. Dohrajte hru!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výhier',
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
      other: '$played hier',
      few: '$played hry',
      one: '$played hra',
    );
    return '$_temp0 · $rate %';
  }

  @override
  String playerStats(String name) {
    return 'Štatistiky: $name';
  }

  @override
  String get statsPlayed => 'Odohrané';

  @override
  String get statsWins => 'Výhry';

  @override
  String get statsWinRate => 'Úspešnosť';

  @override
  String get statsBestStreak => 'Najlepšia séria';

  @override
  String get statsCurrentStreak => 'Aktuálna séria';

  @override
  String get statsByGame => 'Podľa hier';

  @override
  String statsBestScore(int score) {
    return 'Najlepšie skóre: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Najrýchlejšia výhra: $time';
  }

  @override
  String get statsBadges => 'Odznaky';

  @override
  String statsBadgeEarned(String date) {
    return 'Získané $date';
  }

  @override
  String get statsNoGames => 'Zatiaľ žiadna dohraná hra.';

  @override
  String homeBestStars(int stars) {
    return 'Najlepšie hodnotenie: $stars z 3 hviezd';
  }

  @override
  String get resultPoints => 'Body';

  @override
  String get pointsWin => 'Výhra';

  @override
  String get pointsDraw => 'Remíza';

  @override
  String get pointsSecond => '2. miesto';

  @override
  String get pointsParticipation => 'Účasť';

  @override
  String pointsStars(int count) {
    return 'Hodnotenie $count ★';
  }

  @override
  String pointsStreak(int count) {
    return 'Séria $count výhier';
  }

  @override
  String get pointsFirstToday => 'Prvá hra dňa';

  @override
  String get pointsRecord => 'Nový osobný rekord';

  @override
  String pointsBadge(String name) {
    return 'Odznak: $name';
  }

  @override
  String get pointsCapped => 'Dnes už veľa výhier na Ľahkú';

  @override
  String get pointsGift => 'Darček od rodiča';

  @override
  String get pointsPurchase => 'Nákup';

  @override
  String pointsTotal(int points) {
    return 'Spolu +$points ●';
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
    return '$current / $needed ● do ďalšej úrovne';
  }

  @override
  String get levelMax => 'Najvyššia úroveň!';

  @override
  String get statsBalance => 'Zostatok';

  @override
  String get statsTotalEarned => 'Spolu získané';

  @override
  String get statsPointsHistory => 'História bodov';

  @override
  String get settingsParents => 'Rodičovská zóna';

  @override
  String get parentsGateTitle => 'Len pre rodičov';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Koľko je $a × $b?';
  }

  @override
  String get parentsGateWrong => 'To nie je správne.';

  @override
  String get parentsGateLocked =>
      'Príliš veľa pokusov. Skús to znova o minútu.';

  @override
  String get parentsGateOpen => 'Otvoriť';

  @override
  String get parentsGiftTitle => 'Darovať body';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Darovať $points ● hráčovi $name?';
  }

  @override
  String get parentsGiftAction => 'Darovať';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Darované: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Je tu nová verzia $version';
  }

  @override
  String get updateNow => 'Aktualizovať';

  @override
  String get updateLater => 'Neskôr';

  @override
  String updateDownloading(int percent) {
    return 'Sťahujem… $percent %';
  }

  @override
  String get updateMandatory =>
      'Táto verzia je už príliš stará – prosím, aktualizuj.';

  @override
  String get updateFailed => 'Stiahnutie sa nepodarilo. Skús to neskôr.';

  @override
  String get updatePermissionTitle => 'Ešte jedno povolenie';

  @override
  String get updatePermissionText =>
      'Android sa opýta, či Deskovky môžu inštalovať aplikácie. Je to len kvôli novej verzii Deskoviek. Nech dospelý zapne prepínač a potom sa vráťte sem.';

  @override
  String get updatePermissionOpen => 'Otvoriť nastavenia';

  @override
  String get settingsApp => 'Aplikácia';

  @override
  String settingsVersion(String version) {
    return 'Verzia $version';
  }

  @override
  String get settingsCheckNow => 'Skontrolovať aktualizácie teraz';

  @override
  String get settingsAutoUpdate => 'Automaticky kontrolovať';

  @override
  String get updateUpToDate => 'Máš najnovšiu verziu.';

  @override
  String get updateCheckFailed =>
      'Kontrola sa nepodarila – je zariadenie pripojené na internet?';

  @override
  String get itemCap => 'Šiltovka';

  @override
  String get itemEarsHeadband => 'Čelenka s uškami';

  @override
  String get itemFlowerWreath => 'Venček';

  @override
  String get itemTopHat => 'Cylinder';

  @override
  String get itemVikingHelmet => 'Vikingská prilba';

  @override
  String get itemPirateBandana => 'Pirátska šatka';

  @override
  String get itemWizardHat => 'Čarodejnícky klobúk';

  @override
  String get itemCrown => 'Korunka';

  @override
  String get itemHalo => 'Svätožiara';

  @override
  String get itemGlasses => 'Okuliare';

  @override
  String get itemMustache => 'Fúziky';

  @override
  String get itemFacePaintStar => 'Maľovaná hviezda';

  @override
  String get itemSunglasses => 'Slnečné okuliare';

  @override
  String get itemHeroMask => 'Maska hrdinu';

  @override
  String get itemMonocle => 'Monokel';

  @override
  String get itemCarnivalMask => 'Karnevalová maska';

  @override
  String get itemLollipop => 'Lízanka';

  @override
  String get itemBalloon => 'Balónik';

  @override
  String get itemIceCream => 'Zmrzlina';

  @override
  String get itemPhone => 'Mobil';

  @override
  String get itemMicrophone => 'Mikrofón';

  @override
  String get itemMagicWand => 'Čarovný prútik';

  @override
  String get itemTrophy => 'Trofej';

  @override
  String get itemKitten => 'Mačka';

  @override
  String get itemChick => 'Kuriatko';

  @override
  String get itemPuppy => 'Psík';

  @override
  String get itemParrot => 'Papagáj';

  @override
  String get itemDragon => 'Dráčik';

  @override
  String get itemWoodFrame => 'Drevený rámik';

  @override
  String get itemGoldFrame => 'Zlatý rámik';

  @override
  String get itemRainbowFrame => 'Dúhový rámik';

  @override
  String get itemFlameFrame => 'Ohnivý rámik';

  @override
  String get itemStarFrame => 'Hviezdny rámik';

  @override
  String get itemSparkles => 'Trblietky';

  @override
  String get itemBubbles => 'Bublinky';

  @override
  String get itemSnow => 'Sneženie';

  @override
  String get pointsReset => 'Rodič vynuloval body';

  @override
  String get badgeWins50Title => 'Päťdesiatka';

  @override
  String get badgeWins50Description =>
      'Vyhraj 50 hier. Odmena: trofej do ruky.';

  @override
  String get badgeAllHardTitle => 'Majster všetkých hier';

  @override
  String get badgeAllHardDescription =>
      'Poraz robotov na Ťažkú v každej hre. Odmena: hviezdny rámik.';

  @override
  String get badgeCollectorTitle => 'Zberateľ';

  @override
  String get badgeCollectorDescription => 'Kúp si 10 vylepšení avatara.';

  @override
  String get shopTitle => 'Obchod';

  @override
  String shopTryOn(String name) {
    return 'Skúška: $name';
  }

  @override
  String get shopAll => 'Všetko';

  @override
  String get slotHead => 'Na hlavu';

  @override
  String get slotFace => 'Tvár';

  @override
  String get slotHand => 'Do ruky';

  @override
  String get slotPet => 'Miláčik';

  @override
  String get slotFrame => 'Rámik';

  @override
  String get slotEffect => 'Efekt';

  @override
  String shopBuy(int price) {
    return 'Kúpiť za $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Kúpiť $name za $price ●?';
  }

  @override
  String get shopBuyAction => 'Kúpiť';

  @override
  String shopMissing(int points) {
    return 'Chýba ti $points ●';
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
  String get shopEquipped => 'Nasadené';

  @override
  String get shopEquipNow => 'Nasadiť hneď?';

  @override
  String get shopEquip => 'Nasadiť';

  @override
  String get shopUnequip => 'Zložiť';

  @override
  String get shopNotNow => 'Teraz nie';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Úroveň $level → $next · ešte $points bodov';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Úroveň $level';
  }

  @override
  String get wardrobeTitle => 'Šatník';

  @override
  String get wardrobeEmpty =>
      'Zatiaľ tu nič nie je. Vylepšenia kúpiš v obchode.';

  @override
  String get wardrobeToShop => 'Do obchodu';

  @override
  String wardrobeColour(String name) {
    return 'Farba: $name';
  }

  @override
  String get colourGold => 'zlatá';

  @override
  String get colourSilver => 'strieborná';

  @override
  String get colourRed => 'červená';

  @override
  String get colourBlue => 'modrá';

  @override
  String get colourGreen => 'zelená';

  @override
  String get colourYellow => 'žltá';

  @override
  String get colourBrown => 'hnedá';

  @override
  String get parentsResetTitle => 'Vynulovať body a vylepšenia';

  @override
  String get parentsReset => 'Vynulovať';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name príde o $points ● a o všetky kúpené vylepšenia. Úroveň a odznaky zostanú.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: body a vylepšenia vynulované.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, teraz si môžeš kúpiť: $item!';
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
    return '$description Odmena +$points ●.';
  }

  @override
  String get shopHooray => 'Hurá!';

  @override
  String get shopNotEnough => 'Na to teraz nemáš dosť bodov.';

  @override
  String get shopFailed => 'Teraz to nejde. Skús to znova.';

  @override
  String get updatePreparing => 'Pripravujem aktualizáciu…';

  @override
  String get setupDifficultySolo => 'Obťažnosť';

  @override
  String get whereLabel => 'Kde sa hrá';

  @override
  String get whereHere => 'Na tomto zariadení';

  @override
  String get whereWifi => 'Každý na svojom (Wi-Fi)';

  @override
  String get trialTag => 'Skúšobná';

  @override
  String get noWifi =>
      'Nie si na Wi-Fi. Pripoj zariadenie k rovnakej Wi-Fi ako ostatní.';

  @override
  String get setupOpenRoom => 'Otvoriť miestnosť';

  @override
  String get roomTitle => 'Miestnosť';

  @override
  String get roomCode => 'Kód miestnosti';

  @override
  String get roomJoinHint =>
      'Ostatní naskenujú QR kód fotoaparátom alebo zvolia Pripojiť sa k hre.';

  @override
  String get slotOpen => 'Voľné miesto';

  @override
  String get slotHere => '🏠 Tu';

  @override
  String get slotOwnDevice => '📱 Na svojom';

  @override
  String get slotReady => 'Pripravený';

  @override
  String get slotWaiting => 'Čaká sa';

  @override
  String get slotDisconnected => 'Odpojený';

  @override
  String get slotMakeRobot => 'Pridať robota';

  @override
  String get slotAddLocal => 'Pridať hráča z tohto zariadenia';

  @override
  String get slotLeaveOpen => 'Nechať voľné';

  @override
  String get roomRemove => 'Odobrať hráča';

  @override
  String get roomStart => 'Spustiť hru';

  @override
  String get roomWaitReady => 'Čaká sa, kým budú všetci pripravení.';

  @override
  String get roomNoServer => 'Miestnosť sa nepodarilo otvoriť.';

  @override
  String get homeJoin => 'Pripojiť sa k hre';

  @override
  String get joinWho => 'Kto hrá na tomto zariadení';

  @override
  String get joinRooms => 'Miestnosti v sieti';

  @override
  String get joinSearching => 'Hľadám miestnosti…';

  @override
  String get joinByCode => 'Kód miestnosti (4 číslice)';

  @override
  String get joinCodeNotFound =>
      'Miestnosť s týmto kódom som v sieti nenašiel.';

  @override
  String get joinAdvanced => 'Pokročilé';

  @override
  String get joinAddress => 'Adresa (IP:port)';

  @override
  String get joinConnect => 'Pripojiť';

  @override
  String get joinFailed => 'Nepodarilo sa pripojiť.';

  @override
  String get joinPickSomeone => 'Vyber aspoň jedného hráča.';

  @override
  String get joinScanQr => 'Načítať QR';

  @override
  String get joinQrRoom => 'Miestnosť z QR kódu';

  @override
  String get joinOtherRoom => 'Vybrať inú miestnosť';

  @override
  String get qrNotRoom =>
      'Toto nie je QR kód Deskoviek. Naskenuj kód z obrazovky Miestnosť.';

  @override
  String get qrCameraDenied =>
      'Bez fotoaparátu QR kód nenačítam. Povoľ ho v nastaveniach telefónu alebo napíš kód miestnosti.';

  @override
  String get qrScanTitle => 'Namier na QR kód';

  @override
  String get byeVersion =>
      'Hostiteľ má inú verziu aplikácie. Aktualizujte všetci na rovnakú.';

  @override
  String get byeCode => 'Zlý kód miestnosti.';

  @override
  String get byeFull => 'Miestnosť je plná.';

  @override
  String get byeStarted => 'Hra už začala.';

  @override
  String get byeKicked => 'Hostiteľ ťa odobral z miestnosti.';

  @override
  String get byeLost => 'Spojenie s hostiteľom sa prerušilo.';

  @override
  String get lobbyReady => 'Som pripravený';

  @override
  String get lobbyNotReady => 'Ešte nie';

  @override
  String get lobbySettings => 'Nastavenie hry (vyberá hostiteľ)';

  @override
  String get lobbyWaitStart => 'Čaká sa, kým hostiteľ spustí hru.';

  @override
  String get leaveRoom => 'Odísť z miestnosti';

  @override
  String joinFree(int count) {
    return 'Voľné miesta: $count';
  }

  @override
  String get netDecideTitle => 'Hráč sa nevrátil';

  @override
  String get netWaitMore => 'Čakať ďalej';

  @override
  String get netReplaceRobot => 'Nahradiť robotom';

  @override
  String get netEndGame => 'Ukončiť hru';

  @override
  String get netLeave => 'Odísť z hry';

  @override
  String get netRematch => 'Odveta';

  @override
  String get netWaitHost => 'Čaká sa na hostiteľa…';

  @override
  String get byeEnded => 'Hostiteľ hru ukončil.';

  @override
  String netYourTurn(String name) {
    return '$name, si na ťahu!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Na ťahu: $name (na svojom zariadení)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: odpojené – čakám ($time)';
  }

  @override
  String get netReconnect => 'Pripojiť znova';

  @override
  String resultNotThisTime(String name) {
    return '$name, tentoraz to nevyšlo';
  }

  @override
  String get joinLinkBusy =>
      'Už hráš. Najprv odíď z rozohranej hry alebo miestnosti.';

  @override
  String get familyTitle => 'Rodina';

  @override
  String get familyIntro =>
      'Prepojte zariadenia rodiny: profily, body, odmeny a história hier budú na všetkých rovnaké. Stačí domáca Wi-Fi, internet netreba.';

  @override
  String get familyCreate => 'Založiť rodinu';

  @override
  String get familyJoin => 'Pripojiť sa k rodine';

  @override
  String get familyJoinOther => 'Pripojiť sa k inej rodine';

  @override
  String get familyJoinOtherWarning =>
      'Toto zariadenie už je v rodine. Pripojením k inej rodine opustí tú súčasnú; profily z tohto zariadenia sa ponúknu na spárovanie.';

  @override
  String get familyJoinOtherConfirm => 'Napriek tomu pripojiť';

  @override
  String get familyAddDevice => 'Pridať zariadenie';

  @override
  String get familyQrHint =>
      'Na novom zariadení otvor Nastavenia → Rodičovská zóna → Rodina → Pripojiť sa k rodine a naskenuj tento kód. Obe zariadenia musia byť na rovnakej Wi-Fi.';

  @override
  String get familyDevices => 'Zariadenia v rodine';

  @override
  String get familyThisDevice => 'toto zariadenie';

  @override
  String get familyNeverSynced => 'zatiaľ sa nesynchronizovalo';

  @override
  String get familyRemove => 'Odobrať z rodiny';

  @override
  String get familyRemoveMessage =>
      'Zariadenie prestane dostávať profily a body. Dáta, ktoré už na ňom sú, mu zostanú.';

  @override
  String get familyRemoved => 'odobrané';

  @override
  String get familyJoined => 'Hotovo – si v rodine!';

  @override
  String get familyJoinFailed =>
      'Pripojenie k rodine sa nepodarilo. Sú obe zariadenia na rovnakej Wi-Fi a je na druhom otvorená Rodina?';

  @override
  String get familyNotACode => 'Toto nie je rodinný kód.';

  @override
  String get familyUpdateApps =>
      'Niektoré zariadenie má inú verziu aplikácie. Aktualizujte aplikáciu na všetkých zariadeniach.';

  @override
  String get familyCodeInJoin =>
      'Toto je rodinný kód. Zariadenie pridáš v Nastavenia → Rodičovská zóna → Rodina.';

  @override
  String get familySynced => 'Synchronizované s rodinou';

  @override
  String get deviceTablet => 'Tablet';

  @override
  String get devicePhone => 'Telefón';

  @override
  String familyLastSync(String time) {
    return 'naposledy $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Odobrať $name z rodiny?';
  }

  @override
  String get pairTitle => 'Spárovať profily';

  @override
  String get pairQuestion => 'Je to tá istá osoba?';

  @override
  String get pairMerge => 'Áno, spojiť';

  @override
  String get pairKeep => 'Nie, sú to dvaja ľudia';

  @override
  String get pairLook => 'Vzhľad po spojení';

  @override
  String get pairManual => 'Spárovať ručne';

  @override
  String get pairFirst => 'Profil';

  @override
  String get pairSecond => 'patrí k';

  @override
  String get pairNone => 'Žiadne ďalšie dvojice.';

  @override
  String get refundTitle => 'Body sú späť';

  @override
  String get refundOk => 'Rozumiem';

  @override
  String familyPairs(int count) {
    return 'Možné dvojice ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Vrátili sme ti body za $item – na obe veci nebolo dosť bodov.';
  }

  @override
  String get inviteFamily => 'Pozvať z rodiny';

  @override
  String get inviteSent => 'Pozvánka odoslaná.';

  @override
  String get inviteNoDevice =>
      'V sieti som nenašiel žiadne rodinné zariadenie.';

  @override
  String get invitePlay => 'Hrať';

  @override
  String get inviteLater => 'Teraz nie';

  @override
  String inviteTitle(String host, String game) {
    return '$host ťa pozýva do hry $game – hrať?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Vrátené: $item – kúpené dvakrát';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Vrátené: $item – nebolo dosť bodov';
  }

  @override
  String get setupElsewhere => 'Na inom zariadení';

  @override
  String get setupBusyTag => 'Hrá inú hru';

  @override
  String get setupInvitePlay => 'Pozvať a hrať';

  @override
  String get slotInvited => 'Pozvaný, čaká sa';

  @override
  String inviteFailed(String name) {
    return 'Pozvánku pre $name sa nepodarilo doručiť.';
  }

  @override
  String get inviteNotHere => 'Nie je v sieti';

  @override
  String get navDonations => 'Dary';

  @override
  String get donationsTitle => 'Podporte Deskovky';

  @override
  String get donationsIntro =>
      'Deskovky vznikajú doma, pre rodiny s deťmi. Sú a zostanú zadarmo. Keď vám robia radosť, môžete dobrovoľne prispieť na ďalší vývoj.';

  @override
  String get donationsFreeTitle => 'Celá hra zadarmo';

  @override
  String get donationsFreeText =>
      'Žiadne platené úrovne, nič sa neodomyká za peniaze.';

  @override
  String get donationsNoAdsTitle => 'Žiadne reklamy';

  @override
  String get donationsNoAdsText =>
      'Nič deti neruší a nič ich neláka k nákupom.';

  @override
  String get donationsNoDataTitle => 'Žiadny zber dát';

  @override
  String get donationsNoDataText =>
      'Žiadne účty ani prihlasovanie. Profily a výsledky zostávajú vo vašich zariadeniach.';

  @override
  String get donationsOfflineTitle => 'Bezpečne bez internetu';

  @override
  String get donationsOfflineText =>
      'Hrá sa offline a hra o vás nič neposiela von. Internet použije len na stiahnutie novej verzie.';

  @override
  String get donationsFamilyTitle => 'Hrá celá rodina';

  @override
  String get donationsFamilyText =>
      'Pri jednom stole alebo každý na svojom cez domácu Wi-Fi. Zariadenia v rodine si dáta zdieľajú len medzi sebou.';

  @override
  String get donationsKidsTitle => 'Pre deti od malička';

  @override
  String get donationsKidsText =>
      'Roboti na tri obťažnosti, pravidlá s obrázkami, veľké tlačidlá a rodičovská zóna.';

  @override
  String get donationsEveryoneTitle => 'Pre každého';

  @override
  String get donationsEveryoneText =>
      'Funguje s čítačkou obrazovky, má značky pre farboslepých a hovorí desiatimi jazykmi.';

  @override
  String get donationsGrowingTitle => 'Stále nové hry';

  @override
  String get donationsGrowingText =>
      'Deväť hier a ďalšie pribúdajú – aj podľa želaní detí.';

  @override
  String get donationsWhy =>
      'Príspevok pomôže zaplatiť čas na vývoj nových hier a poplatky za Google Play.';

  @override
  String get donationsSoon =>
      'Prispievať bude možné, keď bude hra na Google Play. Ďakujeme!';

  @override
  String get familyRename => 'Premenovať zariadenie';

  @override
  String get familyOnline => 'Deskovky bežia';

  @override
  String get familyOffline => 'Nie je k dispozícii';

  @override
  String familyPlaysNow(String name) {
    return 'Teraz hrá $name';
  }

  @override
  String get settingsShareApp => 'Stiahnuť do iného zariadenia';

  @override
  String get shareAppTitle => 'Deskovky do ďalšieho zariadenia';

  @override
  String get shareAppHint =>
      'Naskenuj kód fotoaparátom druhého telefónu alebo tabletu. Otvorí sa stránka s najnovšou verziou: stiahni súbor deskovky-….apk a otvor ho.';

  @override
  String get inviteToAllDevices =>
      'Pozvánka príde na všetky zariadenia v sieti';

  @override
  String get parentsReportBug => 'Nahlásiť chybu';

  @override
  String get parentsReportBugHint =>
      'Otvorí krátky formulár (bez prihlasovania), kde chybu opíšeš. Nepíš doň mená detí ani iné osobné údaje.';

  @override
  String get bugReportNoBrowser =>
      'Prehliadač sa nepodarilo otvoriť. Chybu môžeš nahlásiť na adrese:';

  @override
  String get saveFailed => 'Hru sa nepodarilo uložiť.';
}
