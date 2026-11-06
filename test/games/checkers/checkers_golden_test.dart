import 'dart:io';

import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/games/checkers/checkers_module.dart';
import 'package:deskovky/games/checkers/checkers_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';
import 'checkers_test_utils.dart';

Widget _app(Widget child) => MaterialApp(
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
  home: child,
);

/// A Czech game in the middle: kings of both sides, the last move marked.
CheckersState _czech() {
  final s = diagram(['...B....', '..b...b.', '.b.b....', '........', '...w.w..', 'w.......', '.w.W.w..', 'w.......']);
  return play(s, [(5, 4), (4, 3)]);
}

/// An international game a few moves in.
CheckersState _international() {
  var s = rules.initialState(config(variant: 'international'), 1);
  for (final step in [
    [(1, 6), (0, 5)],
    [(2, 3), (3, 4)],
    [(7, 6), (8, 5)],
    [(8, 3), (7, 4)],
  ]) {
    s = play(s, step);
  }
  return s;
}

void main() {
  setUpAll(loadAppFonts);

  // The board alone: no text, so the pictures are the same on every system.
  for (final (name, size, state, tapAt) in [
    ('phone', const Size(412, 915), _czech(), (3, 2)),
    ('tablet_portrait', const Size(800, 1280), _international(), (3, 6)),
    ('tablet_landscape', const Size(1280, 800), rules.initialState(config(), 1), (2, 5)),
  ]) {
    testWidgets('board $name', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: MediaQueryData(size: size, disableAnimations: true),
            child: Material(
              color: AppColors.felt,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, size.width >= 600 ? 80 : 140, 16, 72),
                child: Builder(
                  builder: (context) => checkersModule.board(
                    context,
                    GameBoardView<CheckersState>(
                      state: state,
                      lastMove: null,
                      mySeat: state.current,
                      canAct: true,
                      submit: (_) async => true,
                      host: GameTestHost(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final (c, r) = tapAt;
      await tester.tapAt(tester.getCenter(find.byKey(ValueKey('sq${sq(c, r, state.size)}'))));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await expectLater(find.byKey(const ValueKey('checkersBoard')), matchesGoldenFile('goldens/board_$name.png'));
    });
  }

  testWidgets(
    'rule steps',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(520, 170);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          RepaintBoundary(
            child: Material(
              color: AppColors.paper,
              child: Builder(
                builder: (context) => Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: checkersModule.ruleSteps(context),
                  ),
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
