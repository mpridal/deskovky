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
  String get avatarEdit => 'Edit avatar';

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
}
