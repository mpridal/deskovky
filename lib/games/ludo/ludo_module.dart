import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'ludo_icon.dart';
import 'ludo_rules.dart';
import 'ludo_texts.dart';

/// Manifest of Člověče, nezlob se (spec 13). Skeleton from milestone 9:
/// shown as "Brzy" until the game's own session makes it playable.
class LudoModule extends GameModule<Map<String, Object?>> {
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

  @override
  GameOrientation get phoneOrientation => GameOrientation.portrait;

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
  ];

  @override
  GameRules<Map<String, Object?>> get rules => const LudoRules();

  @override
  AiPlayer<Map<String, Object?>>? get ai => null;

  @override
  Widget icon(BuildContext context) => const LudoIcon();

  @override
  Widget board(BuildContext context, GameBoardView<Map<String, Object?>> view) => const SizedBox.shrink();
}

const ludoModule = LudoModule();
