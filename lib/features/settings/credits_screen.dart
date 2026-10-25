import 'package:flutter/material.dart';

import '../../core/audio/credits.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

const _fonts = ['Baloo 2', 'Nunito'];
const _fontLicense = 'SIL Open Font License 1.1';

/// "Autoři a licence" (spec 5.10, 7.4): music and sounds from CREDITS.json,
/// the fonts, and Flutter's page with the library licences.
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  late final Future<List<Credit>> _credits = loadCredits(DefaultAssetBundle.of(context));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: FutureBuilder<List<Credit>>(
            future: _credits,
            builder: (context, snapshot) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    RoundIconButton(
                      icon: Icons.arrow_back,
                      tooltip: l10n.back,
                      sound: UiSound.back,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.settingsCredits, style: AppTypography.h1(color: AppColors.paper))),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.creditsSounds, style: AppTypography.h2(color: AppColors.paper)),
                const SizedBox(height: 8),
                for (final credit in snapshot.data ?? const <Credit>[])
                  _Entry(
                    title: credit.title,
                    lines: [credit.author, l10n.creditsLicense(credit.license), credit.attribution],
                  ),
                const SizedBox(height: 16),
                Text(l10n.creditsFonts, style: AppTypography.h2(color: AppColors.paper)),
                const SizedBox(height: 8),
                for (final font in _fonts) _Entry(title: font, lines: [l10n.creditsLicense(_fontLicense)]),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: PrimaryButton(
                    label: l10n.creditsLibraries,
                    secondary: true,
                    onPressed: () => showLicensePage(context: context, applicationName: l10n.appTitle),
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

class _Entry extends StatelessWidget {
  const _Entry({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PaperCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.button(color: AppColors.ink)),
            for (final line in lines) Text(line, style: AppTypography.caption(color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}
