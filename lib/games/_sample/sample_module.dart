import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/move.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'sample_ai.dart';
import 'sample_rules.dart';

/// Manifest of the sample game that proves the whole game API (spec 8, 12).
class SampleModule extends GameModule<SampleState> {
  const SampleModule();

  @override
  String get id => 'sample';
  @override
  String get titleKey => 'sampleTitle';
  @override
  String get descriptionKey => 'sampleDescription';
  @override
  String get rulesKey => 'sampleRules';
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'music/sample.ogg';
  @override
  bool get supportsSaveResume => true;

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'range',
      labelKey: 'sampleOptionRange',
      choices: [(20, '1–20'), (50, '1–50'), (100, '1–100')],
      defaultValue: SampleRules.defaultRange,
    ),
  ];

  @override
  GameRules<SampleState> get rules => const SampleRules();

  @override
  AiPlayer<SampleState> get ai => const SampleAi();

  @override
  Widget icon(BuildContext context) =>
      Center(child: Text('?', style: AppTypography.h1(color: AppColors.ink).copyWith(fontSize: 48)));

  @override
  Widget board(BuildContext context, GameBoardView<SampleState> view) {
    final s = view.state;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var n = s.low; n <= s.high; n++)
          OutlinedButton(
            onPressed: view.canAct && view.mySeat != null
                ? () => view.submit(Move(seat: view.mySeat!, type: 'guess', data: {'value': n}))
                : null,
            child: Text('$n'),
          ),
      ],
    );
  }
}

const sampleModule = SampleModule();
