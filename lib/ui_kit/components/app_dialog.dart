import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import 'primary_button.dart';

/// Paper confirmation dialog. Resolves to `true` only when confirmed; cancel
/// and tapping outside give `false`.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTypography.h2(color: AppColors.ink)),
            const SizedBox(height: 8),
            Text(message, style: AppTypography.body(color: AppColors.ink)),
            const SizedBox(height: 20),
            PrimaryButton(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: AppColors.ink),
              child: Text(cancelLabel, style: AppTypography.button(color: AppColors.ink)),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Paper dialog with one button, e.g. a new badge; [icon] sits on a gold
/// circle above the title.
Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String okLabel,
  IconData? icon,
}) => showDialog<void>(
  context: context,
  builder: (context) => Dialog(
    backgroundColor: AppColors.paper,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (icon != null) ...[
            Center(
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.gold,
                child: Icon(icon, color: AppColors.ink, size: 32),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(title, textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.ink)),
          const SizedBox(height: 20),
          PrimaryButton(label: okLabel, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    ),
  ),
);
