import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Deskovky'**
  String get appTitle;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get navGames;

  /// No description provided for @navPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navPlayers;

  /// No description provided for @navLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get navLeaderboards;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get comingSoon;

  /// No description provided for @panelPlayersOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Players on this device'**
  String get panelPlayersOnDevice;

  /// No description provided for @panelLeaderboardWeek.
  ///
  /// In en, this message translates to:
  /// **'This week\'s leaderboard'**
  String get panelLeaderboardWeek;

  /// No description provided for @panelLastReward.
  ///
  /// In en, this message translates to:
  /// **'Latest reward'**
  String get panelLastReward;

  /// No description provided for @screenEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get screenEmpty;

  /// No description provided for @fontSample.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog'**
  String get fontSample;

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} player} other{{count} players}}'**
  String playersCount(int count);

  /// No description provided for @avatarEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'My avatar'**
  String get avatarEditorTitle;

  /// No description provided for @avatarSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get avatarSave;

  /// No description provided for @avatarRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get avatarRandom;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @avatarTabFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get avatarTabFace;

  /// No description provided for @avatarTabSkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get avatarTabSkin;

  /// No description provided for @avatarTabHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get avatarTabHair;

  /// No description provided for @avatarTabEyes.
  ///
  /// In en, this message translates to:
  /// **'Eyes'**
  String get avatarTabEyes;

  /// No description provided for @avatarTabMouth.
  ///
  /// In en, this message translates to:
  /// **'Mouth'**
  String get avatarTabMouth;

  /// No description provided for @avatarTabBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get avatarTabBackground;

  /// No description provided for @avatarHairColor.
  ///
  /// In en, this message translates to:
  /// **'Hair colour'**
  String get avatarHairColor;

  /// No description provided for @faceOval.
  ///
  /// In en, this message translates to:
  /// **'oval'**
  String get faceOval;

  /// No description provided for @faceRound.
  ///
  /// In en, this message translates to:
  /// **'round'**
  String get faceRound;

  /// No description provided for @faceWide.
  ///
  /// In en, this message translates to:
  /// **'wide'**
  String get faceWide;

  /// No description provided for @faceSquare.
  ///
  /// In en, this message translates to:
  /// **'square'**
  String get faceSquare;

  /// No description provided for @hairShort.
  ///
  /// In en, this message translates to:
  /// **'short'**
  String get hairShort;

  /// No description provided for @hairLong.
  ///
  /// In en, this message translates to:
  /// **'long'**
  String get hairLong;

  /// No description provided for @hairCurly.
  ///
  /// In en, this message translates to:
  /// **'curly'**
  String get hairCurly;

  /// No description provided for @hairBun.
  ///
  /// In en, this message translates to:
  /// **'bun'**
  String get hairBun;

  /// No description provided for @hairSpiky.
  ///
  /// In en, this message translates to:
  /// **'spiky'**
  String get hairSpiky;

  /// No description provided for @hairPigtails.
  ///
  /// In en, this message translates to:
  /// **'pigtails'**
  String get hairPigtails;

  /// No description provided for @hairBob.
  ///
  /// In en, this message translates to:
  /// **'bob'**
  String get hairBob;

  /// No description provided for @hairBraids.
  ///
  /// In en, this message translates to:
  /// **'braids'**
  String get hairBraids;

  /// No description provided for @hairCap.
  ///
  /// In en, this message translates to:
  /// **'cap'**
  String get hairCap;

  /// No description provided for @hairBald.
  ///
  /// In en, this message translates to:
  /// **'bald'**
  String get hairBald;

  /// No description provided for @eyesRound.
  ///
  /// In en, this message translates to:
  /// **'round'**
  String get eyesRound;

  /// No description provided for @eyesHappy.
  ///
  /// In en, this message translates to:
  /// **'happy'**
  String get eyesHappy;

  /// No description provided for @eyesWink.
  ///
  /// In en, this message translates to:
  /// **'winking'**
  String get eyesWink;

  /// No description provided for @eyesSleepy.
  ///
  /// In en, this message translates to:
  /// **'sleepy'**
  String get eyesSleepy;

  /// No description provided for @eyesWide.
  ///
  /// In en, this message translates to:
  /// **'wide open'**
  String get eyesWide;

  /// No description provided for @eyesLashes.
  ///
  /// In en, this message translates to:
  /// **'with lashes'**
  String get eyesLashes;

  /// No description provided for @mouthSmile.
  ///
  /// In en, this message translates to:
  /// **'smile'**
  String get mouthSmile;

  /// No description provided for @mouthOpen.
  ///
  /// In en, this message translates to:
  /// **'open'**
  String get mouthOpen;

  /// No description provided for @mouthFlat.
  ///
  /// In en, this message translates to:
  /// **'straight'**
  String get mouthFlat;

  /// No description provided for @mouthGrin.
  ///
  /// In en, this message translates to:
  /// **'grin'**
  String get mouthGrin;

  /// No description provided for @mouthTongue.
  ///
  /// In en, this message translates to:
  /// **'tongue out'**
  String get mouthTongue;

  /// No description provided for @mouthSurprised.
  ///
  /// In en, this message translates to:
  /// **'surprised'**
  String get mouthSurprised;

  /// No description provided for @hairColorBlack.
  ///
  /// In en, this message translates to:
  /// **'black'**
  String get hairColorBlack;

  /// No description provided for @hairColorBrown.
  ///
  /// In en, this message translates to:
  /// **'brown'**
  String get hairColorBrown;

  /// No description provided for @hairColorChestnut.
  ///
  /// In en, this message translates to:
  /// **'chestnut'**
  String get hairColorChestnut;

  /// No description provided for @hairColorBlond.
  ///
  /// In en, this message translates to:
  /// **'blond'**
  String get hairColorBlond;

  /// No description provided for @hairColorPlatinum.
  ///
  /// In en, this message translates to:
  /// **'platinum'**
  String get hairColorPlatinum;

  /// No description provided for @hairColorRed.
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get hairColorRed;

  /// No description provided for @hairColorGrey.
  ///
  /// In en, this message translates to:
  /// **'grey'**
  String get hairColorGrey;

  /// No description provided for @hairColorBlue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get hairColorBlue;

  /// No description provided for @skinTone.
  ///
  /// In en, this message translates to:
  /// **'Skin tone {n}'**
  String skinTone(int n);

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background {n}'**
  String backgroundColor(int n);

  /// No description provided for @playersNew.
  ///
  /// In en, this message translates to:
  /// **'New player'**
  String get playersNew;

  /// No description provided for @playersLimit.
  ///
  /// In en, this message translates to:
  /// **'This device can have at most 8 players.'**
  String get playersLimit;

  /// No description provided for @playersEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet. Create the first player!'**
  String get playersEmpty;

  /// No description provided for @playersNowPlaying.
  ///
  /// In en, this message translates to:
  /// **'{name} is playing now'**
  String playersNowPlaying(String name);

  /// No description provided for @playerActiveTag.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playerActiveTag;

  /// No description provided for @playerEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String playerEdit(String name);

  /// No description provided for @playerDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String playerDelete(String name);

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get profileErrorEmpty;

  /// No description provided for @profileErrorTooLong.
  ///
  /// In en, this message translates to:
  /// **'16 characters at most.'**
  String get profileErrorTooLong;

  /// No description provided for @profileErrorTaken.
  ///
  /// In en, this message translates to:
  /// **'Another player already has this name.'**
  String get profileErrorTaken;

  /// No description provided for @profileErrorLimit.
  ///
  /// In en, this message translates to:
  /// **'This device can have at most 8 players.'**
  String get profileErrorLimit;

  /// No description provided for @deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete player {name}?'**
  String deleteTitle(String name);

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Their results will be deleted too. This cannot be undone.'**
  String get deleteMessage;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In en, this message translates to:
  /// **'Your avatar and name changes will not be saved.'**
  String get discardMessage;

  /// No description provided for @discardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hi,'**
  String get homeHello;

  /// No description provided for @homeSwitchPlayer.
  ///
  /// In en, this message translates to:
  /// **'Switch player'**
  String get homeSwitchPlayer;

  /// No description provided for @homeCreatePlayer.
  ///
  /// In en, this message translates to:
  /// **'Create a player'**
  String get homeCreatePlayer;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone setting'**
  String get settingsLanguageSystem;

  /// No description provided for @sampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Guess the number'**
  String get sampleTitle;

  /// No description provided for @sampleDescription.
  ///
  /// In en, this message translates to:
  /// **'Who guesses the secret number first?'**
  String get sampleDescription;

  /// No description provided for @sampleRules.
  ///
  /// In en, this message translates to:
  /// **'The game hides a number. Players take turns guessing. After each guess you learn whether the secret number is higher or lower. Whoever hits it wins!'**
  String get sampleRules;

  /// No description provided for @gamePlayersRange.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} players'**
  String gamePlayersRange(int min, int max);

  /// No description provided for @continueTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue: {game}'**
  String continueTitle(String game);

  /// No description provided for @continueSaved.
  ///
  /// In en, this message translates to:
  /// **'Game in progress'**
  String get continueSaved;

  /// No description provided for @continueSummary.
  ///
  /// In en, this message translates to:
  /// **'{players} · {difficulty}'**
  String continueSummary(String players, String difficulty);

  /// No description provided for @seatSummary.
  ///
  /// In en, this message translates to:
  /// **'{players} ({humans} + {robots} 🤖)'**
  String seatSummary(String players, int humans, int robots);

  /// No description provided for @continuePlay.
  ///
  /// In en, this message translates to:
  /// **'Play ▸'**
  String get continuePlay;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @sampleOptionRange.
  ///
  /// In en, this message translates to:
  /// **'Number range'**
  String get sampleOptionRange;

  /// No description provided for @setupPlayers.
  ///
  /// In en, this message translates to:
  /// **'Number of players'**
  String get setupPlayers;

  /// No description provided for @seatsHumans.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} person} other{{count} people}}'**
  String seatsHumans(int count);

  /// No description provided for @seatsRobots.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} robot} other{{count} robots}}'**
  String seatsRobots(int count);

  /// No description provided for @setupDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Robot difficulty'**
  String get setupDifficulty;

  /// No description provided for @setupSpeed.
  ///
  /// In en, this message translates to:
  /// **'Robot speed'**
  String get setupSpeed;

  /// No description provided for @speedSlow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get speedSlow;

  /// No description provided for @speedNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// No description provided for @speedFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get speedFast;

  /// No description provided for @seatHuman.
  ///
  /// In en, this message translates to:
  /// **'Human'**
  String get seatHuman;

  /// No description provided for @seatRobot.
  ///
  /// In en, this message translates to:
  /// **'🤖 Robot'**
  String get seatRobot;

  /// No description provided for @setupLoaded.
  ///
  /// In en, this message translates to:
  /// **'↺ Settings loaded from your last game'**
  String get setupLoaded;

  /// No description provided for @setupFilled.
  ///
  /// In en, this message translates to:
  /// **'free seats filled with robots'**
  String get setupFilled;

  /// No description provided for @setupNoFreeProfile.
  ///
  /// In en, this message translates to:
  /// **'All players are already at the table.'**
  String get setupNoFreeProfile;

  /// No description provided for @seatMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get seatMoveUp;

  /// No description provided for @seatMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get seatMoveDown;

  /// No description provided for @setupPlay.
  ///
  /// In en, this message translates to:
  /// **'Play!'**
  String get setupPlay;

  /// No description provided for @setupNeedPlayer.
  ///
  /// In en, this message translates to:
  /// **'Create a player first.'**
  String get setupNeedPlayer;

  /// No description provided for @robotName0.
  ///
  /// In en, this message translates to:
  /// **'Robo'**
  String get robotName0;

  /// No description provided for @robotName1.
  ///
  /// In en, this message translates to:
  /// **'Chip'**
  String get robotName1;

  /// No description provided for @robotName2.
  ///
  /// In en, this message translates to:
  /// **'Bolt'**
  String get robotName2;

  /// No description provided for @robotName3.
  ///
  /// In en, this message translates to:
  /// **'Buzz'**
  String get robotName3;

  /// No description provided for @hudExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get hudExit;

  /// No description provided for @hudPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get hudPause;

  /// No description provided for @hudMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get hudMusic;

  /// No description provided for @hudSfx.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get hudSfx;

  /// No description provided for @exitTitle.
  ///
  /// In en, this message translates to:
  /// **'Really quit?'**
  String get exitTitle;

  /// No description provided for @exitSaved.
  ///
  /// In en, this message translates to:
  /// **'The game in progress will be saved.'**
  String get exitSaved;

  /// No description provided for @exitNotSaved.
  ///
  /// In en, this message translates to:
  /// **'The game in progress will not be saved.'**
  String get exitNotSaved;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get exitConfirm;

  /// No description provided for @pauseResume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get pauseResume;

  /// No description provided for @pauseRestart.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get pauseRestart;

  /// No description provided for @pauseRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get pauseRules;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @turnOf.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s turn'**
  String turnOf(String name);

  /// No description provided for @robotThinking.
  ///
  /// In en, this message translates to:
  /// **'🤖 {name} is thinking…'**
  String robotThinking(String name);

  /// No description provided for @resumeFailed.
  ///
  /// In en, this message translates to:
  /// **'The saved game cannot be continued.'**
  String get resumeFailed;

  /// No description provided for @resultWins.
  ///
  /// In en, this message translates to:
  /// **'{name} wins!'**
  String resultWins(String name);

  /// No description provided for @resultDraw.
  ///
  /// In en, this message translates to:
  /// **'It\'s a draw!'**
  String get resultDraw;

  /// No description provided for @resultPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get resultPlayAgain;

  /// No description provided for @resultChangeSettings.
  ///
  /// In en, this message translates to:
  /// **'Change settings'**
  String get resultChangeSettings;

  /// No description provided for @resultHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get resultHome;

  /// No description provided for @resultRobotTag.
  ///
  /// In en, this message translates to:
  /// **'robot'**
  String get resultRobotTag;

  /// No description provided for @resultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{game} · {difficulty}'**
  String resultSubtitle(String game, String difficulty);

  /// No description provided for @sampleHigher.
  ///
  /// In en, this message translates to:
  /// **'Higher!'**
  String get sampleHigher;

  /// No description provided for @sampleLower.
  ///
  /// In en, this message translates to:
  /// **'Lower!'**
  String get sampleLower;

  /// No description provided for @sampleTurnHint.
  ///
  /// In en, this message translates to:
  /// **'{name}, guess a number from {low} to {high}'**
  String sampleTurnHint(String name, int low, int high);

  /// No description provided for @seatReplacedByRobot.
  ///
  /// In en, this message translates to:
  /// **'Missing players were replaced by robots.'**
  String get seatReplacedByRobot;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsMusicVolume.
  ///
  /// In en, this message translates to:
  /// **'Music volume'**
  String get settingsMusicVolume;

  /// No description provided for @settingsSfx.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSfx;

  /// No description provided for @settingsSfxVolume.
  ///
  /// In en, this message translates to:
  /// **'Effects volume'**
  String get settingsSfxVolume;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits and licences'**
  String get settingsCredits;

  /// No description provided for @creditsSounds.
  ///
  /// In en, this message translates to:
  /// **'Music and sounds'**
  String get creditsSounds;

  /// No description provided for @creditsFonts.
  ///
  /// In en, this message translates to:
  /// **'Fonts'**
  String get creditsFonts;

  /// No description provided for @creditsLibraries.
  ///
  /// In en, this message translates to:
  /// **'Library licences'**
  String get creditsLibraries;

  /// No description provided for @creditsLicense.
  ///
  /// In en, this message translates to:
  /// **'Licence: {license}'**
  String creditsLicense(String license);

  /// No description provided for @badgeFirstWinTitle.
  ///
  /// In en, this message translates to:
  /// **'First win'**
  String get badgeFirstWinTitle;

  /// No description provided for @badgeFirstWinDescription.
  ///
  /// In en, this message translates to:
  /// **'Win your first game.'**
  String get badgeFirstWinDescription;

  /// No description provided for @badgeStreak5Title.
  ///
  /// In en, this message translates to:
  /// **'Five in a row'**
  String get badgeStreak5Title;

  /// No description provided for @badgeStreak5Description.
  ///
  /// In en, this message translates to:
  /// **'Win 5 games in a row.'**
  String get badgeStreak5Description;

  /// No description provided for @badgeGames10Title.
  ///
  /// In en, this message translates to:
  /// **'Ten games'**
  String get badgeGames10Title;

  /// No description provided for @badgeGames10Description.
  ///
  /// In en, this message translates to:
  /// **'Play 10 games.'**
  String get badgeGames10Description;

  /// No description provided for @badgeHardWinTitle.
  ///
  /// In en, this message translates to:
  /// **'Robot tamer'**
  String get badgeHardWinTitle;

  /// No description provided for @badgeHardWinDescription.
  ///
  /// In en, this message translates to:
  /// **'Beat the robots on Hard.'**
  String get badgeHardWinDescription;

  /// No description provided for @badgeAllGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get badgeAllGamesTitle;

  /// No description provided for @badgeAllGamesDescription.
  ///
  /// In en, this message translates to:
  /// **'Play every game.'**
  String get badgeAllGamesDescription;

  /// No description provided for @sampleBadgeBullseyeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bullseye!'**
  String get sampleBadgeBullseyeTitle;

  /// No description provided for @sampleBadgeBullseyeDescription.
  ///
  /// In en, this message translates to:
  /// **'Guess the number with your first tip.'**
  String get sampleBadgeBullseyeDescription;

  /// No description provided for @resultNewBadges.
  ///
  /// In en, this message translates to:
  /// **'New badges'**
  String get resultNewBadges;

  /// No description provided for @leaderboardWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get leaderboardWeek;

  /// No description provided for @leaderboardMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get leaderboardMonth;

  /// No description provided for @leaderboardAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get leaderboardAllTime;

  /// No description provided for @leaderboardAllGames.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get leaderboardAllGames;

  /// No description provided for @leaderboardAnyDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Any difficulty'**
  String get leaderboardAnyDifficulty;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody here yet. Finish a game!'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardWins.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} win} other{{count} wins}}'**
  String leaderboardWins(int count);

  /// No description provided for @leaderboardDetail.
  ///
  /// In en, this message translates to:
  /// **'{played, plural, one{{played} game} other{{played} games}} · {rate}%'**
  String leaderboardDetail(int played, int rate);

  /// No description provided for @playerStats.
  ///
  /// In en, this message translates to:
  /// **'Stats: {name}'**
  String playerStats(String name);

  /// No description provided for @statsPlayed.
  ///
  /// In en, this message translates to:
  /// **'Played'**
  String get statsPlayed;

  /// No description provided for @statsWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get statsWins;

  /// No description provided for @statsWinRate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get statsWinRate;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statsBestStreak;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsByGame.
  ///
  /// In en, this message translates to:
  /// **'By game'**
  String get statsByGame;

  /// No description provided for @statsBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}'**
  String statsBestScore(int score);

  /// No description provided for @statsFastestWin.
  ///
  /// In en, this message translates to:
  /// **'Fastest win: {time}'**
  String statsFastestWin(String time);

  /// No description provided for @statsBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get statsBadges;

  /// No description provided for @statsBadgeEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned {date}'**
  String statsBadgeEarned(String date);

  /// No description provided for @statsNoGames.
  ///
  /// In en, this message translates to:
  /// **'No finished games yet.'**
  String get statsNoGames;

  /// No description provided for @homeBestStars.
  ///
  /// In en, this message translates to:
  /// **'Best rating: {stars} of 3 stars'**
  String homeBestStars(int stars);

  /// No description provided for @resultPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get resultPoints;

  /// No description provided for @pointsWin.
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get pointsWin;

  /// No description provided for @pointsDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get pointsDraw;

  /// No description provided for @pointsSecond.
  ///
  /// In en, this message translates to:
  /// **'2nd place'**
  String get pointsSecond;

  /// No description provided for @pointsParticipation.
  ///
  /// In en, this message translates to:
  /// **'Taking part'**
  String get pointsParticipation;

  /// No description provided for @pointsStars.
  ///
  /// In en, this message translates to:
  /// **'Rating {count} ★'**
  String pointsStars(int count);

  /// No description provided for @pointsStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} wins in a row'**
  String pointsStreak(int count);

  /// No description provided for @pointsFirstToday.
  ///
  /// In en, this message translates to:
  /// **'First game today'**
  String get pointsFirstToday;

  /// No description provided for @pointsRecord.
  ///
  /// In en, this message translates to:
  /// **'New personal best'**
  String get pointsRecord;

  /// No description provided for @pointsBadge.
  ///
  /// In en, this message translates to:
  /// **'Badge: {name}'**
  String pointsBadge(String name);

  /// No description provided for @pointsCapped.
  ///
  /// In en, this message translates to:
  /// **'Lots of Easy wins today'**
  String get pointsCapped;

  /// No description provided for @pointsGift.
  ///
  /// In en, this message translates to:
  /// **'Gift from a parent'**
  String get pointsGift;

  /// No description provided for @pointsPurchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get pointsPurchase;

  /// No description provided for @pointsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total +{points} ●'**
  String pointsTotal(int points);

  /// No description provided for @levelUp.
  ///
  /// In en, this message translates to:
  /// **'New level {level}!'**
  String levelUp(int level);

  /// No description provided for @homePointsBalance.
  ///
  /// In en, this message translates to:
  /// **'Points: {points}'**
  String homePointsBalance(int points);

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv {level}'**
  String levelShort(int level);

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelLabel(int level);

  /// No description provided for @levelNext.
  ///
  /// In en, this message translates to:
  /// **'{current} / {needed} ● to the next level'**
  String levelNext(int current, int needed);

  /// No description provided for @levelMax.
  ///
  /// In en, this message translates to:
  /// **'Top level!'**
  String get levelMax;

  /// No description provided for @statsBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get statsBalance;

  /// No description provided for @statsTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get statsTotalEarned;

  /// No description provided for @statsPointsHistory.
  ///
  /// In en, this message translates to:
  /// **'Points history'**
  String get statsPointsHistory;

  /// No description provided for @settingsParents.
  ///
  /// In en, this message translates to:
  /// **'Parents\' corner'**
  String get settingsParents;

  /// No description provided for @parentsGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Parents only'**
  String get parentsGateTitle;

  /// No description provided for @parentsGateQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is {a} × {b}?'**
  String parentsGateQuestion(int a, int b);

  /// No description provided for @parentsGateWrong.
  ///
  /// In en, this message translates to:
  /// **'That is not right.'**
  String get parentsGateWrong;

  /// No description provided for @parentsGateOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get parentsGateOpen;

  /// No description provided for @parentsGiftTitle.
  ///
  /// In en, this message translates to:
  /// **'Give points'**
  String get parentsGiftTitle;

  /// No description provided for @parentsGiftConfirm.
  ///
  /// In en, this message translates to:
  /// **'Give {points} ● to {name}?'**
  String parentsGiftConfirm(int points, String name);

  /// No description provided for @parentsGiftAction.
  ///
  /// In en, this message translates to:
  /// **'Give'**
  String get parentsGiftAction;

  /// No description provided for @parentsGiftDone.
  ///
  /// In en, this message translates to:
  /// **'Given: {points} ● – {name}'**
  String parentsGiftDone(int points, String name);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'New version {version} is here'**
  String updateAvailable(String version);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String updateDownloading(int percent);

  /// No description provided for @updateMandatory.
  ///
  /// In en, this message translates to:
  /// **'This version is too old – please update.'**
  String get updateMandatory;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'The download failed. Try again later.'**
  String get updateFailed;

  /// No description provided for @updatePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'One more permission'**
  String get updatePermissionTitle;

  /// No description provided for @updatePermissionText.
  ///
  /// In en, this message translates to:
  /// **'Android will ask whether Deskovky may install apps. It is only for the new Deskovky version. Ask a grown-up to turn the switch on, then come back here.'**
  String get updatePermissionText;

  /// No description provided for @updatePermissionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get updatePermissionOpen;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApp;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Check for updates now'**
  String get settingsCheckNow;

  /// No description provided for @settingsAutoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check automatically'**
  String get settingsAutoUpdate;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You have the newest version.'**
  String get updateUpToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'The check failed – is the device online?'**
  String get updateCheckFailed;

  /// No description provided for @itemCap.
  ///
  /// In en, this message translates to:
  /// **'Cap'**
  String get itemCap;

  /// No description provided for @itemEarsHeadband.
  ///
  /// In en, this message translates to:
  /// **'Ear headband'**
  String get itemEarsHeadband;

  /// No description provided for @itemFlowerWreath.
  ///
  /// In en, this message translates to:
  /// **'Flower wreath'**
  String get itemFlowerWreath;

  /// No description provided for @itemTopHat.
  ///
  /// In en, this message translates to:
  /// **'Top hat'**
  String get itemTopHat;

  /// No description provided for @itemVikingHelmet.
  ///
  /// In en, this message translates to:
  /// **'Viking helmet'**
  String get itemVikingHelmet;

  /// No description provided for @itemPirateBandana.
  ///
  /// In en, this message translates to:
  /// **'Pirate bandana'**
  String get itemPirateBandana;

  /// No description provided for @itemWizardHat.
  ///
  /// In en, this message translates to:
  /// **'Wizard hat'**
  String get itemWizardHat;

  /// No description provided for @itemCrown.
  ///
  /// In en, this message translates to:
  /// **'Crown'**
  String get itemCrown;

  /// No description provided for @itemHalo.
  ///
  /// In en, this message translates to:
  /// **'Halo'**
  String get itemHalo;

  /// No description provided for @itemGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get itemGlasses;

  /// No description provided for @itemMustache.
  ///
  /// In en, this message translates to:
  /// **'Moustache'**
  String get itemMustache;

  /// No description provided for @itemFacePaintStar.
  ///
  /// In en, this message translates to:
  /// **'Star face paint'**
  String get itemFacePaintStar;

  /// No description provided for @itemSunglasses.
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get itemSunglasses;

  /// No description provided for @itemHeroMask.
  ///
  /// In en, this message translates to:
  /// **'Hero mask'**
  String get itemHeroMask;

  /// No description provided for @itemMonocle.
  ///
  /// In en, this message translates to:
  /// **'Monocle'**
  String get itemMonocle;

  /// No description provided for @itemCarnivalMask.
  ///
  /// In en, this message translates to:
  /// **'Carnival mask'**
  String get itemCarnivalMask;

  /// No description provided for @itemLollipop.
  ///
  /// In en, this message translates to:
  /// **'Lollipop'**
  String get itemLollipop;

  /// No description provided for @itemBalloon.
  ///
  /// In en, this message translates to:
  /// **'Balloon'**
  String get itemBalloon;

  /// No description provided for @itemIceCream.
  ///
  /// In en, this message translates to:
  /// **'Ice cream'**
  String get itemIceCream;

  /// No description provided for @itemPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get itemPhone;

  /// No description provided for @itemMicrophone.
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get itemMicrophone;

  /// No description provided for @itemMagicWand.
  ///
  /// In en, this message translates to:
  /// **'Magic wand'**
  String get itemMagicWand;

  /// No description provided for @itemTrophy.
  ///
  /// In en, this message translates to:
  /// **'Trophy'**
  String get itemTrophy;

  /// No description provided for @itemKitten.
  ///
  /// In en, this message translates to:
  /// **'Kitten'**
  String get itemKitten;

  /// No description provided for @itemChick.
  ///
  /// In en, this message translates to:
  /// **'Chick'**
  String get itemChick;

  /// No description provided for @itemPuppy.
  ///
  /// In en, this message translates to:
  /// **'Puppy'**
  String get itemPuppy;

  /// No description provided for @itemParrot.
  ///
  /// In en, this message translates to:
  /// **'Parrot'**
  String get itemParrot;

  /// No description provided for @itemDragon.
  ///
  /// In en, this message translates to:
  /// **'Little dragon'**
  String get itemDragon;

  /// No description provided for @itemWoodFrame.
  ///
  /// In en, this message translates to:
  /// **'Wooden frame'**
  String get itemWoodFrame;

  /// No description provided for @itemGoldFrame.
  ///
  /// In en, this message translates to:
  /// **'Gold frame'**
  String get itemGoldFrame;

  /// No description provided for @itemRainbowFrame.
  ///
  /// In en, this message translates to:
  /// **'Rainbow frame'**
  String get itemRainbowFrame;

  /// No description provided for @itemFlameFrame.
  ///
  /// In en, this message translates to:
  /// **'Flame frame'**
  String get itemFlameFrame;

  /// No description provided for @itemStarFrame.
  ///
  /// In en, this message translates to:
  /// **'Star frame'**
  String get itemStarFrame;

  /// No description provided for @itemSparkles.
  ///
  /// In en, this message translates to:
  /// **'Sparkles'**
  String get itemSparkles;

  /// No description provided for @itemBubbles.
  ///
  /// In en, this message translates to:
  /// **'Bubbles'**
  String get itemBubbles;

  /// No description provided for @itemSnow.
  ///
  /// In en, this message translates to:
  /// **'Snowfall'**
  String get itemSnow;

  /// No description provided for @pointsReset.
  ///
  /// In en, this message translates to:
  /// **'A parent reset the points'**
  String get pointsReset;

  /// No description provided for @badgeWins50Title.
  ///
  /// In en, this message translates to:
  /// **'Fifty'**
  String get badgeWins50Title;

  /// No description provided for @badgeWins50Description.
  ///
  /// In en, this message translates to:
  /// **'Win 50 games. Reward: a trophy to hold.'**
  String get badgeWins50Description;

  /// No description provided for @badgeAllHardTitle.
  ///
  /// In en, this message translates to:
  /// **'Master of all games'**
  String get badgeAllHardTitle;

  /// No description provided for @badgeAllHardDescription.
  ///
  /// In en, this message translates to:
  /// **'Beat the robots on Hard in every game. Reward: a star frame.'**
  String get badgeAllHardDescription;

  /// No description provided for @badgeCollectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get badgeCollectorTitle;

  /// No description provided for @badgeCollectorDescription.
  ///
  /// In en, this message translates to:
  /// **'Buy 10 avatar upgrades.'**
  String get badgeCollectorDescription;

  /// No description provided for @shopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopTryOn.
  ///
  /// In en, this message translates to:
  /// **'Trying on: {name}'**
  String shopTryOn(String name);

  /// No description provided for @shopAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shopAll;

  /// No description provided for @slotHead.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get slotHead;

  /// No description provided for @slotFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get slotFace;

  /// No description provided for @slotHand.
  ///
  /// In en, this message translates to:
  /// **'Hand'**
  String get slotHand;

  /// No description provided for @slotPet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get slotPet;

  /// No description provided for @slotFrame.
  ///
  /// In en, this message translates to:
  /// **'Frame'**
  String get slotFrame;

  /// No description provided for @slotEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get slotEffect;

  /// No description provided for @shopBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy for {price} ●'**
  String shopBuy(int price);

  /// No description provided for @shopBuyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Buy {name} for {price} ●?'**
  String shopBuyConfirm(String name, int price);

  /// No description provided for @shopBuyAction.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get shopBuyAction;

  /// No description provided for @shopMissing.
  ///
  /// In en, this message translates to:
  /// **'You need {points} more ●'**
  String shopMissing(int points);

  /// No description provided for @shopLevelLock.
  ///
  /// In en, this message translates to:
  /// **'🔒 Level {level}'**
  String shopLevelLock(int level);

  /// No description provided for @shopBadgeLock.
  ///
  /// In en, this message translates to:
  /// **'🔒 Badge: {name}'**
  String shopBadgeLock(String name);

  /// No description provided for @shopOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get shopOwned;

  /// No description provided for @shopEquipped.
  ///
  /// In en, this message translates to:
  /// **'Wearing'**
  String get shopEquipped;

  /// No description provided for @shopEquipNow.
  ///
  /// In en, this message translates to:
  /// **'Wear it now?'**
  String get shopEquipNow;

  /// No description provided for @shopEquip.
  ///
  /// In en, this message translates to:
  /// **'Wear'**
  String get shopEquip;

  /// No description provided for @shopUnequip.
  ///
  /// In en, this message translates to:
  /// **'Take off'**
  String get shopUnequip;

  /// No description provided for @shopNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get shopNotNow;

  /// No description provided for @shopNextLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} → {next} · {points} points to go'**
  String shopNextLevel(int level, int next, int points);

  /// No description provided for @shopPlayerLevel.
  ///
  /// In en, this message translates to:
  /// **'{name} · Level {level}'**
  String shopPlayerLevel(String name, int level);

  /// No description provided for @wardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobeTitle;

  /// No description provided for @wardrobeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Buy upgrades in the shop.'**
  String get wardrobeEmpty;

  /// No description provided for @wardrobeToShop.
  ///
  /// In en, this message translates to:
  /// **'To the shop'**
  String get wardrobeToShop;

  /// No description provided for @wardrobeColour.
  ///
  /// In en, this message translates to:
  /// **'Colour: {name}'**
  String wardrobeColour(String name);

  /// No description provided for @colourGold.
  ///
  /// In en, this message translates to:
  /// **'gold'**
  String get colourGold;

  /// No description provided for @colourSilver.
  ///
  /// In en, this message translates to:
  /// **'silver'**
  String get colourSilver;

  /// No description provided for @colourRed.
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get colourRed;

  /// No description provided for @colourBlue.
  ///
  /// In en, this message translates to:
  /// **'blue'**
  String get colourBlue;

  /// No description provided for @colourGreen.
  ///
  /// In en, this message translates to:
  /// **'green'**
  String get colourGreen;

  /// No description provided for @colourYellow.
  ///
  /// In en, this message translates to:
  /// **'yellow'**
  String get colourYellow;

  /// No description provided for @colourBrown.
  ///
  /// In en, this message translates to:
  /// **'brown'**
  String get colourBrown;

  /// No description provided for @parentsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset points and upgrades'**
  String get parentsResetTitle;

  /// No description provided for @parentsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get parentsReset;

  /// No description provided for @parentsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'{name} will lose {points} ● and all bought upgrades. Level and badges stay.'**
  String parentsResetConfirm(String name, int points);

  /// No description provided for @parentsResetDone.
  ///
  /// In en, this message translates to:
  /// **'{name}: points and upgrades reset.'**
  String parentsResetDone(String name);

  /// No description provided for @resultCanBuy.
  ///
  /// In en, this message translates to:
  /// **'{name}, now you can buy: {item}!'**
  String resultCanBuy(String name, String item);

  /// No description provided for @pointsPurchaseItem.
  ///
  /// In en, this message translates to:
  /// **'Purchase: {item}'**
  String pointsPurchaseItem(String item);

  /// No description provided for @shopNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New badge: {badge}!'**
  String shopNewBadge(String badge);

  /// No description provided for @shopNewBadgeReward.
  ///
  /// In en, this message translates to:
  /// **'{description} Reward +{points} ●.'**
  String shopNewBadgeReward(String description, int points);

  /// No description provided for @shopHooray.
  ///
  /// In en, this message translates to:
  /// **'Hooray!'**
  String get shopHooray;

  /// No description provided for @shopNotEnough.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have enough points for that now.'**
  String get shopNotEnough;

  /// No description provided for @shopFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get shopFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
