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
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:flutter/material.dart';
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

  Future<int> player(WidgetTester tester, {int points = 0}) async => (await tester.runAsync(() async {
    final id = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
    if (points > 0) await PointsRepository(db).addGameLines(id, [PointsLine(PointsReason.win, points)]);
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
  }) async {
    await pumpApp(tester, size: size, db: db, audio: audio, locale: locale, textScale: textScale);
    GoRouter.of(tester.element(find.byType(Navigator).first)).push('/players/$id/shop');
    await settle(tester);
    expect(find.byType(ShopScreen), findsOneWidget);
  }

  Finder card(String id) => find.byKey(ValueKey('item_$id'));

  Future<void> select(WidgetTester tester, String id) async {
    await tester.scrollUntilVisible(card(id), 200, scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(card(id));
    await tester.pumpAndSettle();
    await tester.tap(card(id));
    await tester.pumpAndSettle();
  }

  AvatarSpec tryOn(WidgetTester tester) => tester.widget<AnimatedAvatarView>(find.byKey(const ValueKey('tryOn'))).spec;

  testWidgets('shows the balance, the slots and locks on level and badge items', (tester) async {
    final id = await player(tester, points: 340);
    await open(tester, id);
    expect(find.text('● 340'), findsOneWidget);
    expect(find.text('Na hlavu'), findsOneWidget);
    await tester.scrollUntilVisible(card('crown'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.descendant(of: card('crown'), matching: find.text('🔒 Úroveň 8')), findsOneWidget);
    await tester.tap(find.text('Do ruky'));
    await tester.pumpAndSettle();
    expect(card('crown'), findsNothing, reason: 'the hand tab hides head items');
    await tester.scrollUntilVisible(card('trophy'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.descendant(of: card('trophy'), matching: find.text('🔒 Odznak: Padesátka')), findsOneWidget);
  });

  testWidgets('tapping an item tries it on in the booth without buying', (tester) async {
    final id = await player(tester, points: 10);
    await open(tester, id);
    await select(tester, 'wizard_hat');
    expect(tryOn(tester).equipped[AccessorySlot.head]?.id, 'wizard_hat');
    expect(find.text('Zkouška: Čarodějnický klobouk'), findsOneWidget);
    expect(await tester.runAsync(() => PointsRepository(db).balance(id)), 10);
  });

  testWidgets('buying: confirm, points go, sound plays, "Nasadit hned?" wears it', (tester) async {
    final id = await player(tester, points: 100);
    final audio = FakeAudioBackend();
    await open(tester, id, audio: audio);
    await select(tester, 'glasses');
    await tester.tap(find.text('Koupit za 40 ●'));
    await tester.pumpAndSettle();
    expect(find.text('Koupit Brýle za 40 ●?'), findsOneWidget);
    await tester.tap(find.text('Koupit'));
    await settle(tester);
    expect(await tester.runAsync(() => PointsRepository(db).balance(id)), 60);
    expect([for (final s in audio.sfx) s.$2], contains('sfx/purchase.wav'));
    expect(find.text('Nasadit hned?'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byType(Dialog), matching: find.text('Nasadit')));
    await settle(tester);
    final kuba = await tester.runAsync(() => PlayerRepository(db).byId(id));
    expect(kuba!.avatar.equipped[AccessorySlot.face]?.id, 'glasses');
    expect(find.descendant(of: card('glasses'), matching: find.text('Nasazeno')), findsOneWidget);
  });

  testWidgets('not enough points: the button says how many are missing and is disabled', (tester) async {
    final id = await player(tester, points: 100);
    await open(tester, id);
    await select(tester, 'top_hat');
    expect(find.text('Chybí ti 50 ●'), findsOneWidget);
    await tester.tap(find.text('Chybí ti 50 ●'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Koupit '), findsNothing);
  });

  testWidgets('an owned item can be taken off right in the shop', (tester) async {
    final id = await player(tester, points: 100);
    await tester.runAsync(() async {
      final shop = ShopRepository(
        db,
        catalog: ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync()),
        points: PointsRepository(db),
        stats: StatsRepository(db),
      );
      await shop.buy(id, 'glasses');
      await shop.equip(id, 'glasses');
    });
    await open(tester, id);
    await select(tester, 'glasses');
    await tester.tap(find.text('Sundat'));
    await settle(tester);
    expect((await tester.runAsync(() => PlayerRepository(db).byId(id)))!.avatar.equipped, isEmpty);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('the shop fits 360 dp at 130 % in $code', (tester) async {
        final id = await player(tester, points: 12345);
        await open(tester, id, size: const Size(360, 740), locale: Locale(code), textScale: 1.3);
        expect(tester.takeException(), isNull);
        await select(tester, 'carnival_mask');
        expect(tester.takeException(), isNull);
        final grid = find.byType(Scrollable).last;
        for (var i = 0; i < 8; i++) {
          await tester.drag(grid, const Offset(0, -400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  });
}
