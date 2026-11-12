import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/war/war_events.dart';
import 'package:deskovky/games/war/war_module.dart';
import 'package:deskovky/games/war/war_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';

const rules = WarRules();

int c(int rank, [int suit = 0]) => WarCard.of(rank, suit);

WarState dealt(int players, {int seed = 1}) => rules.initialState(
  GameConfig(
    gameId: 'war',
    seats: [for (var i = 0; i < players; i++) HumanSeat(i + 1)],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: const {},
  ),
  seed,
);

WarState deal(List<List<int>> decks) => WarState(
  decks: decks,
  table: [for (final _ in decks) const []],
  contenders: [for (var s = 0; s < decks.length; s++) s],
  flipped: const [],
  warDepth: 0,
  battleWinner: null,
  round: 0,
  maxRounds: 30,
  out: const [],
  lowest: [for (final d in decks) d.length],
  doubleWar: [for (final _ in decks) false],
  wars: 0,
  over: false,
);

/// Hosts the board like the game screen: moves are applied and the board
/// rebuilt; [humans] are the seats a person plays here.
class _Table extends StatefulWidget {
  const _Table({super.key, required this.start, required this.host, required this.sent, required this.humans, this.firstGame = false});

  final WarState start;
  final GameTestHost host;
  final List<Move> sent;
  final Set<int> humans;
  final bool firstGame;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  late WarState state = widget.start;

  /// A move from elsewhere (a robot, another device).
  void play() => setState(() => state = rules.apply(state, rules.legalMoves(state, rules.currentSeat(state)!).single));

  @override
  Widget build(BuildContext context) {
    final seat = rules.currentSeat(state);
    final mine = seat != null && widget.humans.contains(seat) ? seat : null;
    return warModule.board(
      context,
      GameBoardView<WarState>(
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
  WarState state, {
  Size size = const Size(412, 915),
  Set<int>? humans,
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
            child: _Table(
              key: UniqueKey(),
              start: state,
              host: host,
              sent: sent,
              humans: humans ?? {for (var i = 0; i < state.seats; i++) i},
              firstGame: firstGame,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  return (host, sent);
}

Finder pile(int seat) => find.byKey(ValueKey('warPile$seat'));
final collectButton = find.byKey(const ValueKey('warCollect'));

Future<void> tapPile(WidgetTester tester, int seat) async {
  await tester.tap(pile(seat));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('tapping your pile turns the card; the winner takes the table', (tester) async {
    final (host, sent) = await pumpBoard(
      tester,
      deal([
        [c(9), c(7)],
        [c(12), c(10)],
      ]),
    );
    await tapPile(tester, 1);
    expect(sent, isEmpty, reason: 'not seat 1’s turn yet');
    await tapPile(tester, 0);
    expect(sent, [WarRules.flip(0)]);
    expect(host.sfx, contains('card_flip'));
    expect(find.text('Q'), findsNothing);
    await tapPile(tester, 1);
    expect(find.text('Q'), findsWidgets, reason: 'the queen is face up');
    expect(tester.widget<PrimaryButton>(collectButton).onPressed, isNotNull);
    expect(find.text('Vzít karty (2)'), findsOneWidget);
    await tester.tap(collectButton);
    await tester.pump(const Duration(milliseconds: 300));
    expect(sent.last, WarRules.collect(1));
    expect(find.text('Kolo 2 z 30'), findsOneWidget);
    expect(collectButton, findsNothing);
  });

  testWidgets('a robot or another device: the pile cannot be tapped, the take button waits', (tester) async {
    final (_, sent) = await pumpBoard(
      tester,
      deal([
        [c(9), c(7)],
        [c(12), c(10)],
      ]),
      humans: {0},
    );
    await tapPile(tester, 0);
    final table = tester.state<_TableState>(find.byType(_Table));
    table.play();
    await tester.pump(const Duration(milliseconds: 300));
    final button = tester.widget<PrimaryButton>(collectButton);
    expect(button.onPressed, isNull);
    await tapPile(tester, 1);
    expect(sent, [WarRules.flip(0)]);
  });

  testWidgets('a tie shows "Válka!" and a war after a war reports its event once', (tester) async {
    final (host, _) = await pumpBoard(
      tester,
      deal([
        [c(10), c(7), c(9), c(7, 2), c(13), c(8)],
        [c(10, 1), c(8, 1), c(9, 1), c(8, 2), c(12), c(7, 1)],
      ]),
    );
    await tapPile(tester, 0);
    await tapPile(tester, 1);
    expect(find.text('Válka!'), findsOneWidget);
    await tapPile(tester, 0);
    await tapPile(tester, 1);
    expect(find.text('Válka! ×2'), findsOneWidget);
    await tapPile(tester, 0);
    await tapPile(tester, 1);
    expect([for (final (id, _) in host.events) id], [WarEvents.doubleWar]);
    await tester.tap(collectButton);
    await tester.pump(const Duration(milliseconds: 300));
    expect([for (final (id, _) in host.events) id], [WarEvents.doubleWar]);
  });

  testWidgets('the first game shows a hint on the pile', (tester) async {
    await pumpBoard(tester, dealt(2), firstGame: true);
    expect(find.text('Klepni na svůj balíček'), findsOneWidget);
  });

  for (final size in const [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)]) {
    for (final players in [2, 3, 4]) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} with $players players, in a war too', (tester) async {
        var s = dealt(players, seed: 3);
        // Several battles in, mid-war where one comes up.
        for (var i = 0; i < 40 && !(s.warDepth > 0 && s.battleWinner == null); i++) {
          s = rules.apply(s, rules.legalMoves(s, rules.currentSeat(s)!).single);
        }
        await pumpBoard(tester, s, size: size, textScale: 1.3);
        expect(tester.takeException(), isNull);
        for (var seat = 0; seat < players; seat++) {
          final rect = tester.getRect(pile(seat));
          expect(rect.width, greaterThanOrEqualTo(48), reason: 'seat $seat pile is tappable');
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
        }
      });
    }
  }

  testWidgets('every language has the board texts', (tester) async {
    for (final locale in const [Locale('en'), Locale('es')]) {
      await pumpBoard(tester, dealt(2), locale: locale);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('golden: a war on a phone, four players on a tablet, two on a tablet on its side', (tester) async {
    WarState midWar(int players, int seed) {
      var s = dealt(players, seed: seed);
      for (var i = 0; i < 400 && !(s.warDepth > 0 && s.battleWinner != null); i++) {
        s = rules.apply(s, rules.legalMoves(s, rules.currentSeat(s)!).single);
      }
      return s;
    }

    for (final (size, players, name) in const [
      (Size(412, 915), 2, 'phone'),
      (Size(800, 1280), 4, 'tablet'),
      (Size(1280, 800), 2, 'landscape'),
    ]) {
      await pumpBoard(tester, midWar(players, 3), size: size);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/board_$name.png'));
    }
  },
    // Text uses the app fonts, which Linux (CI) antialiases differently from
    // Windows, where the goldens were made.
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
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: warModule.ruleSteps(context)),
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
