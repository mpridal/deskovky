import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';

import '../../games/registry.dart';
import '../../ui_kit/layout/window_size.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../update/update_card.dart';
import 'active_player_bar.dart';
import 'continue_bar.dart';
import 'game_card.dart';

/// Home screen (spec 5.1): active player, "Pokračovat" and the game grid –
/// registered games first, the rest of the grid "coming soon".
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _spacing = 14.0;

  /// Cards never get narrower than this; on narrow content areas (840 dp
  /// window with rail and right panel) the grid drops a column instead.
  static const _minCardWidth = 140.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bestStars = ref.watch(activeBestStarsProvider);
    final windowColumns = gameGridColumns(MediaQuery.sizeOf(context).width);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gridWidth = constraints.maxWidth - 32;
          final fittingColumns = ((gridWidth + _spacing) / (_minCardWidth + _spacing)).floor();
          final columns = fittingColumns.clamp(1, windowColumns);
          return _buildGrid(context, columns, bestStars);
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context, int columns, Map<String, int> bestStars) {
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverToBoxAdapter(child: ActivePlayerBar()),
        ),
        const SliverToBoxAdapter(child: UpdateCard()),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(child: ContinueBar()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          sliver: SliverGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: _spacing,
            crossAxisSpacing: _spacing,
            childAspectRatio: 0.95,
            children: [
              for (var i = 0; i < homeGridSlots; i++)
                GameCard(
                  key: ValueKey('gameCard$i'),
                  module: i < gameModules.length ? gameModules[i] : null,
                  tint: AppColors.players[i % AppColors.players.length],
                  bestStars: i < gameModules.length ? bestStars[gameModules[i].id] : null,
                  onTap: i < gameModules.length ? () => context.push('/play/${gameModules[i].id}/setup') : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
