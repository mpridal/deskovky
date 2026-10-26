import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../avatar/accessory_slot.dart';

export '../avatar/accessory_slot.dart';

/// Rarity sets the label colour and the price band (spec 5.6 "Katalog").
enum Rarity { common, rare, epic, legendary, badge }

/// One avatar upgrade from `assets/config/shop_items.json`.
@immutable
class ShopItem {
  const ShopItem({
    required this.id,
    required this.slot,
    required this.rarity,
    this.price,
    this.minLevel = 0,
    this.badgeId,
    this.colorVariants = const [],
    this.animated = false,
  });

  final String id;
  final AccessorySlot slot;
  final Rarity rarity;

  /// Points; null for items unlocked by a badge.
  final int? price;
  final int minLevel;

  /// The badge that unlocks the item (`badge:<id>` in the JSON).
  final String? badgeId;

  /// Bought once, the colour is then chosen in the wardrobe for free.
  final List<String> colorVariants;

  /// Animated only at 64 dp and up, never with reduced motion.
  final bool animated;

  String? get defaultVariant => colorVariants.firstOrNull;

  bool get purchasable => price != null;
}

/// The shop's items. Broken entries are skipped (and logged), so one typo
/// in the JSON never hides the whole shop.
@immutable
class ShopCatalog {
  const ShopCatalog(this.items);

  static const asset = 'assets/config/shop_items.json';
  static const empty = ShopCatalog([]);

  final List<ShopItem> items;

  ShopItem? byId(String id) => items.where((i) => i.id == id).firstOrNull;

  List<ShopItem> inSlot(AccessorySlot slot) => [for (final i in items) if (i.slot == slot) i];

  static ShopCatalog parse(String source) {
    Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      debugPrint('ShopCatalog: invalid JSON: $e');
      return empty;
    }
    if (json is! List) return empty;
    final items = <ShopItem>[];
    for (final entry in json) {
      final item = _item(entry);
      if (item == null || items.any((i) => i.id == item.id)) {
        debugPrint('ShopCatalog: skipping $entry');
        continue;
      }
      items.add(item);
    }
    return ShopCatalog(items);
  }

  static ShopItem? _item(Object? e) {
    if (e is! Map<String, Object?>) return null;
    final id = e['id'];
    final slot = AccessorySlot.values.where((s) => s.name == e['slot']).firstOrNull;
    final rarity = Rarity.values.where((r) => r.name == e['rarity']).firstOrNull;
    if (id is! String || id.isEmpty || slot == null || rarity == null) return null;
    final unlock = e['unlock'];
    final badge = unlock is String && unlock.startsWith('badge:') ? unlock.substring(6) : null;
    final price = e['price'];
    if (rarity == Rarity.badge ? badge == null : price is! int || price <= 0) return null;
    final variants = e['colorVariants'];
    return ShopItem(
      id: id,
      slot: slot,
      rarity: rarity,
      price: rarity == Rarity.badge ? null : price as int,
      minLevel: e['minLevel'] is int ? e['minLevel']! as int : 0,
      badgeId: badge,
      colorVariants: variants is List ? variants.whereType<String>().toList() : const [],
      animated: e['animated'] == true,
    );
  }
}
