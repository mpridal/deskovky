import 'package:deskovky/app/family_controller.dart';
import 'package:deskovky/app/family_providers.dart';
import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/app/providers.dart';
import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_net.dart';
import 'package:deskovky/core/multiplayer/client_room.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:deskovky/core/players/player_profile.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/game_play/game_screen.dart';
import 'package:deskovky/features/multiplayer/host_room_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../app/fake_family_net.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

/// A family without a real Wi-Fi: who plays where is set by the test, and
/// invitations are only recorded.
class _Family extends FamilyController {
  _Family(AppDatabase db)
    : super(
        db: db,
        net: FakeLan().device(),
        stats: StatsService(StatsRepository(db), points: PointsRepository(db)),
      );

  Map<String, FamilyBeacon> elsewhere = {};
  final invited = <(String, JoinTicket, String)>[];
  var deliver = true;

  @override
  bool get inFamily => true;

  @override
  Map<String, FamilyBeacon> get playingElsewhere => elsewhere;

  @override
  Future<void> start() async {}

  @override
  Future<bool> invite({
    required String profileUid,
    required JoinTicket room,
    required String gameId,
    required String hostName,
  }) async {
    invited.add((profileUid, room, hostName));
    return deliver;
  }
}

FamilyBeacon _on(String uid, {bool busy = false}) =>
    FamilyBeacon(familyTag: 'tag', deviceId: 'tablet', ip: '192.168.1.9', port: 50600, activeUid: uid, busy: busy);

Future<List<PlayerProfile>> _players(WidgetTester tester, AppDatabase db, List<String> names) async =>
    (await tester.runAsync(() async {
      final out = <PlayerProfile>[];
      for (final n in names) {
        out.add(await PlayerRepository(db).create(name: n, avatar: AvatarSpec.defaults));
      }
      return out;
    }))!;

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pumpAndSettle();
  }
}

Future<(_Family, FakeNetworkEnv)> _setup(WidgetTester tester, AppDatabase db, {String game = 'memory'}) async {
  final family = _Family(db);
  final env = FakeNetworkEnv();
  await pumpApp(
    tester,
    size: const Size(412, 915),
    db: db,
    disableAnimations: true,
    overrides: [
      startGameProvider.overrideWithValue(game),
      networkEnvProvider.overrideWithValue(env),
      familyControllerProvider.overrideWithValue(family),
    ],
  );
  await _settle(tester);
  return (family, env);
}

Future<void> _pickSeat(WidgetTester tester, int seat) async {
  await tester.tap(find.byKey(ValueKey('seat$seat')));
  await tester.pumpAndSettle();
}

ClientRoom _arrive(FakeNetworkEnv env, PlayerProfile p) => ClientRoom(
  channel: env.connectToServed(),
  hello: Hello(
    protocolVersion: protocolVersion,
    appVersion: '0.10.0',
    roomCode: env.announced.last.code,
    token: null,
    profiles: [ProfileCard(name: p.name, avatar: p.avatar.toJson(), uid: p.uid)],
  ),
  localProfileIds: const [77],
);

Future<void> _leave(WidgetTester tester) async {
  final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
  await tester.runAsync(rooms.leave);
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('the seat picker offers who plays now on another device; a busy one cannot be picked', (tester) async {
    final [_, kuba, viky, _] = await _players(tester, db, ['Táta', 'Kuba', 'Viky', 'Máma']);
    final (family, _) = await _setup(tester, db);
    family.elsewhere = {kuba.uid!: _on(kuba.uid!), viky.uid!: _on(viky.uid!, busy: true)};
    await _pickSeat(tester, 1);
    expect(find.text('Na jiném zařízení'), findsOneWidget);
    expect(find.byKey(ValueKey('away_${kuba.id}')), findsOneWidget);
    expect(find.text('Hraje teď'), findsOneWidget);
    expect(find.text('Hraje jinou hru'), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('away_${viky.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Na jiném zařízení'), findsOneWidget, reason: 'a busy one does nothing');
    await tester.tap(find.byKey(ValueKey('away_${kuba.id}')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const ValueKey('seat1')), matching: find.text('Kuba')), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('seat1')), matching: find.text('📱 Na svém')), findsOneWidget);
    expect(find.byKey(const ValueKey('setupInvitePlay')), findsOneWidget);
  });

  testWidgets('the only person of this device cannot be moved to another device', (tester) async {
    final [_, kuba] = await _players(tester, db, ['Táta', 'Kuba']);
    final (family, _) = await _setup(tester, db);
    family.elsewhere = {kuba.uid!: _on(kuba.uid!)};
    await _pickSeat(tester, 0);
    expect(find.text('Na jiném zařízení'), findsNothing);
  });

  testWidgets('"Pozvat a hrát": the room keeps the place, invites, and the game starts once they come', (tester) async {
    final [tata, kuba] = await _players(tester, db, ['Táta', 'Kuba']);
    final (family, env) = await _setup(tester, db);
    family.elsewhere = {kuba.uid!: _on(kuba.uid!)};
    await _pickSeat(tester, 1);
    await tester.tap(find.byKey(ValueKey('away_${kuba.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('setupInvitePlay')));
    await _settle(tester);

    expect(find.byType(HostRoomScreen), findsOneWidget);
    expect(family.invited.single.$1, kuba.uid);
    expect(family.invited.single.$3, 'Táta');
    final room = ProviderScope.containerOf(tester.element(find.byType(HostRoomScreen)))
        .read(networkRoomsProvider)
        .host!;
    expect(room.slots, hasLength(2), reason: 'no extra free place');
    expect((room.slots[1] as OpenSlot).invited!.uid, kuba.uid);
    expect(find.text('Kuba'), findsOneWidget);
    expect(find.text('Pozván, čeká se'), findsOneWidget);

    final client = _arrive(env, kuba);
    await _settle(tester);
    expect(find.byType(GameScreen), findsNothing, reason: 'not ready yet');
    client.setReady(true);
    await _settle(tester);
    expect(find.byType(GameScreen), findsOneWidget, reason: 'started by itself');
    expect(tata.name, 'Táta');
    client.dispose();
    await _leave(tester);
  });

  testWidgets('an invitation nobody took is said, and the room still waits to be started by hand', (tester) async {
    final [_, kuba] = await _players(tester, db, ['Táta', 'Kuba']);
    final (family, _) = await _setup(tester, db);
    family.elsewhere = {kuba.uid!: _on(kuba.uid!)};
    family.deliver = false;
    await _pickSeat(tester, 1);
    await tester.tap(find.byKey(ValueKey('away_${kuba.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('setupInvitePlay')));
    await _settle(tester);
    expect(find.byType(HostRoomScreen), findsOneWidget);
    expect(find.textContaining('Pozvánku pro Kuba se nepodařilo doručit'), findsOneWidget);
    await _leave(tester);
  });

  testWidgets('in the room, who plays now comes first among the family to invite', (tester) async {
    final [_, kuba, viky] = await _players(tester, db, ['Táta', 'Kuba', 'Viky']);
    final (family, _) = await _setup(tester, db);
    family.elsewhere = {viky.uid!: _on(viky.uid!)};
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('whereWifi')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('whereWifi')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('whereWifi')));
    await _settle(tester);
    await tester.tap(find.byKey(const ValueKey('setupOpenRoom')));
    await _settle(tester);
    // The free place is the last one.
    final room = ProviderScope.containerOf(tester.element(find.byType(HostRoomScreen)))
        .read(networkRoomsProvider)
        .host!;
    final open = room.slots.lastIndexWhere((s) => s is OpenSlot);
    await tester.tap(find.byKey(ValueKey('roomSlot$open')));
    await tester.pumpAndSettle();
    final vikyY = tester.getTopLeft(find.byKey(ValueKey('invite_${viky.id}'))).dy;
    final kubaY = tester.getTopLeft(find.byKey(ValueKey('invite_${kuba.id}'))).dy;
    expect(vikyY, lessThan(kubaY));
    expect(
      find.descendant(of: find.byKey(ValueKey('invite_${viky.id}')), matching: find.text('Hraje teď')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(ValueKey('invite_${viky.id}')));
    await _settle(tester);
    expect(family.invited.single.$1, viky.uid);
    expect((room.slots[open] as OpenSlot).invited?.uid, viky.uid, reason: 'the place is kept for her');
    await _leave(tester);
  });
}
