import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'memory_ai.dart';
import 'memory_board.dart';
import 'memory_icon.dart';
import 'memory_rule_step.dart';
import 'memory_rules.dart';
import 'memory_texts.dart';

/// Manifest of Pexeso (spec 13.6).
class MemoryModule extends GameModule<MemoryState> {
  const MemoryModule();

  @override
  String get id => 'memory';
  @override
  String get titleKey => 'memory.title';
  @override
  String get descriptionKey => 'memory.description';
  @override
  String get rulesKey => 'memory.rules';
  @override
  GameTexts get texts => memoryTexts;
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'memory';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => false;
  @override
  bool get difficultyWithoutRobots => true;

  @override
  Map<String, String> get sfx => const {
    'memory.match': 'games/memory/sfx/match.ogg',
    'memory.miss': 'games/memory/sfx/miss.ogg',
  };

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'cards',
      labelKey: 'memory.option.cards',
      choices: [(12, '12'), (16, '16'), (24, '24'), (36, '36'), (48, '48')],
      defaultValue: MemoryRules.defaultCards,
    ),
    ChoiceOption(
      id: 'set',
      labelKey: 'memory.option.set',
      choices: [
        ('animals', 'memory.option.set.animals'),
        ('food', 'memory.option.set.food'),
        ('transport', 'memory.option.set.transport'),
        ('space', 'memory.option.set.space'),
      ],
      defaultValue: 'animals',
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'memory.elephant',
      titleKey: 'memory.badge.elephant.title',
      descriptionKey: 'memory.badge.elephant.description',
      icon: Icons.psychology,
      reward: 40,
      condition: BadgeCondition.event('memory.elephant'),
    ),
    BadgeDef(
      id: 'memory.speed',
      titleKey: 'memory.badge.speed.title',
      descriptionKey: 'memory.badge.speed.description',
      icon: Icons.bolt,
      reward: 30,
      condition: BadgeCondition.event('memory.speed'),
    ),
    BadgeDef(
      id: 'memory.streak',
      titleKey: 'memory.badge.streak.title',
      descriptionKey: 'memory.badge.streak.description',
      icon: Icons.local_fire_department,
      reward: 30,
      condition: BadgeCondition.event('memory.streak'),
    ),
    BadgeDef(
      id: 'memory.collector',
      titleKey: 'memory.badge.collector.title',
      descriptionKey: 'memory.badge.collector.description',
      icon: Icons.style,
      reward: 50,
      condition: BadgeCondition.counter('memory.pairs', 200),
    ),
  ];

  @override
  GameRules<MemoryState> get rules => const MemoryRules();

  @override
  AiPlayer<MemoryState> get ai => const MemoryAi();

  @override
  Widget icon(BuildContext context) => const MemoryIcon();

  @override
  Widget board(BuildContext context, GameBoardView<MemoryState> view) => MemoryBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    MemoryRuleStep(left: 0, right: null, icon: Icons.touch_app, text: memoryTexts.of(context, 'memory.step1')),
    MemoryRuleStep(left: 1, right: 1, icon: Icons.check_circle, text: memoryTexts.of(context, 'memory.step2')),
    MemoryRuleStep(left: 4, right: 2, icon: Icons.replay, text: memoryTexts.of(context, 'memory.step3')),
  ];

  @override
  String? turnHint(BuildContext context, MemoryState state, String playerName) => memoryTexts.of(
    context,
    state.open.isEmpty ? 'memory.turnHint.first' : 'memory.turnHint.second',
    {'name': playerName},
  );
}

const memoryModule = MemoryModule();
