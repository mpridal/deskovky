import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game_kit/dice.dart';
import 'package:deskovky/core/game_kit/piece_token.dart';
import 'package:deskovky/games/ludo/ludo_events.dart';
import 'package:deskovky/games/ludo/ludo_geometry.dart';
import 'package:deskovky/games/ludo/ludo_module.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../game_test_host.dart';
import 'ludo_test_utils.dart';

/// Plays like the game screen: moves sent by the board are applied and the
/// board gets the new state. [robotSeats] cannot act on this device.
class _Table extends StatefulWidget {
  const _Table({required this.session, required this.host, this.robotSeats = const {}, this.firstGame = false});

  final GameSession<LudoState> session;
  final GameTestHost host;
  final Set<int> robotSeats;
  final bool firstGame;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    final seat = rules.currentSeat(s.state);
    final mine = seat != null && !widget.robotSeats.contains(seat) ? seat : null;
    return ludoModule.board(
      context,
      GameBoardView<LudoState>(
        state: s.state,
        lastMove: s.lastMove,
        mySeat: mine,
        canAct: mine != null,
        submit: (Move m) async {
          final ok = s.apply(m);
          if (ok) setState(() {});
          return ok;
        },
        host: widget.host,
        firstGame: widget.firstGame,
      ),
    );
  }
}

/// The area the game screen leaves for the board on a [size] screen.
Future<void> pumpTable(
  WidgetTester tester,
  Size size,
  GameSession<LudoState> session,
  GameTestHost host, {
  Set<int> robotSeats = const {},
  bool firstGame = false,
  String locale = 'cs',
  bool animations = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final wide = size.width >= 600;
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      locale: Locale(locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: !animations),
        child: Scaffold(
          backgroundColor: const Color(0xFF2F5D50),
          body: Column(
            children: [
              SizedBox(height: wide ? 64 : 124),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _Table(session: session, host: host, robotSeats: robotSeats, firstGame: firstGame),
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

GameSession<LudoState> newSession({int players = 4, Map<String, Object?> options = const {}, int seed = 5}) =>
    GameSession.start(rules, ludoConfig(players: players, options: options), seed);

/// Rolls (through the rules) until the seat to move can pick a piece.
void rollUntilChoice(GameSession<LudoState> session) {
  for (var i = 0; i < 500 && session.state.phase == LudoPhase.roll; i++) {
    session.apply(roll(session.state));
  }
}

const sizes = {
  'phone small': Size(360, 740),
  'phone': Size(412, 915),
  'tablet portrait': Size(800, 1280),
  'tablet landscape': Size(1280, 800),
};

void main() {
  for (final MapEntry(key: name, value: size) in sizes.entries) {
    testWidgets('$name: the whole board and the die fit, fields stay apart', (tester) async {
      final session = newSession();
      await pumpTable(tester, size, session, GameTestHost());
      expect(tester.takeException(), isNull);
      expect(find.byType(PieceToken), findsNWidgets(16));
      final dice = tester.getRect(find.byType(Dice));
      final screen = Offset.zero & size;
      expect(screen.contains(dice.topLeft) && screen.contains(dice.bottomRight), isTrue);
      // Every piece lies inside the screen and no two overlap.
      final rects = [for (final e in find.byType(PieceToken).evaluate()) tester.getRect(find.byWidget(e.widget))];
      for (final (i, r) in rects.indexed) {
        expect(screen.contains(r.topLeft) && screen.contains(r.bottomRight), isTrue, reason: '$r');
        for (final other in rects.skip(i + 1)) {
          expect(r.overlaps(other), isFalse);
        }
        expect(r.overlaps(dice), isFalse, reason: 'the die is beside the board');
      }
      // Phones: die under the board; landscape tablet: beside it.
      final board = tester.getRect(find.byKey(const ValueKey('piece0-0')));
      if (size.width > size.height) {
        expect(dice.left, greaterThan(board.right));
      } else {
        expect(dice.top, greaterThan(rects.map((r) => r.bottom).reduce((a, b) => a > b ? a : b)));
      }
    });
  }

  testWidgets('turning the device mid-move breaks nothing; pieces settle on their fields', (tester) async {
    final before = rules.rollWith(position([[5], [28]]), 3);
    final table = _Fixed(state: before);
    await table.pump(tester, GameTestHost(), animations: true);
    await table.update(tester, rules.apply(before, pick(before, 0)), pick(before, 0));
    await tester.pump(const Duration(milliseconds: 100));
    tester.view.physicalSize = const Size(915, 412);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    final hunter = tester.getRect(find.byKey(const ValueKey('piece0-0')));
    final victim = tester.getRect(find.byKey(const ValueKey('piece1-0')));
    expect(hunter.overlaps(victim), isFalse);
    expect(hunter.bottom, lessThanOrEqualTo(412));
  });

  testWidgets('tapping the die rolls; a roll without a six passes on with "no move"', (tester) async {
    final session = newSession(players: 2, seed: 3);
    final host = GameTestHost();
    await pumpTable(tester, sizes['phone']!, session, host);
    expect(find.text('Ukončit a seřadit'), findsNothing, reason: 'no early end before any piece is home');
    await tester.tap(find.byType(Dice));
    await tester.pump();
    expect(session.moves, [const Move(seat: 0, type: 'roll')]);
    expect(host.sfx, contains('dice_roll'));
    expect(host.haptics, 1);
    if (session.state.dice != 6) expect(find.text('Nedá se táhnout'), findsOneWidget);
  });

  testWidgets('a movable piece pulses; tapping it moves it and the piece hops', (tester) async {
    final s = position([[0, 10, base, base], [base, base, base, base]], options: {'autoMove': false});
    final host = GameTestHost();
    final table = _Fixed(state: rules.rollWith(s, 3));
    await table.pump(tester, host);
    final tokens = tester.widgetList<PieceToken>(find.byType(PieceToken)).toList();
    expect(tokens.where((t) => t.pulse), hasLength(2));
    await tester.tap(find.byKey(const ValueKey('piece0-1')));
    await tester.pump();
    expect(table.sent, [const Move(seat: 0, type: 'move', data: {'piece': 1})]);
  });

  testWidgets('a tap next to a small field still picks the nearest movable piece', (tester) async {
    final s = rules.rollWith(position([[0, 20], [base]]), 3);
    final table = _Fixed(state: s);
    await table.pump(tester, GameTestHost(), size: sizes['phone small']!);
    final piece = tester.getRect(find.byKey(const ValueKey('piece0-0')));
    await tester.tapAt(piece.center + Offset(piece.width * 0.75, 0));
    await tester.pump();
    expect(table.sent.single.data['piece'], 0);
  });

  testWidgets('the only possible move plays by itself; with the option off it waits', (tester) async {
    final one = rules.rollWith(position([[5, base, base, base], [base, base, base, base]]), 2);
    final auto = _Fixed(state: one);
    await auto.pump(tester, GameTestHost());
    expect(auto.sent, isEmpty);
    await tester.pump(const Duration(milliseconds: 800));
    expect(auto.sent, [const Move(seat: 0, type: 'move', data: {'piece': 0})]);

    final manual = _Fixed(state: rules.rollWith(position([[5, base, base, base], [base, base, base, base]], options: {'autoMove': false}), 2));
    await manual.pump(tester, GameTestHost());
    await tester.pump(const Duration(seconds: 2));
    expect(manual.sent, isEmpty);
  });

  testWidgets('a robot\'s turn: nothing reacts to taps, no stop button', (tester) async {
    final session = newSession(players: 2);
    await pumpTable(tester, sizes['phone']!, session, GameTestHost(), robotSeats: {0});
    await tester.tap(find.byType(Dice));
    await tester.pump();
    expect(session.moves, isEmpty);
    expect(find.text('Ukončit a seřadit'), findsNothing);
  });

  testWidgets('on a network client "Ukončit a seřadit" is not offered: only the host ends the game for everyone', (tester) async {
    final table = _Fixed(state: position([[3, base], [41, base]]), canEndForAll: false);
    await table.pump(tester, GameTestHost());
    expect(find.byKey(const ValueKey('ludoStop')), findsNothing);
  });

  testWidgets('"Ukončit a seřadit" asks first, then ends the game', (tester) async {
    final table = _Fixed(state: position([[3, base], [41, base]]));
    await table.pump(tester, GameTestHost());
    await tester.tap(find.byKey(const ValueKey('ludoStop')));
    await tester.pumpAndSettle();
    expect(find.text('Ukončit hru?'), findsOneWidget);
    await tester.tap(find.text('Hrát dál'));
    await tester.pumpAndSettle();
    expect(table.sent, isEmpty);
    await tester.tap(find.byKey(const ValueKey('ludoStop')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ukončit a seřadit').last);
    await tester.pumpAndSettle();
    expect(table.sent, [const Move(seat: 0, type: 'stop')]);
  });

  testWidgets('the die cannot be tapped again while it is still rolling', (tester) async {
    final start = position([[38, 43], [base, base]]);
    final table = _Fixed(state: start);
    await table.pump(tester, GameTestHost(), animations: true);
    await tester.tap(find.byType(Dice));
    // A six that cannot move: the same seat rolls again.
    final six = rules.rollWith(start, 6);
    expect(six.phase, LudoPhase.roll);
    await table.update(tester, six, roll(start));
    await tester.tap(find.byType(Dice), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(table.sent, hasLength(1), reason: 'the first roll is still shown');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.byType(Dice));
    await tester.pump();
    expect(table.sent, hasLength(2));
  });

  testWidgets('a capture: the hunter hops, the victim flies home with "boing"', (tester) async {
    final before = rules.rollWith(position([[5], [28]]), 3);
    final after = rules.apply(before, pick(before, 0));
    final host = GameTestHost();
    final table = _Fixed(state: before);
    await table.pump(tester, host, animations: true);
    await tester.pump(const Duration(seconds: 1));
    host.sfx.clear();
    await table.update(tester, after, pick(before, 0));
    expect(host.sfx, ['ludo.hop']);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(host.sfx, ['ludo.hop', 'ludo.boing']);
    await tester.pump(const Duration(seconds: 2));
    // The victim stands in its corner.
    final cell = tester.getSize(find.byType(CustomPaint).first).width / LudoGeometry.size;
    expect(cell, greaterThan(0));
    final victim = tester.getRect(find.byKey(const ValueKey('piece1-0')));
    final hunter = tester.getRect(find.byKey(const ValueKey('piece0-0')));
    expect(victim.overlaps(hunter), isFalse);
  });

  testWidgets('reaching the home plays "home"', (tester) async {
    final before = rules.rollWith(position([[37, 43], [5, base]]), 3);
    final after = rules.apply(before, pick(before, 0));
    final host = GameTestHost();
    final table = _Fixed(state: before);
    await table.pump(tester, host);
    await table.update(tester, after, pick(before, 0));
    await tester.pump();
    expect(host.sfx, containsAll(['ludo.hop', 'ludo.home']));
  });

  testWidgets('badge events are reported once, from the totals in the state', (tester) async {
    final base4 = position([[base], [base], [base], [base]]);
    final s = base4.copyWith(
      stats: [
        const LudoSeatStats(captured: 3, bestSixRun: 3),
        const LudoSeatStats(captures: 5),
        const LudoSeatStats(),
        const LudoSeatStats(),
      ],
    );
    final host = GameTestHost();
    final table = _Fixed(state: s);
    await table.pump(tester, host);
    await table.update(tester, s.copyWith(current: 1), null);
    expect([for (final (id, data) in host.events) '$id $data'], unorderedEquals([
      '${LudoEvents.captured3} {seat: 0}',
      '${LudoEvents.sixes} {seat: 0}',
      '${LudoEvents.hunter} {seat: 1}',
    ]), reason: 'no "Rodinná hra" before the game is well under way');
    // Four people and a piece home: now it counts as a family game.
    await table.update(tester, s.copyWith(current: 2, pieces: [[base], [41], [base], [base]]), null);
    await table.update(tester, s.copyWith(current: 3, pieces: [[base], [42], [base], [base]]), null);
    expect([for (final (id, _) in host.events) id].where((id) => id == LudoEvents.family), hasLength(1));
  });

  testWidgets('no "Rodinná hra" with a robot at the table', (tester) async {
    final host = GameTestHost();
    final s = rules.initialState(ludoConfig(players: 4, robots: 1), 1).copyWith(pieces: [[41, base, base, base], for (var i = 0; i < 3; i++) [base, base, base, base]]);
    await _Fixed(state: s).pump(tester, host);
    expect(host.events, isEmpty);
  });

  testWidgets('first game: a gentle hint what to tap', (tester) async {
    final session = newSession(players: 2);
    await pumpTable(tester, sizes['phone']!, session, GameTestHost(), firstGame: true);
    expect(find.text('Ťukni na kostku.'), findsOneWidget);
  });

  for (final locale in ['cs', 'en', 'es']) {
    testWidgets('$locale: texts fit on the smallest phone', (tester) async {
      final s = rules.rollWith(position([[base, base], [base, base]]), 2);
      await _Fixed(state: s, firstGame: true).pump(tester, GameTestHost(), size: sizes['phone small']!, locale: locale);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a whole game against robots plays through the board', (tester) async {
    final session = GameSession.start(rules, ludoConfig(players: 2, options: {'length': 'short'}), 8);
    final host = GameTestHost();
    await pumpTable(tester, sizes['tablet landscape']!, session, host);
    for (var i = 0; i < 3000 && !rules.isOver(session.state); i++) {
      if (session.state.phase == LudoPhase.roll) {
        await tester.tap(find.byType(Dice));
      } else {
        final step = LudoRules.currentSteps(session.state).first;
        await tester.tap(find.byKey(ValueKey('piece${session.state.current}-${step.piece}')), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 800));
      }
      await tester.pump();
    }
    expect(rules.isOver(session.state), isTrue);
    expect(tester.takeException(), isNull);
  });
}

/// A board with a fixed state (the test swaps states by hand).
class _Fixed {
  _Fixed({required this.state, this.firstGame = false, this.canEndForAll = true});

  LudoState state;
  final bool firstGame;

  /// False on a network client: only the host ends the game for everyone.
  final bool canEndForAll;
  final sent = <Move>[];
  final _key = GlobalKey<_HolderState>();

  Future<void> pump(
    WidgetTester tester,
    GameTestHost host, {
    Size size = const Size(412, 915),
    String locale = 'cs',
    bool animations = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        locale: Locale(locale),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MediaQuery(
          data: MediaQueryData(size: size, disableAnimations: !animations),
          child: Scaffold(
            backgroundColor: const Color(0xFF2F5D50),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: _Holder(key: _key, fixed: this, host: host),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> update(WidgetTester tester, LudoState next, Move? lastMove) async {
    state = next;
    _key.currentState!.show(lastMove);
    await tester.pump();
  }
}

class _Holder extends StatefulWidget {
  const _Holder({super.key, required this.fixed, required this.host});

  final _Fixed fixed;
  final GameTestHost host;

  @override
  State<_Holder> createState() => _HolderState();
}

class _HolderState extends State<_Holder> {
  Move? _last;

  void show(Move? lastMove) => setState(() => _last = lastMove);

  @override
  Widget build(BuildContext context) {
    final s = widget.fixed.state;
    final seat = rules.currentSeat(s);
    return ludoModule.board(
      context,
      GameBoardView<LudoState>(
        state: s,
        lastMove: _last,
        mySeat: seat,
        canAct: seat != null,
        submit: (m) async {
          widget.fixed.sent.add(m);
          return true;
        },
        host: widget.host,
        firstGame: widget.fixed.firstGame,
        canEndForAll: widget.fixed.canEndForAll,
      ),
    );
  }
}
