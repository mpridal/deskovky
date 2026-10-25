import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Placeholder body for screens that are not implemented yet.
class EmptyScreen extends StatelessWidget {
  const EmptyScreen({super.key, required this.title, this.children = const []});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(title, style: AppTypography.h1(color: AppColors.paper)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).screenEmpty, style: AppTypography.body(color: AppColors.woodLight)),
          ...children,
        ],
      ),
    );
  }
}
