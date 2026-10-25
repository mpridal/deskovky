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
}
