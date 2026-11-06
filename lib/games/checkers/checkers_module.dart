import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'checkers_ai.dart';
import 'checkers_board.dart';
import 'checkers_events.dart';
import 'checkers_icon.dart';
import 'checkers_rule_steps.dart';
import 'checkers_rules.dart';
import 'checkers_texts.dart';

/// Manifest of Dáma (spec 13.9): two players, a person against a person or
/// a robot, Czech rules on 8×8 or international on 10×10.
class CheckersModule extends GameModule<CheckersState> {
  const CheckersModule();

  @override
  String get id => 'checkers';
  @override
  String get titleKey => 'checkers.title';
  @override
  String get descriptionKey => 'checkers.description';
  @override
  String get rulesKey => 'checkers.rules';
  @override
  GameTexts get texts => checkersTexts;

  /// "1–2 players (1 = against the robot)": always two seats, the setup
  /// screen makes the second one a robot.
  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'checkers';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => true;

  /// The hardest game of the app (spec 13.1).
  @override
  double get pointsMultiplier => 1.5;

  @override
  GameOrientation get phoneOrientation => GameOrientation.portrait;
  @override
  GameOrientation get tabletOrientation => GameOrientation.any;

  @override
  Map<String, String> get sfx => const {
    'checkers.capture': 'games/checkers/sfx/capture.ogg',
    'checkers.crown': 'games/checkers/sfx/crown.ogg',
  };

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'rules',
      labelKey: 'checkers.option.rules',
      choices: [('czech', 'checkers.option.rules.czech'), ('international', 'checkers.option.rules.international')],
      defaultValue: 'czech',
    ),
    ToggleOption(id: 'undo', labelKey: 'checkers.option.undo', defaultValue: true),
    ToggleOption(id: 'hint', labelKey: 'checkers.option.hint', defaultValue: true),
    ToggleOption(id: 'rotate', labelKey: 'checkers.option.rotate', defaultValue: false),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'checkers.queen',
      titleKey: 'checkers.badge.queen.title',
      descriptionKey: 'checkers.badge.queen.description',
      icon: Icons.workspace_premium,
      reward: 20,
      condition: BadgeCondition.event(CheckersEvents.queen),
    ),
    BadgeDef(
      id: 'checkers.combo',
      titleKey: 'checkers.badge.combo.title',
      descriptionKey: 'checkers.badge.combo.description',
      icon: Icons.auto_awesome,
      reward: 30,
      condition: BadgeCondition.event(CheckersEvents.combo),
    ),
    BadgeDef(
      id: 'checkers.grandmaster',
      titleKey: 'checkers.badge.grandmaster.title',
      descriptionKey: 'checkers.badge.grandmaster.description',
      icon: Icons.emoji_events,
      reward: 50,
      condition: BadgeCondition.wonAgainst(Difficulty.hard),
    ),
    BadgeDef(
      id: 'checkers.international',
      titleKey: 'checkers.badge.international.title',
      descriptionKey: 'checkers.badge.international.description',
      icon: Icons.public,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(CheckersEvents.international)]),
    ),
  ];

  @override
  GameRules<CheckersState> get rules => const CheckersRules();

  @override
  AiPlayer<CheckersState> get ai => const CheckersAi();

  @override
  Widget icon(BuildContext context) => const CheckersIcon();

  @override
  Widget board(BuildContext context, GameBoardView<CheckersState> view) => CheckersBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    for (final kind in CheckersRuleStepKind.values)
      CheckersRuleStep(kind: kind, text: checkersTexts.of(context, 'checkers.step${kind.index + 1}')),
  ];

  @override
  String? turnHint(BuildContext context, CheckersState state, String playerName) {
    final key = state.offerBy != null
        ? 'checkers.turnHint.offer'
        : CheckersRules.steps(state).firstOrNull?.captured.isNotEmpty ?? false
        ? 'checkers.turnHint.capture'
        : 'checkers.turnHint';
    return checkersTexts.of(context, key, {'name': playerName});
  }
}

const checkersModule = CheckersModule();
