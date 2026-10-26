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
  String get sampleTitle => 'Hádej číslo';

  @override
  String get sampleDescription => 'Kdo dřív uhodne tajné číslo?';

  @override
  String get sampleRules =>
      'Hra skryje číslo. Hráči se střídají v tipování. Po každém tipu se dozvíte, jestli je tajné číslo větší, nebo menší. Kdo ho trefí, vyhrává!';

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
  String get sampleOptionRange => 'Rozsah čísel';

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
  String get sampleHigher => 'Víc!';

  @override
  String get sampleLower => 'Míň!';

  @override
  String sampleTurnHint(String name, int low, int high) {
    return '$name, tipni číslo od $low do $high';
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
  String get sampleBadgeBullseyeTitle => 'Trefa!';

  @override
  String get sampleBadgeBullseyeDescription =>
      'Uhádni číslo hned prvním tipem.';

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
}
