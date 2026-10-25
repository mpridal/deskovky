import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/layout/window_size.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Home screen (spec 5.1). For now a grid of placeholder cards; the game
/// registry fills it in milestone 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _placeholderCount = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final columns = gameGridColumns(MediaQuery.sizeOf(context).width);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(child: Text(l10n.appTitle, style: AppTypography.h1(color: AppColors.paper))),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverGrid.count(
              crossAxisCount: columns,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                for (var i = 0; i < _placeholderCount; i++)
                  _PlaceholderCard(
                    key: ValueKey('gamePlaceholder$i'),
                    tint: AppColors.players[i % AppColors.players.length],
                    label: l10n.comingSoon,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({super.key, required this.tint, required this.label});

  final Color tint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.paper2, offset: Offset(0, 5)),
          BoxShadow(color: Color(0x59000000), offset: Offset(0, 8), blurRadius: 16),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(tint.withValues(alpha: 0.25), AppColors.paper),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.walnut, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  label,
                  style: AppTypography.caption(color: AppColors.paper).copyWith(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
