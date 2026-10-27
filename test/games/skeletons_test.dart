import 'package:deskovky/games/game_texts.dart';
import 'package:deskovky/games/registry.dart';
import 'package:deskovky/l10n/app_localizations_cs.dart';
import 'package:deskovky/l10n/app_localizations_en.dart';
import 'package:deskovky/l10n/app_localizations_es.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  const coming = ['tictactoe', 'memory', 'minesweeper', 'ludo', 'checkers'];

  // Whether a game is already playable is its own session's call
  // (`available` in its manifest); the registry itself never changes.
  test('every phase-2 game is registered from the start', () {
    expect([for (final m in gameModules) m.id], ['sample', ...coming]);
  });

  test('their names, descriptions and rules exist in all three languages', () {
    for (final l10n in [AppLocalizationsCs(), AppLocalizationsEn(), AppLocalizationsEs()]) {
      for (final id in coming) {
        final m = moduleById(id)!;
        for (final key in [m.titleKey, m.descriptionKey, m.rulesKey]) {
          expect(gameText(l10n, key), isNot(key), reason: '${l10n.localeName} $key');
        }
      }
    }
  });

  testWidgets('the home grid shows them with their own names', (tester) async {
    await pumpApp(tester, size: const Size(800, 1280));
    for (final name in ['Hádej číslo', 'Piškvorky', 'Pexeso', 'Miny', 'Člověče, nezlob se', 'Dáma']) {
      await tester.scrollUntilVisible(find.text(name), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });
}
