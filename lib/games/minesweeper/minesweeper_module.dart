import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'minesweeper_icon.dart';
import 'minesweeper_rules.dart';
import 'minesweeper_texts.dart';

/// Manifest of Miny (spec 13). Skeleton from milestone 9:
/// shown as "Brzy" until the game's own session makes it playable.
class MinesweeperModule extends GameModule<Map<String, Object?>> {
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
  bool get available => false;

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
      choices: [('longPress', 'minesweeper.option.controls.longPress'), ('switch', 'minesweeper.option.controls.switch')],
      defaultValue: 'longPress',
    ),
  ];

  @override
  GameRules<Map<String, Object?>> get rules => const MinesweeperRules();

  @override
  AiPlayer<Map<String, Object?>>? get ai => null;

  @override
  Widget icon(BuildContext context) => const MinesweeperIcon();

  @override
  Widget board(BuildContext context, GameBoardView<Map<String, Object?>> view) => const SizedBox.shrink();
}

const minesweeperModule = MinesweeperModule();
