import 'dart:io';

import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/core/shop/shop_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every write still goes to the tables as before, and the same change is
/// in the family log: a rebuild from the log must change nothing.
void main() {
  final catalog = ShopCatalog.parse(File('assets/config/shop_items.json').readAsStringSync());
  final cheap = [for (final i in catalog.items) if (i.price != null && i.minLevel == 0) i]
    ..sort((a, b) => a.price!.compareTo(b.price!));
  late AppDatabase db;
  late PlayerRepository players;
  late PointsRepository points;
  late StatsRepository stats;
  late StatsService service;
  late ShopRepository shop;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    players = PlayerRepository(db);
    points = PointsRepository(db);
    stats = StatsRepository(db);
    service = StatsService(stats, points: points);
    shop = ShopRepository(db, catalog: catalog, points: points, stats: stats);
  });
  tearDown(() => db.close());

  Future<String> tables() async => [
    for (final t in ['players', 'matches', 'match_participants', 'points_ledger', 'player_items', 'earned_badges', 'player_counters'])
      '$t: ${(await db.customSelect('SELECT * FROM $t ORDER BY 1, 2').get()).map((r) => r.data).toList()}',
  ].join('\n');

  Future<void> expectRebuildChangesNothing(String step) async {
    final before = await tables();
    await FamilyStore(db).rebuild();
    expect(await tables(), before, reason: step);
  }

  Future<List<String>> opTypes() async => [for (final op in await FamilyStore(db).all()) op.body.type];

  test('profiles, points, games, purchases, resets and deletes are all in the log; a rebuild changes nothing', () async {
    final viky = (await players.create(name: 'Viky', avatar: AvatarSpec.defaults)).id;
    final kuba = (await players.create(name: 'Kuba', avatar: AvatarSpec.defaults, favoriteSeat: 2)).id;
    await expectRebuildChangesNothing('create');
    expect(await opTypes(), ['profileCreated', 'profileCreated']);

    await players.update(viky, name: 'Vikinka');
    await expectRebuildChangesNothing('rename');

    await points.gift(viky, 500);
    await expectRebuildChangesNothing('gift');

    await service.recordFinished(
      config: GameConfig(
        gameId: 'memory',
        seats: [HumanSeat(viky), HumanSeat(kuba), const RobotSeat()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {'cards': 12},
      ),
      result: const GameResult(places: [1, 2, 3], scores: [4, 2, 0], stars: [3, 2, 1]),
      events: const [('memory.pairs', {'seat': 0, 'count': 4}), ('memory.pairs', {'seat': 1, 'count': 2})],
      duration: const Duration(minutes: 2),
    );
    await expectRebuildChangesNothing('match');
    expect(await opTypes(), contains('matchRecorded'));

    expect((await shop.buy(viky, cheap[0].id)).outcome, BuyOutcome.bought);
    expect((await shop.buy(viky, cheap[1].id)).outcome, BuyOutcome.bought);
    await shop.equip(viky, cheap[0].id);
    await expectRebuildChangesNothing('buy and equip');
    expect(await opTypes(), contains('itemBought'));

    await shop.reset(viky);
    await expectRebuildChangesNothing('reset');
    expect(await opTypes(), contains('pointsReset'));

    await points.addGameLines(kuba, const [PointsLine(PointsReason.win, 7)]);
    await players.delete(kuba);
    await expectRebuildChangesNothing('delete');
    expect(await opTypes(), contains('profileDeleted'));
  });

  test('the collector badge from the shop is in the log with its reward', () async {
    final viky = (await players.create(name: 'Viky', avatar: AvatarSpec.defaults)).id;
    await points.gift(viky, 100000);
    for (final item in cheap.take(ShopRepository.collectorCount)) {
      await shop.buy(viky, item.id);
    }
    expect((await stats.earnedBadges(viky)).keys, contains(ShopRepository.collectorBadge));
    await expectRebuildChangesNothing('collector');
    expect(await opTypes(), contains('badgeAwarded'));
  });

  test('checkBadges awards a badge whose counter reached its goal through the family', () async {
    final viky = (await players.create(name: 'Viky', avatar: AvatarSpec.defaults)).id;
    await service.recordFinished(
      config: GameConfig(
        gameId: 'memory',
        seats: [HumanSeat(viky), const RobotSeat()],
        difficulty: Difficulty.easy,
        robotSpeed: RobotSpeed.fast,
        options: const {'cards': 12},
      ),
      result: const GameResult(places: [2, 1], scores: [1, 5], stars: [1, 3]),
      events: const [('memory.pairs', {'seat': 0, 'count': 1})],
      duration: const Duration(minutes: 1),
    );
    expect((await stats.earnedBadges(viky)).keys, isNot(contains('memory.collector')));
    // Another device of the family found 199 more pairs for Viky.
    final store = FamilyStore(db);
    final vikyUid = (await (db.select(db.players)..where((p) => p.id.equals(viky))).getSingle()).uid!;
    await store.insertRemote([
      FamilyOp(origin: 'pho', seq: 1, clock: await store.nextClock(), body: CountersAdded(playerUid: vikyUid, deltas: const {'memory.pairs': 199})),
    ]);
    await store.rebuild();
    expect(await service.checkBadges(viky), ['memory.collector']);
    expect(await service.checkBadges(viky), isEmpty, reason: 'once');
    await expectRebuildChangesNothing('badge after sync');
  });

  test('checkBadges never gives another game badge for this game win (review C1)', () async {
    final viky = (await players.create(name: 'Viky', avatar: AvatarSpec.defaults)).id;
    await service.recordFinished(
      config: GameConfig(
        gameId: 'tictactoe',
        seats: [HumanSeat(viky), const RobotSeat()],
        difficulty: Difficulty.hard,
        robotSpeed: RobotSpeed.fast,
        options: const {},
      ),
      result: const GameResult(places: [1, 2], scores: [1, 0], stars: [3, 1]),
      events: const [],
      duration: const Duration(minutes: 1),
    );
    final before = await points.balance(viky);
    final awarded = await service.checkBadges(viky);
    expect(awarded, isNot(contains('checkers.grandmaster')));
    expect(awarded, isNot(contains('matches.master')));
    expect((await stats.earnedBadges(viky)).keys, isNot(contains('checkers.grandmaster')));
    expect(await points.balance(viky), before);
  });
}
