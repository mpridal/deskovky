import 'dart:io';

import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/ui_kit/avatar/accessories/accessory_art.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync());

  test('every catalog item has art in its slot, animated exactly when the catalog says', () {
    for (final item in catalog.items) {
      final art = accessoryArts[item.id];
      expect(art, isNotNull, reason: item.id);
      expect(art!.slot, item.slot, reason: item.id);
      expect(art.animated, item.animated, reason: item.id);
    }
    expect(accessoryArts.keys.toSet(), catalog.items.map((i) => i.id).toSet(), reason: 'no art without an item');
  });
}
