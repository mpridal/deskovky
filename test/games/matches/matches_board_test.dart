import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/matches/matches_module.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';

const rules = MatchesRules();

MatchesState position(List<(int, int)> takes) {
  var s = rules.initialState(
    const GameConfig(
      gameId: 'matches',
      seats: [HumanSeat(1), HumanSeat(2)],
      difficulty: Difficulty.medium,
      robotSpeed: RobotSpeed.fast,
      options: {'start': MatchesStart.first},
    ),
    1,
  );
  for (final (row, count) in takes) {
    s = rules.apply(s, MatchesRules.take(s.current, row, count));
  }
  return s;
}

/// Hosts the board like the game screen: moves are applied and the board
/// rebuilt; [humans] are the seats a person plays here.
class _Table extends StatefulWidget {
  const _Table({super.key, required this.start, required this.host, required this.sent, this.humans = const {0, 1}, this.firstGame = false});

  final MatchesState start;
  final GameTestHost host;
  final List<Move> sent;
  final Set<int> humans;
  final bool firstGame;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  late MatchesState state = widget.start;

  /// A move from elsewhere (a robot, another device).
  void play(int row, int count) => setState(() => state = rules.apply(state, MatchesRules.take(state.current, row, count)));

  @override
  Widget build(BuildContext context) {
    final seat = rules.currentSeat(state);
    final mine = seat != null && widget.humans.contains(seat) ? seat : null;
    return matchesModule.board(
      context,
      GameBoardView<MatchesState>(
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
  MatchesState state, {
  Size size = const Size(412, 915),
  Set<int> humans = const {0, 1},
  bool firstGame = false,
  Locale locale = const Locale('cs'),
  double textScale = 1,
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
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
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

Finder match(int row, int i) => find.byKey(ValueKey('match$row,$i'));
final takeButton = find.byKey(const ValueKey('matchesTake'));

Future<void> tapMatch(WidgetTester tester, int row, int i) async {
  await tester.tapAt(tester.getCenter(match(row, i)));
  await tester.pump(const Duration(milliseconds: 200));
}

Future<void> tapTake(WidgetTester tester) async {
  await tester.tap(takeButton);
  await tester.pump(const Duration(milliseconds: 200));
}

/// Lets every take animation finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

const sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];

void main() {
  setUpAll(loadAppFonts);

  testWidgets('select matches in one row, then "Vzít (n)" takes them', (tester) async {
    final (host, sent) = await pumpBoard(tester, position([]));
    expect(find.text('Vzít (0)'), findsOneWidget);
    await tapTake(tester);
    expect(sent, isEmpty, reason: 'nothing selected, nothing taken');

    await tapMatch(tester, 2, 0);
    await tapMatch(tester, 2, 3);
    expect(find.text('Vzít (2)'), findsOneWidget);
    expect(sent, isEmpty, reason: 'a tap only selects');
    expect(host.sfx, ['matches.pick', 'matches.pick']);

    await tapTake(tester);
    expect(sent, [MatchesRules.take(0, 2, 2)]);
    expect(host.sfx, contains('matches.take'));
    await settle(tester);
    // The very matches selected are gone, the others stay.
    expect(match(2, 0), findsNothing);
    expect(match(2, 3), findsNothing);
    expect(match(2, 1), findsOneWidget);
    expect(find.byKey(const ValueKey('gap2,0')), findsOneWidget);
    expect(find.text('Vzít (0)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a second tap deselects; a tap in another row moves the selection there', (tester) async {
    final (_, sent) = await pumpBoard(tester, position([]));
    await tapMatch(tester, 1, 0);
    await tapMatch(tester, 1, 1);
    await tapMatch(tester, 1, 1);
    expect(find.text('Vzít (1)'), findsOneWidget);
    await tapMatch(tester, 0, 2);
    expect(find.text('Vzít (1)'), findsOneWidget);
    await tapMatch(tester, 0, 0);
    expect(find.text('Vzít (2)'), findsOneWidget);
    await tapTake(tester);
    expect(sent, [MatchesRules.take(0, 0, 2)]);
  });

  testWidgets('nothing can be selected while a robot or another device is to move', (tester) async {
    final (_, sent) = await pumpBoard(tester, position([(0, 1)]), humans: {0});
    await tapMatch(tester, 2, 0);
    expect(find.text('Vzít (0)'), findsOneWidget);
    await tapTake(tester);
    expect(sent, isEmpty);
  });

  testWidgets("another player's take is first shown as a selection, then flies to their pile", (tester) async {
    final (host, _) = await pumpBoard(tester, position([(0, 1)]), humans: {0});
    final table = tester.state<_TableState>(find.byType(_Table));
    table.play(2, 3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Still on the table (selected), the rightmost three of the row.
    expect(match(2, 6), findsOneWidget);
    expect(find.byKey(const ValueKey('flying2,6')), findsNothing);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('flying2,6')), findsOneWidget);
    await settle(tester);
    expect(match(2, 6), findsNothing);
    expect(match(2, 3), findsOneWidget);
    expect(find.byKey(const ValueKey('gap2,4')), findsOneWidget);
    expect(host.sfx, ['matches.take']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('without animations every take shows at once', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpBoard(tester, position([(0, 1)]), humans: {0});
    final table = tester.state<_TableState>(find.byType(_Table));
    table.play(2, 3);
    await tester.pump();
    expect(match(2, 6), findsNothing);
    expect(find.byKey(const ValueKey('flying2,6')), findsNothing);
    expect(find.byKey(const ValueKey('gap2,6')), findsOneWidget);
  });

  testWidgets('the last match lights up: strike sound, the win reported for the other player', (tester) async {
    // 0-0-1 left, seat 1 to move (seat 0 left it).
    final (host, sent) = await pumpBoard(tester, position([(0, 3), (1, 5), (2, 6)]));
    expect(events(host), ['matches.win {seat: 0}'], reason: 'decided before the forced last move');
    await tapMatch(tester, 2, 3);
    await tapTake(tester);
    expect(sent, [MatchesRules.take(1, 2, 1)]);
    expect(host.sfx, containsAllInOrder(['matches.take', 'matches.strike']));
    await settle(tester);
    expect(events(host), ['matches.win {seat: 0}'], reason: 'reported once');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a win decided by a move from another device or a robot is reported from the new state', (tester) async {
    // Seat 1 (a robot or another device) leaves a single match for seat 0.
    final (host, _) = await pumpBoard(tester, position([(0, 3), (1, 5), (2, 5)]), humans: {0});
    expect(host.events, isEmpty);
    final table = tester.state<_TableState>(find.byType(_Table));
    table.play(2, 1);
    await tester.pump();
    expect(events(host), ['matches.win {seat: 1}']);
    await settle(tester);
  });

  testWidgets('taking all the last matches at once reports the win before the move is sent', (tester) async {
    final (host, sent) = await pumpBoard(tester, position([(0, 3), (1, 5)]));
    for (var i = 0; i < 7; i++) {
      await tapMatch(tester, 2, i);
    }
    await tapTake(tester);
    expect(sent.single, MatchesRules.take(0, 2, 7));
    expect(events(host), ['matches.win {seat: 1}']);
    await settle(tester);
  });

  testWidgets('a flawless winner gets flawless too', (tester) async {
    final (host, _) = await pumpBoard(tester, position([(0, 1), (2, 6), (1, 2), (0, 2)]));
    await tapMatch(tester, 1, 1);
    await tapMatch(tester, 1, 2);
    await tapMatch(tester, 1, 3);
    await tapTake(tester);
    expect(events(host), ['matches.win {seat: 0}', 'matches.flawless {seat: 0}']);
    await settle(tester);
  });

  testWidgets('first game: a gentle hint how to play, gone after the first moves', (tester) async {
    await pumpBoard(tester, position([]), firstGame: true);
    expect(find.text('Klepni na sirky v jedné řadě a pak na Vzít'), findsOneWidget);
    await tapMatch(tester, 0, 0);
    await tapTake(tester);
    await settle(tester);
    await tapMatch(tester, 1, 0);
    await tapTake(tester);
    await settle(tester);
    expect(find.byKey(const ValueKey('matchesHint')), findsNothing);
  });

  testWidgets('screen readers hear each match, its row and whether it is selected, and the piles', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBoard(tester, position([(1, 2)]));
    await tapMatch(tester, 2, 0);
    expect(find.bySemanticsLabel('Vybraná sirka, řada 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Sirka, řada 1'), findsNWidgets(3));
    expect(find.bySemanticsLabel('Hráč 1 vzal 2'), findsOneWidget);
    expect(find.bySemanticsLabel('Hráč 2 vzal 0'), findsOneWidget);
    handle.dispose();
  });

  for (final size in sizes) {
    testWidgets('${size.width.toInt()}×${size.height.toInt()}: draws, every match ≥ 48 dp to tap, a whole row can be taken', (tester) async {
      final (_, sent) = await pumpBoard(tester, position([]), size: size, firstGame: true);
      expect(tester.takeException(), isNull);
      for (var row = 0; row < 3; row++) {
        for (var i = 0; i < MatchesRules.initialRows[row]; i++) {
          final box = tester.getSize(match(row, i));
          expect(box.width, greaterThanOrEqualTo(48), reason: '$row,$i');
          expect(box.height, greaterThanOrEqualTo(48), reason: '$row,$i');
          final centre = tester.getCenter(match(row, i));
          expect(centre.dx, inInclusiveRange(0, size.width));
          expect(centre.dy, inInclusiveRange(0, size.height));
        }
      }
      for (var i = 0; i < 7; i++) {
        await tapMatch(tester, 2, i);
      }
      await tapTake(tester);
      expect(sent, [MatchesRules.take(0, 2, 7)]);
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a phone on its side (915×412 under the HUD) still has 48 dp matches', (tester) async {
    await pumpBoard(tester, position([]), size: const Size(915, 412));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(match(2, 6)).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(match(2, 6)).width, greaterThanOrEqualTo(48));
  });

  testWidgets('texts fit in every language on the narrowest phone, also at 130 %', (tester) async {
    for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
      await pumpBoard(tester, position([]), size: const Size(360, 740), firstGame: true, locale: locale, textScale: 1.3);
      await tapMatch(tester, 2, 0);
      expect(tester.takeException(), isNull, reason: '$locale');
      expect(find.byKey(const ValueKey('matchesHint')), findsOneWidget);
    }
  });

  testWidgets('rotating the device mid-game keeps the game and the selection', (tester) async {
    final (_, sent) = await pumpBoard(tester, position([(1, 2)]), size: const Size(412, 915));
    await tapMatch(tester, 2, 5);
    tester.view.physicalSize = const Size(915, 412);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('Vzít (1)'), findsOneWidget);
    await tapTake(tester);
    expect(sent, [MatchesRules.take(1, 2, 1)]);
  });

  testWidgets('golden: the table in the middle of a game on a phone, a tablet and a tablet on its side', (tester) async {
    for (final (size, name) in const [
      (Size(412, 915), 'phone'),
      (Size(800, 1280), 'tablet'),
      (Size(1280, 800), 'landscape'),
    ]) {
      await pumpBoard(tester, position([(1, 2), (2, 3), (0, 1)]), size: size);
      await tapMatch(tester, 2, 1);
      await tapMatch(tester, 2, 2);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/board_$name.png'));
    }
  },
    // The button and the pile numbers use the app fonts, which Linux (CI)
    // antialiases differently from Windows, where the goldens were made.
    skip: !Platform.isWindows,
  );

  testWidgets('golden: the rule steps', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
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
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: matchesModule.ruleSteps(context)),
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
    skip: !Platform.isWindows,
  );
}
