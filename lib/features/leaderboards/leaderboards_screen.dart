import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/game/difficulty.dart';
import '../../core/players/player_profile.dart';
import '../../core/stats/leaderboard.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/choice_pills.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/segmented_control.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Leaderboards (spec 5.4): by game, difficulty and period; people only.
class LeaderboardsScreen extends ConsumerStatefulWidget {
  const LeaderboardsScreen({super.key});

  @override
  ConsumerState<LeaderboardsScreen> createState() => _LeaderboardsScreenState();
}

class _LeaderboardsScreenState extends ConsumerState<LeaderboardsScreen> {
  var _query = const LeaderboardQuery();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final matches = ref.watch(allMatchesProvider).value ?? const [];
    final players = {for (final p in ref.watch(playersProvider).value ?? const <PlayerProfile>[]) p.id: p};
    final now = ref.watch(statsNowProvider).value ?? ref.read(statsRepositoryProvider).now();
    final rows = leaderboard(matches, _query, now: now, players: players.keys.toSet());
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.navLeaderboards, style: AppTypography.h1(color: AppColors.paper)),
          const SizedBox(height: 16),
          SegmentedControl<StatsPeriod>(
            segments: [
              (StatsPeriod.week, l10n.leaderboardWeek),
              (StatsPeriod.month, l10n.leaderboardMonth),
              (StatsPeriod.all, l10n.leaderboardAllTime),
            ],
            selected: _query.period,
            onChanged: (p) => setState(() => _query = _query.copyWith(period: p)),
          ),
          const SizedBox(height: 12),
          ChoicePills<String?>(
            choices: [
              (null, l10n.leaderboardAllGames),
              for (final m in gameModules) (m.id, gameText(l10n, m.titleKey)),
            ],
            selected: _query.gameId,
            onChanged: (id) => setState(() => _query = _query.copyWith(gameId: () => id)),
          ),
          const SizedBox(height: 8),
          ChoicePills<Difficulty?>(
            choices: [
              (null, l10n.leaderboardAnyDifficulty),
              for (final d in Difficulty.values) (d, difficultyLabel(l10n, d)),
            ],
            selected: _query.difficulty,
            onChanged: (d) => setState(() => _query = _query.copyWith(difficulty: () => d)),
          ),
          const SizedBox(height: 16),
          if (rows.isEmpty)
            Text(l10n.leaderboardEmpty, style: AppTypography.body(color: AppColors.paper))
          else
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Row(entry: row, player: players[row.playerId]!),
              ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.player});

  final LeaderboardEntry entry;
  final PlayerProfile player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PaperCard(
      key: const ValueKey('leaderboardRow'),
      onTap: () => context.push('/players/${player.id}/stats'),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text('${entry.rank}', style: AppTypography.h2(color: AppColors.ink))),
          AvatarView(spec: player.avatar, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button(color: AppColors.ink),
                ),
                Text(
                  l10n.leaderboardDetail(entry.played, (entry.winRate * 100).round()),
                  style: AppTypography.caption(color: AppColors.ink),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(l10n.leaderboardWins(entry.wins), style: AppTypography.button(color: AppColors.ink)),
        ],
      ),
    );
  }
}
