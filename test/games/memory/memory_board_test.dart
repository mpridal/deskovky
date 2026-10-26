import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/memory/memory_board.dart';
import 'package:deskovky/games/memory/memory_card_art.dart';
import 'package:deskovky/games/memory/memory_layout.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:deskovky/games/memory/memory_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../game_test_host.dart';

const rules = MemoryRules();

GameConfig config({int seats = 2, int cards = 16, Difficulty difficulty = Difficulty.medium, String set = 'animals'}) =>
    GameConfig(
      gameId: 'memory',
      seats: [for (var s = 0; s < seats; s++) HumanSeat(s + 1)],
      difficulty: difficulty,
      robotSpeed: RobotSpeed.normal,
      options: {'cards': cards, 'set': set},
    );

const sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];

/// The game screen around the board: HUD on top, the turn bubble below,
/// 16 dp padding – as `GameScreen` lays it out.
class Harness extends StatefulWidget {
  const Harness({super.key, required this.start, required this.host, this.firstGame = false, this.robots = const {}});

  final MemoryState start;
  final GameTestHost host;
  final bool firstGame;
  final Set<int> robots;

  @override
  State<Harness> createState() => HarnessState();
}

class HarnessState extends State<Harness> {
  late MemoryState state = widget.start;
  Move? last;
  final submitted = <Move>[];
  var clock = const Duration(seconds: 3);

  void play(Move move) => setState(() {
    state = rules.apply(state, move);
    last = move;
  });

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final seat = rules.currentSeat(state);
    final mine = seat != null && !widget.robots.contains(seat) ? seat : null;
    return Material(
      color: AppColors.felt,
      child: Column(
        children: [
          SizedBox(height: wide ? 72 : 128),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MemoryBoard(
                view: GameBoardView<MemoryState>(
                  state: state,
                  lastMove: last,
                  mySeat: mine,
                  canAct: mine != null,
                  submit: (move) async {
                    submitted.add(move);
                    play(move);
                    return true;
                  },
                  host: widget.host,
                  elapsed: () => clock,
                  firstGame: widget.firstGame,
                ),
              ),
            ),
          ),
          const SizedBox(height: 56),
        ],
      ),
    );
  }
}

Future<HarnessState> pumpBoard(
  WidgetTester tester,
  MemoryState state, {
  Size size = const Size(412, 915),
  GameTestHost? host,
  bool firstGame = false,
  bool animate = false,
  Set<int> robots = const {},
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('cs'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: !animate),
          child: Harness(start: state, host: host ?? GameTestHost(), firstGame: firstGame, robots: robots),
        ),
      ),
    ),
  );
  return tester.state<HarnessState>(find.byType(Harness));
}

/// Reported events as text, optionally only [id].
List<String> events(GameTestHost host, [String? id]) => [
  for (final (e, data) in host.events)
    if (id == null || e == id) '$e $data',
];

Finder card(int c) => find.byKey(ValueKey('memory.card$c'));

bool faceUp(int c) => find.descendant(of: card(c), matching: find.byType(MemoryCardFace)).evaluate().isNotEmpty;

Future<void> tapCard(WidgetTester tester, int c) async {
  await tester.tap(card(c));
  await tester.pump();
}

(int, int) twoDifferent(MemoryState s) {
  final a = s.owner.indexWhere((o) => o == null);
  final b = List.generate(s.cards, (c) => c).firstWhere((c) => s.owner[c] == null && s.faces[c] != s.faces[a]);
  return (a, b);
}

List<int> pairOf(MemoryState s, int face) => [
  for (var c = 0; c < s.cards; c++)
    if (s.faces[c] == face) c,
];

/// Decodes the card pictures, so goldens show them.
Future<void> loadPictures(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage((element.widget as Image).image, element);
    }
  });
  await tester.pump();
}

void main() {
  setUpAll(loadAppFonts);

  group('layout', () {
    test('the grid keeps cards big and inside the area', () {
      for (final area in [const Size(328, 450), const Size(380, 640), const Size(768, 1000), const Size(1248, 640)]) {
        for (final cards in MemoryRules.cardCounts) {
          final g = MemoryGrid.fit(area, cards);
          expect(g.columns * g.rows, greaterThanOrEqualTo(cards));
          expect(g.columns * g.rows - cards, lessThan(g.columns), reason: 'no empty row');
          expect(g.side, greaterThanOrEqualTo(MemoryGrid.minSide));
          if (g.side > MemoryGrid.minSide) {
            expect(g.size.width, lessThanOrEqualTo(area.width + 0.01), reason: '$area $cards');
            expect(g.size.height, lessThanOrEqualTo(area.height + 0.01), reason: '$area $cards');
          }
        }
      }
      // Landscape gets more columns than rows, portrait the other way round.
      expect(
        MemoryGrid.fit(const Size(1248, 640), 24).columns,
        greaterThan(MemoryGrid.fit(const Size(1248, 640), 24).rows),
      );
      expect(
        MemoryGrid.fit(const Size(380, 640), 24).rows,
        greaterThan(MemoryGrid.fit(const Size(380, 640), 24).columns),
      );
    });

    for (final size in sizes) {
      for (final cards in [12, 16, 48]) {
        testWidgets('$cards cards fit on ${size.width.toInt()}×${size.height.toInt()}, each ≥ 48 dp', (tester) async {
          await pumpBoard(tester, rules.initialState(config(cards: cards), 1), size: size);
          final screen = Offset.zero & size;
          for (var c = 0; c < cards; c++) {
            final rect = tester.getRect(card(c));
            expect(rect.width, greaterThanOrEqualTo(48), reason: 'card $c');
            expect(
              screen.contains(rect.topLeft) && screen.contains(rect.bottomRight - const Offset(1, 1)),
              isTrue,
              reason: 'card $c at $rect',
            );
          }
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('one player sees turns and pairs; the board survives turning the device', (tester) async {
      final h = await pumpBoard(tester, rules.initialState(config(seats: 1, cards: 24), 2), size: const Size(412, 915));
      expect(find.text('Tahy: 0   ·   Dvojice: 0/12'), findsOneWidget);
      final portrait = tester.getRect(card(0)).width;
      final (a, b) = twoDifferent(h.state);
      await tapCard(tester, a);
      await tapCard(tester, b);
      tester.view.physicalSize = const Size(915, 412);
      await tester.pump();
      expect(find.text('Tahy: 1   ·   Dvojice: 0/12'), findsOneWidget);
      expect(tester.getRect(card(23)).bottom, lessThanOrEqualTo(412 - 56));
      expect(tester.getRect(card(0)).width, isNot(portrait));
      expect(tester.takeException(), isNull);
    });
  });

  group('play', () {
    testWidgets('a tap turns a card as a move with the playing time', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(), 4), host: host);
      expect(faceUp(5), isFalse);
      await tapCard(tester, 5);
      expect(h.submitted.single, MemoryRules.flip(0, 5, timeMs: 3000));
      expect(faceUp(5), isTrue);
      expect(host.sfx, ['card_flip']);
      expect(host.haptics, 1);
      // The same card again does nothing.
      await tapCard(tester, 5);
      expect(h.submitted, hasLength(1));
    });

    testWidgets('a miss stays up 1.2 s, then both turn back; a tap anywhere hurries it', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(), 4), host: host);
      var (a, b) = twoDifferent(h.state);
      await tapCard(tester, a);
      await tapCard(tester, b);
      expect(h.state.current, 1);
      expect(faceUp(a) && faceUp(b), isTrue);
      expect(host.sfx, ['card_flip', 'card_flip', 'memory.miss']);
      await tester.pump(const Duration(milliseconds: 1100));
      expect(faceUp(a), isTrue);
      await tester.pump(const Duration(milliseconds: 150));
      expect(faceUp(a) || faceUp(b), isFalse);

      (a, b) = twoDifferent(h.state);
      await tapCard(tester, a);
      await tapCard(tester, b);
      expect(faceUp(b), isTrue);
      // Beside the centred last row: the board, but no card.
      final last = tester.getRect(card(15));
      expect(last.right + 30, lessThan(412 - 16));
      await tester.tapAt(Offset(last.right + 30, last.center.dy));
      await tester.pump();
      expect(faceUp(a) || faceUp(b), isFalse);
    });

    testWidgets('a pair sounds, counts for the collector badge and the player goes again', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(), 4), host: host);
      final [a, b] = pairOf(h.state, h.state.faces[0]);
      await tapCard(tester, a);
      await tapCard(tester, b);
      expect(h.state.current, 0);
      expect(host.sfx, ['card_flip', 'card_flip', 'memory.match']);
      expect(events(host), ['memory.pairs {seat: 0, count: 1}']);
      expect(find.byKey(ValueKey('memory.card$a')), findsNothing, reason: 'found cards leave the table');
    });

    testWidgets('found pairs fly away to their player (animated)', (tester) async {
      final h = await pumpBoard(tester, rules.initialState(config(seats: 3), 4), animate: true);
      final [a, b] = pairOf(h.state, h.state.faces[0]);
      final home = tester.getRect(card(a));
      await tapCard(tester, a);
      await tester.pump(const Duration(milliseconds: 400));
      await tapCard(tester, b);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(card(a)).center, home.center, reason: 'shown first');
      await tester.pump(const Duration(milliseconds: 450));
      expect(tester.getRect(card(a)).center.dy, lessThan(home.center.dy), reason: 'flies up to the HUD');
      await tester.pump(const Duration(milliseconds: 300));
      expect(card(a), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('robots turn cards through the state; the board only shows them', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(), 4), host: host, robots: {0});
      await tapCard(tester, 0);
      expect(h.submitted, isEmpty);
      final (a, b) = twoDifferent(h.state);
      h.play(MemoryRules.flip(0, a));
      await tester.pump();
      h.play(MemoryRules.flip(0, b));
      await tester.pump();
      expect(faceUp(a) && faceUp(b), isTrue);
      expect(host.sfx, ['card_flip', 'card_flip', 'memory.miss']);
      expect(host.events, isEmpty);
    });

    testWidgets("a robot's miss stays up 1.2 s even when the next robot already turns a card", (tester) async {
      final h = await pumpBoard(tester, rules.initialState(config(seats: 3), 4), robots: {0, 1});
      final (a, b) = twoDifferent(h.state);
      h.play(MemoryRules.flip(0, a));
      await tester.pump();
      h.play(MemoryRules.flip(0, b));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      final c = List.generate(16, (i) => i).firstWhere((i) => i != a && i != b);
      h.play(MemoryRules.flip(1, c));
      await tester.pump(const Duration(milliseconds: 500));
      expect(faceUp(a) && faceUp(b) && faceUp(c), isTrue);
      await tester.pump(const Duration(milliseconds: 500));
      expect(faceUp(a) || faceUp(b), isFalse);
      expect(faceUp(c), isTrue);
    });

    testWidgets('five pairs in one turn report the streak badge', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(cards: 24), 4), host: host);
      for (final face in h.state.faces.toSet().take(5)) {
        for (final c in pairOf(h.state, face)) {
          await tapCard(tester, c);
        }
      }
      expect(events(host, 'memory.streak'), ['memory.streak {seat: 0}']);
    });

    testWidgets('the last-but-one pair reports who never forgot a card', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(), 6), host: host);
      final faces = h.state.faces.toSet().toList();
      for (final face in faces.take(7)) {
        expect(host.events.where((e) => e.$1 == 'memory.elephant'), isEmpty);
        for (final c in pairOf(h.state, face)) {
          await tapCard(tester, c);
        }
      }
      expect(events(host, 'memory.elephant'), ['memory.elephant {seat: 0}']);
      for (final c in pairOf(h.state, faces.last)) {
        await tapCard(tester, c);
      }
      expect(rules.isOver(h.state), isTrue);
      expect(host.events.where((e) => e.$1 == 'memory.elephant'), hasLength(1));
    });

    testWidgets('clearing 16 cards alone in 39 s reports Speedy before the last move', (tester) async {
      final host = GameTestHost();
      final h = await pumpBoard(tester, rules.initialState(config(seats: 1), 6), host: host);
      h.clock = const Duration(seconds: 39);
      for (final face in h.state.faces.toSet()) {
        for (final c in pairOf(h.state, face)) {
          await tapCard(tester, c);
        }
      }
      expect(rules.isOver(h.state), isTrue);
      expect(h.state.timeMs, 39000);
      expect(host.events.map((e) => e.$1), contains('memory.speed'));
    });

    testWidgets('a restored game counts the pairs found before', (tester) async {
      var s = rules.initialState(config(), 6);
      for (final face in s.faces.toSet().take(2)) {
        for (final c in pairOf(s, face)) {
          s = rules.apply(s, MemoryRules.flip(0, c));
        }
      }
      final host = GameTestHost();
      await pumpBoard(tester, s, host: host);
      expect(events(host), ['memory.pairs {seat: 0, count: 2}']);
    });
  });

  group('one player', () {
    testWidgets('easy: all cards shown for 2 s', (tester) async {
      await pumpBoard(tester, rules.initialState(config(seats: 1, difficulty: Difficulty.easy), 3));
      expect(find.text('Zapamatuj si obrázky!'), findsOneWidget);
      for (var c = 0; c < 16; c++) {
        expect(faceUp(c), isTrue);
      }
      await tester.pump(const Duration(seconds: 2));
      expect(faceUp(0), isFalse);
      expect(find.text('Zapamatuj si obrázky!'), findsNothing);
    });

    testWidgets('easy: a tap during the preview only ends it', (tester) async {
      final h = await pumpBoard(tester, rules.initialState(config(seats: 1, difficulty: Difficulty.easy), 4));
      await tapCard(tester, 3);
      expect(h.submitted, isEmpty);
      expect(faceUp(3), isFalse);
      await tapCard(tester, 3);
      expect(h.submitted, hasLength(1));
    });

    testWidgets('medium: no preview', (tester) async {
      await pumpBoard(tester, rules.initialState(config(seats: 1), 3));
      expect(faceUp(0), isFalse);
      expect(find.text('Zapamatuj si obrázky!'), findsNothing);
    });

    testWidgets('hard: after the fourth miss two cards visibly change places', (tester) async {
      final h = await pumpBoard(
        tester,
        rules.initialState(config(seats: 1, difficulty: Difficulty.hard), 3),
        animate: true,
      );
      for (var i = 0; i < 4; i++) {
        final (a, b) = twoDifferent(h.state);
        await tapCard(tester, a);
        await tester.pump(const Duration(milliseconds: 400));
        await tapCard(tester, b);
        await tester.pump(const Duration(milliseconds: 400));
        if (i < 3) await tester.pump(const Duration(seconds: 1));
      }
      expect(h.state.swaps, 1);
      final [i, j] = h.state.swap;
      final home = tester.getRect(card(i));
      // The miss is shown first, then the swap starts.
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getRect(card(i)).center, isNot(home.center), reason: 'card $i is on its way');
      expect(card(j), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.getRect(card(i)), home);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('first game: a gentle hint until the first turn is done', (tester) async {
    final h = await pumpBoard(tester, rules.initialState(config(), 3), firstGame: true);
    expect(find.byKey(const ValueKey('memory.firstHint')), findsOneWidget);
    final (a, b) = twoDifferent(h.state);
    await tapCard(tester, a);
    expect(find.byKey(const ValueKey('memory.firstHint')), findsOneWidget);
    await tapCard(tester, b);
    expect(find.byKey(const ValueKey('memory.firstHint')), findsNothing);
  });

  testWidgets('turn hint and illustrated rules in every language', (tester) async {
    for (final locale in const [Locale('cs'), Locale('en'), Locale('es')]) {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              ctx = context;
              return Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 340,
                    child: Wrap(spacing: 8, runSpacing: 8, children: memoryModule.ruleSteps(context)),
                  ),
                ),
              );
            },
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final s = rules.initialState(config(), 1);
      expect(memoryModule.turnHint(ctx, s, 'Kuba'), contains('Kuba'));
      expect(
        memoryModule.turnHint(ctx, rules.apply(s, MemoryRules.flip(0, 0)), 'Kuba'),
        isNot(memoryModule.turnHint(ctx, s, 'Kuba')),
      );
    }
  });

  group('goldens', () {
    MemoryState midGame(int cards, String set, int seats) {
      var s = rules.initialState(config(seats: seats, cards: cards, set: set), 21);
      final faces = s.faces.toSet().toList();
      for (final face in faces.take(3)) {
        for (final c in pairOf(s, face)) {
          s = rules.apply(s, MemoryRules.flip(s.current, c));
        }
      }
      final (a, b) = twoDifferent(s);
      s = rules.apply(rules.apply(s, MemoryRules.flip(s.current, a)), MemoryRules.flip(s.current, b));
      return rules.apply(s, MemoryRules.flip(s.current, s.owner.lastIndexWhere((o) => o == null)));
    }

    for (final (size, cards, set, seats) in [
      (const Size(412, 915), 16, 'animals', 2),
      (const Size(360, 740), 48, 'food', 4),
      (const Size(1280, 800), 48, 'transport', 3),
      (const Size(800, 1280), 36, 'space', 1),
    ]) {
      final name = 'board_${size.width.toInt()}x${size.height.toInt()}_$cards';
      testWidgets(name, (tester) async {
        await pumpBoard(tester, midGame(cards, set, seats), size: size);
        await loadPictures(tester);
        await expectLater(find.byType(Harness), matchesGoldenFile('goldens/$name.png'));
      });
    }

    testWidgets('rule steps', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 160);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('cs'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Material(
              color: AppColors.paper,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [for (final w in memoryModule.ruleSteps(context)) SizedBox(width: 120, child: w)],
              ),
            ),
          ),
        ),
      );
      await loadPictures(tester);
      await expectLater(find.byType(Row).first, matchesGoldenFile('goldens/rule_steps.png'));
    });
  });
}
