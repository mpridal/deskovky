import 'dart:io';

import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File('assets/config/shop_items.json').readAsStringSync());

  test('the bundled catalog has the 36 approved items in 6 slots', () {
    expect(catalog.items, hasLength(36));
    expect({for (final i in catalog.items) i.slot}, AccessorySlot.values.toSet());
    expect(catalog.inSlot(AccessorySlot.head).map((i) => i.id), contains('crown'));
    expect(catalog.byId('halo')!.slot, AccessorySlot.head, reason: 'halo replaces the crown, not with it');
  });

  test('rarity fits the price band; legendary needs level 8; badge items cannot be bought (spec 5.6)', () {
    for (final item in catalog.items) {
      switch (item.rarity) {
        case Rarity.common:
          expect(item.price, inInclusiveRange(30, 60), reason: item.id);
        case Rarity.rare:
          expect(item.price, inInclusiveRange(100, 200), reason: item.id);
        case Rarity.epic:
          expect(item.price, inInclusiveRange(300, 500), reason: item.id);
        case Rarity.legendary:
          expect(item.price, inInclusiveRange(800, 1200), reason: item.id);
          expect(item.minLevel, greaterThanOrEqualTo(8), reason: item.id);
        case Rarity.badge:
          expect(item.price, isNull, reason: item.id);
          expect(item.badgeId, isNotNull, reason: item.id);
      }
    }
    expect(catalog.byId('trophy')!.badgeId, 'wins50');
    expect(catalog.byId('star_frame')!.badgeId, 'all_hard');
  });

  test('colour variants: the first one is the default', () {
    expect(catalog.byId('crown')!.colorVariants, ['gold', 'silver']);
    expect(catalog.byId('crown')!.defaultVariant, 'gold');
    expect(catalog.byId('top_hat')!.defaultVariant, isNull);
  });

  test('broken entries are skipped, the rest still loads; duplicate ids are rejected', () {
    final c = ShopCatalog.parse(
      '[{"id": "cap", "slot": "head", "rarity": "common", "price": 40},'
      ' {"id": "x", "slot": "tail", "rarity": "common", "price": 40},'
      ' {"id": "cap", "slot": "face", "rarity": "common", "price": 40},'
      ' {"id": "y", "slot": "face", "rarity": "rare"}]',
    );
    expect(c.items.map((i) => i.id), ['cap']);
    expect(ShopCatalog.parse('not json').items, isEmpty);
  });
}
