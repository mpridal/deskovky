// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Gry';

  @override
  String get navPlayers => 'Gracze';

  @override
  String get navLeaderboards => 'Rankingi';

  @override
  String get navSettings => 'Opcje';

  @override
  String get comingSoon => 'Wkrótce';

  @override
  String get panelPlayersOnDevice => 'Gracze na urządzeniu';

  @override
  String get panelLeaderboardWeek => 'Ranking tego tygodnia';

  @override
  String get panelLastReward => 'Ostatnia nagroda';

  @override
  String get screenEmpty => 'Na razie nic tu nie ma.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gracza',
      many: '$count graczy',
      few: '$count gracze',
      one: '$count gracz',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Mój awatar';

  @override
  String get avatarSave => 'Zapisz';

  @override
  String get avatarRandom => 'Losowo';

  @override
  String get back => 'Wstecz';

  @override
  String get avatarTabFace => 'Twarz';

  @override
  String get avatarTabSkin => 'Skóra';

  @override
  String get avatarTabHair => 'Włosy';

  @override
  String get avatarTabEyes => 'Oczy';

  @override
  String get avatarTabMouth => 'Usta';

  @override
  String get avatarTabBackground => 'Tło';

  @override
  String get avatarHairColor => 'Kolor włosów';

  @override
  String get faceOval => 'owalna';

  @override
  String get faceRound => 'okrągła';

  @override
  String get faceWide => 'szeroka';

  @override
  String get faceSquare => 'kwadratowa';

  @override
  String get hairShort => 'krótkie';

  @override
  String get hairLong => 'długie';

  @override
  String get hairCurly => 'kręcone';

  @override
  String get hairBun => 'kok';

  @override
  String get hairSpiky => 'jeżyk';

  @override
  String get hairPigtails => 'kucyki';

  @override
  String get hairBob => 'bob';

  @override
  String get hairBraids => 'warkoczyki';

  @override
  String get hairCap => 'czapka z daszkiem';

  @override
  String get hairBald => 'bez włosów';

  @override
  String get eyesRound => 'okrągłe';

  @override
  String get eyesHappy => 'wesołe';

  @override
  String get eyesWink => 'mrugające';

  @override
  String get eyesSleepy => 'śpiące';

  @override
  String get eyesWide => 'szeroko otwarte';

  @override
  String get eyesLashes => 'z rzęsami';

  @override
  String get mouthSmile => 'uśmiech';

  @override
  String get mouthOpen => 'otwarte';

  @override
  String get mouthFlat => 'proste';

  @override
  String get mouthGrin => 'uśmiech z zębami';

  @override
  String get mouthTongue => 'język';

  @override
  String get mouthSurprised => 'zdziwione';

  @override
  String get hairColorBlack => 'czarne';

  @override
  String get hairColorBrown => 'brązowe';

  @override
  String get hairColorChestnut => 'kasztanowe';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platynowe';

  @override
  String get hairColorRed => 'rude';

  @override
  String get hairColorGrey => 'siwe';

  @override
  String get hairColorBlue => 'niebieskie';

  @override
  String skinTone(int n) {
    return 'Skóra $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Tło $n';
  }

  @override
  String get playersNew => 'Nowy gracz';

  @override
  String get playersLimit => 'Na tym urządzeniu może być najwyżej 8 graczy.';

  @override
  String get playersEmpty =>
      'Na razie nikogo tu nie ma. Stwórz pierwszego gracza!';

  @override
  String playersNowPlaying(String name) {
    return 'Teraz gra $name';
  }

  @override
  String get playerActiveTag => 'Teraz gra';

  @override
  String playerEdit(String name) {
    return 'Edytuj: $name';
  }

  @override
  String playerDelete(String name) {
    return 'Usuń: $name';
  }

  @override
  String get profileName => 'Imię';

  @override
  String get profileErrorEmpty => 'Wpisz imię.';

  @override
  String get profileErrorTooLong => 'Najwyżej 16 znaków.';

  @override
  String get profileErrorTaken => 'Inny gracz ma już to imię.';

  @override
  String get profileErrorLimit =>
      'Na tym urządzeniu może być najwyżej 8 graczy.';

  @override
  String deleteTitle(String name) {
    return 'Usunąć gracza $name?';
  }

  @override
  String get deleteMessage =>
      'Jego wyniki też zostaną usunięte. Tego nie da się cofnąć.';

  @override
  String get deleteConfirm => 'Usuń';

  @override
  String get discardTitle => 'Odrzucić zmiany?';

  @override
  String get discardMessage => 'Zmiany awatara i imienia nie zostaną zapisane.';

  @override
  String get discardConfirm => 'Odrzuć';

  @override
  String get cancel => 'Anuluj';

  @override
  String get homeHello => 'Cześć,';

  @override
  String get homeSwitchPlayer => 'Zmień gracza';

  @override
  String get homeCreatePlayer => 'Stwórz gracza';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Jak w telefonie';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max graczy';
  }

  @override
  String continueTitle(String game) {
    return 'Kontynuuj: $game';
  }

  @override
  String get continueSaved => 'Rozpoczęta gra';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Graj ▸';

  @override
  String get difficultyEasy => 'Łatwy';

  @override
  String get difficultyMedium => 'Średni';

  @override
  String get difficultyHard => 'Trudny';

  @override
  String get setupPlayers => 'Liczba graczy';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osoby',
      many: '$count osób',
      few: '$count osoby',
      one: '$count osoba',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count robota',
      many: '$count robotów',
      few: '$count roboty',
      one: '$count robot',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Poziom robotów';

  @override
  String get setupSpeed => 'Szybkość robotów';

  @override
  String get speedSlow => 'Wolno';

  @override
  String get speedNormal => 'Normalnie';

  @override
  String get speedFast => 'Szybko';

  @override
  String get seatHuman => 'Człowiek';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Ustawienia wczytane z ostatniej gry';

  @override
  String get setupFilled => 'wolne miejsca zajęły roboty';

  @override
  String get setupNoFreeProfile => 'Wszyscy gracze już siedzą przy stole.';

  @override
  String get seatMoveUp => 'Przesuń wyżej';

  @override
  String get seatMoveDown => 'Przesuń niżej';

  @override
  String get setupPlay => 'Graj!';

  @override
  String get setupNeedPlayer => 'Najpierw stwórz gracza.';

  @override
  String get robotName0 => 'Robcio';

  @override
  String get robotName1 => 'Czipek';

  @override
  String get robotName2 => 'Śrubek';

  @override
  String get robotName3 => 'Bzyczek';

  @override
  String get hudExit => 'Wyjdź';

  @override
  String get hudPause => 'Pauza';

  @override
  String get hudMusic => 'Muzyka';

  @override
  String get hudSfx => 'Efekty';

  @override
  String get exitTitle => 'Na pewno wyjść?';

  @override
  String get exitSaved => 'Rozpoczęta gra zostanie zapisana.';

  @override
  String get exitNotSaved => 'Rozpoczęta gra nie zostanie zapisana.';

  @override
  String get exitConfirm => 'Wyjdź';

  @override
  String get pauseResume => 'Graj dalej';

  @override
  String get pauseRestart => 'Zacznij od nowa';

  @override
  String get pauseRules => 'Zasady';

  @override
  String get close => 'Zamknij';

  @override
  String turnOf(String name) {
    return 'Teraz ruch: $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name myśli…';
  }

  @override
  String get resumeFailed => 'Nie da się wrócić do zapisanej gry.';

  @override
  String resultWins(String name) {
    return '$name wygrywa!';
  }

  @override
  String get resultDraw => 'Remis!';

  @override
  String get resultPlayAgain => 'Zagraj jeszcze raz';

  @override
  String get resultChangeSettings => 'Zmień ustawienia';

  @override
  String get resultHome => 'Start';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot => 'Brakujących graczy zastąpiły roboty.';

  @override
  String get settingsSound => 'Dźwięk';

  @override
  String get settingsMusic => 'Muzyka';

  @override
  String get settingsMusicVolume => 'Głośność muzyki';

  @override
  String get settingsSfx => 'Efekty dźwiękowe';

  @override
  String get settingsSfxVolume => 'Głośność efektów';

  @override
  String get settingsVibration => 'Wibracje';

  @override
  String get settingsCredits => 'Autorzy i licencje';

  @override
  String get creditsSounds => 'Muzyka i dźwięki';

  @override
  String get creditsFonts => 'Czcionki';

  @override
  String get creditsLibraries => 'Licencje bibliotek';

  @override
  String creditsLicense(String license) {
    return 'Licencja: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Pierwsza wygrana';

  @override
  String get badgeFirstWinDescription => 'Wygraj swoją pierwszą grę.';

  @override
  String get badgeStreak5Title => 'Pięć z rzędu';

  @override
  String get badgeStreak5Description => 'Wygraj 5 gier z rzędu.';

  @override
  String get badgeGames10Title => 'Dziesiątka';

  @override
  String get badgeGames10Description => 'Zagraj 10 gier.';

  @override
  String get badgeHardWinTitle => 'Pogromca robotów';

  @override
  String get badgeHardWinDescription => 'Pokonaj roboty na poziomie Trudny.';

  @override
  String get badgeAllGamesTitle => 'Odkrywca';

  @override
  String get badgeAllGamesDescription => 'Zagraj w każdą grę.';

  @override
  String get resultNewBadges => 'Nowe odznaki';

  @override
  String get leaderboardWeek => 'Tydzień';

  @override
  String get leaderboardMonth => 'Miesiąc';

  @override
  String get leaderboardAllTime => 'Zawsze';

  @override
  String get leaderboardAllGames => 'Wszystkie gry';

  @override
  String get leaderboardAnyDifficulty => 'Każdy poziom';

  @override
  String get leaderboardEmpty => 'Na razie nikogo tu nie ma. Dokończcie grę!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wygranej',
      many: '$count wygranych',
      few: '$count wygrane',
      one: '$count wygrana',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played gry',
      many: '$played gier',
      few: '$played gry',
      one: '$played gra',
    );
    return '$_temp0 · $rate%';
  }

  @override
  String playerStats(String name) {
    return 'Statystyki: $name';
  }

  @override
  String get statsPlayed => 'Rozegrane';

  @override
  String get statsWins => 'Wygrane';

  @override
  String get statsWinRate => 'Skuteczność';

  @override
  String get statsBestStreak => 'Najlepsza seria';

  @override
  String get statsCurrentStreak => 'Obecna seria';

  @override
  String get statsByGame => 'Według gier';

  @override
  String statsBestScore(int score) {
    return 'Najlepszy wynik: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Najszybsza wygrana: $time';
  }

  @override
  String get statsBadges => 'Odznaki';

  @override
  String statsBadgeEarned(String date) {
    return 'Zdobyta $date';
  }

  @override
  String get statsNoGames => 'Na razie brak skończonych gier.';

  @override
  String homeBestStars(int stars) {
    return 'Najlepsza ocena: $stars z 3 gwiazdek';
  }

  @override
  String get resultPoints => 'Punkty';

  @override
  String get pointsWin => 'Wygrana';

  @override
  String get pointsDraw => 'Remis';

  @override
  String get pointsSecond => '2. miejsce';

  @override
  String get pointsParticipation => 'Udział';

  @override
  String pointsStars(int count) {
    return 'Ocena $count ★';
  }

  @override
  String pointsStreak(int count) {
    return 'Seria $count wygranych';
  }

  @override
  String get pointsFirstToday => 'Pierwsza gra dnia';

  @override
  String get pointsRecord => 'Nowy rekord osobisty';

  @override
  String pointsBadge(String name) {
    return 'Odznaka: $name';
  }

  @override
  String get pointsCapped => 'Dziś już dużo wygranych na Łatwym';

  @override
  String get pointsGift => 'Prezent od rodzica';

  @override
  String get pointsPurchase => 'Zakup';

  @override
  String pointsTotal(int points) {
    return 'Razem +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Nowy poziom $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Punkty: $points';
  }

  @override
  String levelShort(int level) {
    return 'Poz. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Poziom $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● do następnego poziomu';
  }

  @override
  String get levelMax => 'Najwyższy poziom!';

  @override
  String get statsBalance => 'Stan konta';

  @override
  String get statsTotalEarned => 'Razem zdobyte';

  @override
  String get statsPointsHistory => 'Historia punktów';

  @override
  String get settingsParents => 'Strefa rodzica';

  @override
  String get parentsGateTitle => 'Tylko dla rodziców';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Ile to jest $a × $b?';
  }

  @override
  String get parentsGateWrong => 'To nie jest dobrze.';

  @override
  String get parentsGateLocked => 'Za dużo prób. Spróbuj ponownie za minutę.';

  @override
  String get parentsGateOpen => 'Otwórz';

  @override
  String get parentsGiftTitle => 'Podaruj punkty';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Podarować $points ● dla: $name?';
  }

  @override
  String get parentsGiftAction => 'Podaruj';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Podarowano: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Jest nowa wersja $version';
  }

  @override
  String get updateNow => 'Aktualizuj';

  @override
  String get updateLater => 'Później';

  @override
  String updateDownloading(int percent) {
    return 'Pobieram… $percent%';
  }

  @override
  String get updateMandatory =>
      'Ta wersja jest już za stara – zaktualizuj, proszę.';

  @override
  String get updateFailed => 'Pobieranie się nie udało. Spróbuj później.';

  @override
  String get updatePermissionTitle => 'Jeszcze jedno pozwolenie';

  @override
  String get updatePermissionText =>
      'Android zapyta, czy Deskovky mogą instalować aplikacje. To tylko dla nowej wersji Deskovky. Poproś dorosłego, żeby włączył przełącznik, a potem wróć tutaj.';

  @override
  String get updatePermissionOpen => 'Otwórz ustawienia';

  @override
  String get settingsApp => 'Aplikacja';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsCheckNow => 'Sprawdź aktualizacje teraz';

  @override
  String get settingsAutoUpdate => 'Sprawdzaj automatycznie';

  @override
  String get updateUpToDate => 'Masz najnowszą wersję.';

  @override
  String get updateCheckFailed =>
      'Sprawdzanie się nie udało – czy urządzenie ma internet?';

  @override
  String get itemCap => 'Czapka z daszkiem';

  @override
  String get itemEarsHeadband => 'Opaska z uszkami';

  @override
  String get itemFlowerWreath => 'Wianek';

  @override
  String get itemTopHat => 'Cylinder';

  @override
  String get itemVikingHelmet => 'Hełm wikinga';

  @override
  String get itemPirateBandana => 'Piracka chusta';

  @override
  String get itemWizardHat => 'Kapelusz czarodzieja';

  @override
  String get itemCrown => 'Korona';

  @override
  String get itemHalo => 'Aureola';

  @override
  String get itemGlasses => 'Okulary';

  @override
  String get itemMustache => 'Wąsik';

  @override
  String get itemFacePaintStar => 'Malunek gwiazdka';

  @override
  String get itemSunglasses => 'Okulary przeciwsłoneczne';

  @override
  String get itemHeroMask => 'Maska bohatera';

  @override
  String get itemMonocle => 'Monokl';

  @override
  String get itemCarnivalMask => 'Maska karnawałowa';

  @override
  String get itemLollipop => 'Lizak';

  @override
  String get itemBalloon => 'Balonik';

  @override
  String get itemIceCream => 'Lody';

  @override
  String get itemPhone => 'Komórka';

  @override
  String get itemMicrophone => 'Mikrofon';

  @override
  String get itemMagicWand => 'Czarodziejska różdżka';

  @override
  String get itemTrophy => 'Puchar';

  @override
  String get itemKitten => 'Kotek';

  @override
  String get itemChick => 'Kurczaczek';

  @override
  String get itemPuppy => 'Piesek';

  @override
  String get itemParrot => 'Papuga';

  @override
  String get itemDragon => 'Smoczek';

  @override
  String get itemWoodFrame => 'Drewniana ramka';

  @override
  String get itemGoldFrame => 'Złota ramka';

  @override
  String get itemRainbowFrame => 'Tęczowa ramka';

  @override
  String get itemFlameFrame => 'Płomienna ramka';

  @override
  String get itemStarFrame => 'Gwiezdna ramka';

  @override
  String get itemSparkles => 'Brokat';

  @override
  String get itemBubbles => 'Bańki';

  @override
  String get itemSnow => 'Śnieżyca';

  @override
  String get pointsReset => 'Rodzic wyzerował punkty';

  @override
  String get badgeWins50Title => 'Pięćdziesiątka';

  @override
  String get badgeWins50Description =>
      'Wygraj 50 gier. Nagroda: puchar do ręki.';

  @override
  String get badgeAllHardTitle => 'Mistrz wszystkich gier';

  @override
  String get badgeAllHardDescription =>
      'Pokonaj roboty na poziomie Trudny w każdej grze. Nagroda: gwiezdna ramka.';

  @override
  String get badgeCollectorTitle => 'Kolekcjoner';

  @override
  String get badgeCollectorDescription => 'Kup 10 dodatków do awatara.';

  @override
  String get shopTitle => 'Sklep';

  @override
  String shopTryOn(String name) {
    return 'Przymierzasz: $name';
  }

  @override
  String get shopAll => 'Wszystko';

  @override
  String get slotHead => 'Na głowę';

  @override
  String get slotFace => 'Twarz';

  @override
  String get slotHand => 'Do ręki';

  @override
  String get slotPet => 'Zwierzak';

  @override
  String get slotFrame => 'Ramka';

  @override
  String get slotEffect => 'Efekt';

  @override
  String shopBuy(int price) {
    return 'Kup za $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Kupić $name za $price ●?';
  }

  @override
  String get shopBuyAction => 'Kup';

  @override
  String shopMissing(int points) {
    return 'Brakuje ci $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Poziom $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Odznaka: $name';
  }

  @override
  String get shopOwned => 'Masz';

  @override
  String get shopEquipped => 'Założone';

  @override
  String get shopEquipNow => 'Założyć od razu?';

  @override
  String get shopEquip => 'Załóż';

  @override
  String get shopUnequip => 'Zdejmij';

  @override
  String get shopNotNow => 'Nie teraz';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Poziom $level → $next · jeszcze $points punktów';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Poziom $level';
  }

  @override
  String get wardrobeTitle => 'Szafa';

  @override
  String get wardrobeEmpty =>
      'Na razie nic tu nie ma. Dodatki kupisz w sklepie.';

  @override
  String get wardrobeToShop => 'Do sklepu';

  @override
  String wardrobeColour(String name) {
    return 'Kolor: $name';
  }

  @override
  String get colourGold => 'złoty';

  @override
  String get colourSilver => 'srebrny';

  @override
  String get colourRed => 'czerwony';

  @override
  String get colourBlue => 'niebieski';

  @override
  String get colourGreen => 'zielony';

  @override
  String get colourYellow => 'żółty';

  @override
  String get colourBrown => 'brązowy';

  @override
  String get parentsResetTitle => 'Wyzeruj punkty i dodatki';

  @override
  String get parentsReset => 'Wyzeruj';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name straci $points ● i wszystkie kupione dodatki. Poziom i odznaki zostaną.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: punkty i dodatki wyzerowane.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, teraz możesz kupić: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Zakup: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Nowa odznaka: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Nagroda +$points ●.';
  }

  @override
  String get shopHooray => 'Hurra!';

  @override
  String get shopNotEnough => 'Masz teraz za mało punktów.';

  @override
  String get shopFailed => 'Nie udało się. Spróbuj jeszcze raz.';

  @override
  String get updatePreparing => 'Przygotowuję aktualizację…';

  @override
  String get setupDifficultySolo => 'Poziom';

  @override
  String get whereLabel => 'Gdzie gramy';

  @override
  String get whereHere => 'Na tym urządzeniu';

  @override
  String get whereWifi => 'Każdy na swoim (Wi-Fi)';

  @override
  String get trialTag => 'Próbna';

  @override
  String get noWifi =>
      'Nie masz Wi-Fi. Połącz się z tą samą siecią Wi-Fi co inni.';

  @override
  String get setupOpenRoom => 'Otwórz pokój';

  @override
  String get roomTitle => 'Pokój';

  @override
  String get roomCode => 'Kod pokoju';

  @override
  String get roomJoinHint =>
      'Inni skanują kod QR aparatem albo wybierają Dołącz do gry.';

  @override
  String get slotOpen => 'Wolne miejsce';

  @override
  String get slotHere => '🏠 Tutaj';

  @override
  String get slotOwnDevice => '📱 Na swoim';

  @override
  String get slotReady => 'Gotowy';

  @override
  String get slotWaiting => 'Czekamy';

  @override
  String get slotDisconnected => 'Rozłączony';

  @override
  String get slotMakeRobot => 'Dodaj robota';

  @override
  String get slotAddLocal => 'Dodaj gracza z tego urządzenia';

  @override
  String get slotLeaveOpen => 'Zostaw wolne';

  @override
  String get roomRemove => 'Usuń gracza';

  @override
  String get roomStart => 'Zacznij grę';

  @override
  String get roomWaitReady => 'Czekamy, aż wszyscy będą gotowi.';

  @override
  String get roomNoServer => 'Nie udało się otworzyć pokoju.';

  @override
  String get homeJoin => 'Dołącz do gry';

  @override
  String get joinWho => 'Kto gra na tym urządzeniu';

  @override
  String get joinRooms => 'Pokoje w sieci';

  @override
  String get joinSearching => 'Szukam pokojów…';

  @override
  String get joinByCode => 'Kod pokoju (4 cyfry)';

  @override
  String get joinCodeNotFound => 'Nie ma w sieci pokoju z tym kodem.';

  @override
  String get joinAdvanced => 'Zaawansowane';

  @override
  String get joinAddress => 'Adres (IP:port)';

  @override
  String get joinConnect => 'Połącz';

  @override
  String get joinFailed => 'Nie udało się połączyć.';

  @override
  String get joinPickSomeone => 'Wybierz co najmniej jednego gracza.';

  @override
  String get joinScanQr => 'Skanuj QR';

  @override
  String get joinQrRoom => 'Pokój z kodu QR';

  @override
  String get joinOtherRoom => 'Wybierz inny pokój';

  @override
  String get qrNotRoom =>
      'To nie jest kod QR Deskovky. Zeskanuj kod z ekranu Pokój.';

  @override
  String get qrCameraDenied =>
      'Bez aparatu nie odczytam kodu QR. Zezwól na niego w ustawieniach telefonu albo wpisz kod pokoju.';

  @override
  String get qrScanTitle => 'Skieruj na kod QR';

  @override
  String get byeVersion =>
      'Gospodarz ma inną wersję aplikacji. Zaktualizujcie wszyscy do tej samej.';

  @override
  String get byeCode => 'Zły kod pokoju.';

  @override
  String get byeFull => 'Pokój jest pełny.';

  @override
  String get byeStarted => 'Gra już się zaczęła.';

  @override
  String get byeKicked => 'Gospodarz usunął cię z pokoju.';

  @override
  String get byeLost => 'Połączenie z gospodarzem zostało przerwane.';

  @override
  String get lobbyReady => 'Jestem gotowy';

  @override
  String get lobbyNotReady => 'Jeszcze nie';

  @override
  String get lobbySettings => 'Ustawienia gry (wybiera gospodarz)';

  @override
  String get lobbyWaitStart => 'Czekamy, aż gospodarz zacznie grę.';

  @override
  String get leaveRoom => 'Wyjdź z pokoju';

  @override
  String joinFree(int count) {
    return 'Wolne miejsca: $count';
  }

  @override
  String get netDecideTitle => 'Gracz nie wrócił';

  @override
  String get netWaitMore => 'Czekaj dalej';

  @override
  String get netReplaceRobot => 'Zastąp robotem';

  @override
  String get netEndGame => 'Zakończ grę';

  @override
  String get netLeave => 'Wyjdź z gry';

  @override
  String get netRematch => 'Rewanż';

  @override
  String get netWaitHost => 'Czekamy na gospodarza…';

  @override
  String get byeEnded => 'Gospodarz zakończył grę.';

  @override
  String netYourTurn(String name) {
    return '$name, twój ruch!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Teraz ruch: $name (na swoim urządzeniu)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: rozłączono – czekam ($time)';
  }

  @override
  String get netReconnect => 'Połącz ponownie';

  @override
  String resultNotThisTime(String name) {
    return '$name, tym razem się nie udało';
  }

  @override
  String get joinLinkBusy =>
      'Już grasz. Najpierw wyjdź z rozpoczętej gry albo pokoju.';

  @override
  String get familyTitle => 'Rodzina';

  @override
  String get familyIntro =>
      'Połączcie urządzenia rodziny: profile, punkty, nagrody i historia gier będą na wszystkich takie same. Wystarczy domowe Wi-Fi, internet nie jest potrzebny.';

  @override
  String get familyCreate => 'Załóż rodzinę';

  @override
  String get familyJoin => 'Dołącz do rodziny';

  @override
  String get familyJoinOther => 'Dołącz do innej rodziny';

  @override
  String get familyJoinOtherWarning =>
      'To urządzenie jest już w rodzinie. Dołączenie do innej oznacza opuszczenie obecnej; profile z tego urządzenia zostaną zaproponowane do sparowania.';

  @override
  String get familyJoinOtherConfirm => 'Dołącz mimo to';

  @override
  String get familyAddDevice => 'Dodaj urządzenie';

  @override
  String get familyQrHint =>
      'Na nowym urządzeniu otwórz Ustawienia → Strefa rodzica → Rodzina → Dołącz do rodziny i zeskanuj ten kod. Oba urządzenia muszą być w tej samej sieci Wi-Fi.';

  @override
  String get familyDevices => 'Urządzenia w rodzinie';

  @override
  String get familyThisDevice => 'to urządzenie';

  @override
  String get familyNeverSynced => 'jeszcze nie zsynchronizowano';

  @override
  String get familyRemove => 'Usuń z rodziny';

  @override
  String get familyRemoveMessage =>
      'Urządzenie zniknie z listy i przestanie dostawać profile i punkty. Dane, które już ma, zostaną na nim. To tylko dla porządku: kto zna rodzinny kod QR, może dołączyć ponownie. Całkiem oddzielić je można tylko, zakładając nową rodzinę.';

  @override
  String get familyRemoved => 'usunięte';

  @override
  String get familyJoined => 'Gotowe – jesteś w rodzinie!';

  @override
  String get familyJoinFailed =>
      'Nie udało się dołączyć do rodziny. Czy oba urządzenia są w tej samej sieci Wi-Fi, a na drugim jest otwarta Rodzina?';

  @override
  String get familyNotACode => 'To nie jest kod rodziny.';

  @override
  String get familyUpdateApps =>
      'Jedno z urządzeń ma inną wersję aplikacji. Zaktualizujcie aplikację na wszystkich urządzeniach.';

  @override
  String get familyCodeInJoin =>
      'To jest kod rodziny. Urządzenie dodasz w Ustawienia → Strefa rodzica → Rodzina.';

  @override
  String get familySynced => 'Zsynchronizowano z rodziną';

  @override
  String get deviceTablet => 'Tablet';

  @override
  String get devicePhone => 'Telefon';

  @override
  String familyLastSync(String time) {
    return 'ostatnio $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Usunąć $name z rodziny?';
  }

  @override
  String get pairTitle => 'Sparuj profile';

  @override
  String get pairQuestion => 'Czy to ta sama osoba?';

  @override
  String get pairMerge => 'Tak, połącz';

  @override
  String get pairKeep => 'Nie, to dwie osoby';

  @override
  String get pairLook => 'Wygląd po połączeniu';

  @override
  String get pairManual => 'Sparuj ręcznie';

  @override
  String get pairFirst => 'Profil';

  @override
  String get pairSecond => 'należy do';

  @override
  String get pairNone => 'Nie ma więcej par.';

  @override
  String get refundTitle => 'Punkty wróciły';

  @override
  String get refundOk => 'Rozumiem';

  @override
  String familyPairs(int count) {
    return 'Możliwe pary ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Oddaliśmy ci punkty za $item – nie starczyło punktów na obie rzeczy.';
  }

  @override
  String get inviteFamily => 'Zaproś z rodziny';

  @override
  String get inviteSent => 'Zaproszenie wysłane.';

  @override
  String get inviteNoDevice =>
      'Nie znalazłem w sieci żadnego urządzenia rodziny.';

  @override
  String get invitePlay => 'Graj';

  @override
  String get inviteLater => 'Nie teraz';

  @override
  String inviteTitle(String host, String game) {
    return '$host zaprasza cię do gry $game – grasz?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Zwrot: $item – kupione dwa razy';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Zwrot: $item – za mało punktów';
  }

  @override
  String get setupElsewhere => 'Na innym urządzeniu';

  @override
  String get setupBusyTag => 'Gra w inną grę';

  @override
  String get setupInvitePlay => 'Zaproś i graj';

  @override
  String get slotInvited => 'Zaproszony, czekamy';

  @override
  String inviteFailed(String name) {
    return 'Nie udało się dostarczyć zaproszenia dla: $name.';
  }

  @override
  String get inviteNotHere => 'Nie ma w sieci';

  @override
  String get navDonations => 'Wsparcie';

  @override
  String get donationsTitle => 'Wesprzyj Deskovky';

  @override
  String get donationsIntro =>
      'Deskovky powstają w domu, dla rodzin z dziećmi. Są i zostaną za darmo. Jeśli sprawiają wam radość, możecie dobrowolnie wesprzeć dalszy rozwój.';

  @override
  String get donationsFreeTitle => 'Cała gra za darmo';

  @override
  String get donationsFreeText =>
      'Żadnych płatnych poziomów, nic nie odblokowuje się za pieniądze.';

  @override
  String get donationsNoAdsTitle => 'Bez reklam';

  @override
  String get donationsNoAdsText =>
      'Nic nie rozprasza dzieci i nic nie namawia ich do zakupów.';

  @override
  String get donationsNoDataTitle => 'Bez zbierania danych';

  @override
  String get donationsNoDataText =>
      'Bez kont i logowania. Profile i wyniki zostają na waszych urządzeniach.';

  @override
  String get donationsOfflineTitle => 'Bezpiecznie bez internetu';

  @override
  String get donationsOfflineText =>
      'Gra działa offline i nie wysyła nigdzie nic o was. Internetu używa tylko do pobrania nowej wersji.';

  @override
  String get donationsFamilyTitle => 'Gra cała rodzina';

  @override
  String get donationsFamilyText =>
      'Przy jednym stole albo każdy na swoim przez domowe Wi-Fi. Urządzenia rodziny dzielą się danymi tylko między sobą.';

  @override
  String get donationsKidsTitle => 'Także dla najmłodszych';

  @override
  String get donationsKidsText =>
      'Roboty na trzech poziomach, zasady z obrazkami, duże przyciski i strefa rodzica.';

  @override
  String get donationsEveryoneTitle => 'Dla każdego';

  @override
  String get donationsEveryoneText =>
      'Działa z czytnikiem ekranu, ma oznaczenia dla daltonistów i mówi w dziesięciu językach.';

  @override
  String get donationsGrowingTitle => 'Ciągle nowe gry';

  @override
  String get donationsGrowingText =>
      'Dziewięć gier i kolejne w drodze – także na życzenie dzieci.';

  @override
  String get donationsWhy =>
      'Wsparcie pomoże opłacić czas na tworzenie nowych gier i opłaty za Google Play.';

  @override
  String get donationsSoon =>
      'Wspierać będzie można, gdy gra trafi do Google Play. Dziękujemy!';

  @override
  String get familyRename => 'Zmień nazwę urządzenia';

  @override
  String get familyOnline => 'Deskovky działają';

  @override
  String get familyOffline => 'Niedostępne';

  @override
  String familyPlaysNow(String name) {
    return 'Teraz gra $name';
  }

  @override
  String get settingsShareApp => 'Pobierz na inne urządzenie';

  @override
  String get shareAppTitle => 'Deskovky na innym urządzeniu';

  @override
  String get shareAppHint =>
      'Zeskanuj kod aparatem drugiego telefonu lub tabletu. Otworzy się strona z najnowszą wersją: pobierz plik deskovky-….apk i otwórz go.';

  @override
  String get inviteToAllDevices =>
      'Zaproszenie trafi na wszystkie urządzenia w sieci';

  @override
  String get saveFailed => 'Nie udało się zapisać gry.';
}
