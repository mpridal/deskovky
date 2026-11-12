import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'ships_ai.dart';
import 'ships_board.dart';
import 'ships_events.dart';
import 'ships_icon.dart';
import 'ships_rule_step.dart';
import 'ships_rules.dart';
import 'ships_texts.dart';

/// Manifest of Lodě (design `docs/superpowers/specs/2026-11-12-lode-design.md`):
/// two players, people or robots, each with a secret fleet; the first to
/// sink the other fleet wins.
class ShipsModule extends GameModule<ShipsState> {
  const ShipsModule();

  @override
  String get id => 'ships';
  @override
  String get titleKey => 'ships.title';
  @override
  String get descriptionKey => 'ships.description';
  @override
  String get rulesKey => 'ships.rules';
  @override
  GameTexts get texts => shipsTexts;

  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;

  @override
  Map<String, String> get sfx => const {
    'ships.splash': 'games/ships/sfx/splash.ogg',
    'ships.hit': 'games/ships/sfx/hit.ogg',
    'ships.sunk': 'games/ships/sfx/sunk.ogg',
  };

  @override
  String get musicTrack => 'ships';
  @override
  bool get supportsSaveResume => true;

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'size',
      labelKey: 'ships.option.size',
      choices: [(ShipsSize.small, 'ships.option.size.8'), (ShipsSize.big, 'ships.option.size.10')],
      defaultValue: ShipsSize.small,
    ),
    ChoiceOption(
      id: 'bonus',
      labelKey: 'ships.option.bonus',
      choices: [(ShipsBonus.again, 'ships.option.bonus.again'), (ShipsBonus.alternate, 'ships.option.bonus.alternate')],
      defaultValue: ShipsBonus.again,
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'ships.first',
      titleKey: 'ships.badge.first.title',
      descriptionKey: 'ships.badge.first.description',
      icon: Icons.sailing,
      reward: 10,
      condition: BadgeCondition.wins(1),
    ),
    BadgeDef(
      id: 'ships.sharp',
      titleKey: 'ships.badge.sharp.title',
      descriptionKey: 'ships.badge.sharp.description',
      icon: Icons.gps_fixed,
      reward: 20,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(ShipsEvents.sharp)]),
    ),
    BadgeDef(
      id: 'ships.untouched',
      titleKey: 'ships.badge.untouched.title',
      descriptionKey: 'ships.badge.untouched.description',
      icon: Icons.shield,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(ShipsEvents.untouched)]),
    ),
    BadgeDef(
      id: 'ships.admiral',
      titleKey: 'ships.badge.admiral.title',
      descriptionKey: 'ships.badge.admiral.description',
      icon: Icons.anchor,
      reward: 40,
      condition: BadgeCondition.wins(20),
    ),
  ];

  @override
  GameRules<ShipsState> get rules => const ShipsRules();

  @override
  AiPlayer<ShipsState> get ai => const ShipsAi();

  @override
  Widget icon(BuildContext context) => const ShipsIcon();

  @override
  Widget board(BuildContext context, GameBoardView<ShipsState> view) => ShipsBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    for (final step in ShipsRuleStepKind.values)
      ShipsRuleStep(kind: step, text: shipsTexts.of(context, 'ships.step${step.index + 1}')),
  ];

  @override
  String? turnHint(BuildContext context, ShipsState state, String playerName) =>
      shipsTexts.of(context, state.placing ? 'ships.turnHint.place' : 'ships.turnHint', {'name': playerName});
}

const shipsModule = ShipsModule();
