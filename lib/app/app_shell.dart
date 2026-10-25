import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../ui_kit/layout/window_size.dart';
import '../ui_kit/tokens/app_colors.dart';
import '../ui_kit/tokens/app_typography.dart';

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
        body: shell,
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
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selectedIcon),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          Expanded(child: shell),
          if (sizeClass == WindowSizeClass.expanded) const _RightPanel(key: Key('rightPanel')),
        ],
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 320,
      color: AppColors.feltDark,
      child: SafeArea(
        left: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final title in [l10n.panelPlayersOnDevice, l10n.panelLeaderboardWeek, l10n.panelLastReward]) ...[
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
