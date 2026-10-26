import 'dart:io';

import 'package:deskovky/core/shop/newly_affordable.dart';
import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File(ShopCatalog.asset).readAsStringSync());

  String? pick({
    Set<String> tried = const {'wizard_hat', 'glasses', 'crown', 'trophy'},
    Set<String> owned = const {},
    int before = 0,
    int after = 0,
    int levelBefore = 1,
    int levelAfter = 1,
  }) => newlyAffordable(
    catalog,
    tried: tried,
    owned: owned,
    balanceBefore: before,
    balanceAfter: after,
    levelBefore: levelBefore,
    levelAfter: levelAfter,
  )?.id;

  test('a tried item that the game made affordable', () {
    // wizard_hat 400, glasses 40.
    expect(pick(before: 380, after: 420), 'wizard_hat');
  });

  test('nothing when it was affordable already, or still is not', () {
    expect(pick(before: 50, after: 60), isNull, reason: 'glasses were affordable before');
    expect(pick(before: 50, after: 390), isNull, reason: 'the hat is still 10 short');
  });

  test('items never tried, owned, or for badges only do not count', () {
    expect(pick(tried: {}, before: 380, after: 420), isNull);
    expect(pick(owned: {'wizard_hat'}, before: 380, after: 420), isNull);
    expect(pick(tried: {'trophy'}, before: 0, after: 99999, levelAfter: 10), isNull);
  });

  test('a level-locked item counts once the level is reached', () {
    // crown 1000, level 8.
    expect(pick(before: 1200, after: 1250, levelBefore: 7, levelAfter: 7), isNull);
    expect(pick(before: 1200, after: 1250, levelBefore: 7, levelAfter: 8), 'crown');
  });

  test('of several, the most expensive one', () {
    expect(pick(before: 0, after: 450), 'wizard_hat');
  });
}
