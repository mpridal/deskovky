import 'package:flutter/foundation.dart';

import '../avatar/avatar_spec.dart';
import '../db/app_database.dart';
import '../players/player_repository.dart';
import '../points/levels.dart';
import '../points/points_math.dart';
import '../points/points_repository.dart';
import '../stats/stats_repository.dart';
import 'shop_catalog.dart';

enum BuyOutcome { bought, alreadyOwned, notEnoughPoints, levelTooLow, notForSale, unknown }

@immutable
class BuyResult {
  const BuyResult(this.outcome, {this.newBadge});

  final BuyOutcome outcome;

  /// "Sběratel" earned with this purchase.
  final String? newBadge;
}

/// Buying, owning and wearing avatar upgrades (spec 5.6). Every purchase is
/// one transaction with its ledger entry, so points are never spent twice.
class ShopRepository {
  ShopRepository(this._db, {required this.catalog, required this.points, required this.stats, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// Earned after this many bought upgrades (spec 5.5 "Sběratel").
  static const collectorCount = 10;
  static const collectorBadge = 'collector';
  static const itemsCounter = 'shop.items';

  final AppDatabase _db;
  final ShopCatalog catalog;
  final PointsRepository points;
  final StatsRepository stats;
  final DateTime Function() _now;

  Future<Set<String>> _bought(int playerId) async => {
    for (final row in await (_db.select(_db.playerItems)..where((i) => i.playerId.equals(playerId))).get()) row.itemId,
  };

  /// Bought upgrades plus those unlocked by the player's badges.
  Future<Set<String>> owned(int playerId) async {
    final badges = (await stats.earnedBadges(playerId)).keys.toSet();
    return {
      ...await _bought(playerId),
      for (final item in catalog.items)
        if (item.badgeId != null && badges.contains(item.badgeId)) item.id,
    };
  }

  /// Owned items now and after every purchase or reset.
  Stream<Set<String>> watchOwned(int playerId) => (_db.select(_db.playerItems)
        ..where((i) => i.playerId.equals(playerId)))
      .watch()
      .asyncMap((_) => owned(playerId));

  Future<BuyResult> buy(int playerId, String itemId) => _db.transaction(() async {
    final item = catalog.byId(itemId);
    if (item == null) return const BuyResult(BuyOutcome.unknown);
    final price = item.price;
    if (price == null) return const BuyResult(BuyOutcome.notForSale);
    final bought = await _bought(playerId);
    if (bought.contains(itemId)) return const BuyResult(BuyOutcome.alreadyOwned);
    if (levelFor(await points.totalEarned(playerId)) < item.minLevel) return const BuyResult(BuyOutcome.levelTooLow);
    if (await points.balance(playerId) < price) return const BuyResult(BuyOutcome.notEnoughPoints);
    await _db
        .into(_db.playerItems)
        .insert(
          PlayerItemsCompanion.insert(playerId: playerId, itemId: itemId, acquiredAt: _now().millisecondsSinceEpoch),
        );
    await points.spend(playerId, price, itemId: itemId);
    String? newBadge;
    if (bought.length + 1 >= collectorCount && await stats.awardBadge(playerId, collectorBadge)) {
      newBadge = collectorBadge;
      await points.addGameLines(playerId, const [PointsLine(PointsReason.badge, 30, badgeId: collectorBadge)]);
    }
    return BuyResult(BuyOutcome.bought, newBadge: newBadge);
  });

  /// Wears [itemId] (replacing whatever is in its slot); the colour variant
  /// is free to change. Throws [StateError] for items the player lacks.
  Future<void> equip(int playerId, String itemId, {String? variant}) async {
    final item = catalog.byId(itemId);
    if (item == null || !(await owned(playerId)).contains(itemId)) {
      throw StateError('$itemId is not owned by player $playerId');
    }
    final chosen = item.colorVariants.contains(variant) ? variant : item.defaultVariant;
    await _changeAvatar(playerId, (a) => {...a.equipped, item.slot: EquippedItem(itemId, variant: chosen)});
  }

  Future<void> unequip(int playerId, AccessorySlot slot) =>
      _changeAvatar(playerId, (a) => {...a.equipped}..remove(slot));

  Future<void> _changeAvatar(int playerId, Map<AccessorySlot, EquippedItem> Function(AvatarSpec) change) async {
    final players = PlayerRepository(_db);
    final profile = await players.byId(playerId);
    if (profile == null) return;
    await players.update(playerId, avatar: profile.avatar.copyWith(equipped: change(profile.avatar)));
  }

  /// Parents' corner (spec 5.6): balance to 0, bought items gone, nothing
  /// worn. Total earned, level and badges stay.
  Future<void> reset(int playerId) => _db.transaction(() async {
    final balance = await points.balance(playerId);
    if (balance > 0) await points.addReset(playerId, -balance);
    await (_db.delete(_db.playerItems)..where((i) => i.playerId.equals(playerId))).go();
    await _changeAvatar(playerId, (_) => const {});
  });
}
