import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/tag_pill.dart';
import '../../ui_kit/layout/window_size.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Home screen (spec 5.1). For now a grid of placeholder cards; the game
/// registry fills it in milestone 4.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _placeholderCount = 6;
  static const _spacing = 14.0;

  /// Cards never get narrower than this; on narrow content areas (840 dp
  /// window with rail and right panel) the grid drops a column instead.
  static const _minCardWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final windowColumns = gameGridColumns(MediaQuery.sizeOf(context).width);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridWidth = constraints.maxWidth - 32;
          final fittingColumns = ((gridWidth + _spacing) / (_minCardWidth + _spacing)).floor();
          final columns = fittingColumns.clamp(1, windowColumns);
          return _buildGrid(l10n, columns);
        },
      ),
    );
  }

  Widget _buildGrid(AppLocalizations l10n, int columns) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(l10n.appTitle, style: AppTypography.h1(color: AppColors.paper)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
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
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({super.key, required this.tint, required this.label});

  final Color tint;
  final String label;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
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
          // The badge may use the whole card width; TagPill scales down
          // rather than being clipped on narrow cards or large text.
          Positioned(
            top: 6,
            left: 6,
            right: 6,
            child: Align(alignment: Alignment.topRight, child: TagPill(label: label)),
          ),
        ],
      ),
    );
  }
}
