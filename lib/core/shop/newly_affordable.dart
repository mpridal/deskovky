import 'shop_catalog.dart';

/// The item to announce after a game (spec 5.6 "Teď si můžeš koupit…"): one
/// the player tried on in the shop, does not own, and could not buy before
/// the game but can now — by points or by reaching its level. Of several,
/// the most expensive one.
ShopItem? newlyAffordable(
  ShopCatalog catalog, {
  required Set<String> tried,
  required Set<String> owned,
  required int balanceBefore,
  required int balanceAfter,
  required int levelBefore,
  required int levelAfter,
}) {
  bool canBuy(ShopItem item, int balance, int level) =>
      item.purchasable && item.price! <= balance && item.minLevel <= level;
  final now = [
    for (final id in tried)
      if (catalog.byId(id) case final item?
          when !owned.contains(id) && canBuy(item, balanceAfter, levelAfter) && !canBuy(item, balanceBefore, levelBefore))
        item,
  ]..sort((a, b) => b.price!.compareTo(a.price!));
  return now.firstOrNull;
}
