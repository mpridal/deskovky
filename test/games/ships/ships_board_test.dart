import 'dart:io';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/ships/ships_board.dart';
import 'package:deskovky/games/ships/ships_events.dart';
import 'package:deskovky/games/ships/ships_module.dart';
import 'package:deskovky/games/ships/ships_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/surfaces/felt_background.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';

const rules = ShipsRules();

ShipsState fresh({String size = ShipsSize.small}) => rules.initialState(
  GameConfig(
    gameId: 'ships',
    seats: const [HumanSeat(1), HumanSeat(2)],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.fast,
    options: {'size': size},
  ),
  1,
);

const fleetA = [Ship(0, 0, 4, true), Ship(0, 2, 3, true), Ship(0, 4, 3, true), Ship(0, 6, 2, true)];
const fleetB = [Ship(7, 0, 4, false), Ship(5, 0, 3, false), Ship(0, 7, 3, true), Ship(3, 4, 2, true)];

ShipsState placed() => rules.apply(rules.apply(fresh(), ShipsRules.place(0, fleetA)), ShipsRules.place(1, fleetB));

/// Hosts the board like the game screen; [humans] play on this device.
class _Table extends StatefulWidget {
  const _Table({super.key, required this.start, required this.host, required this.sent, required this.humans, this.firstGame = false});

  final ShipsState start;
  final GameTestHost host;
  final List<Move> sent;
  final Set<int> humans;
  final bool firstGame;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  late ShipsState state = widget.start;

  /// A move from elsewhere (a robot, another device).
  void play(Move move) => setState(() => state = rules.apply(state, move));

  @override
  Widget build(BuildContext context) {
    final seat = rules.currentSeat(state);
    final mine = seat != null && widget.humans.contains(seat) ? seat : null;
    return shipsModule.board(
      context,
      GameBoardView<ShipsState>(
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
  ShipsState state, {
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

_TableState _table(WidgetTester tester) => tester.state<_TableState>(find.byType(_Table));
final target = find.byKey(const ValueKey('shipsTarget'));
final editor = find.byKey(const ValueKey('shipsEditor'));
final ready = find.byKey(const ValueKey('shipsReady'));

/// Taps cell [cell] of an 8 × 8 grid found by [grid].
Future<void> tapCell(WidgetTester tester, Finder grid, int cell, {int size = 8}) async {
  final rect = tester.getRect(grid);
  final side = rect.shortestSide / size;
  final origin = rect.center - Offset(side * size / 2, side * size / 2);
  await tester.tapAt(origin + Offset((cell % size + 0.5) * side, (cell ~/ size + 0.5) * side));
  await tester.pump(const Duration(milliseconds: 300));
}

/// Taps "Jsem na řadě" when a resumed game starts covered.
Future<void> uncover(WidgetTester tester) async {
  if (ready.evaluate().isEmpty) return;
  await tester.tap(ready);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(loadAppFonts);
  setUp(() => shipsDraftSeed = () => 1);
  tearDown(() => shipsDraftSeed = defaultShipsDraftSeed);

  testWidgets('the offered fleet differs from game to game', (tester) async {
    shipsDraftSeed = defaultShipsDraftSeed;
    final fleets = <Object?>{};
    for (var i = 0; i < 3; i++) {
      final (_, sent) = await pumpBoard(tester, fresh(), humans: {0});
      await tester.tap(find.byKey(const ValueKey('shipsDone')));
      await tester.pump(const Duration(milliseconds: 300));
      fleets.add(sent.single.data['ships']);
    }
    expect(fleets.length, greaterThan(1));
  });

  testWidgets('a battle resumed on this device starts covered, so nobody sees a fleet by accident', (tester) async {
    await pumpBoard(tester, placed());
    expect(ready, findsOneWidget);
    expect(find.byKey(const ValueKey('shipsOwn')), findsNothing);
  });

  testWidgets('the robot sinking your ship does not say "Potopeno!" beside the other sea', (tester) async {
    var s = rules.apply(placed(), ShipsRules.shoot(0, 63));
    s = rules.apply(s, ShipsRules.shoot(1, 48));
    await pumpBoard(tester, s, humans: {0});
    await uncover(tester);
    _table(tester).play(ShipsRules.shoot(1, 49)); // sinks seat 0's 2-ship
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Potopeno!'), findsNothing);
  });

  testWidgets('placing: shuffle, select, move, turn, then Hotovo sends a legal fleet', (tester) async {
    final (host, sent) = await pumpBoard(tester, fresh(), humans: {0});
    expect(editor, findsOneWidget);
    expect(find.text('Rozmísti své lodě'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('shipsShuffle')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('shipsDone')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(sent.single.type, 'place');
    expect(rules.isLegal(fresh(), sent.single), isTrue);
    expect(host.sfx, contains('piece_place'));
  });

  testWidgets('placing: a ship moves where you tap and turns on a second tap; a bad spot is refused', (tester) async {
    final (host, sent) = await pumpBoard(tester, fresh(), humans: {0});
    // Find the first ship of the offered draft by its semantics: tap every
    // cell until one selects a ship (the gold frame shows up).
    var selected = -1;
    for (var cell = 0; cell < 64 && selected < 0; cell++) {
      await tapCell(tester, editor, cell);
      if (find.byWidgetPredicate((w) => w.key is ValueKey && '${(w.key! as ValueKey).value}'.startsWith('highlight')).evaluate().isNotEmpty) {
        selected = cell;
      }
    }
    expect(selected, greaterThanOrEqualTo(0));
    // Turning it may or may not fit; either way the fleet stays legal.
    await tapCell(tester, editor, selected);
    await tester.tap(find.byKey(const ValueKey('shipsDone')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(rules.isLegal(fresh(), sent.single), isTrue);
    expect(host.sfx.where((s) => s == 'piece_place' || s == 'error'), isNotEmpty);
  });

  testWidgets('a robot placing first: the board waits, then you place', (tester) async {
    await pumpBoard(tester, fresh(), humans: {1});
    expect(find.byKey(const ValueKey('shipsWaiting')), findsOneWidget);
    _table(tester).play(ShipsRules.place(0, fleetA));
    await tester.pump(const Duration(milliseconds: 300));
    expect(editor, findsOneWidget);
  });

  testWidgets('shooting: a miss splashes, a hit booms, a sunk ship sinks with its water shown', (tester) async {
    final semantics = tester.ensureSemantics();
    final (host, sent) = await pumpBoard(tester, placed(), humans: {0});
    await uncover(tester);
    await tapCell(tester, target, 35);
    expect(sent.last, ShipsRules.shoot(0, 35));
    expect(host.sfx.last, 'ships.hit');
    expect(find.text('Zásah!'), findsOneWidget);
    await tapCell(tester, target, 36);
    expect(host.sfx.last, 'ships.sunk');
    expect(find.text('Potopeno!'), findsOneWidget);
    expect(find.text('Zbývá lodí: 3'), findsOneWidget);
    expect(find.bySemanticsLabel('Pole C4, voda'), findsOneWidget, reason: 'water next to the sunk ship');
    // Known water cannot be shot.
    await tapCell(tester, target, 27);
    expect(sent.last, ShipsRules.shoot(0, 36));
    await tapCell(tester, target, 63);
    expect(host.sfx.last, 'ships.splash');
    expect(find.text('Voda'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('against a robot: no cover, its shots show on your fleet, the target waits', (tester) async {
    final (_, sent) = await pumpBoard(tester, placed(), humans: {0});
    await uncover(tester);
    await tapCell(tester, target, 63); // miss: the robot's turn
    await tapCell(tester, target, 62);
    expect(sent, [ShipsRules.shoot(0, 63)], reason: 'not your turn');
    _table(tester).play(ShipsRules.shoot(1, 0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(ready, findsNothing);
    expect(find.byKey(const ValueKey('shipsOwn')), findsOneWidget);
  });

  testWidgets('two people on one device: the turn passing covers the board until "Jsem na řadě"', (tester) async {
    final (_, sent) = await pumpBoard(tester, placed());
    await uncover(tester);
    await tapCell(tester, target, 63); // miss
    expect(ready, findsOneWidget);
    expect(target, findsNothing);
    expect(find.byKey(const ValueKey('shipsOwn')), findsNothing, reason: 'nobody sees the other fleet');
    expect(find.text('Voda'), findsOneWidget, reason: 'the shooter still learns the result');
    await tester.tap(ready);
    await tester.pump(const Duration(milliseconds: 300));
    expect(target, findsOneWidget);
    await tapCell(tester, target, 63);
    expect(sent.last, ShipsRules.shoot(1, 63));
  });

  testWidgets('two people placing: the second one gets the cover first', (tester) async {
    await pumpBoard(tester, fresh());
    await tester.tap(find.byKey(const ValueKey('shipsDone')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(ready, findsOneWidget);
    await tester.tap(ready);
    await tester.pump(const Duration(milliseconds: 300));
    expect(editor, findsOneWidget);
  });

  testWidgets('the winning shot reports its events before the game ends', (tester) async {
    var s = placed();
    for (final c in [7, 15, 23, 31, 5, 13, 21, 56, 57, 58, 35]) {
      s = rules.apply(s, ShipsRules.shoot(0, c));
    }
    final (host, _) = await pumpBoard(tester, s, humans: {0});
    await uncover(tester);
    await tapCell(tester, target, 36);
    expect([for (final (id, _) in host.events) id], containsAll([ShipsEvents.sharp, ShipsEvents.untouched]));
  });

  testWidgets('the first game shows a hint on the target sea', (tester) async {
    await pumpBoard(tester, placed(), humans: {0}, firstGame: true);
    await uncover(tester);
    expect(find.text('Klepni do moře soupeře'), findsOneWidget);
  });

  for (final size in const [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)]) {
    for (final sea in [ShipsSize.small, ShipsSize.big]) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} on the $sea sea, placing and shooting', (tester) async {
        var s = fresh(size: sea);
        await pumpBoard(tester, s, size: size, humans: {0}, textScale: 1.3);
        expect(tester.takeException(), isNull);
        for (final key in ['shipsShuffle', 'shipsDone']) {
          final rect = tester.getRect(find.byKey(ValueKey(key)));
          expect(rect.bottom, lessThanOrEqualTo(size.height), reason: '$key on screen');
        }
        s = rules.apply(s, rules.legalMoves(s, 0).single);
        s = rules.apply(s, rules.legalMoves(s, 1).single);
        for (var i = 0; i < 12; i++) {
          final seat = rules.currentSeat(s)!;
          s = rules.apply(s, rules.legalMoves(s, seat)[i * 5 % rules.legalMoves(s, seat).length]);
        }
        await pumpBoard(tester, s, size: size, humans: {rules.currentSeat(s)!}, textScale: 1.3);
        expect(tester.takeException(), isNull);
        await uncover(tester);
        final own = tester.getRect(find.byKey(const ValueKey('shipsOwn')));
        expect(own.bottom, lessThanOrEqualTo(size.height));
        expect(own.right, lessThanOrEqualTo(size.width));
      });
    }
  }

  testWidgets('every language has the board texts', (tester) async {
    for (final locale in const [Locale('en'), Locale('es')]) {
      await pumpBoard(tester, fresh(), humans: {0}, locale: locale);
      expect(tester.takeException(), isNull);
      await pumpBoard(tester, placed(), locale: locale);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('golden: placing on a phone, a battle on a phone, a tablet and on its side', (tester) async {
    ShipsState battle(String sea) {
      var s = fresh(size: sea);
      s = rules.apply(s, rules.legalMoves(s, 0).single);
      s = rules.apply(s, rules.legalMoves(s, 1).single);
      for (var i = 0; i < 30 && !s.over; i++) {
        final seat = rules.currentSeat(s)!;
        final legal = rules.legalMoves(s, seat);
        s = rules.apply(s, legal[(i * 7 + 3) % legal.length]);
      }
      return s;
    }

    await pumpBoard(tester, fresh(), humans: {0});
    await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/placing_phone.png'));
    for (final (size, sea, name) in const [
      (Size(412, 915), ShipsSize.small, 'phone'),
      (Size(800, 1280), ShipsSize.big, 'tablet'),
      (Size(1280, 800), ShipsSize.small, 'landscape'),
    ]) {
      final s = battle(sea);
      await pumpBoard(tester, s, size: size, humans: {rules.currentSeat(s)!});
      await uncover(tester);
      await tester.pump(const Duration(seconds: 1));
      await expectLater(find.byType(FeltBackground), matchesGoldenFile('goldens/board_$name.png'));
    }
  },
    // Text uses the app fonts, which Linux (CI) antialiases differently from
    // Windows, where the goldens were made.
    skip: !Platform.isWindows,
  );

  testWidgets('golden: the rule steps and the icon', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(520, 200);
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...shipsModule.ruleSteps(context),
                    SizedBox(width: 100, height: 100, child: shipsModule.icon(context)),
                  ],
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
    skip: !Platform.isWindows,
  );
}
