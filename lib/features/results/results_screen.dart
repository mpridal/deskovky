import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/game/game_config.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/player_slot.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../game_play/game_outcome.dart';
import 'confetti.dart';

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
        if (!didPop) context.go('/games');
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
                    const SizedBox(height: 16),
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
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
