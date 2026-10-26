import 'package:deskovky/core/game/game_texts.dart';
import 'package:deskovky/games/badge_texts.dart';
import 'package:deskovky/games/game_texts.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/l10n/app_localizations_cs.dart';
import 'package:deskovky/l10n/app_localizations_en.dart';
import 'package:deskovky/l10n/app_localizations_es.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const texts = GameTexts(
    cs: {'demo.hello': 'Ahoj, {name}!'},
    en: {'demo.hello': 'Hi, {name}!', 'demo.only': 'English only'},
  );

  group('GameTexts', () {
    test('looks up by language and fills placeholders', () {
      expect(texts.lookup('cs', 'demo.hello', {'name': 'Kuba'}), 'Ahoj, Kuba!');
      expect(texts.lookup('en', 'demo.hello', {'name': 'Kuba'}), 'Hi, Kuba!');
    });

    test('falls back to English, then to null', () {
      expect(texts.lookup('es', 'demo.hello', {'name': 'Ana'}), 'Hi, Ana!');
      expect(texts.lookup('cs', 'demo.only'), 'English only');
      expect(texts.lookup('cs', 'demo.missing'), isNull);
    });

    test('lists every key of every language', () {
      expect(texts.keys, {'demo.hello', 'demo.only'});
    });
  });

  group('gameText and badgeText read the game folders', () {
    final AppLocalizations cs = AppLocalizationsCs(), en = AppLocalizationsEn(), es = AppLocalizationsEs();

    test('the sample game title, rules and option come from its own texts', () {
      expect(gameText(cs, 'sample.title'), 'Hádej číslo');
      expect(gameText(en, 'sample.title'), 'Guess the number');
      expect(gameText(es, 'sample.title'), 'Adivina el número');
      expect(gameText(cs, 'sample.option.range'), 'Rozsah čísel');
      expect(gameText(cs, 'sample.turnHint', {'name': 'Kuba', 'low': 1, 'high': 20}), 'Kuba, tipni číslo od 1 do 20');
    });

    test('game badges translate, framework badges still do, unknown keys stay keys', () {
      expect(badgeText(cs, 'sample.badge.bullseye.title'), 'Trefa!');
      expect(badgeText(cs, 'badgeFirstWinTitle'), 'První výhra');
      expect(gameText(cs, 'nothing.here'), 'nothing.here');
    });
  });
}
