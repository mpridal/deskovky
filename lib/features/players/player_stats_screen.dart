import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/badges/badge.dart';
import '../../core/players/player_profile.dart';
import '../../core/points/levels.dart';
import '../../core/points/points_repository.dart';
import '../../core/stats/player_stats.dart';
import '../../games/badge_texts.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../results/points_labels.dart';

String _time(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

/// A player's statistics, records per game and badges (spec 5.4, 5.5).
class PlayerStatsScreen extends ConsumerWidget {
  const PlayerStatsScreen({super.key, required this.playerId});

  final int playerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final player = (ref.watch(playersProvider).value ?? const <PlayerProfile>[])
        .where((p) => p.id == playerId)
        .firstOrNull;
    final stats = computePlayerStats(playerId, ref.watch(allMatchesProvider).value ?? const []);
    final earned = ref.watch(earnedBadgesProvider(playerId)).value ?? const {};
    final badges = ref.read(statsServiceProvider).allBadges;
    final points = ref.watch(pointsSummaryProvider)[playerId] ?? (balance: 0, earned: 0);
    final progress = levelProgress(points.earned);
    final history = [
      for (final e in (ref.watch(pointsLedgerProvider).value ?? const <PointsEntry>[]).reversed)
        if (e.playerId == playerId) e,
    ].take(30).toList();
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: l10n.back,
                    sound: UiSound.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  if (player != null) AvatarView(spec: player.avatar, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.playerStats(player?.name ?? ''),
                      style: AppTypography.h2(color: AppColors.paper),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.levelLabel(progress.level), style: AppTypography.h2(color: AppColors.ink)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress.needed == 0 ? 1 : progress.current / progress.needed,
                        minHeight: 10,
                        color: AppColors.gold,
                        backgroundColor: AppColors.paper2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progress.needed == 0 ? l10n.levelMax : l10n.levelNext(progress.current, progress.needed),
                      style: AppTypography.caption(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _Tiles(
                tiles: [
                  ('statBalance', l10n.statsBalance, '${points.balance}'),
                  ('statTotalEarned', l10n.statsTotalEarned, '${points.earned}'),
                ],
              ),
              const SizedBox(height: 16),
              if (stats.played == 0)
                Text(l10n.statsNoGames, style: AppTypography.body(color: AppColors.paper))
              else ...[
                _Tiles(
                  tiles: [
                    ('statPlayed', l10n.statsPlayed, '${stats.played}'),
                    ('statWins', l10n.statsWins, '${stats.wins}'),
                    ('statWinRate', l10n.statsWinRate, '${(stats.winRate * 100).round()} %'),
                    ('statBestStreak', l10n.statsBestStreak, '${stats.bestStreak}'),
                    ('statCurrentStreak', l10n.statsCurrentStreak, '${stats.currentStreak}'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.statsByGame, style: AppTypography.h2(color: AppColors.paper)),
                const SizedBox(height: 8),
                for (final MapEntry(key: gameId, value: best) in stats.byGame.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PaperCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_gameTitle(l10n, gameId)}  ${'★' * best.bestStars}${'☆' * (3 - best.bestStars)}',
                            style: AppTypography.button(color: AppColors.ink),
                          ),
                          Text(l10n.statsBestScore(best.bestScore), style: AppTypography.caption(color: AppColors.ink)),
                          if (best.fastestWin != null)
                            Text(
                              l10n.statsFastestWin(_time(best.fastestWin!)),
                              style: AppTypography.caption(color: AppColors.ink),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 16),
              Text(l10n.statsBadges, style: AppTypography.h2(color: AppColors.paper)),
              const SizedBox(height: 8),
              for (final badge in badges) _BadgeTile(badge: badge, earnedAt: earned[badge.id]),
              if (history.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(l10n.statsPointsHistory, style: AppTypography.h2(color: AppColors.paper)),
                const SizedBox(height: 8),
                PaperCard(
                  child: Column(
                    children: [
                      for (final e in history)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pointsLabel(l10n, e.reason, detail: e.detail),
                                  style: AppTypography.caption(color: AppColors.ink),
                                ),
                              ),
                              Text(
                                e.amount >= 0 ? '+${e.amount}' : '−${-e.amount}',
                                style: AppTypography.caption(color: e.amount >= 0 ? AppColors.ink : AppColors.wood),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _gameTitle(AppLocalizations l10n, String gameId) {
    final module = moduleById(gameId);
    return module == null ? gameId : gameText(l10n, module.titleKey);
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles({required this.tiles});

  final List<(String key, String label, String value)> tiles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (key, label, value) in tiles)
              SizedBox(
                key: ValueKey(key),
                width: width,
                child: PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(value, style: AppTypography.h1(color: AppColors.ink)),
                      Text(label, style: AppTypography.caption(color: AppColors.ink)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Earned badges in gold with the date; the others grey with how to get them.
class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earnedAt});

  final BadgeDef badge;
  final DateTime? earnedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final earned = earnedAt != null;
    return Padding(
      key: ValueKey('badge_${badge.id}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: earned ? 1 : 0.6,
        child: PaperCard(
          child: Row(
            children: [
              CircleAvatar(
                key: earned ? ValueKey('badge_${badge.id}_earned') : null,
                radius: 22,
                backgroundColor: earned ? AppColors.gold : AppColors.paper2,
                child: Icon(earned ? badge.icon : Icons.lock_outline, color: AppColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(badgeText(l10n, badge.titleKey), style: AppTypography.button(color: AppColors.ink)),
                    Text(
                      earned
                          ? l10n.statsBadgeEarned(MaterialLocalizations.of(context).formatShortDate(earnedAt!))
                          : badgeText(l10n, badge.descriptionKey),
                      style: AppTypography.caption(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
