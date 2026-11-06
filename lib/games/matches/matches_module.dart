import 'package:flutter/material.dart';

import '../../core/badges/badge.dart';
import '../../core/game/ai_player.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'matches_ai.dart';
import 'matches_board.dart';
import 'matches_events.dart';
import 'matches_icon.dart';
import 'matches_rule_step.dart';
import 'matches_rules.dart';
import 'matches_texts.dart';

/// Manifest of Sirky (design `docs/superpowers/specs/2026-11-06-sirky-design.md`):
/// two players, people or robots, rows of 3, 5 and 7 matches; whoever takes
/// the last match loses.
class MatchesModule extends GameModule<MatchesState> {
  const MatchesModule();

  @override
  String get id => 'matches';
  @override
  String get titleKey => 'matches.title';
  @override
  String get descriptionKey => 'matches.description';
  @override
  String get rulesKey => 'matches.rules';
  @override
  GameTexts get texts => matchesTexts;

  @override
  int get minPlayers => 2;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'matches';
  @override
  bool get supportsSaveResume => true;

  /// A game takes a minute or two (design §3).
  @override
  double get pointsMultiplier => 0.8;

  @override
  Map<String, String> get sfx => const {
    'matches.pick': 'games/matches/sfx/pick.ogg',
    'matches.take': 'games/matches/sfx/take.ogg',
    'matches.strike': 'games/matches/sfx/strike.ogg',
  };

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'start',
      labelKey: 'matches.option.start',
      choices: [
        (MatchesStart.random, 'matches.option.start.random'),
        (MatchesStart.first, 'matches.option.start.first'),
      ],
      defaultValue: MatchesStart.random,
    ),
  ];

  @override
  List<BadgeDef> get badges => const [
    BadgeDef(
      id: 'matches.first',
      titleKey: 'matches.badge.first.title',
      descriptionKey: 'matches.badge.first.description',
      icon: Icons.local_fire_department,
      reward: 10,
      condition: BadgeCondition.counter(MatchesEvents.win, 1),
    ),
    BadgeDef(
      id: 'matches.master',
      titleKey: 'matches.badge.master.title',
      descriptionKey: 'matches.badge.master.description',
      icon: Icons.emoji_events,
      reward: 50,
      condition: BadgeCondition.wonAgainst(Difficulty.hard),
    ),
    BadgeDef(
      id: 'matches.flawless',
      titleKey: 'matches.badge.flawless.title',
      descriptionKey: 'matches.badge.flawless.description',
      icon: Icons.verified,
      reward: 30,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event(MatchesEvents.flawless)]),
    ),
    BadgeDef(
      id: 'matches.collector',
      titleKey: 'matches.badge.collector.title',
      descriptionKey: 'matches.badge.collector.description',
      icon: Icons.inventory_2,
      reward: 40,
      condition: BadgeCondition.counter(MatchesEvents.win, 25),
    ),
  ];

  @override
  GameRules<MatchesState> get rules => const MatchesRules();

  @override
  AiPlayer<MatchesState> get ai => const MatchesAi();

  @override
  Widget icon(BuildContext context) => const MatchesIcon();

  @override
  Widget board(BuildContext context, GameBoardView<MatchesState> view) => MatchesBoard(view: view);

  @override
  List<Widget> ruleSteps(BuildContext context) => [
    for (final step in MatchesRuleStepKind.values)
      MatchesRuleStep(kind: step, text: matchesTexts.of(context, 'matches.step${step.index + 1}')),
  ];

  @override
  String? turnHint(BuildContext context, MatchesState state, String playerName) =>
      matchesTexts.of(context, state.total == 1 ? 'matches.turnHint.last' : 'matches.turnHint', {'name': playerName});
}

const matchesModule = MatchesModule();
