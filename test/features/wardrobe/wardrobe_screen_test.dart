import 'dart:io';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/core/shop/shop_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/features/shop/shop_screen.dart';
import 'package:deskovky/features/wardrobe/wardrobe_screen.dart';
import 'package:deskovky/app/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/fake_audio_backend.dart';
import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  ShopRepository shop() => ShopRepository(
    db,
    catalog: ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync()),
    points: PointsRepository(db),
    stats: StatsRepository(db),
  );

  Future<int> player(WidgetTester tester, {List<String> items = const []}) async => (await tester.runAsync(() async {
    final id = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
    await PointsRepository(db).addGameLines(id, [PointsLine(PointsReason.win, 5000)]);
    for (final item in items) {
      await shop().buy(id, item);
    }
    return id;
  }))!;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<void> open(
    WidgetTester tester,
    int id, {
    FakeAudioBackend? audio,
    Size size = const Size(412, 915),
    Locale locale = const Locale('cs'),
    double textScale = 1,
    List<Override> overrides = const [],
  }) async {
    await pumpApp(tester, size: size, db: db, audio: audio, locale: locale, textScale: textScale, overrides: overrides);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/players/$id/wardrobe');
    await settle(tester);
    expect(find.byType(WardrobeScreen), findsOneWidget);
  }

  Finder card(String id) => find.byKey(ValueKey('own_$id'));

  Future<void> tapCard(WidgetTester tester, String id) async {
    await tester.ensureVisible(card(id));
    await tester.pumpAndSettle();
    await tester.tap(card(id));
    await settle(tester);
  }

  Future<AvatarSpec> saved(WidgetTester tester, int id) async =>
      (await tester.runAsync(() => PlayerRepository(db).byId(id)))!.avatar;

  testWidgets('an empty wardrobe sends the player to the shop', (tester) async {
    final id = await player(tester);
    await open(tester, id);
    expect(find.text('Zatím tu nic není. Vylepšení koupíš v obchodě.'), findsOneWidget);
    await tester.tap(find.text('Do obchodu'));
    await settle(tester);
    expect(find.byType(ShopScreen), findsOneWidget);
  });

  testWidgets('shows only owned items, grouped by slot', (tester) async {
    final id = await player(tester, items: ['cap', 'glasses']);
    await open(tester, id);
    expect(card('cap'), findsOneWidget);
    expect(card('glasses'), findsOneWidget);
    expect(card('wizard_hat'), findsNothing);
    expect(find.text('Na hlavu'), findsOneWidget);
    expect(find.text('Obličej'), findsOneWidget);
    expect(find.text('Do ruky'), findsNothing, reason: 'no hand items owned');
  });

  testWidgets('tapping puts an item on and off with the equip sound', (tester) async {
    final id = await player(tester, items: ['glasses']);
    final audio = FakeAudioBackend();
    await open(tester, id, audio: audio);
    await tapCard(tester, 'glasses');
    expect((await saved(tester, id)).equipped[AccessorySlot.face]?.id, 'glasses');
    expect([for (final s in audio.sfx) s.$2], contains('sfx/equip.wav'));
    expect(find.descendant(of: card('glasses'), matching: find.text('Nasazeno')), findsOneWidget);
    await tapCard(tester, 'glasses');
    expect((await saved(tester, id)).equipped, isEmpty);
  });

  testWidgets('a worn item with colours can be recoloured for free', (tester) async {
    final id = await player(tester, items: ['cap']);
    final balance = await tester.runAsync(() => PointsRepository(db).balance(id));
    await open(tester, id);
    await tapCard(tester, 'cap');
    final blue = find.bySemanticsLabel('Barva: modrá');
    await tester.ensureVisible(blue);
    await tester.tap(blue);
    await settle(tester);
    expect((await saved(tester, id)).equipped[AccessorySlot.head], const EquippedItem('cap', variant: 'blue'));
    expect(await tester.runAsync(() => PointsRepository(db).balance(id)), balance);
  });

  testWidgets('a failing equip does not crash and tells the player', (tester) async {
    final id = await player(tester, items: ['glasses']);
    await open(tester, id, overrides: [shopRepositoryProvider.overrideWith((ref) => _FailingShop(db))]);
    await tapCard(tester, 'glasses');
    expect(tester.takeException(), isNull);
    expect(find.text('To teď nejde. Zkus to znovu.'), findsOneWidget);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('the wardrobe fits 360 dp at 130 % in $code', (tester) async {
        final id = await player(tester, items: ['cap', 'crown', 'glasses', 'kitten', 'gold_frame', 'sparkles', 'phone']);
        await open(tester, id, size: const Size(360, 740), locale: Locale(code), textScale: 1.3);
        await tapCard(tester, 'cap');
        expect(tester.takeException(), isNull);
        final list = find.byType(Scrollable).last;
        for (var i = 0; i < 6; i++) {
          await tester.drag(list, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}

/// Fails to equip, like after a parent's reset in the meantime.
class _FailingShop extends ShopRepository {
  _FailingShop(AppDatabase db)
    : super(
        db,
        catalog: ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync()),
        points: PointsRepository(db),
        stats: StatsRepository(db),
      );

  @override
  Future<void> equip(int playerId, String itemId, {String? variant}) async => throw StateError('not owned');
}
