import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/avatar/avatar_spec.dart';
import '../../core/players/player_profile.dart';
import '../../core/shop/shop_catalog.dart';
import '../../games/item_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/accessories/accessory_art.dart' show Art;
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/color_swatch_picker.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../shop/shop_screen.dart' show rarityColor, slotLabel;

/// Name of a colour variant from `shop_items.json`.
String colourName(AppLocalizations l10n, String variant) => switch (variant) {
  'gold' => l10n.colourGold,
  'silver' => l10n.colourSilver,
  'red' => l10n.colourRed,
  'blue' => l10n.colourBlue,
  'green' => l10n.colourGreen,
  'yellow' => l10n.colourYellow,
  'brown' => l10n.colourBrown,
  _ => variant,
};

/// The wardrobe (spec 5.6 "Obchod a šatník"): the player's own upgrades by
/// slot, put on and off with a tap; a worn item's colour changes for free.
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = (ref.watch(playersProvider).value ?? const <PlayerProfile>[])
        .where((p) => p.id == playerId)
        .firstOrNull;
    final catalog = ref.watch(shopCatalogProvider);
    final owned = ref.watch(ownedItemsProvider(playerId)).value ?? const <String>{};
    if (player == null) return const Scaffold(body: FeltBackground(child: SizedBox.expand()));
    final avatar = player.avatar;

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back,
                      tooltip: l10n.back,
                      sound: UiSound.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.wardrobeTitle, style: AppTypography.h1(color: AppColors.paper))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(child: AnimatedAvatarView(key: const ValueKey('wardrobeAvatar'), spec: avatar, size: 120)),
              ),
              Expanded(
                child: owned.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              l10n.wardrobeEmpty,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(color: AppColors.paper),
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: l10n.wardrobeToShop,
                              icon: Icons.storefront,
                              onPressed: () => context.push('/players/$playerId/shop'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          for (final slot in AccessorySlot.values)
                            if (catalog.inSlot(slot).where((i) => owned.contains(i.id)).toList() case final items
                                when items.isNotEmpty)
                              _SlotSection(
                                slot: slot,
                                items: items,
                                avatar: avatar,
                                onTap: (item) => _guard(context, () => _toggle(ref, avatar, item)),
                                onColour: (item, variant) => _guard(context, () => _recolour(ref, item, variant)),
                              ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Runs a wardrobe change; if it fails (e.g. a parent reset meanwhile),
  /// says so instead of failing silently.
  Future<void> _guard(BuildContext context, Future<void> Function() change) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).shopFailed;
    try {
      await change();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(failed)));
    }
  }

  Future<void> _toggle(WidgetRef ref, AvatarSpec avatar, ShopItem item) async {
    final shop = ref.read(shopRepositoryProvider);
    ref.read(audioServiceProvider).playSfx('equip');
    avatar.equipped[item.slot]?.id == item.id
        ? await shop.unequip(playerId, item.slot)
        : await shop.equip(playerId, item.id);
  }

  Future<void> _recolour(WidgetRef ref, ShopItem item, String variant) =>
      ref.read(shopRepositoryProvider).equip(playerId, item.id, variant: variant);
}

class _SlotSection extends StatelessWidget {
  const _SlotSection({
    required this.slot,
    required this.items,
    required this.avatar,
    required this.onTap,
    required this.onColour,
  });

  final AccessorySlot slot;
  final List<ShopItem> items;
  final AvatarSpec avatar;
  final ValueChanged<ShopItem> onTap;
  final void Function(ShopItem item, String variant) onColour;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final worn = avatar.equipped[slot];
    final wornItem = items.where((i) => i.id == worn?.id).firstOrNull;
    final variants = wornItem?.colorVariants ?? const <String>[];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slotLabel(l10n, slot), style: AppTypography.h2(color: AppColors.paper)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in items)
                _OwnedCard(
                  key: ValueKey('own_${item.id}'),
                  item: item,
                  avatar: avatar,
                  worn: worn?.id == item.id,
                  onTap: () => onTap(item),
                ),
            ],
          ),
          if (wornItem != null && variants.isNotEmpty) ...[
            const SizedBox(height: 6),
            ColorSwatchPicker(
              colors: [for (final v in variants) Art.variant(v, AppColors.paper)],
              selected: variants.indexOf(worn?.variant ?? wornItem.defaultVariant ?? '').clamp(0, variants.length - 1),
              onSelected: (i) => onColour(wornItem, variants[i]),
              semanticLabels: [for (final v in variants) l10n.wardrobeColour(colourName(l10n, v))],
            ),
          ],
        ],
      ),
    );
  }
}

class _OwnedCard extends StatelessWidget {
  const _OwnedCard({super.key, required this.item, required this.avatar, required this.worn, required this.onTap});

  final ShopItem item;
  final AvatarSpec avatar;
  final bool worn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final variant = worn ? avatar.equipped[item.slot]?.variant : item.defaultVariant;
    return Semantics(
      button: true,
      selected: worn,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 104,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: PaperCard.radius,
              border: Border.all(color: worn ? AppColors.gold : rarityColor(item.rarity), width: worn ? 4 : 2.5),
            ),
            child: PaperCard(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AvatarView(spec: avatar.copyWith(equipped: {item.slot: EquippedItem(item.id, variant: variant)}), size: 58),
                  const SizedBox(height: 4),
                  Text(
                    itemName(l10n, item.id),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(color: AppColors.ink),
                  ),
                  if (worn)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.shopEquipped,
                        style: AppTypography.button(color: AppColors.gold).copyWith(fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
