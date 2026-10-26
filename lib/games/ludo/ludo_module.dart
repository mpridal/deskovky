import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'ludo_ai.dart';
import 'ludo_board.dart';
import 'ludo_events.dart';
import 'ludo_icon.dart';
import 'ludo_rule_steps.dart';
import 'ludo_rules.dart';
import 'ludo_texts.dart';

/// Manifest of Člověče, nezlob se (spec 13.8).
class LudoModule extends GameModule<LudoState> {
  const LudoModule();

  @override
  String get id => 'ludo';
  @override
  String get titleKey => 'ludo.title';
  @override
  String get descriptionKey => 'ludo.description';
  @override
  String get rulesKey => 'ludo.rules';
  @override
  GameTexts get texts => ludoTexts;
  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 4;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'ludo';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => false;

  /// A long game with luck: a bit more than the base points.
  @override
  double get pointsMultiplier => 1.2;

  @override
  GameOrientation get phoneOrientation => GameOrientation.portrait;
  @override
  GameOrientation get tabletOrientation => GameOrientation.landscape;

  @override
  Map<String, String> get sfx => const {
    'ludo.hop': 'games/ludo/sfx/hop.ogg',
    'ludo.boing': 'games/ludo/sfx/boing.ogg',
    'ludo.home': 'games/ludo/sfx/home.ogg',
  };

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'length',
      labelKey: 'ludo.option.length',
      choices: [('full', 'ludo.option.length.full'), ('short', 'ludo.option.length.short')],
      defaultValue: 'full',
    ),
    ToggleOption(id: 'mustCapture', labelKey: 'ludo.option.mustCapture', defaultValue: false),
    ToggleOption(id: 'threeTries', labelKey: 'ludo.option.threeTries', defaultValue: true),
    ToggleOption(id: 'playOut', labelKey: 'ludo.option.playOut', defaultValue: false),
    ToggleOption(id: 'autoMove', labelKey: 'ludo.option.autoMove', defaultValue: true),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'ludo.calm',
      titleKey: 'ludo.badge.calm.title',
      descriptionKey: 'ludo.badge.calm.description',
      icon: Icons.sentiment_very_satisfied,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(LudoEvents.captured3)]),
    ),
    BadgeDef(
      id: 'ludo.hunter',
      titleKey: 'ludo.badge.hunter.title',
      descriptionKey: 'ludo.badge.hunter.description',
      icon: Icons.gps_fixed,
      reward: 25,
      condition: BadgeCondition.event(LudoEvents.hunter),
    ),
    BadgeDef(
      id: 'ludo.sixes',
      titleKey: 'ludo.badge.sixes.title',
      descriptionKey: 'ludo.badge.sixes.description',
      icon: Icons.casino,
      reward: 20,
      condition: BadgeCondition.event(LudoEvents.sixes),
    ),
    BadgeDef(
      id: 'ludo.family',
      titleKey: 'ludo.badge.family.title',
      descriptionKey: 'ludo.badge.family.description',
      icon: Icons.family_restroom,
      reward: 20,
      condition: BadgeCondition.event(LudoEvents.family),
    ),
  ];

  @override
  GameRules<LudoState> get rules => const LudoRules();

  @override
  AiPlayer<LudoState> get ai => const LudoAi();

  @override
  Widget icon(BuildContext context) => const LudoIcon();

  @override
  Widget board(BuildContext context, GameBoardView<LudoState> view) => LudoBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    LudoRuleStep(kind: LudoRuleStepKind.enter, text: ludoTexts.of(context, 'ludo.step.enter')),
    LudoRuleStep(kind: LudoRuleStepKind.capture, text: ludoTexts.of(context, 'ludo.step.capture')),
    LudoRuleStep(kind: LudoRuleStepKind.home, text: ludoTexts.of(context, 'ludo.step.home')),
  ];

  @override
  String? turnHint(BuildContext context, LudoState state, String playerName) => ludoTexts.of(
    context,
    state.phase == LudoPhase.roll ? 'ludo.turnHint.roll' : 'ludo.turnHint.move',
    {'name': playerName, 'dice': state.dice},
  );
}

const ludoModule = LudoModule();
