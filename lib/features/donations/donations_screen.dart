import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/donations_providers.dart';
import '../../core/donations/donors.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// The amounts offered, in euros.
const donationAmounts = [2, 5, 10, 25];

/// Dary: why Deskovky deserve support, the (not yet working) buttons to give,
/// and the thanks to the donors – a list that fills the rest of the screen
/// and scrolls, newest first.
class DonationsScreen extends ConsumerWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final donors = ref.watch(donorsProvider).value ?? const <Donor>[];
    final points = [
      (Icons.money_off, l10n.donationsFreeTitle, l10n.donationsFreeText),
      (Icons.block, l10n.donationsNoAdsTitle, l10n.donationsNoAdsText),
      (Icons.lock_outline, l10n.donationsNoDataTitle, l10n.donationsNoDataText),
      (Icons.wifi_off, l10n.donationsOfflineTitle, l10n.donationsOfflineText),
      (Icons.family_restroom, l10n.donationsFamilyTitle, l10n.donationsFamilyText),
      (Icons.child_care, l10n.donationsKidsTitle, l10n.donationsKidsText),
      (Icons.accessibility_new, l10n.donationsEveryoneTitle, l10n.donationsEveryoneText),
      (Icons.extension, l10n.donationsGrowingTitle, l10n.donationsGrowingText),
    ];
    final top = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.donationsTitle, style: AppTypography.h1(color: AppColors.paper)),
        const SizedBox(height: 8),
        Text(l10n.donationsIntro, style: AppTypography.body(color: AppColors.paper)),
        const SizedBox(height: 12),
        PaperCard(
          child: Column(
            children: [
              for (final (icon, title, text) in points)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: AppColors.felt, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTypography.button(color: AppColors.ink)),
                            Text(text, style: AppTypography.caption(color: AppColors.wood)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.donationsWhy, style: AppTypography.body(color: AppColors.paper)),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final amount in donationAmounts)
              PrimaryButton(
                key: ValueKey('donate_$amount €'),
                label: '$amount €',
                icon: Icons.favorite,
                // Giving comes with Google Play Billing, behind the parents' check.
                onPressed: () => showAppToast(context, l10n.donationsSoon),
              ),
          ],
        ),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: LayoutBuilder(
          builder: (context, box) {
            final thanks = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.donationsThanks, style: AppTypography.h2(color: AppColors.paper)),
                const SizedBox(height: 6),
                Expanded(
                  child: PaperCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: donors.isEmpty
                        ? Center(
                            child: Text(
                              l10n.donationsNobody,
                              textAlign: TextAlign.center,
                              style: AppTypography.body(color: AppColors.wood),
                            ),
                          )
                        : ListView.separated(
                            key: const ValueKey('donorsList'),
                            itemCount: donors.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.paper2),
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.favorite, size: 18, color: AppColors.players[0]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      donors[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.body(color: AppColors.ink),
                                    ),
                                  ),
                                  Text(donors[i].amountText, style: AppTypography.button(color: AppColors.felt)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            );
            final story = SingleChildScrollView(key: const ValueKey('donationsStory'), child: top);
            // Wide and low (a phone on its side, a tablet lying): side by side.
            if (box.maxWidth > box.maxHeight * 1.3 && box.maxWidth >= 480) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: story),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: thanks),
                ],
              );
            }
            // Upright: the story and the buttons take at most ~60 %, the thanks the rest.
            final topMax = max(120.0, box.maxHeight * 0.6);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: topMax),
                  child: story,
                ),
                const SizedBox(height: 12),
                Expanded(child: thanks),
              ],
            );
          },
        ),
      ),
    );
  }
}
