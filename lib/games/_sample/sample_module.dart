import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../l10n/app_localizations.dart';
import 'sample_ai.dart';
import 'sample_board.dart';
import 'sample_icon.dart';
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
  String get musicTrack => 'sample';
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
  Widget icon(BuildContext context) => const SampleIcon();

  @override
  Widget board(BuildContext context, GameBoardView<SampleState> view) => SampleBoard(view: view);

  @override
  String? turnHint(BuildContext context, SampleState state, String playerName) =>
      AppLocalizations.of(context).sampleTurnHint(playerName, state.low, state.high);
}

const sampleModule = SampleModule();
