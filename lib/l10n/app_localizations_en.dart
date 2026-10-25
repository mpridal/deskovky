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
  String get fontSample => 'The quick brown fox jumps over the lazy dog';

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
  String get sampleTitle => 'Guess the number';

  @override
  String get sampleDescription => 'Who guesses the secret number first?';

  @override
  String get sampleRules =>
      'The game hides a number. Players take turns guessing. After each guess you learn whether the secret number is higher or lower. Whoever hits it wins!';

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
  String get sampleOptionRange => 'Number range';

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
  String get sampleHigher => 'Higher!';

  @override
  String get sampleLower => 'Lower!';

  @override
  String sampleTurnHint(String name, int low, int high) {
    return '$name, guess a number from $low to $high';
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
  String get sampleBadgeBullseyeTitle => 'Bullseye!';

  @override
  String get sampleBadgeBullseyeDescription =>
      'Guess the number with your first tip.';

  @override
  String get resultNewBadges => 'New badges';
}
