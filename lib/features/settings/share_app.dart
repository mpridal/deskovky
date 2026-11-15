import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// The page of the newest release on GitHub; its APK is always attached.
const appDownloadUrl = 'https://github.com/mpridal/deskovky/releases/latest';

/// "Stáhnout do jiného zařízení": a QR code another device scans with its
/// camera to reach the newest APK.
Future<void> showShareApp(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.shareAppTitle, textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
            const SizedBox(height: 12),
            QrImageView(
              key: const ValueKey('shareAppQr'),
              data: appDownloadUrl,
              size: 220,
              backgroundColor: AppColors.paper,
              semanticsLabel: l10n.shareAppTitle,
            ),
            const SizedBox(height: 8),
            SelectableText(
              appDownloadUrl.replaceFirst('https://', ''),
              textAlign: TextAlign.center,
              style: AppTypography.caption(color: AppColors.wood),
            ),
            const SizedBox(height: 12),
            Text(l10n.shareAppHint, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.ink)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.close)),
          ],
        ),
      ),
    );
  },
);
