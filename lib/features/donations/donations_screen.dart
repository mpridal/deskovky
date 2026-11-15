import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// The amounts offered, in euros.
const donationAmounts = [2, 5, 10, 25];

/// Dary: why Deskovky deserve support and the (not yet working) buttons to
/// give. No list of donors: showing names would need their consent.
class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      child: SingleChildScrollView(
        key: const ValueKey('donationsStory'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Center(
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: top),
        ),
      ),
    );
  }
}
