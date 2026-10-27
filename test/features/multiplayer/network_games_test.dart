import 'dart:async';

import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/app/providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/network_rooms.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/multiplayer/host_room_screen.dart';
import 'package:deskovky/games/registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

/// Lets the database streams and the loopback lines deliver.
Future<void> _settle(WidgetTester tester, [int rounds = 5]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  for (final module in gameModules.where((m) => m.playableOnNetwork)) {
    testWidgets('${module.id}: a room from the game setup, a device joins, its move shows on the host', (tester) async {
      final env = FakeNetworkEnv();
      await tester.runAsync(() => PlayerRepository(db).create(name: 'Táta', avatar: AvatarSpec.defaults));
      await pumpApp(
        tester,
        size: const Size(412, 915),
        db: db,
        disableAnimations: true,
        overrides: [
          startGameProvider.overrideWithValue(module.id),
          networkEnvProvider.overrideWithValue(env),
          // The same deal every run: no robot or random guess wins before Kuba's turn.
          networkRoomsProvider.overrideWith((ref) {
            final rooms = NetworkRooms(env, seed: 17);
            ref.onDispose(rooms.leave);
            return rooms;
          }),
        ],
      );
      await _settle(tester);
      // The setup's vertical list (option pills scroll sideways).
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('whereWifi')),
        120,
        scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('whereWifi')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('whereWifi')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('setupOpenRoom')));
      await _settle(tester);
      expect(find.byType(HostRoomScreen), findsOneWidget);

      final kuba = ClientRoom(
        channel: env.connectToServed(),
        hello: Hello(
          protocolVersion: protocolVersion,
          appVersion: '0.4.1',
          roomCode: env.announced.last.code,
          token: null,
          profiles: [ProfileCard(name: 'Kuba', avatar: AvatarSpec.defaults.toJson())],
        ),
        localProfileIds: const [99],
      );
      await _settle(tester);
      kuba.setReady(true);
      await _settle(tester);
      final start = find.byKey(const ValueKey('roomStart'));
      await tester.tap(start);
      await _settle(tester);
      expect(find.byType(GameScreen), findsOneWidget);

      final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
      final host = rooms.host!;
      final kubaSeat = host.session!.config.seats.indexWhere((s) => s is RemoteSeat && s.clientId == kuba.clientId);
      expect(kubaSeat, greaterThanOrEqualTo(0));
      final random = SeededRandom(3);
      // The host's person (and robots) play until it is Kuba's turn.
      for (var i = 0; i < 200 && host.session!.rules.currentSeat(host.session!.state) != kubaSeat && !host.isOver; i++) {
        final seat = host.session!.rules.currentSeat(host.session!.state)!;
        if (host.ownerOf(seat) == HostRoom.hostId) {
          final legal = host.session!.rules.legalMoves(host.session!.state, seat);
          unawaited(host.submitLocal(legal[random.nextInt(legal.length)]));
        }
        await _settle(tester, 1);
      }
      expect(host.session!.rules.currentSeat(host.session!.state), kubaSeat);
      expect(find.text('Na tahu: Kuba (na svém zařízení)'), findsOneWidget);
      final screen = tester.state<GameScreenState>(find.byType(GameScreen));
      final before = screen.debugSession!.moves.length;
      for (var i = 0; i < 20 && kuba.seq != host.seq; i++) {
        await _settle(tester, 1);
      }
      final legal = kuba.session!.rules.legalMoves(kuba.session!.state, kubaSeat);
      unawaited(kuba.submit(legal[random.nextInt(legal.length)]));
      for (var i = 0; i < 20 && screen.debugSession!.moves.length == before; i++) {
        await _settle(tester, 1);
      }
      expect(screen.debugSession!.moves.length, before + 1, reason: "Kuba's move arrived on the host");
      expect(tester.takeException(), isNull);
      kuba.dispose();
      await tester.runAsync(rooms.leave);
      await tester.pump();
    });
  }
}
