import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/stats_service.dart';
import '../../core/avatar/avatar_spec.dart';
import '../../core/players/player_profile.dart';
import '../../core/points/levels.dart';
import '../../core/shop/shop_catalog.dart';
import '../../core/shop/shop_repository.dart';
import '../../games/badge_texts.dart';
import '../../games/item_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/choice_pills.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Label colour of each rarity (spec 5.6 "Katalog").
Color rarityColor(Rarity rarity) => switch (rarity) {
  Rarity.common => const Color(0xFFB8A58F),
  Rarity.rare => AppColors.players[1],
  Rarity.epic => const Color(0xFF8E5BC8),
  Rarity.legendary => AppColors.gold,
  Rarity.badge => AppColors.players[3],
};

String slotLabel(AppLocalizations l10n, AccessorySlot slot) => switch (slot) {
  AccessorySlot.head => l10n.slotHead,
  AccessorySlot.face => l10n.slotFace,
  AccessorySlot.hand => l10n.slotHand,
  AccessorySlot.pet => l10n.slotPet,
  AccessorySlot.frame => l10n.slotFrame,
  AccessorySlot.effect => l10n.slotEffect,
};

/// The shop (spec 5.6 "Obchod a šatník"): a try-on booth with the player's
/// avatar, items by slot, buying for points and wearing at once.
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key, required this.playerId});

  final int playerId;

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  AccessorySlot? _tab;
  ShopItem? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final player = (ref.watch(playersProvider).value ?? const <PlayerProfile>[])
        .where((p) => p.id == widget.playerId)
        .firstOrNull;
    final catalog = ref.watch(shopCatalogProvider);
    final owned = ref.watch(ownedItemsProvider(widget.playerId)).value ?? const <String>{};
    final points = ref.watch(pointsSummaryProvider)[widget.playerId] ?? (balance: 0, earned: 0);
    final progress = levelProgress(points.earned);
    if (player == null) return const Scaffold(body: FeltBackground(child: SizedBox.expand()));
    final selected = _selected;
    final booth = selected == null
        ? player.avatar
        : player.avatar.copyWith(
            equipped: {
              ...player.avatar.equipped,
              selected.slot: EquippedItem(selected.id, variant: selected.defaultVariant),
            },
          );
    final items = _tab == null ? catalog.items : catalog.inSlot(_tab!);

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
                    Expanded(child: Text(l10n.shopTitle, style: AppTypography.h1(color: AppColors.paper))),
                    Text('● ${points.balance}', style: AppTypography.h2(color: AppColors.gold)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    AnimatedAvatarView(key: const ValueKey('tryOn'), spec: booth, size: 104),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selected != null)
                            Text(
                              l10n.shopTryOn(itemName(l10n, selected.id)),
                              style: AppTypography.button(color: AppColors.paper),
                            ),
                          Text(
                            l10n.shopPlayerLevel(player.name, progress.level),
                            style: AppTypography.caption(color: AppColors.woodLight),
                          ),
                          if (progress.needed > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.shopNextLevel(progress.level, progress.level + 1, progress.needed - progress.current),
                              style: AppTypography.caption(color: AppColors.woodLight),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress.current / progress.needed,
                                minHeight: 8,
                                color: AppColors.gold,
                                backgroundColor: const Color(0x40000000),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: ChoicePills<AccessorySlot?>(
                  choices: [
                    (null, l10n.shopAll),
                    for (final s in AccessorySlot.values) (s, slotLabel(l10n, s)),
                  ],
                  selected: _tab,
                  onChanged: (s) => setState(() => _tab = s),
                ),
              ),
              Expanded(
                child: GridView.extent(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  maxCrossAxisExtent: 128,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.72,
                  children: [
                    for (final item in items)
                      _ItemCard(
                        key: ValueKey('item_${item.id}'),
                        item: item,
                        avatar: player.avatar,
                        status: _status(l10n, item, owned, player.avatar, progress.level),
                        selected: item.id == selected?.id,
                        onTap: () => setState(() => _selected = item),
                      ),
                  ],
                ),
              ),
              if (selected != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                  child: _action(l10n, selected, owned, player, points.balance, progress.level),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// "Máš", "Nasazeno", a lock, or null for the price.
  String? _status(AppLocalizations l10n, ShopItem item, Set<String> owned, AvatarSpec avatar, int level) {
    if (avatar.equipped[item.slot]?.id == item.id) return l10n.shopEquipped;
    if (owned.contains(item.id)) return l10n.shopOwned;
    if (item.badgeId case final badge?) return l10n.shopBadgeLock(_badgeTitle(l10n, badge));
    if (level < item.minLevel) return l10n.shopLevelLock(item.minLevel);
    return null;
  }

  String _badgeTitle(AppLocalizations l10n, String id) {
    final badge = badgeById(id);
    return badge == null ? id : badgeText(l10n, badge.titleKey);
  }

  Widget _action(AppLocalizations l10n, ShopItem item, Set<String> owned, PlayerProfile player, int balance, int level) {
    final shop = ref.read(shopRepositoryProvider);
    if (owned.contains(item.id)) {
      final wearing = player.avatar.equipped[item.slot]?.id == item.id;
      return PrimaryButton(
        label: wearing ? l10n.shopUnequip : l10n.shopEquip,
        onPressed: () async {
          ref.read(audioServiceProvider).playSfx('equip');
          wearing ? await shop.unequip(player.id, item.slot) : await shop.equip(player.id, item.id);
        },
      );
    }
    final price = item.price;
    if (item.badgeId case final badge?) {
      return PrimaryButton(label: l10n.shopBadgeLock(_badgeTitle(l10n, badge)), onPressed: null);
    }
    if (level < item.minLevel || price == null) {
      return PrimaryButton(label: l10n.shopLevelLock(item.minLevel), onPressed: null);
    }
    if (balance < price) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: balance / price,
              minHeight: 6,
              color: AppColors.gold,
              backgroundColor: const Color(0x40000000),
            ),
          ),
          const SizedBox(height: 6),
          PrimaryButton(label: l10n.shopMissing(price - balance), onPressed: null),
        ],
      );
    }
    return PrimaryButton(label: l10n.shopBuy(price), onPressed: () => _buy(l10n, item, price, player.id));
  }

  Future<void> _buy(AppLocalizations l10n, ShopItem item, int price, int playerId) async {
    final shop = ref.read(shopRepositoryProvider);
    final audio = ref.read(audioServiceProvider);
    final name = itemName(l10n, item.id);
    final ok = await showAppConfirmDialog(
      context,
      title: l10n.shopTitle,
      message: l10n.shopBuyConfirm(name, price),
      confirmLabel: l10n.shopBuyAction,
      cancelLabel: l10n.cancel,
    );
    if (!ok) return;
    final result = await shop.buy(playerId, item.id);
    if (result.outcome != BuyOutcome.bought) return;
    audio.playSfx('purchase');
    if (!mounted) return;
    final wear = await showAppConfirmDialog(
      context,
      title: name,
      message: l10n.shopEquipNow,
      confirmLabel: l10n.shopEquip,
      cancelLabel: l10n.shopNotNow,
    );
    if (!wear) return;
    audio.playSfx('equip');
    await shop.equip(playerId, item.id);
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    super.key,
    required this.item,
    required this.avatar,
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final ShopItem item;
  final AvatarSpec avatar;
  final String? status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colour = rarityColor(item.rarity);
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: PaperCard.radius,
            border: Border.all(color: selected ? AppColors.gold : colour, width: selected ? 4 : 2.5),
          ),
          child: PaperCard(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                AvatarView(
                  spec: avatar.copyWith(equipped: {item.slot: EquippedItem(item.id, variant: item.defaultVariant)}),
                  size: 58,
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    itemName(l10n, item.id),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption(color: AppColors.ink),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    status ?? '● ${item.price}',
                    style: AppTypography.button(color: status == null ? AppColors.wood : colour).copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
