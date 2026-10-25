import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/leaderboards/leaderboards_screen.dart';
import '../features/players/players_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/games',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/games', builder: (_, _) => const HomeScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/players', builder: (_, _) => const PlayersScreen())]),
            StatefulShellBranch(
              routes: [GoRoute(path: '/leaderboards', builder: (_, _) => const LeaderboardsScreen())],
            ),
            StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())]),
          ],
        ),
      ],
    );
