import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'minesweeper_ai.dart';
import 'minesweeper_board.dart';
import 'minesweeper_icon.dart';
import 'minesweeper_rule_step.dart';
import 'minesweeper_rules.dart';
import 'minesweeper_state.dart';
import 'minesweeper_texts.dart';

/// Manifest of Miny (spec 13.7): the classic game for one player,
/// "Střídačka" for 2–4; difficulty = board size, also without robots.
class MinesweeperModule extends GameModule<MinesweeperState> {
  const MinesweeperModule();

  @override
  String get id => 'minesweeper';
  @override
  String get titleKey => 'minesweeper.title';
  @override
  String get descriptionKey => 'minesweeper.description';
  @override
  String get rulesKey => 'minesweeper.rules';
  @override
  GameTexts get texts => minesweeperTexts;
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'minesweeper';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => true;
  @override
  bool get difficultyWithoutRobots => true;

  @override
  Map<String, String> get sfx => const {
    'minesweeper.dig': 'games/minesweeper/sfx/dig.ogg',
    'minesweeper.flag': 'games/minesweeper/sfx/flag.ogg',
    'minesweeper.puff': 'games/minesweeper/sfx/puff.ogg',
  };

  @override
  List<GameOption> get options => const [
    ToggleOption(id: 'questionMarks', labelKey: 'minesweeper.option.questionMarks', defaultValue: false),
    ChoiceOption(
      id: 'controls',
      labelKey: 'minesweeper.option.controls',
      choices: [
        ('longPress', 'minesweeper.option.controls.longPress'),
        ('switch', 'minesweeper.option.controls.switch'),
      ],
      defaultValue: 'longPress',
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'minesweeper.defuser',
      titleKey: 'minesweeper.badge.defuser.title',
      descriptionKey: 'minesweeper.badge.defuser.description',
      icon: Icons.shield_outlined,
      reward: 40,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('minesweeper.defuser')]),
    ),
    BadgeDef(
      id: 'minesweeper.noflag',
      titleKey: 'minesweeper.badge.noflag.title',
      descriptionKey: 'minesweeper.badge.noflag.description',
      icon: Icons.outlined_flag,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('minesweeper.noflag')]),
    ),
    BadgeDef(
      id: 'minesweeper.blitz',
      titleKey: 'minesweeper.badge.blitz.title',
      descriptionKey: 'minesweeper.badge.blitz.description',
      icon: Icons.bolt,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('minesweeper.blitz')]),
    ),
    BadgeDef(
      id: 'minesweeper.sapper',
      titleKey: 'minesweeper.badge.sapper.title',
      descriptionKey: 'minesweeper.badge.sapper.description',
      icon: Icons.military_tech,
      reward: 50,
      condition: BadgeCondition.counter('minesweeper.win', 25),
    ),
  ];

  @override
  GameRules<MinesweeperState> get rules => const MinesweeperRules();

  @override
  AiPlayer<MinesweeperState> get ai => const MinesweeperAi();

  @override
  Widget icon(BuildContext context) => const MinesweeperIcon();

  @override
  Widget board(BuildContext context, GameBoardView<MinesweeperState> view) => MinesweeperBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    MinesweeperRuleStep(cells: MinesweeperRuleStep.open, text: minesweeperTexts.of(context, 'minesweeper.step.open')),
    MinesweeperRuleStep(
      cells: MinesweeperRuleStep.number,
      text: minesweeperTexts.of(context, 'minesweeper.step.number'),
    ),
    MinesweeperRuleStep(cells: MinesweeperRuleStep.flag, text: minesweeperTexts.of(context, 'minesweeper.step.flag')),
    MinesweeperRuleStep(
      cells: MinesweeperRuleStep.out,
      puff: true,
      text: minesweeperTexts.of(context, 'minesweeper.step.out'),
    ),
  ];

  @override
  String? turnHint(BuildContext context, MinesweeperState state, String playerName) => minesweeperTexts.of(
    context,
    state.solo ? 'minesweeper.turn.solo' : 'minesweeper.turn.multi',
    {'name': playerName},
  );
}

const minesweeperModule = MinesweeperModule();
