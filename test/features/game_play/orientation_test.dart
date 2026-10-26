import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_module.dart';
import 'package:deskovky/features/game_play/game_orientation.dart';
import 'package:deskovky/games/registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/pump_app.dart';

void main() {
  const phone = Size(412, 915), tablet = Size(1280, 800);

  test('a portrait game locks a phone upright; tablets follow the tablet setting', () {
    final ludo = moduleById('ludo')!;
    expect(orientationsFor(ludo, phone), [DeviceOrientation.portraitUp]);
    expect(orientationsFor(ludo, tablet), [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    expect(orientationsFor(moduleById('sample')!, phone), isEmpty, reason: 'any = no lock');
  });

  test('the orientation values map to device orientations', () {
    expect(devicesFor(GameOrientation.any), isEmpty);
    expect(devicesFor(GameOrientation.portrait), [DeviceOrientation.portraitUp]);
    expect(devicesFor(GameOrientation.landscape), [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  });

  testWidgets('the game screen applies it and frees the phone again afterwards', (tester) async {
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemChrome.setPreferredOrientations') calls.add(call.arguments);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    await pumpApp(tester, size: phone, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(
      '/play/ludo',
      extra: const GameConfig(
        gameId: 'ludo',
        seats: [HumanSeat(1), RobotSeat()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: {},
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect([for (final c in calls) (c! as List).join(',')], contains('DeviceOrientation.portraitUp'));
    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/games');
    await tester.pumpAndSettle();
    expect(calls.last as List, isEmpty);
  });
}
