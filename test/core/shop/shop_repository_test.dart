import 'dart:io';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/core/shop/shop_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File('assets/config/shop_items.json').readAsStringSync());
  late AppDatabase db;
  late ShopRepository shop;
  late PointsRepository points;
  late int kuba;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    points = PointsRepository(db);
    shop = ShopRepository(db, catalog: catalog, points: points, stats: StatsRepository(db));
    kuba = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  Future<void> earn(int amount) => points.addGameLines(kuba, [PointsLine(PointsReason.win, amount)]);

  test('buying spends points once; owning it twice is impossible', () async {
    await earn(100);
    expect((await shop.buy(kuba, 'glasses')).outcome, BuyOutcome.bought);
    expect(await points.balance(kuba), 60);
    expect((await shop.buy(kuba, 'glasses')).outcome, BuyOutcome.alreadyOwned);
    expect(await points.balance(kuba), 60);
    expect(await shop.owned(kuba), contains('glasses'));
    expect((await points.history(kuba)).first.reason, PointsReason.purchase);
  });

  test('two purchases at the same moment never overspend', () async {
    await earn(200);
    final results = await Future.wait([shop.buy(kuba, 'sunglasses'), shop.buy(kuba, 'top_hat')]);
    expect(results.where((r) => r.outcome == BuyOutcome.bought), hasLength(1));
    expect(await points.balance(kuba), greaterThanOrEqualTo(0));
  });

  test('not enough points, too low a level, badge-only and unknown items are refused', () async {
    await earn(100);
    expect((await shop.buy(kuba, 'top_hat')).outcome, BuyOutcome.notEnoughPoints);
    await earn(1600);
    expect((await shop.buy(kuba, 'crown')).outcome, BuyOutcome.levelTooLow, reason: 'level 7 at 1700 points, 8 needs 1800');
    expect((await shop.buy(kuba, 'trophy')).outcome, BuyOutcome.notForSale);
    expect((await shop.buy(kuba, 'nope')).outcome, BuyOutcome.unknown);
    expect(await points.balance(kuba), 1700);
  });

  test('spending never lowers the total earned or the level', () async {
    await earn(500);
    await shop.buy(kuba, 'wizard_hat');
    expect(await points.totalEarned(kuba), 500);
  });

  test('badge items are owned as soon as the badge is earned', () async {
    expect(await shop.owned(kuba), isNot(contains('trophy')));
    await StatsRepository(db).awardBadge(kuba, 'wins50');
    expect(await shop.owned(kuba), contains('trophy'));
  });

  test('equipping writes the avatar; one item per slot; only owned items; variants are free', () async {
    await earn(1000);
    await shop.buy(kuba, 'cap');
    await shop.buy(kuba, 'top_hat');
    await shop.equip(kuba, 'cap', variant: 'blue');
    var avatar = (await PlayerRepository(db).byId(kuba))!.avatar;
    expect(avatar.equipped[AccessorySlot.head], const EquippedItem('cap', variant: 'blue'));
    await shop.equip(kuba, 'top_hat');
    avatar = (await PlayerRepository(db).byId(kuba))!.avatar;
    expect(avatar.equipped[AccessorySlot.head]!.id, 'top_hat');
    expect(() => shop.equip(kuba, 'crown'), throwsStateError, reason: 'not owned');
    await shop.unequip(kuba, AccessorySlot.head);
    expect((await PlayerRepository(db).byId(kuba))!.avatar.equipped, isEmpty);
  });

  test('the tenth purchase earns "Sběratel" with its points', () async {
    await earn(5000);
    final ids = ['cap', 'ears_headband', 'flower_wreath', 'glasses', 'mustache', 'face_paint_star', 'lollipop', 'balloon', 'ice_cream'];
    for (final id in ids) {
      expect((await shop.buy(kuba, id)).newBadge, isNull);
    }
    final tenth = await shop.buy(kuba, 'wood_frame');
    expect(tenth.newBadge, 'collector');
    expect((await StatsRepository(db).earnedBadges(kuba)).keys, contains('collector'));
    expect((await points.history(kuba)).first.reason, PointsReason.badge);
  });

  test("a parent's reset: balance 0, no items, nothing equipped; total earned and level stay", () async {
    await earn(300);
    await shop.buy(kuba, 'glasses');
    await shop.equip(kuba, 'glasses');
    await shop.reset(kuba);
    expect(await points.balance(kuba), 0);
    expect(await points.totalEarned(kuba), 300);
    expect(await shop.owned(kuba), isEmpty);
    expect((await PlayerRepository(db).byId(kuba))!.avatar.equipped, isEmpty);
  });

  test('deleting the player deletes the inventory', () async {
    await earn(100);
    await shop.buy(kuba, 'glasses');
    await PlayerRepository(db).delete(kuba);
    expect(await shop.owned(kuba), isEmpty);
  });
}
