import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/players/player_profile.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/game_play/game_outcome.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/game_play/seat_identity.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/features/home/active_player_bar.dart';
import 'package:deskovky/features/results/confetti.dart';
import 'package:deskovky/features/results/results_screen.dart';
import 'package:deskovky/ui_kit/avatar/robot_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

final _tereza = PlayerProfile(id: 1, name: 'Tereza', avatar: AvatarSpec.defaults, favoriteSeat: null, createdAt: DateTime.utc(2026));

const _config = GameConfig(
  gameId: 'sample',
  seats: [HumanSeat(1), RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: {'range': 20},
);

GameOutcomeView _outcome({required List<int> places}) => GameOutcomeView(
  config: _config,
  result: GameResult(places: places, scores: const [4, 3], stars: const [3, 1]),
  seats: [
    SeatIdentity(seat: 0, name: 'Tereza', profile: _tereza, difficulty: null),
    const SeatIdentity(seat: 1, name: 'Čipík', profile: null, difficulty: Difficulty.medium),
  ],
);

Future<void> _showResults(
  WidgetTester tester,
  GameOutcomeView outcome, {
  bool disableAnimations = true,
  Locale locale = const Locale('cs'),
  Size size = const Size(412, 915),
  double textScale = 1.0,
}) async {
  // Profile 1 must exist: "Hrát znovu" refuses games without a person.
  final db = testDatabase();
  addTearDown(db.close);
  await tester.runAsync(() => PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults));
  await pumpApp(tester, size: size, locale: locale, textScale: textScale, db: db, disableAnimations: disableAnimations);
  GoRouter.of(tester.element(find.byType(Navigator).first)).push('/play/sample/results', extra: outcome);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.byType(ResultsScreen), findsOneWidget);
}

GoRouterState _route(WidgetTester tester) => GoRouter.of(tester.element(find.byType(Navigator).last)).state;

void main() {
  testWidgets('a human win: title, ranking, stars, robot without stars', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]));
    expect(find.text('Tereza vyhrává!'), findsOneWidget);
    expect(find.text('Hádej číslo · Střední'), findsOneWidget);
    expect(find.text('1. Tereza'), findsOneWidget);
    expect(find.text('2. Čipík'), findsOneWidget);
    expect(find.text('★★★'), findsOneWidget);
    expect(find.text('robot'), findsOneWidget);
    expect(tester.getTopLeft(find.text('1. Tereza')).dy, lessThan(tester.getTopLeft(find.text('2. Čipík')).dy));
  });

  testWidgets('a robot win shows the robot name and avatar', (tester) async {
    await _showResults(tester, _outcome(places: const [2, 1]));
    expect(find.text('Čipík vyhrává!'), findsOneWidget);
    expect(tester.getSize(find.byType(RobotAvatar).first), const Size(120, 120));
    expect(find.text('1. Čipík'), findsOneWidget);
  });

  testWidgets('shared first place is a draw', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 1]));
    expect(find.text('Remíza!'), findsOneWidget);
  });

  testWidgets('play again starts the same setup', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]));
    await tester.tap(find.text('Hrát znovu'));
    // Not pumpAndSettle: the new game would run on until its own results.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(_route(tester).uri.path, '/play/sample');
    expect(_route(tester).extra, _config);
    expect(find.byType(GameScreen), findsOneWidget);
  });

  testWidgets('change settings opens the setup with this setup', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]));
    await tester.tap(find.text('Změnit nastavení'));
    await tester.pumpAndSettle();
    expect(find.byType(GameSetupScreen), findsOneWidget);
    expect(tester.widget<GameSetupScreen>(find.byType(GameSetupScreen)).initialConfig, _config);
  });

  testWidgets('home returns to the home screen', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]));
    await tester.tap(find.text('Domů'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivePlayerBar), findsOneWidget);
  });

  testWidgets('no confetti with reduced motion', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]));
    expect(find.byType(Confetti), findsNothing);
  });

  testWidgets('confetti when animations are allowed', (tester) async {
    await _showResults(tester, _outcome(places: const [1, 2]), disableAnimations: false);
    expect(find.byType(Confetti), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  group('fit', () {
    setUpAll(loadAppFonts);

    testWidgets('title and buttons stay on one line (es, 360 dp, 130 %)', (tester) async {
      await _showResults(
        tester,
        _outcome(places: const [1, 2]),
        locale: const Locale('es'),
        size: const Size(360, 740),
        textScale: 1.3,
      );
      for (final label in ['¡Gana Tereza!', 'Jugar otra vez', 'Cambiar ajustes', 'Inicio']) {
        final p = tester.renderObject<RenderParagraph>(find.text(label));
        expect(p.getMaxIntrinsicWidth(double.infinity) <= p.size.width + 0.5, isTrue, reason: label);
      }
    });
  });
}
