import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/_sample/sample_module.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class _Host implements GameHost {
  @override
  void haptic() {}
  @override
  void playSfx(String id) {}
  @override
  void reportEvent(String id, [Map<String, Object?> data = const {}]) {}
}

const _config = GameConfig(
  gameId: 'sample',
  seats: [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.easy,
  robotSpeed: RobotSpeed.fast,
  options: {'range': 20},
);

Future<List<Move>> _pumpBoard(WidgetTester tester, SampleState state, {bool canAct = true, Move? lastMove}) async {
  final sent = <Move>[];
  await tester.pumpWidget(MaterialApp(
    theme: buildAppTheme(),
    locale: const Locale('cs'),
    supportedLocales: const [Locale('cs'), Locale('en'), Locale('es')],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(
      body: Builder(
        builder: (context) => sampleModule.board(
          context,
          GameBoardView<SampleState>(
            state: state,
            lastMove: lastMove,
            mySeat: canAct ? 0 : null,
            canAct: canAct,
            submit: (m) async {
              sent.add(m);
              return true;
            },
            host: _Host(),
          ),
        ),
      ),
    ),
  ));
  return sent;
}

Finder _tile(int n) => find.byKey(ValueKey('number$n'));

void main() {
  testWidgets('shows only numbers still possible and the range', (tester) async {
    final session = GameSession.start(const SampleRules(), _config, 4);
    final secret = session.state.secret;
    final miss = secret > 10 ? 5 : 15;
    session.apply(Move(seat: 0, type: 'guess', data: {'value': miss}));
    await _pumpBoard(tester, session.state, lastMove: session.lastMove);
    final s = session.state;
    expect(find.text('${s.low} – ${s.high}'), findsOneWidget);
    expect(_tile(miss), findsNothing);
    expect(find.text('$miss → ${secret > miss ? 'Víc!' : 'Míň!'}'), findsOneWidget);
  });

  testWidgets('tapping a number sends a guess', (tester) async {
    final state = const SampleRules().initialState(_config, 1);
    final sent = await _pumpBoard(tester, state);
    await tester.tap(_tile(7));
    expect(sent, [const Move(seat: 0, type: 'guess', data: {'value': 7})]);
  });

  testWidgets('nothing is sent while the player cannot act', (tester) async {
    final state = const SampleRules().initialState(_config, 1);
    final sent = await _pumpBoard(tester, state, canAct: false);
    await tester.tap(_tile(7), warnIfMissed: false);
    expect(sent, isEmpty);
  });

  testWidgets('number tiles are at least 56 dp (children\'s board)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 740);
    addTearDown(tester.view.reset);
    await _pumpBoard(tester, const SampleRules().initialState(_config, 1));
    final size = tester.getSize(_tile(1));
    expect(size.width >= 56 && size.height >= 56, isTrue, reason: '$size');
  });

  testWidgets('turn hint names the player and the range', (tester) async {
    final state = const SampleRules().initialState(_config, 1);
    late String? hint;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('cs'),
      supportedLocales: const [Locale('cs')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(builder: (context) {
        hint = sampleModule.turnHint(context, state, 'Kuba');
        return const SizedBox();
      }),
    ));
    expect(hint, 'Kuba, tipni číslo od 1 do 20');
  });
}
