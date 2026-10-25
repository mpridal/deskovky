import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/layout/empty_screen.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyScreen(
      title: l10n.navSettings,
      children: [
        // Visual check of bundled fonts with diacritics (milestone 1).
        const SizedBox(height: 24),
        Text(l10n.fontSample, style: AppTypography.h2(color: AppColors.paper)),
        const SizedBox(height: 8),
        Text(l10n.fontSample, style: AppTypography.body(color: AppColors.paper)),
        if (kDebugMode) ...[
          const SizedBox(height: 24),
          // Developer tool, debug builds only – not localized on purpose.
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(label: 'UI kit', onPressed: () => context.push('/settings/ui-kit')),
          ),
        ],
      ],
    );
  }
}
