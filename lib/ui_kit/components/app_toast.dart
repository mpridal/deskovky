import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Short floating message on walnut, 2.5 s.
void showAppToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: AppTypography.button(color: AppColors.paper)),
      backgroundColor: AppColors.walnut,
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
      duration: const Duration(milliseconds: 2500),
    ));
}
