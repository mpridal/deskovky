import 'dart:io';
import 'dart:math';

import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/shop/random_look.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync());
  final owned = [for (final id in ['cap', 'crown', 'glasses', 'kitten']) catalog.byId(id)!];

  test('without owned items it is the plain random avatar', () {
    expect(randomLook(Random(7), const []), AvatarSpec.random(Random(7)));
  });

  test('wears only owned items, each in its slot with a known variant', () {
    var worn = 0, bare = 0;
    for (var seed = 0; seed < 60; seed++) {
      final look = randomLook(Random(seed), owned);
      for (final MapEntry(key: slot, value: e) in look.equipped.entries) {
        final item = catalog.byId(e.id)!;
        expect(owned, contains(item));
        expect(item.slot, slot);
        if (item.colorVariants.isNotEmpty) expect(item.colorVariants, contains(e.variant));
      }
      look.equipped.containsKey(AccessorySlot.head) ? worn++ : bare++;
    }
    expect(worn, greaterThan(0), reason: 'owned hats come out sometimes');
    expect(bare, greaterThan(0), reason: 'a slot may also stay empty');
  });
}
