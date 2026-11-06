import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/checkers/checkers_module.dart';
import 'package:deskovky/games/checkers/checkers_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';
import 'checkers_test_utils.dart';

/// Hosts the board like the game screen: moves are applied and the board
/// rebuilt; [humans] are the seats a person plays here.
class Table extends StatefulWidget {
  const Table({
    super.key,
    required this.start,
    required this.host,
    required this.sent,
    this.humans = const {0, 1},
    this.firstGame = false,
  });

  final CheckersState start;
  final GameTestHost host;
  final List<Move> sent;
  final Set<int> humans;
  final bool firstGame;

  @override
  State<Table> createState() => TableState();
}

class TableState extends State<Table> {
  late CheckersState state = widget.start;

  /// A move from elsewhere: a robot or another device.
  void apply(Move move) => setState(() => state = rules.apply(state, move));

  @override
  Widget build(BuildContext context) {
    final seat = rules.currentSeat(state);
    final mine = seat != null && widget.humans.contains(seat) ? seat : null;
    return checkersModule.board(
      context,
      GameBoardView<CheckersState>(
        state: state,
        lastMove: null,
        mySeat: mine,
        canAct: mine != null,
        firstGame: widget.firstGame,
        submit: (move) async {
          widget.sent.add(move);
          if (!rules.isLegal(state, move)) return false;
          setState(() => state = rules.apply(state, move));
          return true;
        },
        host: widget.host,
      ),
    );
  }
}

/// The table of the last [pumpBoard].
late GlobalKey<TableState> tableKey;

Future<(GameTestHost, List<Move>)> pumpBoard(
  WidgetTester tester,
  CheckersState state, {
  Size size = const Size(412, 915),
  Set<int> humans = const {0, 1},
  bool firstGame = false,
  bool reducedMotion = false,
  Locale locale = const Locale('cs'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final host = GameTestHost();
  final sent = <Move>[];
  tableKey = GlobalKey<TableState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reducedMotion),
          child: Scaffold(
            body: FeltBackground(
              // Roughly the space the game screen leaves under its HUD.
              child: Padding(
                padding: const EdgeInsets.only(top: 96, bottom: 72),
                child: Table(key: tableKey, start: state, host: host, sent: sent, humans: humans, firstGame: firstGame),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  return (host, sent);
}

Finder square(int c, int r, [int size = 8]) => find.byKey(ValueKey('sq${sq(c, r, size)}'));

Future<void> tapSquare(WidgetTester tester, int c, int r, [int size = 8]) async {
  await tester.tapAt(tester.getCenter(square(c, r, size)));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Lets the hop and the flight of taken pieces finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

List<String> events(GameTestHost host) => [for (final (id, data) in host.events) '$id $data'];

Finder target(int c, int r, [int size = 8]) => find.byKey(ValueKey('target${sq(c, r, size)}'));

const sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a tap on a piece shows its targets, a tap on a target plays the move', (tester) async {
    final (host, sent) = await pumpBoard(tester, rules.initialState(config(), 1));
    await tapSquare(tester, 2, 5);
    expect(target(1, 4), findsOneWidget);
    expect(target(3, 4), findsOneWidget);
    await tapSquare(tester, 3, 4);
    expect(sent.map(pathOf), [
      [sq(2, 5), sq(3, 4)],
    ]);
    expect(host.sfx, ['piece_place']);
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pieces that cannot move and empty squares do nothing; the robot\'s turn takes no taps', (tester) async {
    final (_, sent) = await pumpBoard(tester, rules.initialState(config(robot: true), 1), humans: {0});
    await tapSquare(tester, 1, 6);
    expect(find.byKey(ValueKey('picked${sq(1, 6)}')), findsNothing);
    await tapSquare(tester, 3, 4);
    expect(sent, isEmpty);
    await tapSquare(tester, 0, 5);
    await tapSquare(tester, 1, 4);
    expect(sent, hasLength(1));
    // Now the robot is to move: taps are ignored.
    await tapSquare(tester, 2, 5);
    await tapSquare(tester, 3, 4);
    expect(sent, hasLength(1));
  });

  testWidgets('a compulsory capture is shown; a capture with one way on is played with one tap', (tester) async {
    final (host, sent) = await pumpBoard(tester, diagram(board({(1, 6): 'w', (2, 5): 'b', (4, 3): 'b', (7, 6): 'w'})));
    expect(find.byKey(const ValueKey('checkersHint')), findsOneWidget);
    expect(find.textContaining('Musíš brát'), findsOneWidget);
    await tapSquare(tester, 7, 6);
    expect(find.byKey(ValueKey('picked${sq(7, 6)}')), findsNothing, reason: 'that piece cannot capture');
    await tapSquare(tester, 1, 6);
    await tapSquare(tester, 3, 4);
    expect(sent.map(pathOf), [
      [sq(1, 6), sq(3, 4), sq(5, 2)],
    ]);
    expect(host.sfx, ['checkers.capture']);
    await settle(tester);
    expect(find.byKey(ValueKey('taken${sq(2, 5)}')), findsNothing, reason: 'taken pieces have flown off');
  });

  testWidgets('a capture that branches is played square by square', (tester) async {
    final (_, sent) = await pumpBoard(tester, diagram(board({(3, 6): 'w', (4, 5): 'b', (4, 3): 'b', (6, 3): 'b'})));
    await tapSquare(tester, 3, 6);
    await tapSquare(tester, 5, 4);
    expect(sent, isEmpty);
    expect(find.textContaining('Skákej dál'), findsOneWidget);
    expect(target(3, 2), findsOneWidget);
    expect(target(7, 2), findsOneWidget);
    await tapSquare(tester, 0, 7); // a stray tap keeps the half-done capture
    await tapSquare(tester, 7, 2);
    expect(sent.map(pathOf), [
      [sq(3, 6), sq(5, 4), sq(7, 2)],
    ]);
  });

  testWidgets('crowning plays the crown after the hop and reports checkers.queen once', (tester) async {
    final (host, _) = await pumpBoard(tester, diagram(board({(2, 1): 'w', (7, 6): 'b'})));
    await tapSquare(tester, 2, 1);
    await tapSquare(tester, 1, 0);
    expect(events(host), ['checkers.queen {seat: 0}']);
    await settle(tester);
    expect(host.sfx, ['piece_place', 'checkers.crown']);
    expect(host.events, hasLength(1));
    expect(find.byKey(const ValueKey('crown0')), findsOneWidget);
  });

  testWidgets('with reduced motion the crown sounds at once and nothing flies', (tester) async {
    final (host, _) = await pumpBoard(
      tester,
      diagram(board({(1, 2): 'w', (2, 1): 'b', (7, 6): 'b'})),
      reducedMotion: true,
    );
    await tapSquare(tester, 1, 2);
    await tapSquare(tester, 3, 0);
    await tester.pump();
    expect(host.sfx, ['checkers.capture', 'checkers.crown']);
    expect(find.byKey(ValueKey('taken${sq(2, 1)}')), findsNothing);
  });

  testWidgets('moves from a robot or another device sound and report their events too', (tester) async {
    final s = diagram(board({(6, 7): 'w', (1, 6): 'b', (5, 6): 'b'}), current: 1);
    final (host, _) = await pumpBoard(tester, s, humans: {0});
    tableKey.currentState!.apply(go(tableKey.currentState!.state, [(1, 6), (0, 7)]));
    await settle(tester);
    expect(host.sfx, ['piece_place', 'checkers.crown']);
    expect(events(host), ['checkers.queen {seat: 1}']);
  });

  testWidgets('three pieces with one move report checkers.combo; the international board is reported at the start', (
    tester,
  ) async {
    final (host, _) = await pumpBoard(
      tester,
      diagram(board({(0, 9): 'w', (1, 8): 'b', (3, 6): 'b', (5, 4): 'b', (9, 0): 'b'}, 10)),
    );
    expect(events(host), ['checkers.international {}']);
    await tapSquare(tester, 0, 9, 10);
    await tapSquare(tester, 2, 7, 10);
    expect(events(host).last, 'checkers.combo {seat: 0}');
  });

  testWidgets('take back against an easy robot; no button against the hard one', (tester) async {
    CheckersState twoMoves(Difficulty d) {
      var s = rules.initialState(config(robot: true, difficulty: d), 1);
      s = play(s, [(0, 5), (1, 4)]);
      return play(s, [(1, 2), (0, 3)]);
    }

    var (_, sent) = await pumpBoard(tester, twoMoves(Difficulty.easy), humans: {0});
    expect(find.byKey(const ValueKey('checkersUndo')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('checkersUndo')));
    await tester.pump();
    expect(sent, [const Move(seat: 0, type: CheckersRules.undo)]);
    expect(tableKey.currentState!.state.log, isEmpty);

    (_, sent) = await pumpBoard(tester, twoMoves(Difficulty.hard), humans: {0});
    expect(find.byKey(const ValueKey('checkersUndo')), findsNothing);
  });

  testWidgets('a draw is offered after a confirmation and the other player answers on the board', (tester) async {
    final (_, sent) = await pumpBoard(tester, rules.initialState(config(), 1));
    await tester.tap(find.byKey(const ValueKey('checkersOffer')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nabídnout'));
    await tester.pumpAndSettle();
    expect(sent, [const Move(seat: 0, type: CheckersRules.offer)]);
    expect(find.byKey(const ValueKey('checkersOfferPanel')), findsOneWidget);
    expect(find.byKey(const ValueKey('checkersOffer')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('checkersDecline')));
    await tester.pump();
    expect(sent.last, const Move(seat: 1, type: CheckersRules.decline));
    expect(find.byKey(const ValueKey('checkersOfferPanel')), findsNothing);
    expect(find.byKey(const ValueKey('checkersOffer')), findsNothing, reason: 'not again before moving');
  });

  testWidgets('a device waiting for the answer says so; an accepted draw ends the game', (tester) async {
    final offered = rules.apply(rules.initialState(config(), 1), const Move(seat: 0, type: CheckersRules.offer));
    await pumpBoard(tester, offered, humans: {0});
    expect(find.textContaining('Čeká se'), findsOneWidget);
    tableKey.currentState!.apply(const Move(seat: 1, type: CheckersRules.accept));
    await tester.pump();
    expect(find.text('Remíza dohodou'), findsOneWidget);
  });

  group('orientation', () {
    double rowY(WidgetTester tester, int c, int r) => tester.getCenter(square(c, r)).dy;

    testWidgets('the person plays from the bottom, also as seat 2 against a robot', (tester) async {
      await pumpBoard(tester, rules.initialState(config(), 1));
      expect(rowY(tester, 0, 5), greaterThan(rowY(tester, 1, 2)));
      await pumpBoard(tester, rules.initialState(config(robotFirst: true), 1), humans: {1});
      expect(rowY(tester, 1, 2), greaterThan(rowY(tester, 0, 5)));
    });

    testWidgets('"Otáčet desku" turns the board to the player to move; without it the board stays', (tester) async {
      for (final rotate in [true, false]) {
        await pumpBoard(tester, rules.initialState(config(rotate: rotate), 1));
        await tapSquare(tester, 0, 5);
        await tapSquare(tester, 1, 4);
        await settle(tester);
        expect(rowY(tester, 1, 2) > rowY(tester, 0, 5), rotate, reason: 'rotate $rotate');
      }
    });
  });

  for (final size in sizes) {
    for (final variant in ['czech', 'international']) {
      testWidgets('${size.width.toInt()}×${size.height.toInt()} $variant: fits, squares big enough or zoomable', (
        tester,
      ) async {
        final s = rules.initialState(config(variant: variant), 1);
        await pumpBoard(tester, s, size: size, firstGame: true);
        expect(tester.takeException(), isNull);
        final n = s.size;
        final cell = tester.getSize(square(0, n - 1, n)).width;
        expect(tester.getSize(find.byKey(const ValueKey('checkersBoard'))).width, lessThanOrEqualTo(size.width));
        if (cell < 48) {
          expect(find.byKey(const ValueKey('checkersCentre')), findsOneWidget, reason: 'cell $cell');
          expect(find.byType(InteractiveViewer), findsOneWidget);
        } else {
          expect(find.byKey(const ValueKey('checkersCentre')), findsNothing);
        }
        expect(find.textContaining('Ťukni na svůj kámen'), findsOneWidget);
        // A tap a little beside a small square still picks the piece there.
        final front = n - s.variant.rows, column = front.isEven ? 1 : 0;
        final piece = tester.getCenter(square(column, front, n));
        await tester.tapAt(piece + Offset(cell * 0.6, 0));
        await tester.pump();
        expect(find.byKey(ValueKey('picked${sq(column, front, n)}')), findsOneWidget);
      });
    }
  }

  testWidgets('texts fit in every language on a small phone', (tester) async {
    for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
      await pumpBoard(
        tester,
        rules.initialState(config(variant: 'international'), 1),
        size: const Size(360, 740),
        firstGame: true,
        locale: locale,
      );
      await tester.tap(find.byKey(const ValueKey('checkersOffer')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$locale');
    }
  });
}
