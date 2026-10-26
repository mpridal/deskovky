// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Deskovky';

  @override
  String get navGames => 'Games';

  @override
  String get navPlayers => 'Players';

  @override
  String get navLeaderboards => 'Rankings';

  @override
  String get navSettings => 'Settings';

  @override
  String get comingSoon => 'Soon';

  @override
  String get panelPlayersOnDevice => 'Players on this device';

  @override
  String get panelLeaderboardWeek => 'This week\'s leaderboard';

  @override
  String get panelLastReward => 'Latest reward';

  @override
  String get screenEmpty => 'Nothing here yet.';

  @override
  String playersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '$count player',
    );
    return '$_temp0';
  }

  @override
  String get avatarEditorTitle => 'My avatar';

  @override
  String get avatarSave => 'Save';

  @override
  String get avatarRandom => 'Random';

  @override
  String get back => 'Back';

  @override
  String get avatarTabFace => 'Face';

  @override
  String get avatarTabSkin => 'Skin';

  @override
  String get avatarTabHair => 'Hair';

  @override
  String get avatarTabEyes => 'Eyes';

  @override
  String get avatarTabMouth => 'Mouth';

  @override
  String get avatarTabBackground => 'Background';

  @override
  String get avatarHairColor => 'Hair colour';

  @override
  String get faceOval => 'oval';

  @override
  String get faceRound => 'round';

  @override
  String get faceWide => 'wide';

  @override
  String get faceSquare => 'square';

  @override
  String get hairShort => 'short';

  @override
  String get hairLong => 'long';

  @override
  String get hairCurly => 'curly';

  @override
  String get hairBun => 'bun';

  @override
  String get hairSpiky => 'spiky';

  @override
  String get hairPigtails => 'pigtails';

  @override
  String get hairBob => 'bob';

  @override
  String get hairBraids => 'braids';

  @override
  String get hairCap => 'cap';

  @override
  String get hairBald => 'bald';

  @override
  String get eyesRound => 'round';

  @override
  String get eyesHappy => 'happy';

  @override
  String get eyesWink => 'winking';

  @override
  String get eyesSleepy => 'sleepy';

  @override
  String get eyesWide => 'wide open';

  @override
  String get eyesLashes => 'with lashes';

  @override
  String get mouthSmile => 'smile';

  @override
  String get mouthOpen => 'open';

  @override
  String get mouthFlat => 'straight';

  @override
  String get mouthGrin => 'grin';

  @override
  String get mouthTongue => 'tongue out';

  @override
  String get mouthSurprised => 'surprised';

  @override
  String get hairColorBlack => 'black';

  @override
  String get hairColorBrown => 'brown';

  @override
  String get hairColorChestnut => 'chestnut';

  @override
  String get hairColorBlond => 'blond';

  @override
  String get hairColorPlatinum => 'platinum';

  @override
  String get hairColorRed => 'red';

  @override
  String get hairColorGrey => 'grey';

  @override
  String get hairColorBlue => 'blue';

  @override
  String skinTone(int n) {
    return 'Skin tone $n';
  }

  @override
  String backgroundColor(int n) {
    return 'Background $n';
  }

  @override
  String get playersNew => 'New player';

  @override
  String get playersLimit => 'This device can have at most 8 players.';

  @override
  String get playersEmpty => 'Nobody here yet. Create the first player!';

  @override
  String playersNowPlaying(String name) {
    return '$name is playing now';
  }

  @override
  String get playerActiveTag => 'Playing';

  @override
  String playerEdit(String name) {
    return 'Edit $name';
  }

  @override
  String playerDelete(String name) {
    return 'Delete $name';
  }

  @override
  String get profileName => 'Name';

  @override
  String get profileErrorEmpty => 'Enter a name.';

  @override
  String get profileErrorTooLong => '16 characters at most.';

  @override
  String get profileErrorTaken => 'Another player already has this name.';

  @override
  String get profileErrorLimit => 'This device can have at most 8 players.';

  @override
  String deleteTitle(String name) {
    return 'Delete player $name?';
  }

  @override
  String get deleteMessage =>
      'Their results will be deleted too. This cannot be undone.';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get discardTitle => 'Discard changes?';

  @override
  String get discardMessage =>
      'Your avatar and name changes will not be saved.';

  @override
  String get discardConfirm => 'Discard';

  @override
  String get cancel => 'Cancel';

  @override
  String get homeHello => 'Hi,';

  @override
  String get homeSwitchPlayer => 'Switch player';

  @override
  String get homeCreatePlayer => 'Create a player';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Phone setting';

  @override
  String gamePlayersRange(int min, int max) {
    return '$min–$max players';
  }

  @override
  String continueTitle(String game) {
    return 'Continue: $game';
  }

  @override
  String get continueSaved => 'Game in progress';

  @override
  String continueSummary(String players, String difficulty) {
    return '$players · $difficulty';
  }

  @override
  String seatSummary(String players, int humans, int robots) {
    return '$players ($humans + $robots 🤖)';
  }

  @override
  String get continuePlay => 'Play ▸';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get setupPlayers => 'Number of players';

  @override
  String seatsHumans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '$count person',
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
  String get setupDifficulty => 'Robot difficulty';

  @override
  String get setupSpeed => 'Robot speed';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get seatHuman => 'Human';

  @override
  String get seatRobot => '🤖 Robot';

  @override
  String get setupLoaded => '↺ Settings loaded from your last game';

  @override
  String get setupFilled => 'free seats filled with robots';

  @override
  String get setupNoFreeProfile => 'All players are already at the table.';

  @override
  String get seatMoveUp => 'Move up';

  @override
  String get seatMoveDown => 'Move down';

  @override
  String get setupPlay => 'Play!';

  @override
  String get setupNeedPlayer => 'Create a player first.';

  @override
  String get robotName0 => 'Robo';

  @override
  String get robotName1 => 'Chip';

  @override
  String get robotName2 => 'Bolt';

  @override
  String get robotName3 => 'Buzz';

  @override
  String get hudExit => 'Exit';

  @override
  String get hudPause => 'Pause';

  @override
  String get hudMusic => 'Music';

  @override
  String get hudSfx => 'Sound effects';

  @override
  String get exitTitle => 'Really quit?';

  @override
  String get exitSaved => 'The game in progress will be saved.';

  @override
  String get exitNotSaved => 'The game in progress will not be saved.';

  @override
  String get exitConfirm => 'Quit';

  @override
  String get pauseResume => 'Continue';

  @override
  String get pauseRestart => 'Start again';

  @override
  String get pauseRules => 'Rules';

  @override
  String get close => 'Close';

  @override
  String turnOf(String name) {
    return '$name\'s turn';
  }

  @override
  String robotThinking(String name) {
    return '🤖 $name is thinking…';
  }

  @override
  String get resumeFailed => 'The saved game cannot be continued.';

  @override
  String resultWins(String name) {
    return '$name wins!';
  }

  @override
  String get resultDraw => 'It\'s a draw!';

  @override
  String get resultPlayAgain => 'Play again';

  @override
  String get resultChangeSettings => 'Change settings';

  @override
  String get resultHome => 'Home';

  @override
  String get resultRobotTag => 'robot';

  @override
  String resultSubtitle(String game, String difficulty) {
    return '$game · $difficulty';
  }

  @override
  String get seatReplacedByRobot => 'Missing players were replaced by robots.';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsMusicVolume => 'Music volume';

  @override
  String get settingsSfx => 'Sound effects';

  @override
  String get settingsSfxVolume => 'Effects volume';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsCredits => 'Credits and licences';

  @override
  String get creditsSounds => 'Music and sounds';

  @override
  String get creditsFonts => 'Fonts';

  @override
  String get creditsLibraries => 'Library licences';

  @override
  String creditsLicense(String license) {
    return 'Licence: $license';
  }

  @override
  String get badgeFirstWinTitle => 'First win';

  @override
  String get badgeFirstWinDescription => 'Win your first game.';

  @override
  String get badgeStreak5Title => 'Five in a row';

  @override
  String get badgeStreak5Description => 'Win 5 games in a row.';

  @override
  String get badgeGames10Title => 'Ten games';

  @override
  String get badgeGames10Description => 'Play 10 games.';

  @override
  String get badgeHardWinTitle => 'Robot tamer';

  @override
  String get badgeHardWinDescription => 'Beat the robots on Hard.';

  @override
  String get badgeAllGamesTitle => 'Explorer';

  @override
  String get badgeAllGamesDescription => 'Play every game.';

  @override
  String get resultNewBadges => 'New badges';

  @override
  String get leaderboardWeek => 'Week';

  @override
  String get leaderboardMonth => 'Month';

  @override
  String get leaderboardAllTime => 'All time';

  @override
  String get leaderboardAllGames => 'All games';

  @override
  String get leaderboardAnyDifficulty => 'Any difficulty';

  @override
  String get leaderboardEmpty => 'Nobody here yet. Finish a game!';

  @override
  String leaderboardWins(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wins',
      one: '$count win',
    );
    return '$_temp0';
  }

  @override
  String leaderboardDetail(int played, int rate) {
    String _temp0 = intl.Intl.pluralLogic(
      played,
      locale: localeName,
      other: '$played games',
      one: '$played game',
    );
    return '$_temp0 · $rate%';
  }

  @override
  String playerStats(String name) {
    return 'Stats: $name';
  }

  @override
  String get statsPlayed => 'Played';

  @override
  String get statsWins => 'Wins';

  @override
  String get statsWinRate => 'Win rate';

  @override
  String get statsBestStreak => 'Best streak';

  @override
  String get statsCurrentStreak => 'Current streak';

  @override
  String get statsByGame => 'By game';

  @override
  String statsBestScore(int score) {
    return 'Best score: $score';
  }

  @override
  String statsFastestWin(String time) {
    return 'Fastest win: $time';
  }

  @override
  String get statsBadges => 'Badges';

  @override
  String statsBadgeEarned(String date) {
    return 'Earned $date';
  }

  @override
  String get statsNoGames => 'No finished games yet.';

  @override
  String homeBestStars(int stars) {
    return 'Best rating: $stars of 3 stars';
  }

  @override
  String get resultPoints => 'Points';

  @override
  String get pointsWin => 'Win';

  @override
  String get pointsDraw => 'Draw';

  @override
  String get pointsSecond => '2nd place';

  @override
  String get pointsParticipation => 'Taking part';

  @override
  String pointsStars(int count) {
    return 'Rating $count ★';
  }

  @override
  String pointsStreak(int count) {
    return '$count wins in a row';
  }

  @override
  String get pointsFirstToday => 'First game today';

  @override
  String get pointsRecord => 'New personal best';

  @override
  String pointsBadge(String name) {
    return 'Badge: $name';
  }

  @override
  String get pointsCapped => 'Lots of Easy wins today';

  @override
  String get pointsGift => 'Gift from a parent';

  @override
  String get pointsPurchase => 'Purchase';

  @override
  String pointsTotal(int points) {
    return 'Total +$points ●';
  }

  @override
  String levelUp(int level) {
    return 'New level $level!';
  }

  @override
  String homePointsBalance(int points) {
    return 'Points: $points';
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
    return '$current / $needed ● to the next level';
  }

  @override
  String get levelMax => 'Top level!';

  @override
  String get statsBalance => 'Balance';

  @override
  String get statsTotalEarned => 'Total earned';

  @override
  String get statsPointsHistory => 'Points history';

  @override
  String get settingsParents => 'Parents\' corner';

  @override
  String get parentsGateTitle => 'Parents only';

  @override
  String parentsGateQuestion(int a, int b) {
    return 'What is $a × $b?';
  }

  @override
  String get parentsGateWrong => 'That is not right.';

  @override
  String get parentsGateOpen => 'Open';

  @override
  String get parentsGiftTitle => 'Give points';

  @override
  String parentsGiftConfirm(int points, String name) {
    return 'Give $points ● to $name?';
  }

  @override
  String get parentsGiftAction => 'Give';

  @override
  String parentsGiftDone(int points, String name) {
    return 'Given: $points ● – $name';
  }

  @override
  String updateAvailable(String version) {
    return 'New version $version is here';
  }

  @override
  String get updateNow => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String updateDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get updateMandatory => 'This version is too old – please update.';

  @override
  String get updateFailed => 'The download failed. Try again later.';

  @override
  String get updatePermissionTitle => 'One more permission';

  @override
  String get updatePermissionText =>
      'Android will ask whether Deskovky may install apps. It is only for the new Deskovky version. Ask a grown-up to turn the switch on, then come back here.';

  @override
  String get updatePermissionOpen => 'Open settings';

  @override
  String get settingsApp => 'App';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsCheckNow => 'Check for updates now';

  @override
  String get settingsAutoUpdate => 'Check automatically';

  @override
  String get updateUpToDate => 'You have the newest version.';

  @override
  String get updateCheckFailed => 'The check failed – is the device online?';

  @override
  String get itemCap => 'Cap';

  @override
  String get itemEarsHeadband => 'Ear headband';

  @override
  String get itemFlowerWreath => 'Flower wreath';

  @override
  String get itemTopHat => 'Top hat';

  @override
  String get itemVikingHelmet => 'Viking helmet';

  @override
  String get itemPirateBandana => 'Pirate bandana';

  @override
  String get itemWizardHat => 'Wizard hat';

  @override
  String get itemCrown => 'Crown';

  @override
  String get itemHalo => 'Halo';

  @override
  String get itemGlasses => 'Glasses';

  @override
  String get itemMustache => 'Moustache';

  @override
  String get itemFacePaintStar => 'Star face paint';

  @override
  String get itemSunglasses => 'Sunglasses';

  @override
  String get itemHeroMask => 'Hero mask';

  @override
  String get itemMonocle => 'Monocle';

  @override
  String get itemCarnivalMask => 'Carnival mask';

  @override
  String get itemLollipop => 'Lollipop';

  @override
  String get itemBalloon => 'Balloon';

  @override
  String get itemIceCream => 'Ice cream';

  @override
  String get itemPhone => 'Phone';

  @override
  String get itemMicrophone => 'Microphone';

  @override
  String get itemMagicWand => 'Magic wand';

  @override
  String get itemTrophy => 'Trophy';

  @override
  String get itemKitten => 'Kitten';

  @override
  String get itemChick => 'Chick';

  @override
  String get itemPuppy => 'Puppy';

  @override
  String get itemParrot => 'Parrot';

  @override
  String get itemDragon => 'Little dragon';

  @override
  String get itemWoodFrame => 'Wooden frame';

  @override
  String get itemGoldFrame => 'Gold frame';

  @override
  String get itemRainbowFrame => 'Rainbow frame';

  @override
  String get itemFlameFrame => 'Flame frame';

  @override
  String get itemStarFrame => 'Star frame';

  @override
  String get itemSparkles => 'Sparkles';

  @override
  String get itemBubbles => 'Bubbles';

  @override
  String get itemSnow => 'Snowfall';

  @override
  String get pointsReset => 'A parent reset the points';

  @override
  String get badgeWins50Title => 'Fifty';

  @override
  String get badgeWins50Description =>
      'Win 50 games. Reward: a trophy to hold.';

  @override
  String get badgeAllHardTitle => 'Master of all games';

  @override
  String get badgeAllHardDescription =>
      'Beat the robots on Hard in every game. Reward: a star frame.';

  @override
  String get badgeCollectorTitle => 'Collector';

  @override
  String get badgeCollectorDescription => 'Buy 10 avatar upgrades.';

  @override
  String get shopTitle => 'Shop';

  @override
  String shopTryOn(String name) {
    return 'Trying on: $name';
  }

  @override
  String get shopAll => 'All';

  @override
  String get slotHead => 'Head';

  @override
  String get slotFace => 'Face';

  @override
  String get slotHand => 'Hand';

  @override
  String get slotPet => 'Pet';

  @override
  String get slotFrame => 'Frame';

  @override
  String get slotEffect => 'Effect';

  @override
  String shopBuy(int price) {
    return 'Buy for $price ●';
  }

  @override
  String shopBuyConfirm(String name, int price) {
    return 'Buy $name for $price ●?';
  }

  @override
  String get shopBuyAction => 'Buy';

  @override
  String shopMissing(int points) {
    return 'You need $points more ●';
  }

  @override
  String shopLevelLock(int level) {
    return '🔒 Level $level';
  }

  @override
  String shopBadgeLock(String name) {
    return '🔒 Badge: $name';
  }

  @override
  String get shopOwned => 'Owned';

  @override
  String get shopEquipped => 'Wearing';

  @override
  String get shopEquipNow => 'Wear it now?';

  @override
  String get shopEquip => 'Wear';

  @override
  String get shopUnequip => 'Take off';

  @override
  String get shopNotNow => 'Not now';

  @override
  String shopNextLevel(int level, int next, int points) {
    return 'Level $level → $next · $points points to go';
  }

  @override
  String shopPlayerLevel(String name, int level) {
    return '$name · Level $level';
  }

  @override
  String get wardrobeTitle => 'Wardrobe';

  @override
  String get wardrobeEmpty => 'Nothing here yet. Buy upgrades in the shop.';

  @override
  String get wardrobeToShop => 'To the shop';

  @override
  String wardrobeColour(String name) {
    return 'Colour: $name';
  }

  @override
  String get colourGold => 'gold';

  @override
  String get colourSilver => 'silver';

  @override
  String get colourRed => 'red';

  @override
  String get colourBlue => 'blue';

  @override
  String get colourGreen => 'green';

  @override
  String get colourYellow => 'yellow';

  @override
  String get colourBrown => 'brown';

  @override
  String get parentsResetTitle => 'Reset points and upgrades';

  @override
  String get parentsReset => 'Reset';

  @override
  String parentsResetConfirm(String name, int points) {
    return '$name will lose $points ● and all bought upgrades. Level and badges stay.';
  }

  @override
  String parentsResetDone(String name) {
    return '$name: points and upgrades reset.';
  }

  @override
  String resultCanBuy(String name, String item) {
    return '$name, now you can buy: $item!';
  }

  @override
  String pointsPurchaseItem(String item) {
    return 'Purchase: $item';
  }

  @override
  String shopNewBadge(String badge) {
    return 'New badge: $badge!';
  }

  @override
  String shopNewBadgeReward(String description, int points) {
    return '$description Reward +$points ●.';
  }

  @override
  String get shopHooray => 'Hooray!';

  @override
  String get shopNotEnough => 'You don\'t have enough points for that now.';

  @override
  String get shopFailed => 'That didn\'t work. Try again.';

  @override
  String get updatePreparing => 'Preparing the update…';

  @override
  String get setupDifficultySolo => 'Difficulty';
}
