import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/multiplayer_providers.dart';
import '../../app/providers.dart';
import '../../core/game/game_config.dart';
import '../../core/multiplayer/network_rooms.dart';
import '../../app/stats_service.dart';
import '../../games/badge_texts.dart';
import '../../core/points/points_math.dart';
import '../../core/shop/newly_affordable.dart';
import '../../games/game_texts.dart';
import '../../games/item_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/player_slot.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../game_play/game_outcome.dart';
import 'confetti.dart';
import 'points_labels.dart';

/// Results of a game (spec 5.9, mockup "Výsledky"): winner, ranking with
/// scores and stars, play again / change settings / home. The points
/// breakdown joins in milestone 7.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.outcome});

  final GameOutcomeView outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = outcome.config;
    final result = outcome.result;
    final module = moduleById(config.gameId);
    final order = [for (var s = 0; s < outcome.seats.length; s++) s]
      ..sort((a, b) => result.places[a].compareTo(result.places[b]));
    final winners = order.where((s) => result.places[s] == 1).toList();
    final winner = outcome.seats[order.first];
    final draw = winners.length > 1;
    final gameName = module == null ? config.gameId : gameText(l10n, module.titleKey);
    final subtitle = config.robots > 0
        ? l10n.resultSubtitle(gameName, difficultyLabel(l10n, config.difficulty))
        : gameName;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (outcome.network) {
          // Leaving the results leaves the room too: no server or line stays open.
          final router = GoRouter.of(context);
          leaveNetworkRoom(ProviderScope.containerOf(context).read(networkRoomsProvider)).then((_) => router.go('/games'));
        } else {
          context.go('/games');
        }
      },
      child: Scaffold(
        body: FeltBackground(
          child: Stack(
            children: [
              _Jingle(outcome: outcome),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      draw ? l10n.resultDraw : l10n.resultWins(winner.name),
                      textAlign: TextAlign.center,
                      style: AppTypography.h1(color: AppColors.paper),
                    ),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(color: AppColors.woodLight),
                    ),
                    const SizedBox(height: 12),
                    Center(child: winner.avatar(120)),
                    const SizedBox(height: 16),
                    for (final seat in order)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PlayerSlot(
                          seat: seat,
                          avatar: outcome.seats[seat].avatar(36),
                          name: '${result.places[seat]}. ${outcome.seats[seat].name}',
                          tag: outcome.seats[seat].isRobot ? l10n.resultRobotTag : '${result.scores[seat]}',
                          detail: outcome.seats[seat].isRobot
                              ? null
                              : Text(
                                  '${'★' * result.stars[seat]}${'☆' * (3 - result.stars[seat])}',
                                  style: AppTypography.button(color: AppColors.gold).copyWith(fontSize: 14),
                                ),
                        ),
                      ),
                    if (outcome.rewards.points.isNotEmpty) _Points(outcome: outcome),
                    if (outcome.newBadges.isNotEmpty) _NewBadges(outcome: outcome),
                    const SizedBox(height: 16),
                    if (outcome.network)
                      _NetworkActions(gameId: config.gameId)
                    else ...[
                      PrimaryButton(
                        label: l10n.resultPlayAgain,
                        onPressed: () => context.pushReplacement('/play/${config.gameId}', extra: config),
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        label: l10n.resultChangeSettings,
                        secondary: true,
                        onPressed: () => context.pushReplacement('/play/${config.gameId}/setup', extra: config),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/games'),
                          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                          child: Text(l10n.resultHome, style: AppTypography.button(color: AppColors.paper)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!MediaQuery.disableAnimationsOf(context)) Positioned.fill(child: Confetti(color: winner.color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plays the results jingle once, with the music ducked (spec 7.1, 7.2):
/// a human's outright win gets `jingle_win`, a robot's win or a draw
/// `jingle_lose`.
class _Jingle extends ConsumerStatefulWidget {
  const _Jingle({required this.outcome});

  final GameOutcomeView outcome;

  @override
  ConsumerState<_Jingle> createState() => _JingleState();
}

class _JingleState extends ConsumerState<_Jingle> {
  Timer? _fanfare;

  @override
  void dispose() {
    _fanfare?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final places = widget.outcome.result.places;
    final winners = [
      for (var s = 0; s < places.length; s++)
        if (places[s] == 1) s,
    ];
    final humanWon = winners.length == 1 && widget.outcome.config.seats[winners.single] is HumanSeat;
    final audio = ref.read(audioServiceProvider);
    // Music dips only when the jingle is actually heard.
    if (audio.playSfx(humanWon ? 'jingle_win' : 'jingle_lose')) audio.duck(const Duration(seconds: 3));
    // One fanfare for all new badges, after the jingle (spec 5.5).
    if (widget.outcome.newBadges.isNotEmpty) {
      _fanfare = Timer(const Duration(milliseconds: 1200), () {
        if (audio.playSfx('achievement')) audio.duck(const Duration(seconds: 2));
      });
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// New badges slide up from below (spec 5.5); still with reduced motion.
class _NewBadges extends StatelessWidget {
  const _NewBadges({required this.outcome});

  final GameOutcomeView outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);
    String nameOf(EarnedBadge e) =>
        outcome.seats.where((s) => s.profile?.id == e.playerId).firstOrNull?.name ?? '';
    return Column(
      key: const ValueKey('newBadges'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(l10n.resultNewBadges, style: AppTypography.h2(color: AppColors.paper)),
        const SizedBox(height: 8),
        for (final (i, e) in outcome.newBadges.indexed)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: animate ? 1 : 0, end: 0),
            duration: Duration(milliseconds: 300 + 120 * i),
            curve: Curves.easeOutBack,
            builder: (context, t, child) =>
                Transform.translate(offset: Offset(0, 80 * t), child: Opacity(opacity: 1 - t.clamp(0, 1), child: child)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PaperCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.gold,
                      child: Icon(e.badge.icon, color: AppColors.ink),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(badgeText(l10n, e.badge.titleKey), style: AppTypography.button(color: AppColors.ink)),
                          Text(
                            '${nameOf(e)} · ${badgeText(l10n, e.badge.descriptionKey)}',
                            style: AppTypography.caption(color: AppColors.ink),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Points breakdown of every person (spec 5.6 "Výsledky partie"): lines appear
/// one by one, then the total and a new level.
class _Points extends StatelessWidget {
  const _Points({required this.outcome});

  final GameOutcomeView outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final animate = !MediaQuery.disableAnimationsOf(context);
    String nameOf(int playerId) {
      final seats = outcome.config.seats;
      for (var s = 0; s < seats.length; s++) {
        if (seats[s] case HumanSeat(:final profileId) when profileId == playerId) return outcome.seats[s].name;
      }
      return '';
    }

    String label(PointsLine line) =>
        pointsLabel(l10n, line.reason, detail: line.badgeId ?? line.count?.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(l10n.resultPoints, style: AppTypography.h2(color: AppColors.paper)),
        const SizedBox(height: 8),
        for (final MapEntry(key: playerId, value: points) in outcome.rewards.points.entries)
          Padding(
            key: ValueKey('points$playerId'),
            padding: const EdgeInsets.only(bottom: 8),
            child: PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(nameOf(playerId), style: AppTypography.button(color: AppColors.ink)),
                  for (final (i, line) in points.lines.indexed)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: animate ? 0 : 1, end: 1),
                      duration: Duration(milliseconds: animate ? 250 + 150 * i : 1),
                      builder: (context, t, child) => Opacity(opacity: t, child: child),
                      child: Row(
                        children: [
                          Expanded(child: Text(label(line), style: AppTypography.caption(color: AppColors.ink))),
                          Text('+${line.amount}', style: AppTypography.caption(color: AppColors.ink)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.pointsTotal(points.total),
                    textAlign: TextAlign.end,
                    style: AppTypography.button(color: AppColors.wood),
                  ),
                  if (points.levelAfter > points.levelBefore)
                    Text(
                      l10n.levelUp(points.levelAfter),
                      textAlign: TextAlign.end,
                      style: AppTypography.button(color: AppColors.gold),
                    ),
                  _CanBuy(playerId: playerId, name: nameOf(playerId), points: points),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// "Teď si můžeš koupit: …!" when the game made a tried item affordable
/// (spec 5.6).
class _CanBuy extends ConsumerWidget {
  const _CanBuy({required this.playerId, required this.name, required this.points});

  final int playerId;
  final String name;
  final PlayerPoints points;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final item = newlyAffordable(
      ref.watch(shopCatalogProvider),
      tried: ref.watch(triedItemsProvider(playerId)).value ?? const {},
      owned: ref.watch(ownedItemsProvider(playerId)).value ?? const {},
      balanceBefore: points.balanceBefore,
      balanceAfter: points.balanceBefore + points.total,
      levelBefore: points.levelBefore,
      levelAfter: points.levelAfter,
    );
    if (item == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        l10n.resultCanBuy(name, itemName(l10n, item.id)),
        textAlign: TextAlign.end,
        style: AppTypography.button(color: AppColors.gold),
      ),
    );
  }
}

/// Leaves the network room after a game: a client says goodbye, the host
/// ends the room for everyone, then every line and the server close.
Future<void> leaveNetworkRoom(NetworkRooms rooms) async {
  final client = rooms.client;
  if (client != null && client.closedReason == null) client.leave();
  rooms.host?.endGame();
  await rooms.leave();
}

/// After a network game (spec 14.2 step 8): the host offers a rematch in the
/// same room, the others wait for it; anyone can go home and leave the room.
class _NetworkActions extends ConsumerStatefulWidget {
  const _NetworkActions({required this.gameId});

  final String gameId;

  @override
  ConsumerState<_NetworkActions> createState() => _NetworkActionsState();
}

class _NetworkActionsState extends ConsumerState<_NetworkActions> {
  late final NetworkRooms _rooms;

  /// The game that just ended; any other session in the room is a rematch.
  Object? _finished;
  ChangeNotifier? _room;
  var _moved = false;

  @override
  void initState() {
    super.initState();
    _rooms = ref.read(networkRoomsProvider);
    _finished = _rooms.host?.session ?? _rooms.client?.session;
    _room = _rooms.host ?? _rooms.client;
    _room?.addListener(_onRoom);
  }

  @override
  void dispose() {
    _room?.removeListener(_onRoom);
    super.dispose();
  }

  void _onRoom() {
    final session = _rooms.host?.session ?? _rooms.client?.session;
    if (_moved || !mounted) return;
    if (session != null && !identical(session, _finished)) {
      _moved = true;
      context.pushReplacement('/play/${widget.gameId}/net');
      return;
    }
    setState(() {});
  }

  Future<void> _home() async {
    final router = GoRouter.of(context);
    await leaveNetworkRoom(_rooms);
    router.go('/games');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final host = _rooms.host;
    final client = _rooms.client;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (host != null)
          PrimaryButton(key: const ValueKey('netRematch'), label: l10n.netRematch, onPressed: host.rematch)
        else if (client != null && client.closedReason == null)
          Text(l10n.netWaitHost, textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.paper)),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            key: const ValueKey('netResultsHome'),
            onPressed: _home,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(l10n.resultHome, style: AppTypography.button(color: AppColors.paper)),
          ),
        ),
      ],
    );
  }
}
