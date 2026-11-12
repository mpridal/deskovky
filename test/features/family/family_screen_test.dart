import 'package:deskovky/app/family_controller.dart';
import 'package:deskovky/app/family_providers.dart';
import 'package:deskovky/app/multiplayer_providers.dart';
import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_identity.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/family/family_screen.dart';
import 'package:deskovky/features/multiplayer/qr_scanner.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/fake_family_net.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

class _Scanner implements QrScanner {
  String? text;

  @override
  Future<QrScanResult> scan(BuildContext context) async => text == null ? const QrScanCancelled() : QrScanned(text!);
}

/// Lets the database and the loopback lines move on.
Future<void> _settle(WidgetTester tester, [int rounds = 8]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// A widget test that closes the app at the end, so the family stops
/// announcing (no timers left behind).
void familyTest(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (tester) async {
    await body(tester);
    await tester.pumpWidget(const SizedBox());
    await _settle(tester, 2);
  });
}

void main() {
  late AppDatabase db;
  late FakeLan lan;
  late _Scanner scanner;
  setUp(() {
    db = testDatabase();
    lan = FakeLan();
    scanner = _Scanner();
  });
  tearDown(() => db.close());

  Future<void> openFamily(WidgetTester tester, {Size size = const Size(412, 915), String locale = 'cs', double scale = 1}) async {
    await pumpApp(
      tester,
      size: size,
      locale: Locale(locale),
      textScale: scale,
      db: db,
      disableAnimations: true,
      overrides: [familyNetProvider.overrideWithValue(lan.device()), qrScannerProvider.overrideWithValue(scanner)],
    );
    await _settle(tester, 2);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/settings/parents/family');
    await _settle(tester);
    expect(find.byType(FamilyScreen), findsOneWidget);
  }

  /// A tablet that already has a family with Viky, outside the widget tree.
  Future<(FamilyController, AppDatabase)> otherTablet(WidgetTester tester) async {
    final tabletDb = AppDatabase(NativeDatabase.memory());
    addTearDown(tabletDb.close);
    final controller = FamilyController(
      db: tabletDb,
      net: lan.device(),
      stats: StatsService(StatsRepository(tabletDb), points: PointsRepository(tabletDb)),
    );
    addTearDown(controller.dispose);
    await tester.runAsync(() async {
      await PlayerRepository(tabletDb).create(name: 'Viky', avatar: AvatarSpec.defaults);
      await controller.createFamily(deviceName: 'Tablet');
    });
    return (controller, tabletDb);
  }

  familyTest('the parents corner leads to Rodina', (tester) async {
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/settings/parents');
    await _settle(tester);
    expect(find.byKey(const ValueKey('familyLink')), findsOneWidget);
  });

  familyTest('creating a family shows its QR code with a valid family ticket', (tester) async {
    await openFamily(tester);
    expect(find.textContaining('Propojte zařízení rodiny'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('familyCreate')));
    await _settle(tester);
    expect(find.byType(QrImageView), findsOneWidget);
    final controller = ProviderScope.containerOf(tester.element(find.byType(FamilyScreen))).read(familyControllerProvider);
    expect(FamilyTicket.parse(controller.ticket!.toUri().toString()), controller.ticket);
    expect(find.text('Telefon'), findsOneWidget, reason: 'this device in the list');
    expect(find.text('toto zařízení'), findsOneWidget);
  });

  familyTest('joining by scanning the tablet code brings Viky here', (tester) async {
    final (tablet, _) = await otherTablet(tester);
    scanner.text = tablet.ticket!.toUri().toString();
    await openFamily(tester);
    await tester.tap(find.byKey(const ValueKey('familyJoin')));
    await _settle(tester, 20);
    expect(find.text('Hotovo – jsi v rodině!'), findsOneWidget);
    expect((await tester.runAsync(() => PlayerRepository(db).all()))!.map((p) => p.name), ['Viky']);
    expect(find.text('Tablet'), findsOneWidget);
  });

  familyTest('a code that is not a family code says so', (tester) async {
    scanner.text = 'deskovky://join?ip=192.168.1.9&port=1&code=1234';
    await openFamily(tester);
    await tester.tap(find.byKey(const ValueKey('familyJoin')));
    await _settle(tester);
    expect(find.text('Tohle není rodinný kód.'), findsOneWidget);
  });

  familyTest('a parent removes a device from the family', (tester) async {
    final (tablet, _) = await otherTablet(tester);
    scanner.text = tablet.ticket!.toUri().toString();
    await openFamily(tester);
    await tester.tap(find.byKey(const ValueKey('familyJoin')));
    await _settle(tester, 20);
    final remove = find.byKey(const ValueKey('familyRemove'));
    await tester.scrollUntilVisible(
      remove,
      200,
      scrollable: find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.text('Odebrat Tablet z rodiny?'), findsOneWidget);
    await tester.tap(find.text('Odebrat z rodiny').last);
    await _settle(tester);
    expect(find.text('odebráno'), findsOneWidget);
  });

  familyTest('a device with another app version asks to update every device', (tester) async {
    await openFamily(tester);
    await tester.tap(find.byKey(const ValueKey('familyCreate')));
    await _settle(tester);
    final container = ProviderScope.containerOf(tester.element(find.byType(FamilyScreen)));
    container.read(familyControllerProvider).debugReport('version');
    await tester.pump();
    expect(find.textContaining('Aktualizujte aplikaci'), findsOneWidget);
  });

  familyTest('new data from the family shows a short sync blip on the home screen', (tester) async {
    await tester.runAsync(() => PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults));
    await openFamily(tester);
    await tester.tap(find.byKey(const ValueKey('familyCreate')));
    await _settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/games');
    await _settle(tester);
    expect(find.byKey(const ValueKey('syncBlip')), findsNothing);
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first)).read(familyControllerProvider).debugNewData();
    await tester.pump();
    expect(find.byKey(const ValueKey('syncBlip')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const ValueKey('syncBlip')), findsNothing);
  });

  for (final locale in ['cs', 'en', 'es']) {
    familyTest('Rodina fits a 360 dp phone at 130 % ($locale)', (tester) async {
      await openFamily(tester, size: const Size(360, 740), locale: locale, scale: 1.3);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('familyCreate')));
      await _settle(tester);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
