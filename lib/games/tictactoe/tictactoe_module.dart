import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'tictactoe_icon.dart';
import 'tictactoe_rules.dart';
import 'tictactoe_texts.dart';

/// Manifest of Piškvorky (spec 13). Skeleton from milestone 9:
/// shown as "Brzy" until the game's own session makes it playable.
class TictactoeModule extends GameModule<Map<String, Object?>> {
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
  @override
  int get minPlayers => 1;
  @override
  int get maxPlayers => 2;
  @override
  bool get supportsAi => true;
  @override
  String get musicTrack => 'tictactoe';
  @override
  bool get supportsSaveResume => true;
  @override
  bool get available => false;

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
      defaultValue: 3,
    ),
    ChoiceOption(
      id: 'start',
      labelKey: 'tictactoe.option.start',
      choices: [('alternate', 'tictactoe.option.start.alternate'), ('random', 'tictactoe.option.start.random'), ('first', 'tictactoe.option.start.first')],
      defaultValue: 'alternate',
    ),
  ];

  @override
  GameRules<Map<String, Object?>> get rules => const TictactoeRules();

  @override
  AiPlayer<Map<String, Object?>>? get ai => null;

  @override
  Widget icon(BuildContext context) => const TictactoeIcon();

  @override
  Widget board(BuildContext context, GameBoardView<Map<String, Object?>> view) => const SizedBox.shrink();
}

const tictactoeModule = TictactoeModule();
