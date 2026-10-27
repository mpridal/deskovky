import 'dart:io';

import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/games/ludo/ludo_module.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';
import 'ludo_test_utils.dart';

/// A game in the middle: pieces on the ring, in corners and homes, seat 0
/// rolled a 6 and may pick one of the pulsing pieces (targets ringed).
LudoState _midGame(int players) {
  final pieces = [
    [base, 4, 17, 41],
    [base, base, 9, 40],
    [base, 2, 33, 43],
    [base, base, base, 12],
  ].take(players).toList();
  return rules.rollWith(position(pieces), 6);
}

void main() {
  setUpAll(loadAppFonts);

  for (final (name, size, players) in [
    ('phone_small', const Size(360, 740), 4),
    ('phone', const Size(412, 915), 2),
    ('tablet_portrait', const Size(800, 1280), 3),
    ('tablet_landscape', const Size(1280, 800), 4),
  ]) {
    testWidgets('board $name', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final state = _midGame(players);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: RepaintBoundary(
              child: Material(
                color: AppColors.felt,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, size.width >= 600 ? 80 : 140, 16, 72),
                  child: Builder(
                    builder: (context) => ludoModule.board(
                      context,
                      GameBoardView<LudoState>(
                        state: state,
                        lastMove: null,
                        mySeat: 0,
                        canAct: true,
                        submit: (_) async => true,
                        host: GameTestHost(),
                        firstGame: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('goldens/board_$name.png'));
    });
  }

  testWidgets('rule steps', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 160);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        locale: const Locale('cs'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: RepaintBoundary(
          child: Material(
            color: AppColors.paper,
            child: Builder(
              builder: (context) => Center(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ludoModule.ruleSteps(context)),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('goldens/rule_steps.png'));
  },
    // The captions use the app fonts, which Linux (CI) antialiases differently
    // from Windows, where the golden was made; the pictures are checked there.
    skip: !Platform.isWindows,
  );
}
