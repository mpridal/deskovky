import 'dart:io';

import 'package:deskovky/core/shop/shop_catalog.dart';
import 'package:deskovky/games/item_texts.dart';
import 'package:deskovky/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = ShopCatalog.parse(File('assets/config/shop_items.json').readAsStringSync());
  for (final code in ['cs', 'en', 'es']) {
    test('every shop item has a name in $code', () async {
      final l10n = await AppLocalizations.delegate.load(Locale(code));
      for (final item in catalog.items) {
        expect(itemName(l10n, item.id), isNot(item.id), reason: item.id);
      }
    });
  }
}
