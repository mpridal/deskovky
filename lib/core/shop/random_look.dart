import 'dart:math';

import '../avatar/avatar_spec.dart';
import 'shop_catalog.dart';

/// The avatar editor's "Random" (spec 5.6): a random base look, plus per slot
/// either nothing or one of the [owned] items in a random colour. Slots with
/// no owned item draw nothing, so without items this is [AvatarSpec.random].
AvatarSpec randomLook(Random random, Iterable<ShopItem> owned) {
  final base = AvatarSpec.random(random);
  final equipped = <AccessorySlot, EquippedItem>{};
  for (final slot in AccessorySlot.values) {
    final items = [for (final i in owned) if (i.slot == slot) i];
    if (items.isEmpty) continue;
    final pick = random.nextInt(items.length + 1);
    if (pick == items.length) continue;
    final item = items[pick];
    final variants = item.colorVariants;
    equipped[slot] = EquippedItem(item.id, variant: variants.isEmpty ? null : variants[random.nextInt(variants.length)]);
  }
  return equipped.isEmpty ? base : base.copyWith(equipped: equipped);
}
