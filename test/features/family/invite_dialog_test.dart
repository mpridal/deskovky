import 'dart:async';

import 'package:deskovky/app/family_controller.dart';
import 'package:deskovky/app/family_providers.dart';
import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/multiplayer/client_lobby_screen.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../app/fake_family_net.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import '../multiplayer/fake_network.dart';

Future<void> _settle(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 60));
  }
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<(HostRoom, String)> start(WidgetTester tester) async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [LocalSlot(profileId: 99, card: ProfileCard(name: 'Táta', avatar: AvatarSpec.defaults.toJson())), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12},
      runner: const InlineAiRunner(),
    );
    final viky = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Viky', avatar: AvatarSpec.defaults)))!;
    await pumpApp(
      tester,
      size: const Size(412, 915),
      db: db,
      disableAnimations: true,
      overrides: [
        familyNetProvider.overrideWithValue(FakeLan().device()),
        networkEnvProvider.overrideWithValue(FakeNetworkEnv(onConnect: host.accept)),
      ],
    );
    await _settle(tester);
    return (host, viky.uid!);
  }

  void invite(WidgetTester tester, String uid) => ProviderScope.containerOf(tester.element(find.byType(Scaffold).first))
      .read(familyControllerProvider)
      .debugReceiveInvite(
        FamilyInvite(profileUid: uid, room: const JoinTicket(ip: '192.168.1.10', port: 50505, code: '4321'), gameId: 'memory', hostName: 'Táta'),
      );

  testWidgets('"Hrát" joins the room as the invited child, ready', (tester) async {
    final (host, uid) = await start(tester);
    invite(tester, uid);
    await _settle(tester);
    expect(find.text('Táta tě zve do hry Pexeso – hrát?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('invitePlay')));
    await _settle(tester, 12);
    expect(find.byType(ClientLobbyScreen), findsOneWidget);
    final slot = host.slots[1];
    expect(slot, isA<RemoteSlot>());
    expect((slot as RemoteSlot).card.name, 'Viky');
    expect(slot.card.uid, uid);
    expect(slot.ready, isTrue);
    expect(find.text('Ještě ne'), findsOneWidget, reason: 'the lobby knows the child is ready');
    await tester.runAsync(ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider).leave);
    host.dispose();
    await tester.pumpWidget(const SizedBox());
    await _settle(tester, 2);
  });

  testWidgets('"Teď ne" closes the invitation; it also goes away by itself after 60 s', (tester) async {
    final (host, uid) = await start(tester);
    invite(tester, uid);
    await _settle(tester);
    await tester.tap(find.text('Teď ne'));
    await _settle(tester);
    expect(find.textContaining('tě zve'), findsNothing);
    expect(host.slots[1], isA<OpenSlot>());
    invite(tester, uid);
    await _settle(tester);
    expect(find.textContaining('tě zve'), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    expect(find.textContaining('tě zve'), findsNothing);
    host.dispose();
  });

  testWidgets('the room offers family people to invite; with no family device on the Wi-Fi it says so', (tester) async {
    final tata = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Táta', avatar: AvatarSpec.defaults)))!;
    final viky = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Viky', avatar: AvatarSpec.defaults)))!;
    final net = FakeNetworkEnv();
    await pumpApp(
      tester,
      size: const Size(412, 915),
      db: db,
      disableAnimations: true,
      overrides: [familyNetProvider.overrideWithValue(FakeLan().device()), networkEnvProvider.overrideWithValue(net)],
    );
    await _settle(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    // In the app's own time, like a tap would (the database works there).
    unawaited(container.read(familyControllerProvider).createFamily(deviceName: 'Tablet'));
    await _settle(tester);
    unawaited(
      container.read(networkRoomsProvider).openHost(
        module: memoryModule,
        slots: [LocalSlot(profileId: tata.id, card: ProfileCard(name: 'Táta', avatar: AvatarSpec.defaults.toJson(), uid: tata.uid)), const OpenSlot()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {'cards': 12},
        runner: const InlineAiRunner(),
        hostCard: ProfileCard(name: 'Táta', avatar: AvatarSpec.defaults.toJson()),
      ),
    );
    await _settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/room');
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('roomSlot1')));
    await _settle(tester);
    expect(find.text('Pozvat z rodiny'), findsOneWidget);
    expect(find.byKey(ValueKey('invite_${tata.id}')), findsNothing, reason: 'already seated');
    await tester.tap(find.byKey(ValueKey('invite_${viky.id}')));
    await _settle(tester);
    expect(find.text('V síti jsem nenašel žádné rodinné zařízení.'), findsOneWidget);
    await tester.runAsync(container.read(networkRoomsProvider).leave);
    await tester.pumpWidget(const SizedBox());
    await _settle(tester, 2);
  });
}
