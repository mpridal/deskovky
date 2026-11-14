import 'dart:async';

import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/memory/memory_board.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game_test_host.dart';

const rules = MemoryRules();

MemoryState dealt() => rules.initialState(
  GameConfig(
    gameId: 'memory',
    seats: const [HumanSeat(1), HumanSeat(2)],
    difficulty: Difficulty.medium,
    robotSpeed: RobotSpeed.normal,
    options: const {'cards': 12, 'set': 'animals'},
  ),
  3,
);

/// One device of a network game: [mine] is the seat played here.
Future<(List<Map<String, Object?>>, StreamController<BoardSignal>, List<Move>)> pumpDevice(
  WidgetTester tester, {
  required int mine,
  bool network = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(412, 915);
  addTearDown(tester.view.reset);
  final sent = <Map<String, Object?>>[];
  final incoming = StreamController<BoardSignal>.broadcast();
  addTearDown(incoming.close);
  final moves = <Move>[];
  final state = dealt();
  final turn = rules.currentSeat(state);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('cs'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Material(
        color: AppColors.felt,
        child: MemoryBoard(
          view: GameBoardView<MemoryState>(
            state: state,
            lastMove: null,
            mySeat: turn == mine ? mine : null,
            canAct: turn == mine,
            submit: (m) async {
              moves.add(m);
              return true;
            },
            host: GameTestHost(),
            localSeats: {mine},
            signal: network ? sent.add : null,
            signals: incoming.stream,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (sent, incoming, moves);
}

Finder card(int c) => find.byKey(ValueKey('memory.card$c'));

void main() {
  testWidgets('not on turn over Wi-Fi: a tap on a card sends a hint, no move', (tester) async {
    final (sent, _, moves) = await pumpDevice(tester, mine: 1); // seat 0 is on turn
    await tester.tap(card(4));
    await tester.pump(const Duration(milliseconds: 300));
    expect(sent, [
      {'hint': 4},
    ]);
    expect(moves, isEmpty);
    expect(find.text('Nápověda odeslána'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('on one device (no Wi-Fi) a tap out of turn does nothing', (tester) async {
    final (sent, _, moves) = await pumpDevice(tester, mine: 1, network: false);
    await tester.tap(card(4));
    await tester.pump(const Duration(milliseconds: 300));
    expect(sent, isEmpty);
    expect(moves, isEmpty);
  });

  testWidgets('the player on turn sees the hinted card shake and who hinted', (tester) async {
    final (_, incoming, _) = await pumpDevice(tester, mine: 0); // seat 0 on turn here
    incoming.add(const BoardSignal(seat: 1, name: 'Kuba', data: {'hint': 6}));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('memory.hint6')), findsOneWidget, reason: 'card 6 shakes');
    expect(find.text('Nápověda od Kuba'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Nápověda od Kuba'), findsNothing, reason: 'it fades after a while');
    expect(find.byKey(const ValueKey('memory.hint6')), findsNothing);
  });

  testWidgets('a hint for a card already open or found is ignored', (tester) async {
    final (_, incoming, _) = await pumpDevice(tester, mine: 0);
    incoming.add(const BoardSignal(seat: 1, name: 'Kuba', data: {'hint': 99}));
    incoming.add(const BoardSignal(seat: 1, name: 'Kuba', data: {'nonsense': true}));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Nápověda od'), findsNothing);
  });

  testWidgets('a device whose player is not on turn shows nothing for others\' hints', (tester) async {
    final (_, incoming, _) = await pumpDevice(tester, mine: 1);
    incoming.add(const BoardSignal(seat: 0, name: 'Táta', data: {'hint': 2}));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Nápověda od'), findsNothing);
  });
}
