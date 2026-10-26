import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'tictactoe_ai.dart';
import 'tictactoe_board.dart';
import 'tictactoe_icon.dart';
import 'tictactoe_rule_step.dart';
import 'tictactoe_rules.dart';
import 'tictactoe_texts.dart';

/// Manifest of Piškvorky (spec 13.5): two players, a person against a
/// person or a robot, on 3×3, 10×10 or 15×15.
class TictactoeModule extends GameModule<TictactoeState> {
  const TictactoeModule();

  @override
  String get id => 'tictactoe';
  @override
  String get titleKey => 'tictactoe.title';
  @override
  String get descriptionKey => 'tictactoe.description';
  @override
  String get rulesKey => 'tictactoe.rules';
  @override
  GameTexts get texts => tictactoeTexts;

  /// "1–2 players (1 = against the robot)": always two seats, the setup
  /// screen makes the second one a robot.
  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'tictactoe';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => true;

  @override
  Map<String, String> get sfx => const {
    'tictactoe.draw': 'games/tictactoe/sfx/draw.ogg',
    'tictactoe.line': 'games/tictactoe/sfx/line.ogg',
  };

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'board',
      labelKey: 'tictactoe.option.board',
      choices: [(3, '3×3'), (10, '10×10'), (15, '15×15')],
      defaultValue: TictactoeRules.defaultSize,
    ),
    ChoiceOption(
      id: 'start',
      labelKey: 'tictactoe.option.start',
      choices: [
        (TictactoeStart.alternate, 'tictactoe.option.start.alternate'),
        (TictactoeStart.random, 'tictactoe.option.start.random'),
        (TictactoeStart.first, 'tictactoe.option.start.first'),
      ],
      defaultValue: TictactoeStart.alternate,
    ),
    ToggleOption(id: 'confirm', labelKey: 'tictactoe.option.confirm', defaultValue: false),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'tictactoe.wall',
      titleKey: 'tictactoe.badge.wall.title',
      descriptionKey: 'tictactoe.badge.wall.description',
      icon: Icons.shield,
      reward: 40,
      condition: BadgeCondition.counter('tictactoe.wall', 10),
    ),
    BadgeDef(
      id: 'tictactoe.five',
      titleKey: 'tictactoe.badge.five.title',
      descriptionKey: 'tictactoe.badge.five.description',
      icon: Icons.looks_5,
      reward: 20,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('tictactoe.win15')]),
    ),
    BadgeDef(
      id: 'tictactoe.blitz',
      titleKey: 'tictactoe.badge.blitz.title',
      descriptionKey: 'tictactoe.badge.blitz.description',
      icon: Icons.bolt,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('tictactoe.blitz')]),
    ),
    BadgeDef(
      id: 'tictactoe.master',
      titleKey: 'tictactoe.badge.master.title',
      descriptionKey: 'tictactoe.badge.master.description',
      icon: Icons.emoji_events,
      reward: 50,
      condition: BadgeCondition.all([
        BadgeCondition.wonAgainst(Difficulty.hard),
        BadgeCondition.event('tictactoe.win15'),
      ]),
    ),
  ];

  @override
  GameRules<TictactoeState> get rules => const TictactoeRules();

  @override
  AiPlayer<TictactoeState> get ai => const TictactoeAi();

  @override
  Widget icon(BuildContext context) => const TictactoeIcon();

  @override
  Widget board(BuildContext context, GameBoardView<TictactoeState> view) => TictactoeBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    for (final step in TictactoeRuleStepKind.values)
      TictactoeRuleStep(kind: step, text: tictactoeTexts.of(context, 'tictactoe.step${step.index + 1}')),
  ];

  @override
  String? turnHint(BuildContext context, TictactoeState state, String playerName) =>
      tictactoeTexts.of(context, 'tictactoe.turnHint', {'name': playerName, 'mark': state.current == 0 ? '✕' : '◯'});
}

const tictactoeModule = TictactoeModule();
