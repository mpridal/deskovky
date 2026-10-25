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
