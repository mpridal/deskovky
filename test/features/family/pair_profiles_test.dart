import 'package:deskovky/app/family_providers.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/family/hlc.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:deskovky/core/shop/shop_repository.dart';
import 'package:deskovky/features/family/pair_profiles_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../app/fake_family_net.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _settle(WidgetTester tester, [int rounds = 6]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump(const Duration(milliseconds: 60));
  }
}

/// Ops as if they came from the family's phone.
List<FamilyOp> _fromPhone(List<OpBody> bodies, {int start = 1}) => [
  for (final (i, body) in bodies.indexed)
    FamilyOp(origin: 'phone', seq: start + i, clock: Hlc(1762000000000 + i, 0, 'phone'), body: body),
];

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  /// Viky on this tablet (100 points, a hat for 30) and another Viky from
  /// the phone (50 points, the same hat).
  Future<int> twoVikys(WidgetTester tester) async => (await tester.runAsync(() async {
    final viky = await PlayerRepository(db).create(name: 'Viky', avatar: AvatarSpec.defaults);
    await PointsRepository(db).gift(viky.id, 100);
    final store = FamilyStore.of(db);
    await store.append(ItemBought(itemUid: 'tab-hat', playerUid: await FamilyStore.playerUid(db, viky.id), itemId: 'hat', price: 30, atMs: 1));
    await store.insertRemote(_fromPhone([
      ProfileCreated(uid: 'phone-viky', name: 'Viky', avatar: AvatarSpec.defaults.toJson()),
      const PointsAdded(entryUid: 'g1', playerUid: 'phone-viky', amount: 50, reason: 'gift', atMs: 2),
      const ItemBought(itemUid: 'phone-hat', playerUid: 'phone-viky', itemId: 'hat', price: 30, atMs: 3),
    ]));
    await store.rebuild();
    return viky.id;
  }))!;

  Future<void> openPairs(WidgetTester tester) async {
    await pumpApp(
      tester,
      size: const Size(412, 915),
      db: db,
      disableAnimations: true,
      overrides: [familyNetProvider.overrideWithValue(FakeLan().device())],
    );
    await _settle(tester, 2);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/settings/parents/family/pairs');
    await _settle(tester);
    expect(find.byType(PairProfilesScreen), findsOneWidget);
  }

  Future<List<String>> names(WidgetTester tester) async =>
      [for (final p in (await tester.runAsync(() => PlayerRepository(db).all()))!) p.name];

  testWidgets('Viky and Viky are offered; merging sums the points and gives the duplicate hat back', (tester) async {
    final viky = await twoVikys(tester);
    expect(await names(tester), ['Viky', 'Viky 2']);
    await openPairs(tester);
    expect(find.text('Je to stejná osoba?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('pairMerge0')));
    await _settle(tester);
    expect(await names(tester), ['Viky']);
    // The older profile stays (here the phone's); everything is on it.
    final joined = (await tester.runAsync(() => PlayerRepository(db).all()))!.single;
    expect(viky, isNot(joined.id));
    expect(await tester.runAsync(() => PointsRepository(db).balance(joined.id)), 100 - 30 + 50 - 30 + 30);
    expect(find.text('Žádné další dvojice.'), findsOneWidget);
  });

  testWidgets('"two people" keeps both and does not ask again', (tester) async {
    await twoVikys(tester);
    await openPairs(tester);
    await tester.tap(find.byKey(const ValueKey('pairKeep0')));
    await _settle(tester);
    expect(await names(tester), ['Viky', 'Viky 2']);
    expect(find.text('Žádné další dvojice.'), findsOneWidget);
    await tester.tap(find.byTooltip('Zpět').last);
    await _settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).push('/settings/parents/family/pairs');
    await _settle(tester);
    expect(find.text('Je to stejná osoba?'), findsNothing);
  });

  testWidgets('a purchase taken back is explained once, and only to the child it belongs to', (tester) async {
    await tester.runAsync(() async {
      final viky = await PlayerRepository(db).create(name: 'Viky', avatar: AvatarSpec.defaults);
      await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults);
      await PointsRepository(db).gift(viky.id, ShopRepository.collectorCount);
      final uid = await FamilyStore.playerUid(db, viky.id);
      final store = FamilyStore.of(db);
      // The phone spent the same points on glasses, later than the tablet's hat.
      await store.append(ItemBought(itemUid: 'tab-hat', playerUid: uid, itemId: 'hat', price: ShopRepository.collectorCount, atMs: 1));
      await store.insertRemote(_fromPhone([
        ItemBought(itemUid: 'phone-glasses', playerUid: uid, itemId: 'glasses', price: ShopRepository.collectorCount, atMs: 9),
      ]));
      await store.rebuild();
      await SettingsRepository(db).setActivePlayerId((await PlayerRepository(db).all()).last.id);
    });
    // Kuba is signed in: nothing for him.
    await pumpApp(tester, size: const Size(412, 915), db: db, disableAnimations: true, overrides: [familyNetProvider.overrideWithValue(FakeLan().device())]);
    await _settle(tester);
    expect(find.byKey(const ValueKey('refundNotice')), findsNothing);
    // Viky signs in: she hears it once.
    await tester.runAsync(() async => SettingsRepository(db).setActivePlayerId((await PlayerRepository(db).all()).first.id));
    await _settle(tester);
    expect(find.byKey(const ValueKey('refundNotice')), findsOneWidget);
    expect(find.textContaining('nebylo dost bodů'), findsOneWidget);
    await tester.tap(find.text('Rozumím'));
    await _settle(tester);
    expect(find.byKey(const ValueKey('refundNotice')), findsNothing);
    await tester.runAsync(() async => SettingsRepository(db).setActivePlayerId((await PlayerRepository(db).all()).last.id));
    await _settle(tester);
    await tester.runAsync(() async => SettingsRepository(db).setActivePlayerId((await PlayerRepository(db).all()).first.id));
    await _settle(tester);
    expect(find.byKey(const ValueKey('refundNotice')), findsNothing, reason: 'once');
  });
}
