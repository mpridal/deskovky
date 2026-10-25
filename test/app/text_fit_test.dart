import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_fonts.dart';
import '../helpers/pump_app.dart';

const _sizes = [
  Size(360, 740),
  Size(412, 915),
  Size(740, 360),
  Size(915, 412),
  Size(840, 600),
  Size(800, 1280),
  Size(1280, 800),
];
const _locales = [Locale('cs'), Locale('en'), Locale('es')];
const _scales = [1.0, 1.3];

/// True when [finder]'s paragraph shows its whole text on one line.
bool _fitsOnOneLine(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  return paragraph.getMaxIntrinsicWidth(double.infinity) <= paragraph.size.width + 0.5;
}

/// The text inside a PrimaryButton (the same label may also appear elsewhere).
Finder _inButton(String label) =>
    find.descendant(of: find.byType(PrimaryButton), matching: find.text(label));

void main() {
  setUpAll(loadAppFonts);

  for (final locale in _locales) {
    final l10n = lookupAppLocalizations(locale);
    for (final size in _sizes) {
      for (final scale in _scales) {
        final name = '$locale ${size.width.toInt()}x${size.height.toInt()} text x$scale';

        testWidgets('navigation labels fit on one line: $name', (tester) async {
          await pumpApp(tester, size: size, locale: locale, textScale: scale);
          for (final label in [l10n.navGames, l10n.navPlayers, l10n.navLeaderboards, l10n.navSettings]) {
            final text = find.text(label).last;
            expect(_fitsOnOneLine(tester, text), isTrue, reason: '"$label" wraps or is clipped');
          }
        });

        testWidgets('"coming soon" badges are fully visible: $name', (tester) async {
          await pumpApp(tester, size: size, locale: locale, textScale: scale);
          final badges = find.text(l10n.comingSoon);
          expect(badges, findsWidgets);
          for (var i = 0; i < badges.evaluate().length; i++) {
            final badge = badges.at(i);
            final card = find.ancestor(of: badge, matching: find.byType(DecoratedBox)).last;
            final badgeRect = tester.getRect(badge);
            final cardRect = tester.getRect(card);
            expect(_fitsOnOneLine(tester, badge), isTrue, reason: 'badge $i text clipped');
            expect(cardRect.left <= badgeRect.left && badgeRect.right <= cardRect.right, isTrue,
                reason: 'badge $i $badgeRect sticks out of card $cardRect');
          }
        });

        testWidgets('players screen labels fit on one line: $name', (tester) async {
          await pumpApp(tester, size: size, locale: locale, textScale: scale);
          await tester.tap(find.text(l10n.navPlayers).last);
          await tester.pumpAndSettle();
          expect(_fitsOnOneLine(tester, _inButton(l10n.playersNew)), isTrue, reason: l10n.playersNew);
        });

        testWidgets('avatar editor labels fit on one line: $name', (tester) async {
          await pumpApp(tester, size: size, locale: locale, textScale: scale);
          await tester.tap(find.text(l10n.navPlayers).last);
          await tester.pumpAndSettle();
          await tester.tap(_inButton(l10n.playersNew));
          await tester.pumpAndSettle();
          for (final label in [
            l10n.avatarEditorTitle,
            l10n.avatarTabFace,
            l10n.avatarTabSkin,
            l10n.avatarTabHair,
            l10n.avatarTabEyes,
            l10n.avatarTabMouth,
            l10n.avatarTabBackground,
            l10n.avatarHairColor.toUpperCase(),
            l10n.avatarSave,
            l10n.profileName,
          ]) {
            expect(_fitsOnOneLine(tester, find.text(label)), isTrue, reason: '"$label" wraps or is clipped');
          }
        });
      }
    }
  }
}
