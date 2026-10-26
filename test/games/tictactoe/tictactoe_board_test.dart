import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/tictactoe/tictactoe_module.dart';
import 'package:deskovky/games/tictactoe/tictactoe_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';

const rules = TictactoeRules();

GameConfig config({
  int board = 3,
  bool confirm = false,
  bool robot = false,
  bool robotFirst = false,
  Difficulty difficulty = Difficulty.hard,
}) => GameConfig(
      gameId: 'tictactoe',
      seats: robotFirst
          ? const [RobotSeat(), HumanSeat(1)]
          : [const HumanSeat(1), robot ? const RobotSeat() : const HumanSeat(2)],
      difficulty: difficulty,
      robotSpeed: RobotSpeed.fast,
      options: {'board': board, 'start': 'first', 'confirm': confirm},
    );

TictactoeState position(GameConfig c, List<(int, int)> cells) {
  var s = rules.initialState(c, 1);
  for (final (col, row) in cells) {
    s = rules.apply(s, TictactoeRules.place(s.current, col, row));
  }
  return s;
}

/// Hosts the board like the game screen: moves are applied and the board
/// rebuilt; [humans] are the seats a person plays here.
class _Table extends StatefulWidget {
  const _Table({super.key, required this.start, required this.host, required this.sent, this.humans = const {0, 1}, this.firstGame = false});

  final TictactoeState start;
  final GameTestHost host;
  final List<Move> sent;
  final Set<int> humans;
  final bool firstGame;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  late TictactoeState state = widget.start;

  @override
  Widget build(BuildContext context) {
    final seat = rules.currentSeat(state);
    final mine = seat != null && widget.humans.contains(seat) ? seat : null;
    return tictactoeModule.board(
      context,
      GameBoardView<TictactoeState>(
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

Future<(GameTestHost, List<Move>)> pumpBoard(
  WidgetTester tester,
  TictactoeState state, {
  Size size = const Size(412, 915),
  Set<int> humans = const {0, 1},
  bool firstGame = false,
  Locale locale = const Locale('cs'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final host = GameTestHost();
  final sent = <Move>[];
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
      home: Scaffold(
        body: FeltBackground(
          // Roughly the space the game screen leaves under its HUD.
          child: Padding(
            padding: const EdgeInsets.only(top: 96, bottom: 72),
            child: _Table(key: UniqueKey(), start: state, host: host, sent: sent, humans: humans, firstGame: firstGame),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  return (host, sent);
}

List<String> events(GameTestHost host) => [for (final (id, data) in host.events) '$id $data'];

Finder cell(int c, int r) => find.byKey(ValueKey('cell$c,$r'));

Future<void> tapCell(WidgetTester tester, int c, int r) async {
  await tester.tapAt(tester.getCenter(cell(c, r)));
  await tester.pump(const Duration(milliseconds: 600));
}

const sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a tap places the mark of the seat to move', (tester) async {
    final (host, sent) = await pumpBoard(tester, position(config(), []));
    await tapCell(tester, 1, 1);
    expect(sent, [TictactoeRules.place(0, 1, 1)]);
    expect(host.sfx, contains('tictactoe.draw'));
    await tapCell(tester, 1, 1);
    expect(sent, hasLength(1), reason: 'a taken cell takes nothing');
    await tapCell(tester, 0, 0);
    expect(sent.last, TictactoeRules.place(1, 0, 0));
  });

  testWidgets('nothing happens while a robot is to move', (tester) async {
    final (_, sent) = await pumpBoard(tester, position(config(robot: true), [(1, 1)]), humans: {0});
    await tapCell(tester, 0, 0);
    expect(sent, isEmpty);
  });

  testWidgets('the winning row is crossed out with its sound', (tester) async {
    final (host, sent) = await pumpBoard(tester, position(config(), [(0, 0), (0, 1), (1, 0), (1, 1)]));
    await tapCell(tester, 2, 0);
    expect(sent.single, TictactoeRules.place(0, 2, 0));
    expect(host.sfx, containsAllInOrder(['tictactoe.draw', 'tictactoe.line']));
    expect(tester.takeException(), isNull);
  });

  testWidgets('big board with confirm: first tap marks, second tap on the same cell places', (tester) async {
    final (_, sent) = await pumpBoard(tester, position(config(board: 10, confirm: true), []), size: const Size(1280, 800));
    await tapCell(tester, 4, 4);
    expect(sent, isEmpty);
    expect(find.text('Ťukni na stejné políčko ještě jednou'), findsOneWidget);
    await tapCell(tester, 5, 4);
    expect(sent, isEmpty, reason: 'another cell moves the mark');
    await tapCell(tester, 5, 4);
    expect(sent, [TictactoeRules.place(0, 5, 4)]);
    expect(find.text('Ťukni na stejné políčko ještě jednou'), findsNothing);
  });

  testWidgets('confirm is not used on 3×3', (tester) async {
    final (_, sent) = await pumpBoard(tester, position(config(confirm: true), []));
    await tapCell(tester, 0, 0);
    expect(sent, hasLength(1));
  });

  testWidgets('first game: a gentle hint how to play, gone after the first moves', (tester) async {
    await pumpBoard(tester, position(config(), []), firstGame: true);
    expect(find.text('Ťukni na volné políčko. Slož tři v řadě!'), findsOneWidget);
    await tapCell(tester, 1, 1);
    await tapCell(tester, 0, 0);
    expect(find.byKey(const ValueKey('tictactoeHint')), findsNothing);
  });

  group('badge events', () {
    testWidgets('a quick win on 15×15 reports win15 and blitz for the winner', (tester) async {
      final s = position(config(board: 15), [(3, 7), (3, 8), (4, 7), (4, 8), (5, 7), (5, 8), (6, 7), (6, 8)]);
      final (host, _) = await pumpBoard(tester, s, size: const Size(1280, 800));
      await tapCell(tester, 7, 7);
      expect(events(host), ['tictactoe.win15 {seat: 0}', 'tictactoe.blitz {seat: 0}']);
    });

    testWidgets('a draw against the hard robot on 3×3 reports wall, also when the robot fills the last cell', (tester) async {
      // The person fills the last cell.
      final last = position(config(robot: true), [(1, 1), (0, 0), (0, 2), (2, 0), (1, 0), (1, 2), (0, 1), (2, 1)]);
      final (host, _) = await pumpBoard(tester, last, humans: {0});
      await tapCell(tester, 2, 2);
      expect(events(host), ['tictactoe.wall {seat: 0}']);

      // The robot (✕) has only (2,2) left after ◯ blocks at (2,1).
      final forced = position(config(robotFirst: true), [(1, 1), (0, 0), (0, 2), (2, 0), (1, 0), (1, 2), (0, 1)]);
      final (host2, _) = await pumpBoard(tester, forced, humans: {1});
      await tapCell(tester, 2, 1);
      expect(events(host2), ['tictactoe.wall {seat: 1}']);
    });

    testWidgets('no wall against a medium robot or another person', (tester) async {
      for (final c in [config(robot: true, difficulty: Difficulty.medium), config()]) {
        final s = position(c, [(1, 1), (0, 0), (0, 2), (2, 0), (1, 0), (1, 2), (0, 1), (2, 1)]);
        final (host, _) = await pumpBoard(tester, s, humans: {0});
        await tapCell(tester, 2, 2);
        expect(host.events, isEmpty);
      }
    });
  });

  for (final size in sizes) {
    group('${size.width.toInt()}×${size.height.toInt()}', () {
      for (final board in TictactoeRules.sizes) {
        testWidgets('$board×$board: draws, cells ≥ 48 dp, a tap places a stone', (tester) async {
          final (_, sent) = await pumpBoard(tester, position(config(board: board), []), size: size, firstGame: true);
          expect(tester.takeException(), isNull);
          final middle = board ~/ 2;
          final cellSize = tester.getSize(cell(middle, middle));
          expect(cellSize.width, greaterThanOrEqualTo(48));
          final zooms = find.byKey(const ValueKey('tictactoeCentre'));
          // The centre cell starts on screen, also on a zoomed board.
          await tapCell(tester, middle, middle);
          expect(sent, [TictactoeRules.place(0, middle, middle)]);
          if (zooms.evaluate().isNotEmpty) {
            await tester.tap(zooms);
            await tester.pump(const Duration(milliseconds: 600));
          }
          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  testWidgets('15×15 on a phone zooms and has a centre button; 3×3 and tablets need none', (tester) async {
    await pumpBoard(tester, position(config(board: 15), []), size: const Size(360, 740));
    expect(find.byKey(const ValueKey('tictactoeCentre')), findsOneWidget);
    await pumpBoard(tester, position(config(), []), size: const Size(360, 740));
    expect(find.byKey(const ValueKey('tictactoeCentre')), findsNothing);
    await pumpBoard(tester, position(config(board: 10), []), size: const Size(1280, 800));
    expect(find.byKey(const ValueKey('tictactoeCentre')), findsNothing);
  });

  testWidgets('hints fit in every language on the narrowest phone', (tester) async {
    for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
      await pumpBoard(tester, position(config(board: 15), []), size: const Size(360, 740), firstGame: true, locale: locale);
      expect(tester.takeException(), isNull, reason: '$locale');
      expect(find.byKey(const ValueKey('tictactoeHint')), findsOneWidget);
    }
  });

  testWidgets('screen readers hear the mark and the position of every cell', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBoard(tester, position(config(), [(2, 0), (0, 1)]));
    expect(find.bySemanticsLabel('✕, sloupec 3, řádek 1'), findsOneWidget);
    expect(find.bySemanticsLabel('◯, sloupec 1, řádek 2'), findsOneWidget);
    expect(find.bySemanticsLabel('volné, sloupec 2, řádek 2'), findsOneWidget);
    handle.dispose();
  });

  group('a move outside the zoomed view is brought into it', () {
    Future<void> robotPlays(WidgetTester tester, List<(int, int)> cells) async {
      final table = tester.state<_TableState>(find.byType(_Table));
      for (final (c, r) in cells) {
        // ignore: invalid_use_of_protected_member
        table.setState(() => table.state = rules.apply(table.state, TictactoeRules.place(table.state.current, c, r)));
        await tester.pump();
      }
      // The glide starts on the frame after the move and takes 350 ms.
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    bool visible(WidgetTester tester, int c, int r) {
      final view = tester.getRect(find.byType(InteractiveViewer));
      final rect = tester.getRect(cell(c, r));
      return view.contains(rect.topLeft) && view.contains(rect.bottomRight);
    }

    testWidgets('the robot answers in a far corner of 15×15 on a phone', (tester) async {
      await pumpBoard(tester, position(config(board: 15, robot: true), [(7, 7)]), size: const Size(360, 740), humans: {0});
      expect(visible(tester, 14, 14), isFalse);
      await robotPlays(tester, [(14, 14)]);
      expect(visible(tester, 14, 14), isTrue);
    });

    testWidgets('a winning row ending off screen is shown, also without animations', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      // ◯ (robot) has (0..3, 0); ✕ scattered in the middle.
      final s = position(config(board: 15, robot: true), [(7, 7), (0, 0), (8, 8), (1, 0), (6, 6), (2, 0), (9, 9), (3, 0), (5, 9)]);
      await pumpBoard(tester, s, size: const Size(360, 740), humans: {0});
      await robotPlays(tester, [(4, 0)]);
      for (var c = 0; c <= 4; c++) {
        expect(visible(tester, c, 0), isTrue, reason: '($c, 0)');
      }
    });
  });

  testWidgets('rotating the device mid-game keeps the game', (tester) async {
    final (_, sent) = await pumpBoard(tester, position(config(board: 10), [(5, 5), (4, 4)]), size: const Size(412, 915));
    tester.view.physicalSize = const Size(915, 412);
    await tester.pump(const Duration(milliseconds: 600));
    // BoardGrid centres the new layout one frame later.
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tapCell(tester, 6, 6);
    expect(sent, [TictactoeRules.place(0, 6, 6)]);
  });

  testWidgets('golden: 3×3 won game and a 15×15 game on a phone', (tester) async {
    await pumpBoard(
      tester,
      position(config(), [(0, 0), (1, 0), (1, 1), (2, 0), (0, 2), (0, 1), (2, 2)]),
      size: const Size(412, 915),
    );
    await tester.pump(const Duration(seconds: 1));
    await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/board_3x3_won.png'));

    await pumpBoard(
      tester,
      position(config(board: 15), [(7, 7), (8, 8), (7, 8), (8, 7), (6, 6), (9, 9), (6, 9), (5, 5)]),
      size: const Size(360, 740),
    );
    await tester.pump(const Duration(seconds: 1));
    await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/board_15x15_phone.png'));
  });
}
