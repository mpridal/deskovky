import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'war_ai.dart';
import 'war_board.dart';
import 'war_events.dart';
import 'war_icon.dart';
import 'war_rule_step.dart';
import 'war_rules.dart';
import 'war_texts.dart';

/// Manifest of Válka (design `docs/superpowers/specs/2026-11-12-valka-design.md`):
/// 2–4 players, people or robots; each turns their top card and the highest
/// takes the table.
class WarModule extends GameModule<WarState> {
  const WarModule();

  @override
  String get id => 'war';
  @override
  String get titleKey => 'war.title';
  @override
  String get descriptionKey => 'war.description';
  @override
  String get rulesKey => 'war.rules';
  @override
  GameTexts get texts => warTexts;

  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;

  /// Pure luck: a robot has nothing to be good or bad at, so there is one
  /// difficulty and the setup does not ask.
  @override
  List<Difficulty> get difficulties => const [Difficulty.medium];

  @override
  String get musicTrack => 'war';
  @override
  bool get supportsSaveResume => true;

  /// Luck, not skill.
  @override
  double get pointsMultiplier => 0.6;

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'deck',
      labelKey: 'war.option.deck',
      choices: [(WarDeck.small, 'war.option.deck.32'), (WarDeck.full, 'war.option.deck.52')],
      defaultValue: WarDeck.small,
    ),
    ChoiceOption(
      id: 'length',
      labelKey: 'war.option.length',
      choices: [
        (WarLength.short, 'war.option.length.short'),
        (WarLength.long, 'war.option.length.long'),
        (WarLength.full, 'war.option.length.full'),
      ],
      defaultValue: WarLength.short,
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'war.first',
      titleKey: 'war.badge.first.title',
      descriptionKey: 'war.badge.first.description',
      icon: Icons.style,
      reward: 10,
      condition: BadgeCondition.wins(1),
    ),
    BadgeDef(
      id: 'war.doubleWar',
      titleKey: 'war.badge.doubleWar.title',
      descriptionKey: 'war.badge.doubleWar.description',
      icon: Icons.flash_on,
      reward: 20,
      condition: BadgeCondition.event(WarEvents.doubleWar),
    ),
    BadgeDef(
      id: 'war.comeback',
      titleKey: 'war.badge.comeback.title',
      descriptionKey: 'war.badge.comeback.description',
      icon: Icons.trending_up,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(WarEvents.comeback)]),
    ),
    BadgeDef(
      id: 'war.veteran',
      titleKey: 'war.badge.veteran.title',
      descriptionKey: 'war.badge.veteran.description',
      icon: Icons.military_tech,
      reward: 40,
      condition: BadgeCondition.wins(20),
    ),
  ];

  @override
  GameRules<WarState> get rules => const WarRules();

  @override
  AiPlayer<WarState> get ai => const WarAi();

  @override
  Widget icon(BuildContext context) => const WarIcon();

  @override
  Widget board(BuildContext context, GameBoardView<WarState> view) => WarBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    for (final step in WarRuleStepKind.values)
      WarRuleStep(kind: step, text: warTexts.of(context, 'war.step${step.index + 1}')),
  ];

  @override
  String? turnHint(BuildContext context, WarState state, String playerName) => warTexts.of(
    context,
    state.battleWinner != null ? 'war.turnHint.collect' : (state.warDepth > 0 ? 'war.turnHint.war' : 'war.turnHint'),
    {'name': playerName},
  );
}

const warModule = WarModule();
