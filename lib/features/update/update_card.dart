import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/update_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Gentle "new version" card on the home screen (spec 4.5): Aktualizovat /
/// Později, download progress, and no "Později" for a mandatory update.
class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateControllerProvider);
    final release = state.release;
    if (!state.offered || release == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final notes = release.notesFor(Localizations.localeOf(context).languageCode);
    final progress = state.progress;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: PaperCard(
        key: const ValueKey('updateCard'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.system_update, color: AppColors.wood),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.updateAvailable('${release.version}'),
                    style: AppTypography.button(color: AppColors.ink),
                  ),
                ),
              ],
            ),
            if (state.mandatory) Text(l10n.updateMandatory, style: AppTypography.caption(color: AppColors.ink)),
            if (notes.isNotEmpty) Text(notes, style: AppTypography.caption(color: AppColors.ink)),
            if (state.failed) Text(l10n.updateFailed, style: AppTypography.caption(color: AppColors.players[0])),
            const SizedBox(height: 8),
            if (progress != null) ...[
              LinearProgressIndicator(value: progress, color: AppColors.gold, backgroundColor: AppColors.paper2),
              const SizedBox(height: 4),
              Text(
                l10n.updateDownloading((progress * 100).round()),
                style: AppTypography.caption(color: AppColors.ink),
              ),
            ] else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  PrimaryButton(label: l10n.updateNow, onPressed: () => _update(context, ref)),
                  if (!state.mandatory)
                    TextButton(
                      onPressed: () => ref.read(updateControllerProvider.notifier).dismiss(),
                      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                      child: Text(l10n.updateLater, style: AppTypography.button(color: AppColors.ink)),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, WidgetRef ref) async {
    final allowed = await ref.read(updateControllerProvider.notifier).update();
    if (allowed || !context.mounted) return;
    await _explainPermission(context, ref);
  }

  /// Android asks the parent to allow "install unknown apps" once (spec 4.6).
  static Future<void> _explainPermission(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.updatePermissionTitle, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(l10n.updatePermissionText, style: AppTypography.body(color: AppColors.ink)),
              const SizedBox(height: 16),
              PrimaryButton(
                label: l10n.updatePermissionOpen,
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  ref.read(apkInstallerProvider).openInstallSettings();
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text(l10n.cancel, style: AppTypography.button(color: AppColors.ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
