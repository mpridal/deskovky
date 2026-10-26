import 'package:deskovky/app/providers.dart';
import 'package:deskovky/features/game_setup/game_setup_screen.dart';
import 'package:deskovky/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('--dart-define=GAME=<id> opens that game setup at once (spec 8 bod 5)', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), overrides: [startGameProvider.overrideWithValue('sample')]);
    expect(find.byType(GameSetupScreen), findsOneWidget);
  });

  testWidgets('an unknown or empty game id starts at home as usual', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), overrides: [startGameProvider.overrideWithValue('nonsense')]);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
