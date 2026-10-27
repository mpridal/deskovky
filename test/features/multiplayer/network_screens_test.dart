import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/app/providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/multiplayer/client_lobby_screen.dart';
import 'package:deskovky/features/multiplayer/host_room_screen.dart';
import 'package:deskovky/features/multiplayer/join_screen.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:deskovky/ui_kit/components/segmented_control.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

final _avatar = AvatarSpec.defaults.toJson();

Future<void> _players(WidgetTester tester, AppDatabase db, List<String> names) async {
  await tester.runAsync(() async {
    for (final n in names) {
      await PlayerRepository(db).create(name: n, avatar: AvatarSpec.defaults);
    }
  });
}

/// Lets the database streams and the loopback lines deliver.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

Future<void> _openMemorySetup(
  WidgetTester tester,
  AppDatabase db,
  FakeNetworkEnv env, {
  Size size = const Size(412, 915),
  Locale locale = const Locale('cs'),
  double textScale = 1.0,
}) async {
  await pumpApp(
    tester,
    size: size,
    locale: locale,
    textScale: textScale,
    db: db,
    disableAnimations: true,
    overrides: [startGameProvider.overrideWithValue('memory'), networkEnvProvider.overrideWithValue(env)],
  );
  await _settle(tester);
}

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(f, 120, scrollable: find.byType(Scrollable).first);
  await tester.pumpAndSettle();
}

Future<void> _openRoom(WidgetTester tester) async {
  await _scrollTo(tester, find.byKey(const ValueKey('whereWifi')));
  await tester.tap(find.byKey(const ValueKey('whereWifi')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('setupOpenRoom')));
  await _settle(tester);
  expect(find.byType(HostRoomScreen), findsOneWidget);
}

ClientRoom _virtualClient(FakeNetworkEnv env, String name) => ClientRoom(
  channel: env.connectToServed(),
  hello: Hello(
    protocolVersion: protocolVersion,
    appVersion: '0.4.0',
    roomCode: env.announced.last.code,
    token: null,
    profiles: [ProfileCard(name: name, avatar: _avatar)],
  ),
  localProfileIds: const [77],
);

/// Closes the room, so no line or timer outlives the test.
Future<void> _leave(WidgetTester tester) async {
  final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
  await tester.runAsync(rooms.leave);
  await tester.pumpAndSettle();
}

HostRoom _memoryHost(String code) => HostRoom(
  module: memoryModule,
  roomCode: code,
  slots: [LocalSlot(profileId: 1, card: ProfileCard(name: 'Bartoloměj', avatar: _avatar)), const OpenSlot()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 16, 'set': 'transport'},
  runner: const InlineAiRunner(),
);

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('the host opens a room with a QR code and a code and sees who joined', (tester) async {
    final env = FakeNetworkEnv();
    await _players(tester, db, ['Táta']);
    await _openMemorySetup(tester, db, env);
    await _openRoom(tester);
    final code = env.announced.last.code;
    expect(code, matches(RegExp(r'^\d{4}$')));
    expect(find.text(code), findsOneWidget);
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Táta'), findsOneWidget);

    final kuba = _virtualClient(env, 'Kuba');
    await _settle(tester);
    expect(find.text('Kuba'), findsOneWidget);
    expect(find.text('📱 Na svém'), findsOneWidget);
    expect(env.announced.last.free, lessThan(env.announced.first.free), reason: 'fewer free places announced');

    // Start only once everybody is ready.
    final start = find.byKey(const ValueKey('roomStart'));
    await _scrollTo(tester, start);
    expect(tester.widget<PrimaryButton>(start).onPressed != null, isFalse);
    kuba.setReady(true);
    await _settle(tester);
    expect(find.text('Připraven'), findsOneWidget);
    expect(tester.widget<PrimaryButton>(start).onPressed != null, isTrue);
    kuba.dispose();
    await _leave(tester);
  });

  testWidgets('the host can remove a joined player', (tester) async {
    final env = FakeNetworkEnv();
    await _players(tester, db, ['Táta']);
    await _openMemorySetup(tester, db, env);
    await _openRoom(tester);
    final kuba = _virtualClient(env, 'Kuba');
    await _settle(tester);
    await tester.tap(find.text('Kuba'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Odebrat hráče'));
    await _settle(tester);
    expect(find.text('Kuba'), findsNothing);
    expect(kuba.closedReason, 'kicked');
    kuba.dispose();
    await _leave(tester);
  });

  testWidgets('without Wi-Fi the network choice explains why it cannot be used', (tester) async {
    final env = FakeNetworkEnv(address: null);
    await _players(tester, db, ['Táta']);
    await _openMemorySetup(tester, db, env);
    await _scrollTo(tester, find.byKey(const ValueKey('whereWifi')));
    await tester.tap(find.byKey(const ValueKey('whereWifi')));
    await _settle(tester);
    await _scrollTo(tester, find.textContaining('Nejsi ve Wi-Fi'));
    expect(find.textContaining('Nejsi ve Wi-Fi'), findsOneWidget);
    expect(find.byKey(const ValueKey('setupOpenRoom')), findsNothing);
  });

  testWidgets('a client finds the room, joins with its profile and sees the settings read-only', (tester) async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '4321',
      slots: [
        LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)),
        const OpenSlot(),
      ],
      difficulty: Difficulty.hard,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 16, 'set': 'animals'},
      runner: const InlineAiRunner(),
    );
    final env = FakeNetworkEnv(
      found: [
        RoomInfo(code: '4321', gameId: 'memory', hostName: 'Táta', hostAvatar: _avatar, port: 50505, free: 1, ip: '192.168.1.9'),
      ],
      onConnect: host.accept,
    );
    await _players(tester, db, ['Kuba']);
    await pumpApp(
      tester,
      size: const Size(412, 915),
      db: db,
      disableAnimations: true,
      overrides: [networkEnvProvider.overrideWithValue(env)],
    );
    await _settle(tester);
    await _scrollTo(tester, find.byKey(const ValueKey('homeJoin')));
    await tester.tap(find.byKey(const ValueKey('homeJoin')));
    await _settle(tester);
    expect(find.byType(JoinScreen), findsOneWidget);
    expect(find.textContaining('Táta'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('room4321')));
    await _settle(tester);
    expect(find.byType(ClientLobbyScreen), findsOneWidget);
    expect(env.searching, isFalse, reason: 'joined: no more looking for rooms (battery, multicast lock)');
    expect(find.byType(JoinScreen, skipOffstage: false), findsNothing);
    expect(host.slots[1], isA<RemoteSlot>());
    expect((host.slots[1] as RemoteSlot).card.name, 'Kuba');
    expect(find.text('Těžká'), findsOneWidget, reason: 'the difficulty is shown');
    expect(find.byType(SegmentedControl<Difficulty>), findsNothing, reason: 'read-only for clients');
    await tester.tap(find.byKey(const ValueKey('lobbyReady')));
    await _settle(tester);
    expect((host.slots[1] as RemoteSlot).ready, isTrue);
    host.dispose();
    await _leave(tester);
  });

  testWidgets('the client types the room code when the list does not show it', (tester) async {
    final host = HostRoom(
      module: memoryModule,
      roomCode: '0042',
      slots: [LocalSlot(profileId: 1, card: ProfileCard(name: 'Táta', avatar: _avatar)), const OpenSlot()],
      difficulty: Difficulty.easy,
      robotSpeed: RobotSpeed.fast,
      options: const {'cards': 12, 'set': 'animals'},
      runner: const InlineAiRunner(),
    );
    final env = FakeNetworkEnv(onConnect: host.accept);
    await _players(tester, db, ['Kuba']);
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [networkEnvProvider.overrideWithValue(env)]);
    await _settle(tester);
    await _scrollTo(tester, find.byKey(const ValueKey('homeJoin')));
    await tester.tap(find.byKey(const ValueKey('homeJoin')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('joinAdvancedToggle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('joinCode')), '0042');
    await tester.enterText(find.byKey(const ValueKey('joinAddress')), '192.168.1.9:50505');
    await tester.tap(find.byKey(const ValueKey('joinConnect')));
    await _settle(tester);
    expect(find.byType(ClientLobbyScreen), findsOneWidget);
    expect(host.slots[1], isA<RemoteSlot>());
    host.dispose();
    await _leave(tester);
  });

  for (final locale in ['cs', 'en', 'es']) {
    testWidgets('the room fits a 360 dp phone at 130 % ($locale)', (tester) async {
      final env = FakeNetworkEnv();
      await _players(tester, db, ['Maximiliánek']);
      await _openMemorySetup(tester, db, env, size: const Size(360, 740), locale: Locale(locale), textScale: 1.3);
      await _openRoom(tester);
      final kuba = _virtualClient(env, 'Kristýnka Novák');
      await _settle(tester);
      kuba.setReady(true);
      await _settle(tester);
      expect(tester.takeException(), isNull);
      kuba.dispose();
      await _leave(tester);
    });

    testWidgets('joining and the lobby fit a 360 dp phone at 130 % ($locale)', (tester) async {
      final host = _memoryHost('4321');
      final env = FakeNetworkEnv(
        found: [
          RoomInfo(code: '4321', gameId: 'memory', hostName: 'Bartoloměj', hostAvatar: _avatar, port: 1, free: 3, ip: '192.168.1.9'),
        ],
        onConnect: host.accept,
      );
      await _players(tester, db, ['Maximiliánek', 'Kristýnka']);
      await pumpApp(
        tester,
        size: const Size(360, 740),
        locale: Locale(locale),
        textScale: 1.3,
        db: db,
        disableAnimations: true,
        overrides: [networkEnvProvider.overrideWithValue(env)],
      );
      await _settle(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('homeJoin')));
    await tester.tap(find.byKey(const ValueKey('homeJoin')));
      await _settle(tester);
      await tester.tap(find.byKey(const ValueKey('joinAdvancedToggle')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('room4321')));
      await _settle(tester);
      expect(find.byType(ClientLobbyScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      host.dispose();
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: 'the host leaving shows a message, not an overflow');
      await _leave(tester);
    });
  }
}
