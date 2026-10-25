import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/choice_pills.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(localeSettingProvider).value?.languageCode;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.navSettings, style: AppTypography.h1(color: AppColors.paper)),
          const SizedBox(height: 24),
          Text(l10n.settingsLanguage, style: AppTypography.h2(color: AppColors.paper)),
          const SizedBox(height: 8),
          ChoicePills<String?>(
            // Language names stay in their own language, so they are not in the ARB files.
            choices: [
              (null, l10n.settingsLanguageSystem),
              ('cs', 'Čeština'),
              ('en', 'English'),
              ('es', 'Español'),
            ],
            selected: chosen,
            onChanged: (code) => ref.read(settingsRepositoryProvider).setLocale(code == null ? null : Locale(code)),
          ),
          // Visual check of bundled fonts with diacritics (milestone 1).
          const SizedBox(height: 32),
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
      ),
    );
  }
}
