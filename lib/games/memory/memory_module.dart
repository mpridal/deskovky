import 'package:flutter/material.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/game/game_rules.dart';
import '../../core/game/game_texts.dart';
import 'memory_icon.dart';
import 'memory_rules.dart';
import 'memory_texts.dart';

/// Manifest of Pexeso (spec 13). Skeleton from milestone 9:
/// shown as "Brzy" until the game's own session makes it playable.
class MemoryModule extends GameModule<Map<String, Object?>> {
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
      defaultValue: 16,
    ),
    ChoiceOption(
      id: 'set',
      labelKey: 'memory.option.set',
      choices: [('animals', 'memory.option.set.animals'), ('food', 'memory.option.set.food'), ('transport', 'memory.option.set.transport'), ('space', 'memory.option.set.space')],
      defaultValue: 'animals',
    ),
  ];

  @override
  GameRules<Map<String, Object?>> get rules => const MemoryRules();

  @override
  AiPlayer<Map<String, Object?>>? get ai => null;

  @override
  Widget icon(BuildContext context) => const MemoryIcon();

  @override
  Widget board(BuildContext context, GameBoardView<Map<String, Object?>> view) => const SizedBox.shrink();
}

const memoryModule = MemoryModule();
