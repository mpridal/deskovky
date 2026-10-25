import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/avatar/avatar_spec.dart';
import '../features/avatar_editor/avatar_editor_screen.dart';
import '../features/home/home_screen.dart';
import '../features/leaderboards/leaderboards_screen.dart';
import '../features/players/players_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/games',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/games', builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/players',
                builder: (_, _) => const PlayersScreen(),
                routes: [
                  // Full screen above the navigation, like the mockup.
                  GoRoute(
                    path: 'avatar',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) =>
                        AvatarEditorScreen(initial: state.extra as AvatarSpec? ?? AvatarSpec.defaults),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/leaderboards', builder: (_, _) => const LeaderboardsScreen())],
          ),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())]),
        ],
      ),
    ],
  );
}
