import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/players/player_repository.dart';
import '../l10n/app_localizations.dart';
import '../ui_kit/avatar/avatar_view.dart';
import '../ui_kit/layout/window_size.dart';
import '../ui_kit/surfaces/felt_background.dart';
import '../ui_kit/tokens/app_colors.dart';
import '../ui_kit/tokens/app_typography.dart';
import 'providers.dart';

/// Frame around the four main tabs: bottom bar on phones, rail on tablets,
/// plus the right-hand panel on expanded widths (spec 3, 5.1).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  void _select(int index) => shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sizeClass = WindowSizeClass.fromWidth(MediaQuery.sizeOf(context).width);
    final items = [
      (Icons.casino_outlined, Icons.casino, l10n.navGames),
      (Icons.people_outline, Icons.people, l10n.navPlayers),
      (Icons.emoji_events_outlined, Icons.emoji_events, l10n.navLeaderboards),
      (Icons.settings_outlined, Icons.settings, l10n.navSettings),
    ];

    if (sizeClass == WindowSizeClass.compact) {
      return Scaffold(
        body: FeltBackground(child: shell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _select,
          destinations: [
            for (final (icon, selectedIcon, label) in items)
              NavigationDestination(icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: label),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            right: false,
            child: NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (icon, selectedIcon, label) in items)
                  NavigationRailDestination(icon: Icon(icon), selectedIcon: Icon(selectedIcon), label: Text(label)),
              ],
            ),
          ),
          Expanded(child: FeltBackground(child: shell)),
          if (sizeClass == WindowSizeClass.expanded) const _RightPanel(key: Key('rightPanel')),
        ],
      ),
    );
  }
}

class _RightPanel extends ConsumerWidget {
  const _RightPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider).value ?? const [];
    return Container(
      width: 320,
      color: AppColors.feltDark,
      child: SafeArea(
        left: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.panelPlayersOnDevice, style: AppTypography.h2(color: AppColors.paper)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in players)
                  SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        AvatarView(spec: p.avatar, size: 52),
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(color: AppColors.paper),
                        ),
                      ],
                    ),
                  ),
                if (players.length < PlayerRepository.maxProfiles)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      onTap: () => context.push('/players/new'),
                      child: SizedBox(
                        width: 64,
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.woodLight, width: 3),
                              ),
                              child: const Icon(Icons.add, color: AppColors.woodLight),
                            ),
                            Text(
                              l10n.playersNew,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption(color: AppColors.woodLight),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            for (final title in [l10n.panelLeaderboardWeek, l10n.panelLastReward]) ...[
              Text(title, style: AppTypography.h2(color: AppColors.paper)),
              const SizedBox(height: 4),
              Text(l10n.screenEmpty, style: AppTypography.caption(color: AppColors.woodLight)),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
