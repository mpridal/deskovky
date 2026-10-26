import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'sample_ai.dart';
import 'sample_board.dart';
import 'sample_icon.dart';
import 'sample_rules.dart';
import 'sample_texts.dart';

/// Manifest of the sample game that proves the whole game API (spec 8, 12).
class SampleModule extends GameModule<SampleState> {
  const SampleModule();

  @override
  String get id => 'sample';
  @override
  String get titleKey => 'sample.title';
  @override
  String get descriptionKey => 'sample.description';
  @override
  String get rulesKey => 'sample.rules';
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'sample';
  @override
  bool get supportsSaveResume => true;

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'range',
      labelKey: 'sample.option.range',
      choices: [(20, '1–20'), (50, '1–50'), (100, '1–100')],
      defaultValue: SampleRules.defaultRange,
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'sample.bullseye',
      titleKey: 'sample.badge.bullseye.title',
      descriptionKey: 'sample.badge.bullseye.description',
      icon: Icons.gps_fixed,
      reward: 15,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('sample.bullseye')]),
    ),
  ];

  @override
  GameTexts get texts => sampleTexts;

  @override
  GameRules<SampleState> get rules => const SampleRules();

  @override
  AiPlayer<SampleState> get ai => const SampleAi();

  @override
  Widget icon(BuildContext context) => const SampleIcon();

  @override
  Widget board(BuildContext context, GameBoardView<SampleState> view) => SampleBoard(view: view);

  @override
  String? turnHint(BuildContext context, SampleState state, String playerName) =>
      sampleTexts.of(context, 'sample.turnHint', {'name': playerName, 'low': state.low, 'high': state.high});
}

const sampleModule = SampleModule();
