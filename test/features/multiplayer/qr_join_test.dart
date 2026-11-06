import 'dart:async';

import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/multiplayer/host_room.dart';
import 'package:deskovky/core/multiplayer/join_links.dart';
import 'package:deskovky/core/multiplayer/protocol.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/home/home_screen.dart';
import 'package:deskovky/features/multiplayer/client_lobby_screen.dart';
import 'package:deskovky/features/multiplayer/join_screen.dart';
import 'package:deskovky/features/multiplayer/qr_scanner.dart';
import 'package:deskovky/games/memory/memory_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';
import 'fake_network.dart';

final _avatar = AvatarSpec.defaults.toJson();
const _link = 'deskovky://join?ip=192.168.1.9&port=50505&code=4321';

/// Deep links as Android would hand them over, without Android.
class FakeJoinLinks implements JoinLinks {
  FakeJoinLinks({this.initial});

  String? initial;
  final _links = StreamController<String>.broadcast();

  void open(String link) => _links.add(link);

  @override
  Future<String?> initialLink() async {
    final link = initial;
    initial = null;
    return link;
  }

  @override
  Stream<String> get links => _links.stream;
}

/// The camera, without a camera: every scan answers [next].
class FakeQrScanner implements QrScanner {
  FakeQrScanner(this.next);

  QrScanResult next;
  var scans = 0;

  @override
  Future<QrScanResult> scan(BuildContext context) async {
    scans++;
    return next;
  }
}

HostRoom _memoryHost() => HostRoom(
  module: memoryModule,
  roomCode: '4321',
  slots: [
    LocalSlot(
      profileId: 1,
      card: ProfileCard(name: 'Táta', avatar: _avatar),
    ),
    const OpenSlot(),
  ],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: const {'cards': 16, 'set': 'animals'},
  runner: const InlineAiRunner(),
);

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

Future<void> _pump(
  WidgetTester tester,
  AppDatabase db,
  FakeNetworkEnv env, {
  FakeJoinLinks? links,
  FakeQrScanner? scanner,
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
    overrides: [
      networkEnvProvider.overrideWithValue(env),
      joinLinksProvider.overrideWithValue(links ?? FakeJoinLinks()),
      qrScannerProvider.overrideWithValue(scanner ?? FakeQrScanner(const QrScanCancelled())),
    ],
  );
  await _settle(tester);
}

Future<void> _leave(WidgetTester tester) async {
  final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
  await tester.runAsync(rooms.leave);
  await tester.pumpAndSettle();
}

Future<void> _openJoin(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey('homeJoin')),
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('homeJoin')));
  await _settle(tester);
  expect(find.byType(JoinScreen), findsOneWidget);
}

Finder get _ticketConnect => find.byKey(const ValueKey('joinTicketConnect'));

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  group('deep link from the phone camera', () {
    testWidgets('on a cold start the link opens joining that room; the player picks who plays', (tester) async {
      final host = _memoryHost();
      final env = FakeNetworkEnv(onConnect: host.accept);
      await _players(tester, db, ['Kuba', 'Ema']);
      await _pump(tester, db, env, links: FakeJoinLinks(initial: _link));

      expect(find.byType(JoinScreen), findsOneWidget);
      expect(find.textContaining('4321'), findsOneWidget, reason: 'the room from the link');
      expect(env.searching, isFalse, reason: 'the room is known: no looking for rooms');
      expect(find.byKey(const ValueKey('joinCode')), findsNothing);

      // Nobody picked → a gentle reminder, no connection.
      await tester.tap(find.byKey(const ValueKey('who1')));
      await tester.pumpAndSettle();
      await tester.tap(_ticketConnect);
      await _settle(tester);
      expect(find.text('Vyber aspoň jednoho hráče.'), findsOneWidget);
      expect(host.slots[1], isA<OpenSlot>());

      // Ema plays on this device.
      await tester.tap(find.byKey(const ValueKey('who2')));
      await tester.pumpAndSettle();
      await tester.tap(_ticketConnect);
      await _settle(tester);
      expect(find.byType(ClientLobbyScreen), findsOneWidget);
      expect(find.byType(JoinScreen, skipOffstage: false), findsNothing);
      expect((host.slots[1] as RemoteSlot).card.name, 'Ema');
      host.dispose();
      await _leave(tester);
    });

    testWidgets('a link while this device is already in a room does not throw anyone out', (tester) async {
      final host = _memoryHost();
      final env = FakeNetworkEnv(onConnect: host.accept);
      final links = FakeJoinLinks(initial: _link);
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, links: links);
      await tester.tap(_ticketConnect);
      await _settle(tester);
      expect(find.byType(ClientLobbyScreen), findsOneWidget);
      final rooms = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(networkRoomsProvider);
      final client = rooms.client;

      // The room QR is scanned again with the phone camera.
      links.open('deskovky://join?ip=192.168.1.10&port=50506&code=0042');
      await _settle(tester);
      expect(find.byType(ClientLobbyScreen), findsOneWidget, reason: 'stays in the room');
      expect(find.byType(JoinScreen, skipOffstage: false), findsNothing);
      expect(rooms.client, same(client));
      expect(client!.closedReason, isNull);
      expect(find.text('Už hraješ. Nejdřív odejdi z rozehrané hry nebo místnosti.'), findsOneWidget);
      host.dispose();
      await _leave(tester);
    });

    testWidgets('while the app runs a link opens joining; a second link replaces the first', (tester) async {
      final env = FakeNetworkEnv();
      final links = FakeJoinLinks();
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, links: links);
      expect(find.byType(HomeScreen), findsOneWidget);

      links.open(_link);
      await _settle(tester);
      expect(find.byType(JoinScreen), findsOneWidget);
      expect(find.textContaining('4321'), findsOneWidget);

      links.open('deskovky://join?ip=192.168.1.10&port=50506&code=0042');
      await _settle(tester);
      expect(find.byType(JoinScreen, skipOffstage: false), findsOneWidget, reason: 'not two join screens on top');
      expect(find.textContaining('0042'), findsOneWidget);
      expect(find.textContaining('4321'), findsNothing);

      // Back goes home, not to the first link.
      await tester.tap(find.byTooltip('Zpět'));
      await _settle(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('foreign or broken links are ignored', (tester) async {
      final env = FakeNetworkEnv();
      final links = FakeJoinLinks(initial: 'deskovky://join?ip=evil.example.com&port=443&code=1234');
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, links: links);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(JoinScreen), findsNothing);

      links.open('https://example.com');
      links.open('deskovky://play?x=1');
      await _settle(tester);
      expect(find.byType(JoinScreen), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('from a link, "another room" goes to the usual join screen', (tester) async {
      final env = FakeNetworkEnv();
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, links: FakeJoinLinks(initial: _link));
      await tester.tap(find.byKey(const ValueKey('joinOtherRoom')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('joinCode')), findsOneWidget);
      expect(env.searching, isTrue);
    });
  });

  group('Načíst QR on the join screen', () {
    testWidgets('a room QR code fills in the room and joins', (tester) async {
      final host = _memoryHost();
      final env = FakeNetworkEnv(onConnect: host.accept);
      final scanner = FakeQrScanner(const QrScanned(_link));
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, scanner: scanner);
      await _openJoin(tester);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(scanner.scans, 1);
      expect(find.textContaining('4321'), findsOneWidget);
      await tester.tap(_ticketConnect);
      await _settle(tester);
      expect(find.byType(ClientLobbyScreen), findsOneWidget);
      expect((host.slots[1] as RemoteSlot).card.name, 'Kuba');
      host.dispose();
      await _leave(tester);
    });

    testWidgets('a QR code that is not a Deskovky room says so kindly', (tester) async {
      final env = FakeNetworkEnv();
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, scanner: FakeQrScanner(const QrScanned('https://example.com')));
      await _openJoin(tester);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(find.textContaining('Tohle není QR kód Deskovek'), findsOneWidget);
      expect(_ticketConnect, findsNothing);
    });

    testWidgets('a refused camera says what to do instead', (tester) async {
      final env = FakeNetworkEnv();
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env, scanner: FakeQrScanner(const QrCameraDenied()));
      await _openJoin(tester);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(find.textContaining('Bez fotoaparátu'), findsOneWidget);
      expect(find.byType(JoinScreen), findsOneWidget);
    });

    testWidgets('closing the camera changes nothing', (tester) async {
      final env = FakeNetworkEnv();
      await _players(tester, db, ['Kuba']);
      await _pump(tester, db, env);
      await _openJoin(tester);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byKey(const ValueKey('joinCode')), findsOneWidget);
    });
  });

  for (final locale in ['cs', 'en', 'es']) {
    testWidgets('joining from a QR code fits a 360 dp phone at 130 % ($locale)', (tester) async {
      final env = FakeNetworkEnv();
      final scanner = FakeQrScanner(const QrScanned('nope'));
      await _players(tester, db, ['Maximiliánek', 'Kristýnka']);
      await _pump(
        tester,
        db,
        env,
        scanner: scanner,
        size: const Size(360, 740),
        locale: Locale(locale),
        textScale: 1.3,
      );
      await _openJoin(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: 'the "not a room" message fits');
      scanner.next = const QrCameraDenied();
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: 'the camera message fits');
      scanner.next = const QrScanned(_link);
      await tester.tap(find.byKey(const ValueKey('joinScanQr')));
      await _settle(tester);
      expect(_ticketConnect, findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'the room from the QR code fits');
    });
  }
}
