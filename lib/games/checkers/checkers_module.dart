import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'checkers_icon.dart';
import 'checkers_rules.dart';
import 'checkers_texts.dart';

/// Manifest of Dáma (spec 13). Skeleton from milestone 9:
/// shown as "Brzy" until the game's own session makes it playable.
class CheckersModule extends GameModule<Map<String, Object?>> {
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
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'checkers';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => false;

  @override
  GameOrientation get phoneOrientation => GameOrientation.portrait;

  @override
  List<GameOption> get options => const [
    ChoiceOption(
      id: 'rules',
      labelKey: 'checkers.option.rules',
      choices: [('czech', 'checkers.option.rules.czech'), ('international', 'checkers.option.rules.international')],
      defaultValue: 'czech',
    ),
  ];

  @override
  GameRules<Map<String, Object?>> get rules => const CheckersRules();

  @override
  AiPlayer<Map<String, Object?>>? get ai => null;

  @override
  Widget icon(BuildContext context) => const CheckersIcon();

  @override
  Widget board(BuildContext context, GameBoardView<Map<String, Object?>> view) => const SizedBox.shrink();
}

const checkersModule = CheckersModule();
