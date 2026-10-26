import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../games/game_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// A game's rules (spec 13.4): the short text and its 2–4 illustrated steps,
/// from the pause menu and from the setup screen.
Future<void> showRulesDialog(BuildContext context, GameModule<Object?> module) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) {
      final steps = module.ruleSteps(context);
      return Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.pauseRules, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(gameText(l10n, module.rulesKey), style: AppTypography.body(color: AppColors.ink)),
                      if (steps.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final (i, step) in steps.indexed)
                              SizedBox(key: ValueKey('ruleStep$i'), width: 150, child: step),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: l10n.close, onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      );
    },
  );
}
