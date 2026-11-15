// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Ігри';

  @override
  String get navPlayers => 'Гравці';

  @override
  String get navLeaderboards => 'Рейтинг';

  @override
  String get navSettings => 'Опції';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get panelPlayersOnDevice => 'Гравці на цьому пристрої';

  @override
  String get panelLeaderboardWeek => 'Рейтинг цього тижня';

  @override
  String get panelLastReward => 'Остання нагорода';

  @override
  String get screenEmpty => 'Тут поки нічого немає.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count гравця',
      many: '$count гравців',
      few: '$count гравці',
      one: '$count гравець',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'Мій аватар';

  @override
  String get avatarSave => 'Зберегти';

  @override
  String get avatarRandom => 'Навмання';

  @override
  String get back => 'Назад';

  @override
  String get avatarTabFace => 'Обличчя';

  @override
  String get avatarTabSkin => 'Шкіра';

  @override
  String get avatarTabHair => 'Волосся';

  @override
  String get avatarTabEyes => 'Очі';

  @override
  String get avatarTabMouth => 'Рот';

  @override
  String get avatarTabBackground => 'Тло';

  @override
  String get avatarHairColor => 'Колір волосся';

  @override
  String get faceOval => 'овальне';

  @override
  String get faceRound => 'кругле';

  @override
  String get faceWide => 'широке';

  @override
  String get faceSquare => 'квадратне';

  @override
  String get hairShort => 'коротке';

  @override
  String get hairLong => 'довге';

  @override
  String get hairCurly => 'кучеряве';

  @override
  String get hairBun => 'гулька';

  @override
  String get hairSpiky => 'їжачок';

  @override
  String get hairPigtails => 'хвостики';

  @override
  String get hairBob => 'каре';

  @override
  String get hairBraids => 'косички';

  @override
  String get hairCap => 'кепка';

  @override
  String get hairBald => 'лисина';

  @override
  String get eyesRound => 'круглі';

  @override
  String get eyesHappy => 'веселі';

  @override
  String get eyesWink => 'підморгують';

  @override
  String get eyesSleepy => 'сонні';

  @override
  String get eyesWide => 'широко розплющені';

  @override
  String get eyesLashes => 'з віями';

  @override
  String get mouthSmile => 'усмішка';

  @override
  String get mouthOpen => 'відкритий';

  @override
  String get mouthFlat => 'рівний';

  @override
  String get mouthGrin => 'широка усмішка';

  @override
  String get mouthTongue => 'показує язик';

  @override
  String get mouthSurprised => 'здивований';

  @override
  String get hairColorBlack => 'чорне';

  @override
  String get hairColorBrown => 'коричневе';

  @override
  String get hairColorChestnut => 'каштанове';

  @override
  String get hairColorBlond => 'біляве';

  @override
  String get hairColorPlatinum => 'платинове';

  @override
  String get hairColorRed => 'руде';

  @override
  String get hairColorGrey => 'сиве';

  @override
  String get hairColorBlue => 'синє';

  @override
  String skinTone(int n) {
    return 'Колір шкіри $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Тло $n';
  }

  @override
  String get playersNew => 'Новий гравець';

  @override
  String get playersLimit =>
      'На цьому пристрої може бути щонайбільше 8 гравців.';

  @override
  String get playersEmpty => 'Тут ще нікого немає. Створи першого гравця!';

  @override
  String playersNowPlaying(String name) {
    return 'Зараз грає $name';
  }

  @override
  String get playerActiveTag => 'Грає';

  @override
  String playerEdit(String name) {
    return 'Змінити: $name';
  }

  @override
  String playerDelete(String name) {
    return 'Видалити: $name';
  }

  @override
  String get profileName => 'Ім’я';

  @override
  String get profileErrorEmpty => 'Введи ім’я.';

  @override
  String get profileErrorTooLong => 'Щонайбільше 16 символів.';

  @override
  String get profileErrorTaken => 'Таке ім’я вже має інший гравець.';

  @override
  String get profileErrorLimit =>
      'На цьому пристрої може бути щонайбільше 8 гравців.';

  @override
  String deleteTitle(String name) {
    return 'Видалити гравця $name?';
  }

  @override
  String get deleteMessage =>
      'Його результати теж буде видалено. Це не можна скасувати.';

  @override
  String get deleteConfirm => 'Видалити';

  @override
  String get discardTitle => 'Скасувати зміни?';

  @override
  String get discardMessage => 'Зміни аватара та імені не буде збережено.';

  @override
  String get discardConfirm => 'Скасувати';

  @override
  String get cancel => 'Скасувати';

  @override
  String get homeHello => 'Привіт,';

  @override
  String get homeSwitchPlayer => 'Змінити гравця';

  @override
  String get homeCreatePlayer => 'Створити гравця';

  @override
  String get settingsLanguage => 'Мова';

  @override
  String get settingsLanguageSystem => 'Як у телефоні';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max гравців';
  }

  @override
  String continueTitle(String game) {
    return 'Продовжити: $game';
  }

  @override
  String get continueSaved => 'Незавершена гра';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Грати ▸';

  @override
  String get difficultyEasy => 'Легко';

  @override
  String get difficultyMedium => 'Середньо';

  @override
  String get difficultyHard => 'Важко';

  @override
  String get setupPlayers => 'Кількість гравців';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count людини',
      many: '$count людей',
      few: '$count людини',
      one: '$count людина',
    );
    return '$_temp0';
  }

  @override
  String seatsRobots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count робота',
      many: '$count роботів',
      few: '$count роботи',
      one: '$count робот',
    );
    return '$_temp0';
  }

  @override
  String get setupDifficulty => 'Складність роботів';

  @override
  String get setupSpeed => 'Швидкість роботів';

  @override
  String get speedSlow => 'Повільно';

  @override
  String get speedNormal => 'Звичайно';

  @override
  String get speedFast => 'Швидко';

  @override
  String get seatHuman => 'Людина';

  @override
  String get seatRobot => '🤖 Робот';

  @override
  String get setupLoaded => '↺ Налаштування з твоєї останньої гри';

  @override
  String get setupFilled => 'вільні місця зайняли роботи';

  @override
  String get setupNoFreeProfile => 'Усі гравці вже за столом.';

  @override
  String get seatMoveUp => 'Вгору';

  @override
  String get seatMoveDown => 'Вниз';

  @override
  String get setupPlay => 'Грати!';

  @override
  String get setupNeedPlayer => 'Спершу створи гравця.';

  @override
  String get robotName0 => 'Робо';

  @override
  String get robotName1 => 'Чіп';

  @override
  String get robotName2 => 'Болт';

  @override
  String get robotName3 => 'Базз';

  @override
  String get hudExit => 'Вийти';

  @override
  String get hudPause => 'Пауза';

  @override
  String get hudMusic => 'Музика';

  @override
  String get hudSfx => 'Звукові ефекти';

  @override
  String get exitTitle => 'Справді вийти?';

  @override
  String get exitSaved => 'Незавершену гру буде збережено.';

  @override
  String get exitNotSaved => 'Незавершену гру не буде збережено.';

  @override
  String get exitConfirm => 'Вийти';

  @override
  String get pauseResume => 'Продовжити';

  @override
  String get pauseRestart => 'Почати знову';

  @override
  String get pauseRules => 'Правила';

  @override
  String get close => 'Закрити';

  @override
  String turnOf(String name) {
    return 'Хід: $name';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name думає…';
  }

  @override
  String get resumeFailed => 'Збережену гру не вдається продовжити.';

  @override
  String resultWins(String name) {
    return 'Перемагає $name!';
  }

  @override
  String get resultDraw => 'Нічия!';

  @override
  String get resultPlayAgain => 'Грати ще';

  @override
  String get resultChangeSettings => 'Змінити налаштування';

  @override
  String get resultHome => 'Додому';

  @override
  String get resultRobotTag => 'робот';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot => 'Відсутніх гравців замінили роботи.';

  @override
  String get settingsSound => 'Звук';

  @override
  String get settingsMusic => 'Музика';

  @override
  String get settingsMusicVolume => 'Гучність музики';

  @override
  String get settingsSfx => 'Звукові ефекти';

  @override
  String get settingsSfxVolume => 'Гучність ефектів';

  @override
  String get settingsVibration => 'Вібрація';

  @override
  String get settingsCredits => 'Автори та ліцензії';

  @override
  String get creditsSounds => 'Музика та звуки';

  @override
  String get creditsFonts => 'Шрифти';

  @override
  String get creditsLibraries => 'Ліцензії бібліотек';

  @override
  String creditsLicense(String license) {
    return 'Ліцензія: $license';
  }

  @override
  String get badgeFirstWinTitle => 'Перша перемога';

  @override
  String get badgeFirstWinDescription => 'Виграй свою першу гру.';

  @override
  String get badgeStreak5Title => 'П’ять поспіль';

  @override
  String get badgeStreak5Description => 'Виграй 5 ігор поспіль.';

  @override
  String get badgeGames10Title => 'Десять ігор';

  @override
  String get badgeGames10Description => 'Зіграй 10 ігор.';

  @override
  String get badgeHardWinTitle => 'Приборкувач роботів';

  @override
  String get badgeHardWinDescription => 'Переможи роботів на рівні «Важко».';

  @override
  String get badgeAllGamesTitle => 'Дослідник';

  @override
  String get badgeAllGamesDescription => 'Зіграй у кожну гру.';

  @override
  String get resultNewBadges => 'Нові значки';

  @override
  String get leaderboardWeek => 'Тиждень';

  @override
  String get leaderboardMonth => 'Місяць';

  @override
  String get leaderboardAllTime => 'За весь час';

  @override
  String get leaderboardAllGames => 'Усі ігри';

  @override
  String get leaderboardAnyDifficulty => 'Будь-яка складність';

  @override
  String get leaderboardEmpty => 'Тут ще нікого немає. Дограй гру!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count перемоги',
      many: '$count перемог',
      few: '$count перемоги',
      one: '$count перемога',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played гри',
      many: '$played ігор',
      few: '$played гри',
      one: '$played гра',
    );
    return '$_temp0 · $rate%';
  }

  @override
  String playerStats(String name) {
    return 'Статистика: $name';
  }

  @override
  String get statsPlayed => 'Зіграно';

  @override
  String get statsWins => 'Перемоги';

  @override
  String get statsWinRate => 'Успішність';

  @override
  String get statsBestStreak => 'Найдовша серія';

  @override
  String get statsCurrentStreak => 'Поточна серія';

  @override
  String get statsByGame => 'За іграми';

  @override
  String statsBestScore(int score) {
    return 'Найкращий рахунок: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Найшвидша перемога: $time';
  }

  @override
  String get statsBadges => 'Значки';

  @override
  String statsBadgeEarned(String date) {
    return 'Отримано $date';
  }

  @override
  String get statsNoGames => 'Ще немає завершених ігор.';

  @override
  String homeBestStars(int stars) {
    return 'Найкраща оцінка: $stars з 3 зірок';
  }

  @override
  String get resultPoints => 'Бали';

  @override
  String get pointsWin => 'Перемога';

  @override
  String get pointsDraw => 'Нічия';

  @override
  String get pointsSecond => '2-ге місце';

  @override
  String get pointsParticipation => 'Участь';

  @override
  String pointsStars(int count) {
    return 'Оцінка $count ★';
  }

  @override
  String pointsStreak(int count) {
    return 'Перемог поспіль: $count';
  }

  @override
  String get pointsFirstToday => 'Перша гра сьогодні';

  @override
  String get pointsRecord => 'Новий особистий рекорд';

  @override
  String pointsBadge(String name) {
    return 'Значок: $name';
  }

  @override
  String get pointsCapped => 'Сьогодні багато легких перемог';

  @override
  String get pointsGift => 'Подарунок від батьків';

  @override
  String get pointsPurchase => 'Покупка';

  @override
  String pointsTotal(int points) {
    return 'Разом +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'Новий рівень $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Бали: $points';
  }

  @override
  String levelShort(int level) {
    return 'Рів. $level';
  }

  @override
  String levelLabel(int level) {
    return 'Рівень $level';
  }

  @override
  String levelNext(int current, int needed) {
    return '$current / $needed ● до наступного рівня';
  }

  @override
  String get levelMax => 'Найвищий рівень!';

  @override
  String get statsBalance => 'Баланс';

  @override
  String get statsTotalEarned => 'Усього зароблено';

  @override
  String get statsPointsHistory => 'Історія балів';

  @override
  String get settingsParents => 'Куточок батьків';

  @override
  String get parentsGateTitle => 'Лише для батьків';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'Скільки буде $a × $b?';
  }

  @override
  String get parentsGateWrong => 'Неправильно.';

  @override
  String get parentsGateOpen => 'Відкрити';

  @override
  String get parentsGiftTitle => 'Подарувати бали';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Подарувати $points ● гравцю $name?';
  }

  @override
  String get parentsGiftAction => 'Подарувати';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Подаровано: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'Вийшла нова версія $version';
  }

  @override
  String get updateNow => 'Оновити';

  @override
  String get updateLater => 'Пізніше';

  @override
  String updateDownloading(int percent) {
    return 'Завантаження… $percent%';
  }

  @override
  String get updateMandatory => 'Ця версія застаріла – будь ласка, онови її.';

  @override
  String get updateFailed => 'Не вдалося завантажити. Спробуй пізніше.';

  @override
  String get updatePermissionTitle => 'Ще один дозвіл';

  @override
  String get updatePermissionText =>
      'Android запитає, чи може Deskovky встановлювати застосунки. Це потрібно лише для нової версії Deskovky. Попроси дорослого увімкнути перемикач і повернися сюди.';

  @override
  String get updatePermissionOpen => 'Відкрити налаштування';

  @override
  String get settingsApp => 'Застосунок';

  @override
  String settingsVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get settingsCheckNow => 'Перевірити оновлення зараз';

  @override
  String get settingsAutoUpdate => 'Перевіряти автоматично';

  @override
  String get updateUpToDate => 'У тебе найновіша версія.';

  @override
  String get updateCheckFailed =>
      'Перевірка не вдалася – пристрій підключено до інтернету?';

  @override
  String get itemCap => 'Кепка';

  @override
  String get itemEarsHeadband => 'Обруч з вушками';

  @override
  String get itemFlowerWreath => 'Вінок із квітів';

  @override
  String get itemTopHat => 'Циліндр';

  @override
  String get itemVikingHelmet => 'Шолом вікінга';

  @override
  String get itemPirateBandana => 'Піратська бандана';

  @override
  String get itemWizardHat => 'Капелюх чарівника';

  @override
  String get itemCrown => 'Корона';

  @override
  String get itemHalo => 'Німб';

  @override
  String get itemGlasses => 'Окуляри';

  @override
  String get itemMustache => 'Вуса';

  @override
  String get itemFacePaintStar => 'Зірочка-аквагрим';

  @override
  String get itemSunglasses => 'Сонячні окуляри';

  @override
  String get itemHeroMask => 'Маска супергероя';

  @override
  String get itemMonocle => 'Монокль';

  @override
  String get itemCarnivalMask => 'Карнавальна маска';

  @override
  String get itemLollipop => 'Льодяник';

  @override
  String get itemBalloon => 'Повітряна кулька';

  @override
  String get itemIceCream => 'Морозиво';

  @override
  String get itemPhone => 'Телефон';

  @override
  String get itemMicrophone => 'Мікрофон';

  @override
  String get itemMagicWand => 'Чарівна паличка';

  @override
  String get itemTrophy => 'Кубок';

  @override
  String get itemKitten => 'Кошеня';

  @override
  String get itemChick => 'Курча';

  @override
  String get itemPuppy => 'Цуценя';

  @override
  String get itemParrot => 'Папуга';

  @override
  String get itemDragon => 'Дракончик';

  @override
  String get itemWoodFrame => 'Дерев’яна рамка';

  @override
  String get itemGoldFrame => 'Золота рамка';

  @override
  String get itemRainbowFrame => 'Райдужна рамка';

  @override
  String get itemFlameFrame => 'Вогняна рамка';

  @override
  String get itemStarFrame => 'Зоряна рамка';

  @override
  String get itemSparkles => 'Іскорки';

  @override
  String get itemBubbles => 'Бульбашки';

  @override
  String get itemSnow => 'Снігопад';

  @override
  String get pointsReset => 'Батьки обнулили бали';

  @override
  String get badgeWins50Title => 'П’ятдесят';

  @override
  String get badgeWins50Description =>
      'Виграй 50 ігор. Нагорода: кубок у руку.';

  @override
  String get badgeAllHardTitle => 'Майстер усіх ігор';

  @override
  String get badgeAllHardDescription =>
      'Переможи роботів на рівні «Важко» в кожній грі. Нагорода: зоряна рамка.';

  @override
  String get badgeCollectorTitle => 'Колекціонер';

  @override
  String get badgeCollectorDescription => 'Купи 10 прикрас для аватара.';

  @override
  String get shopTitle => 'Крамниця';

  @override
  String shopTryOn(String name) {
    return 'Приміряєш: $name';
  }

  @override
  String get shopAll => 'Усе';

  @override
  String get slotHead => 'Голова';

  @override
  String get slotFace => 'Обличчя';

  @override
  String get slotHand => 'Рука';

  @override
  String get slotPet => 'Улюбленець';

  @override
  String get slotFrame => 'Рамка';

  @override
  String get slotEffect => 'Ефект';

  @override
  String shopBuy(int price) {
    return 'Купити за $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Купити $name за $price ●?';
  }

  @override
  String get shopBuyAction => 'Купити';

  @override
  String shopMissing(int points) {
    return 'Бракує ще $points ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Рівень $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Значок: $name';
  }

  @override
  String get shopOwned => 'Є в тебе';

  @override
  String get shopEquipped => 'Одягнено';

  @override
  String get shopEquipNow => 'Одягнути зараз?';

  @override
  String get shopEquip => 'Одягнути';

  @override
  String get shopUnequip => 'Зняти';

  @override
  String get shopNotNow => 'Не зараз';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Рівень $level → $next · ще $points балів';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Рівень $level';
  }

  @override
  String get wardrobeTitle => 'Гардероб';

  @override
  String get wardrobeEmpty =>
      'Тут поки нічого немає. Купи прикраси в крамниці.';

  @override
  String get wardrobeToShop => 'До крамниці';

  @override
  String wardrobeColour(String name) {
    return 'Колір: $name';
  }

  @override
  String get colourGold => 'золотий';

  @override
  String get colourSilver => 'срібний';

  @override
  String get colourRed => 'червоний';

  @override
  String get colourBlue => 'синій';

  @override
  String get colourGreen => 'зелений';

  @override
  String get colourYellow => 'жовтий';

  @override
  String get colourBrown => 'коричневий';

  @override
  String get parentsResetTitle => 'Обнулити бали та прикраси';

  @override
  String get parentsReset => 'Обнулити';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name втратить $points ● і всі куплені прикраси. Рівень і значки залишаться.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: бали та прикраси обнулено.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, тепер ти можеш купити: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Покупка: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'Новий значок: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Нагорода +$points ●.';
  }

  @override
  String get shopHooray => 'Ура!';

  @override
  String get shopNotEnough => 'Зараз тобі на це не вистачає балів.';

  @override
  String get shopFailed => 'Не вийшло. Спробуй ще раз.';

  @override
  String get updatePreparing => 'Готуємо оновлення…';

  @override
  String get setupDifficultySolo => 'Складність';

  @override
  String get whereLabel => 'Де грати';

  @override
  String get whereHere => 'На цьому пристрої';

  @override
  String get whereWifi => 'Кожен на своєму (Wi-Fi)';

  @override
  String get trialTag => 'Пробна';

  @override
  String get noWifi =>
      'Ти не підключений до Wi-Fi. Підключись до тієї ж мережі Wi-Fi, що й інші.';

  @override
  String get setupOpenRoom => 'Відкрити кімнату';

  @override
  String get roomTitle => 'Кімната';

  @override
  String get roomCode => 'Код кімнати';

  @override
  String get roomJoinHint =>
      'Інші сканують QR-код камерою або натискають «Приєднатися до гри».';

  @override
  String get slotOpen => 'Вільне місце';

  @override
  String get slotHere => '🏠 Тут';

  @override
  String get slotOwnDevice => '📱 Свій пристрій';

  @override
  String get slotReady => 'Готовий';

  @override
  String get slotWaiting => 'Чекає';

  @override
  String get slotDisconnected => 'Від’єднано';

  @override
  String get slotMakeRobot => 'Додати робота';

  @override
  String get slotAddLocal => 'Додати гравця з цього пристрою';

  @override
  String get slotLeaveOpen => 'Залишити вільним';

  @override
  String get roomRemove => 'Прибрати гравця';

  @override
  String get roomStart => 'Почати гру';

  @override
  String get roomWaitReady => 'Чекаємо, поки всі будуть готові.';

  @override
  String get roomNoServer => 'Не вдалося відкрити кімнату.';

  @override
  String get homeJoin => 'Приєднатися до гри';

  @override
  String get joinWho => 'Хто грає на цьому пристрої';

  @override
  String get joinRooms => 'Кімнати в мережі';

  @override
  String get joinSearching => 'Шукаємо кімнати…';

  @override
  String get joinByCode => 'Код кімнати (4 цифри)';

  @override
  String get joinCodeNotFound => 'У мережі немає кімнати з таким кодом.';

  @override
  String get joinAdvanced => 'Додатково';

  @override
  String get joinAddress => 'Адреса (IP:порт)';

  @override
  String get joinConnect => 'Підключитися';

  @override
  String get joinFailed => 'Не вдалося підключитися.';

  @override
  String get joinPickSomeone => 'Вибери хоча б одного гравця.';

  @override
  String get joinScanQr => 'Сканувати QR';

  @override
  String get joinQrRoom => 'Кімната з QR-коду';

  @override
  String get joinOtherRoom => 'Вибрати іншу кімнату';

  @override
  String get qrNotRoom =>
      'Це не QR-код Deskovky. Скануй код з екрана «Кімната».';

  @override
  String get qrCameraDenied =>
      'Без камери я не прочитаю QR-код. Дозволь її в налаштуваннях телефону або введи код кімнати.';

  @override
  String get qrScanTitle => 'Наведи камеру на QR-код';

  @override
  String get byeVersion =>
      'У господаря інша версія застосунку. Оновіть усі пристрої до однакової.';

  @override
  String get byeCode => 'Неправильний код кімнати.';

  @override
  String get byeFull => 'Кімната заповнена.';

  @override
  String get byeStarted => 'Гра вже почалася.';

  @override
  String get byeKicked => 'Господар прибрав тебе з кімнати.';

  @override
  String get byeLost => 'Зв’язок із господарем втрачено.';

  @override
  String get lobbyReady => 'Я готовий';

  @override
  String get lobbyNotReady => 'Ще ні';

  @override
  String get lobbySettings => 'Налаштування гри (вибирає господар)';

  @override
  String get lobbyWaitStart => 'Чекаємо, поки господар почне гру.';

  @override
  String get leaveRoom => 'Вийти з кімнати';

  @override
  String joinFree(int count) {
    return 'Вільних місць: $count';
  }

  @override
  String get netDecideTitle => 'Гравець не повернувся';

  @override
  String get netWaitMore => 'Чекати далі';

  @override
  String get netReplaceRobot => 'Замінити роботом';

  @override
  String get netEndGame => 'Завершити гру';

  @override
  String get netLeave => 'Вийти з гри';

  @override
  String get netRematch => 'Реванш';

  @override
  String get netWaitHost => 'Чекаємо на господаря…';

  @override
  String get byeEnded => 'Господар завершив гру.';

  @override
  String netYourTurn(String name) {
    return '$name, твій хід!';
  }

  @override
  String netTurnRemote(String name) {
    return 'Хід: $name (на своєму пристрої)';
  }

  @override
  String netWaiting(String name, String time) {
    return '$name: від’єднано – чекаємо ($time)';
  }

  @override
  String get netReconnect => 'Підключитися знову';

  @override
  String resultNotThisTime(String name) {
    return '$name, цього разу не вийшло';
  }

  @override
  String get joinLinkBusy => 'Ти вже граєш. Спершу вийди з гри або кімнати.';

  @override
  String get familyTitle => 'Сім’я';

  @override
  String get familyIntro =>
      'З’єднай пристрої своєї сім’ї: профілі, бали, нагороди та історія ігор будуть однакові на всіх. Досить домашнього Wi-Fi, інтернет не потрібен.';

  @override
  String get familyCreate => 'Створити сім’ю';

  @override
  String get familyJoin => 'Приєднатися до сім’ї';

  @override
  String get familyJoinOther => 'Приєднатися до іншої сім’ї';

  @override
  String get familyJoinOtherWarning =>
      'Цей пристрій уже в сім’ї. Якщо приєднаєшся до іншої, він вийде з поточної сім’ї; профілі на цьому пристрої буде запропоновано для поєднання.';

  @override
  String get familyJoinOtherConfirm => 'Усе одно приєднатися';

  @override
  String get familyAddDevice => 'Додати пристрій';

  @override
  String get familyQrHint =>
      'На новому пристрої відкрий Опції → Куточок батьків → Сім’я → Приєднатися до сім’ї і скануй цей код. Обидва пристрої мають бути в одній мережі Wi-Fi.';

  @override
  String get familyDevices => 'Пристрої в сім’ї';

  @override
  String get familyThisDevice => 'цей пристрій';

  @override
  String get familyNeverSynced => 'ще не синхронізовано';

  @override
  String get familyRemove => 'Прибрати із сім’ї';

  @override
  String get familyRemoveMessage =>
      'Пристрій більше не отримуватиме профілі та бали. Дані, які вже на ньому є, залишаться.';

  @override
  String get familyRemoved => 'прибрано';

  @override
  String get familyJoined => 'Готово – ти в сім’ї!';

  @override
  String get familyJoinFailed =>
      'Не вдалося приєднатися до сім’ї. Обидва пристрої в одній мережі Wi-Fi, а на іншому відкрито «Сім’я»?';

  @override
  String get familyNotACode => 'Це не код сім’ї.';

  @override
  String get familyUpdateApps =>
      'На одному з пристроїв інша версія застосунку. Онови застосунок на всіх пристроях.';

  @override
  String get familyCodeInJoin =>
      'Це код сім’ї. Додай пристрій в Опції → Куточок батьків → Сім’я.';

  @override
  String get familySynced => 'Синхронізовано із сім’єю';

  @override
  String get deviceTablet => 'Планшет';

  @override
  String get devicePhone => 'Телефон';

  @override
  String familyLastSync(String time) {
    return 'остання синхронізація $time';
  }

  @override
  String familyRemoveTitle(String name) {
    return 'Прибрати $name із сім’ї?';
  }

  @override
  String get pairTitle => 'Поєднати профілі';

  @override
  String get pairQuestion => 'Це та сама людина?';

  @override
  String get pairMerge => 'Так, поєднати';

  @override
  String get pairKeep => 'Ні, це двоє';

  @override
  String get pairLook => 'Переглянути після поєднання';

  @override
  String get pairManual => 'Поєднати вручну';

  @override
  String get pairFirst => 'Профіль';

  @override
  String get pairSecond => 'належить до';

  @override
  String get pairNone => 'Більше пар немає.';

  @override
  String get refundTitle => 'Бали повернуто';

  @override
  String get refundOk => 'Зрозуміло';

  @override
  String familyPairs(int count) {
    return 'Можливі пари ($count)';
  }

  @override
  String refundNotice(String item) {
    return 'Твої бали за $item повернуто – на обидві покупки балів не вистачило.';
  }

  @override
  String get inviteFamily => 'Запросити із сім’ї';

  @override
  String get inviteSent => 'Запрошення надіслано.';

  @override
  String get inviteNoDevice => 'У мережі не знайдено жодного пристрою сім’ї.';

  @override
  String get invitePlay => 'Грати';

  @override
  String get inviteLater => 'Не зараз';

  @override
  String inviteTitle(String host, String game) {
    return '$host запрошує тебе в гру $game – граєш?';
  }

  @override
  String pointsRefundDuplicate(String item) {
    return 'Повернено: $item – куплено двічі';
  }

  @override
  String pointsRefundNotEnough(String item) {
    return 'Повернено: $item – не вистачило балів';
  }

  @override
  String get setupElsewhere => 'На іншому пристрої';

  @override
  String get setupBusyTag => 'В іншій грі';

  @override
  String get setupInvitePlay => 'Запросити й грати';

  @override
  String get slotInvited => 'Запрошено, чекаємо';

  @override
  String inviteFailed(String name) {
    return 'Не вдалося доставити запрошення гравцю $name.';
  }

  @override
  String get inviteNotHere => 'Немає у Wi-Fi';

  @override
  String get navDonations => 'Донат';

  @override
  String get donationsTitle => 'Підтримай Deskovky';

  @override
  String get donationsIntro =>
      'Deskovky створюється вдома, для сімей з дітьми. Гра безкоштовна і такою залишиться. Якщо вона приносить тобі радість, можеш добровільно підтримати її розвиток.';

  @override
  String get donationsFreeTitle => 'Уся гра безкоштовна';

  @override
  String get donationsFreeText =>
      'Жодних платних рівнів, нічого не відкривається за гроші.';

  @override
  String get donationsNoAdsTitle => 'Без реклами';

  @override
  String get donationsNoAdsText =>
      'Ніщо не відволікає дітей і не спокушає їх щось купити.';

  @override
  String get donationsNoDataTitle => 'Без збору даних';

  @override
  String get donationsNoDataText =>
      'Без облікових записів і входу. Профілі та результати залишаються на ваших пристроях.';

  @override
  String get donationsOfflineTitle => 'Безпечно без інтернету';

  @override
  String get donationsOfflineText =>
      'Грає офлайн і нікуди нічого про вас не надсилає. Інтернет потрібен лише для завантаження нової версії та списку тих, хто підтримав.';

  @override
  String get donationsFamilyTitle => 'Грає вся сім’я';

  @override
  String get donationsFamilyText =>
      'За одним столом або кожен на своєму пристрої через домашній Wi-Fi. Пристрої сім’ї діляться даними лише між собою.';

  @override
  String get donationsKidsTitle => 'І для наймолодших';

  @override
  String get donationsKidsText =>
      'Роботи трьох рівнів, правила з картинками, великі кнопки та куточок батьків.';

  @override
  String get donationsEveryoneTitle => 'Для всіх';

  @override
  String get donationsEveryoneText =>
      'Працює зі зчитувачем екрана, має позначки для людей з дальтонізмом і розмовляє десятьма мовами.';

  @override
  String get donationsGrowingTitle => 'Нові ігри з’являються';

  @override
  String get donationsGrowingText =>
      'Дев’ять ігор, і ще більше на підході – деякі побажали самі діти.';

  @override
  String get donationsWhy =>
      'Внесок допомагає оплатити час на створення нових ігор і збори Google Play.';

  @override
  String get donationsSoon =>
      'Підтримати можна буде, щойно гра з’явиться в Google Play. Дякуємо!';

  @override
  String get donationsThanks => 'Щиро дякуємо тим, хто нас підтримав:';

  @override
  String get donationsNobody => 'Тут ще нікого немає. Будеш першим?';

  @override
  String get familyRename => 'Перейменувати пристрій';

  @override
  String get familyOnline => 'Deskovky запущено';

  @override
  String get familyOffline => 'Недоступний';

  @override
  String familyPlaysNow(String name) {
    return 'Зараз грає $name';
  }

  @override
  String get settingsShareApp => 'Завантажити на інший пристрій';

  @override
  String get shareAppTitle => 'Deskovky на іншому пристрої';

  @override
  String get shareAppHint =>
      'Скануй код камерою іншого телефона чи планшета. Відкриється сторінка з найновішою версією: завантаж файл deskovky-….apk і відкрий його.';

  @override
  String get inviteToAllDevices => 'Запрошення прийде на всі пристрої в мережі';

  @override
  String get parentsReportBug => 'Повідомити про помилку';

  @override
  String get parentsReportBugHint =>
      'Відкриває форму на GitHub, де ти опишеш помилку. Повідомлення публічні: не пиши імена дітей чи інші особисті дані.';

  @override
  String get bugReportNoBrowser =>
      'Не вдалося відкрити браузер. Повідомити про помилку можна тут:';
}
