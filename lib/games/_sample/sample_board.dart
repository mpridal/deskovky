import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'sample_rules.dart';
import 'sample_texts.dart';

/// Board of "Guess the number": the range still possible, the last tip with
/// "Higher!"/"Lower!", and one paper tile per possible number (≥ 56 dp).
class SampleBoard extends StatelessWidget {
  const SampleBoard({super.key, required this.view});

  final GameBoardView<SampleState> view;

  @override
  Widget build(BuildContext context) {
    final s = view.state;
    final last = s.guesses.isEmpty ? null : s.guesses.last;
    final seat = view.mySeat;

    return Column(
      children: [
        Text('${s.low} – ${s.high}', style: AppTypography.h1(color: AppColors.paper).copyWith(fontSize: 40)),
        if (last != null && last.verdict != 0)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: AppColors.players[last.seat], borderRadius: BorderRadius.circular(999)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(last.verdict > 0 ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    '${last.value} → ${sampleTexts.of(context, last.verdict > 0 ? 'sample.higher' : 'sample.lower')}',
                    style: AppTypography.button(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        if (view.firstGame && view.canAct && s.guesses.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              sampleTexts.of(context, 'sample.firstHint'),
              style: AppTypography.button(color: AppColors.gold),
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: Opacity(
            opacity: view.canAct ? 1 : 0.55,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 72,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: s.high - s.low + 1,
              itemBuilder: (context, i) {
                final n = s.low + i;
                return Semantics(
                  key: ValueKey('number$n'),
                  button: true,
                  enabled: view.canAct,
                  label: '$n',
                  excludeSemantics: true,
                  onTap: view.canAct && seat != null ? () => _guess(seat, n) : null,
                  child: GestureDetector(
                    onTap: view.canAct && seat != null ? () => _guess(seat, n) : null,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: AppColors.paper2, offset: Offset(0, 4))],
                      ),
                      child: Text('$n', style: AppTypography.h2(color: AppColors.ink)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _guess(int seat, int n) {
    view.host.haptic();
    view.host.playSfx('piece_place');
    final s = view.state;
    if (n == s.secret && !s.guesses.any((g) => g.seat == seat)) {
      view.host.reportEvent('sample.bullseye', {'seat': seat});
    }
    view.submit(Move(seat: seat, type: 'guess', data: {'value': n}));
  }
}
