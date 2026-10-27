import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/minesweeper/minesweeper_module.dart';
import 'package:deskovky/games/minesweeper/minesweeper_rules.dart';
import 'package:deskovky/games/minesweeper/minesweeper_state.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';
import 'helpers.dart';

const sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];

/// The board in a game-screen-like space; [state] can be changed later
/// to see how the board reacts (sounds, puff).
class Harness {
  Harness(MinesweeperState state) : notifier = ValueNotifier(state);

  final ValueNotifier<MinesweeperState> notifier;
  final host = GameTestHost();
  final sent = <Move>[];
  bool canAct = true;
  bool firstGame = false;
  Duration elapsed = const Duration(seconds: 12);

  MinesweeperState get state => notifier.value;

  /// A tablet by default: the whole easy board fits there without zoom.
  Future<void> pump(WidgetTester tester, {Size size = const Size(800, 1280), String locale = 'cs'}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        debugShowCheckedModeBanner: false,
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: FeltBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Roughly the game screen's HUD and turn bubble.
                  const SizedBox(height: 110),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ValueListenableBuilder(
                        valueListenable: notifier,
                        builder: (context, state, _) => minesweeperModule.board(
                          context,
                          GameBoardView<MinesweeperState>(
                            state: state,
                            lastMove: null,
                            mySeat: canAct ? state.current : null,
                            canAct: canAct && !state.over,
                            submit: (m) async {
                              sent.add(m);
                              notifier.value = rules.apply(notifier.value, m);
                              return true;
                            },
                            host: host,
                            elapsed: () => elapsed,
                            firstGame: firstGame,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 56),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }
}

Finder cell(int c, int r) => find.byKey(ValueKey('cell$c,$r'));

void main() {
  setUpAll(loadAppFonts);

  group('fits every screen', () {
    for (final size in sizes) {
      for (final difficulty in Difficulty.values) {
        testWidgets('${size.width.toInt()}×${size.height.toInt()} $difficulty', (tester) async {
          final s0 = rules.initialState(config(difficulty: difficulty), 5);
          final h = Harness(rules.apply(s0, reveal(s0.columns ~/ 2, s0.rows ~/ 2)));
          await h.pump(tester, size: size);
          expect(tester.takeException(), isNull);
          // Every square is a 48 dp target (spec 13.4); a board that does
          // not fit zooms instead and offers the centre button.
          final square = tester.getSize(cell(0, 0));
          expect(square.width, greaterThanOrEqualTo(48 - 0.01));
          final zoomed = find.byType(InteractiveViewer).evaluate().isNotEmpty;
          expect(find.byKey(const ValueKey('centre')), zoomed ? findsOneWidget : findsNothing);
        });
      }
    }

    testWidgets('medium on a small phone: 48 dp squares, pinch-zoom and the centre button', (tester) async {
      final h = Harness(rules.initialState(config(difficulty: Difficulty.medium), 1));
      await h.pump(tester, size: const Size(360, 740));
      expect(tester.getSize(cell(0, 0)).width, greaterThanOrEqualTo(48));
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byKey(const ValueKey('centre')), findsOneWidget);
    });

    testWidgets('on a phone the zoomed board still uncovers with a tap and flags with a long press', (tester) async {
      final h = Harness(board([(0, 0), (8, 8)]));
      await h.pump(tester, size: const Size(412, 915));
      expect(find.byType(InteractiveViewer), findsOneWidget);
      await tester.longPress(cell(4, 3));
      await tester.pump();
      await tester.tap(cell(4, 5));
      await tester.pump();
      expect(h.sent, [mark(4, 3), reveal(4, 5, t: 12000)]);
    });

    testWidgets('easy on a tablet fits without zooming', (tester) async {
      final h = Harness(rules.initialState(config(), 1));
      await h.pump(tester, size: const Size(800, 1280));
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(find.byKey(const ValueKey('centre')), findsNothing);
    });

    testWidgets('a tall board is turned on a wide screen', (tester) async {
      final h = Harness(rules.initialState(config(difficulty: Difficulty.medium), 1));
      await h.pump(tester, size: const Size(1280, 800));
      // 12 columns × 16 rows shown as 16 wide: the last column of the
      // board (11) is the bottom row on screen.
      final top = tester.getTopLeft(cell(0, 0));
      final turned = tester.getTopLeft(cell(0, 15));
      expect(turned.dx, greaterThan(top.dx));
      expect(turned.dy, closeTo(top.dy, 0.01));
    });

    testWidgets('the centre button brings a zoomed board back to the start', (tester) async {
      final h = Harness(rules.initialState(config(difficulty: Difficulty.hard), 1));
      await h.pump(tester, size: const Size(412, 915));
      await tester.pump();
      final start = tester.getTopLeft(cell(8, 12));
      await tester.drag(find.byType(InteractiveViewer), const Offset(-120, -200));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(cell(8, 12)), isNot(start));
      await tester.tap(find.byKey(const ValueKey('centre')));
      await tester.pump();
      expect(tester.getTopLeft(cell(8, 12)), start);
    });

    testWidgets('texts fit in all languages with the switch and the centre button', (tester) async {
      for (final locale in ['cs', 'en', 'es']) {
        final h = Harness(rules.initialState(config(difficulty: Difficulty.hard, controls: 'switch'), 1))
          ..firstGame = true;
        await h.pump(tester, size: const Size(360, 740), locale: locale);
        expect(tester.takeException(), isNull, reason: locale);
        expect(find.byKey(const ValueKey('minesweeperHint')), findsOneWidget);
      }
    });
  });

  group('controls', () {
    testWidgets('a tap uncovers and sends the playing time; the dig sound plays', (tester) async {
      final h = Harness(rules.initialState(config(), 2));
      await h.pump(tester);
      await tester.tap(cell(4, 4));
      await tester.pump();
      expect(h.sent.single, reveal(4, 4, t: 12000));
      expect(h.state.started, isTrue);
      expect(h.host.sfx, contains('minesweeper.dig'));
    });

    testWidgets('a long press places a flag with haptics and the flag sound; a tap on a flag does nothing', (
      tester,
    ) async {
      final h = Harness(board([(0, 0), (8, 8)]));
      await h.pump(tester);
      await tester.longPress(cell(0, 0));
      await tester.pump();
      expect(h.sent.single, mark(0, 0));
      expect(h.host.haptics, 1);
      expect(h.host.sfx, contains('minesweeper.flag'));
      await tester.tap(cell(0, 0));
      await tester.pump();
      expect(h.sent, hasLength(1));
    });

    testWidgets('with the ⛏/🚩 switch a tap places flags in flag mode', (tester) async {
      final s = board([(0, 0), (8, 8)]);
      final h = Harness(
        MinesweeperState.start(
          level: s.level,
          seats: 1,
          questionMarks: false,
          seed: 1,
          switchControls: true,
        ).copyWith(mines: s.mines),
      );
      await h.pump(tester);
      await tester.tap(find.byKey(const ValueKey('modeFlag')));
      await tester.pump();
      await tester.tap(cell(0, 0));
      await tester.pump();
      expect(h.sent.single, mark(0, 0));
      await tester.tap(find.byKey(const ValueKey('modeDig')));
      await tester.pump();
      await tester.tap(cell(1, 1));
      await tester.pump();
      expect(h.sent.last.type, MinesweeperMove.reveal);
    });

    testWidgets('a tap on a number with its flags chords', (tester) async {
      final h = Harness(play(board([(0, 0), (8, 8)]), [reveal(1, 1), mark(0, 0)]));
      await h.pump(tester);
      await tester.tap(cell(1, 1));
      await tester.pump();
      expect(h.sent.single.type, MinesweeperMove.chord);
    });

    testWidgets('nothing is sent while the player cannot act', (tester) async {
      final h = Harness(rules.initialState(config(), 2))..canAct = false;
      await h.pump(tester);
      await tester.tap(cell(4, 4), warnIfMissed: false);
      await tester.longPress(cell(3, 3), warnIfMissed: false);
      await tester.pump();
      expect(h.sent, isEmpty);
    });

    testWidgets('the first game shows how to start, then how to flag', (tester) async {
      final h = Harness(rules.initialState(config(), 2))..firstGame = true;
      await h.pump(tester);
      expect(find.text('Ťukni na kterékoli pole – první je vždy bezpečné.'), findsOneWidget);
      await tester.tap(cell(4, 4));
      await tester.pump();
      expect(find.textContaining('dlouhým stiskem'), findsOneWidget);
    });
  });

  testWidgets('a screen reader hears what each square shows', (tester) async {
    final handle = tester.ensureSemantics();
    final h = Harness(play(board([(0, 0), (8, 8)]), [reveal(1, 1), mark(0, 0)]));
    await h.pump(tester);
    expect(find.bySemanticsLabel('A1, vlajka'), findsOneWidget);
    expect(find.bySemanticsLabel('B2, 1'), findsOneWidget);
    expect(find.bySemanticsLabel('C1, skryté pole'), findsOneWidget);
    handle.dispose();
  });

  group('the end', () {
    testWidgets('a mine is a puff: sound, smoke and all mines shown', (tester) async {
      final h = Harness(play(board([(0, 0), (8, 8)]), [reveal(1, 1)]));
      await h.pump(tester);
      await tester.tap(cell(0, 0));
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.host.sfx, contains('minesweeper.puff'));
      expect(h.state.over, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('clearing an easy board fast reports the win, no flags and lightning', (tester) async {
      // A tap on (8,8) opens all the rest.
      final s = play(board([(0, 0), (0, 1)]), [reveal(1, 0)]);
      final h = Harness(s)..elapsed = const Duration(seconds: 15);
      await h.pump(tester);
      await tester.tap(cell(8, 8));
      await tester.pump();
      expect(h.state.cleared, isTrue);
      expect([for (final (id, _) in h.host.events) id], ['minesweeper.win', 'minesweeper.noflag', 'minesweeper.blitz']);
      expect(h.host.events.first.$2, {'seat': 0});
    });

    testWidgets('Střídačka: the winner by the last move gets the win event', (tester) async {
      final h = Harness(play(board([(0, 0), (8, 8), (4, 4)], seats: 2), [reveal(0, 0, seat: 0)]));
      await h.pump(tester);
      expect(h.state.over, isTrue, reason: 'one player left');
      final h2 = Harness(board([(0, 0), (8, 8), (4, 4)], seats: 3));
      await h2.pump(tester);
      await tester.tap(cell(0, 0));
      await tester.pump();
      expect(h2.host.events, isEmpty, reason: 'two players still in');
    });
  });

  testWidgets('Střídačka over the network: a move from another device that ends the game still reports the win', (tester) async {
    // Táta (seat 0) plays on another device and hits a mine: Kuba (seat 1) wins here.
    final h = Harness(board([(0, 0), (8, 8), (4, 4)], seats: 2))..canAct = false;
    await h.pump(tester);
    expect(h.state.over, isFalse);
    h.notifier.value = rules.apply(h.state, reveal(0, 0, seat: 0));
    await tester.pump();
    expect(h.state.over, isTrue);
    expect([for (final (id, data) in h.host.events) (id, data['seat'])], [('minesweeper.win', 1)]);
  });

  testWidgets('Střídačka: ending the game with my own move reports the win once', (tester) async {
    final h = Harness(board([(0, 0), (8, 8), (4, 4)], seats: 2));
    await h.pump(tester);
    expect(h.state.over, isFalse);
    await tester.tap(cell(0, 0));
    await tester.pump();
    expect(h.state.over, isTrue);
    expect([for (final (id, data) in h.host.events) (id, data['seat'])], [('minesweeper.win', 1)]);
  });

  testWidgets('the rule steps and the turn hint draw in every language', (tester) async {
    for (final locale in ['cs', 'en', 'es']) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 740);
      addTearDown(tester.view.reset);
      late String? hint;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                hint = minesweeperModule.turnHint(context, board([(0, 0)], seats: 2), 'Kuba');
                return Wrap(spacing: 12, runSpacing: 12, children: minesweeperModule.ruleSteps(context));
              },
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: locale);
      expect(minesweeperModule.ruleSteps(tester.element(find.byType(Wrap))), hasLength(4));
      expect(hint, contains('Kuba'));
    }
  });

  group('goldens', () {
    MinesweeperState midGame(Difficulty difficulty, {int seats = 1}) {
      var s = rules.initialState(config(difficulty: difficulty, seats: seats), 21);
      s = rules.apply(s, reveal(s.columns ~/ 2, s.rows ~/ 2));
      for (final m in s.mines.take(3)) {
        s = rules.apply(s, mark(m % s.columns, m ~/ s.columns, seat: s.current));
      }
      return s;
    }

    for (final (name, size, difficulty) in [
      ('phone_easy', const Size(412, 915), Difficulty.easy),
      ('tablet_medium', const Size(800, 1280), Difficulty.medium),
      ('tablet_wide_hard', const Size(1280, 800), Difficulty.hard),
    ]) {
      testWidgets(name, (tester) async {
        final h = Harness(midGame(difficulty));
        await h.pump(tester, size: size);
        await tester.pump(const Duration(milliseconds: 400));
        await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/$name.png'));
      });
    }

    testWidgets('lost_with_puff', (tester) async {
      final h = Harness(play(board([(0, 0), (8, 8), (3, 6)]), [reveal(1, 1), mark(8, 8), mark(5, 5)]));
      await h.pump(tester, size: const Size(800, 1280));
      await tester.tap(cell(0, 0));
      await tester.pump(const Duration(milliseconds: 250));
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/lost_with_puff.png'));
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
