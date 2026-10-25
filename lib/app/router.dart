import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/leaderboards/leaderboards_screen.dart';
import '../features/players/players_screen.dart';
import '../features/players/profile_editor_route.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/ui_kit_catalog_screen.dart';
import 'app_shell.dart';

GoRouter buildRouter() {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/games',
    routes: [
      // Games run full screen above the navigation. Placeholders until the
      // setup and game screens exist (milestone 4, tasks 5–6).
      GoRoute(
        path: '/play/:gameId/setup',
        builder: (_, state) => _PlayStub(label: 'setup ${state.pathParameters['gameId']}'),
      ),
      GoRoute(
        path: '/play/:gameId',
        builder: (_, state) => _PlayStub(label: 'play ${state.pathParameters['gameId']}'),
      ),
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
                    path: 'new',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ProfileEditorRoute(),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    parentNavigatorKey: rootKey,
                    builder: (_, state) => ProfileEditorRoute(playerId: int.tryParse(state.pathParameters['id'] ?? '')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/leaderboards', builder: (_, _) => const LeaderboardsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  if (kDebugMode)
                    GoRoute(
                      path: 'ui-kit',
                      parentNavigatorKey: rootKey,
                      builder: (_, _) => const UiKitCatalogScreen(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _PlayStub extends StatelessWidget {
  const _PlayStub({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text(label)));
}
