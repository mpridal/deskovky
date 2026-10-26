import 'package:flutter/widgets.dart';

import 'ai_player.dart';
import 'difficulty.dart';
import 'game_option.dart';
import 'game_rules.dart';
import 'move.dart';

enum GameOrientation { any, portrait, landscape }

/// What the framework offers a game while it is played (spec 8).
abstract class GameHost {
  void haptic();

  /// Plays a sound effect by its AudioCatalog id (spec 7.3).
  void playSfx(String id);

  /// Reports a game event for achievements (milestone 6).
  void reportEvent(String id, [Map<String, Object?> data = const {}]);
}

/// What a game's board widget gets from the framework.
@immutable
class GameBoardView<S> {
  const GameBoardView({
    required this.state,
    required this.lastMove,
    required this.mySeat,
    required this.canAct,
    required this.submit,
    required this.host,
  });

  final S state;
  final Move? lastMove;

  /// The human seat to move on this device, or null (robot's turn, game over).
  final int? mySeat;
  final bool canAct;
  final Future<bool> Function(Move move) submit;
  final GameHost host;
}

/// A game registered with the framework (spec 8). The framework never looks
/// inside the game: it only uses this manifest, the rules, the AI and the board.
abstract class GameModule<S> {
  const GameModule();

  String get id;
  String get titleKey;
  String get descriptionKey;
  String get rulesKey;
  int get minPlayers;
  int get maxPlayers;
  bool get supportsAi;
  List<Difficulty> get difficulties => Difficulty.values;
  List<GameOption> get options => const [];
  GameOrientation get phoneOrientation => GameOrientation.any;

  /// Music id in the AudioCatalog (spec 7.2), e.g. 'ludo'.
  String get musicTrack;
  bool get supportsSaveResume;
  bool get available => true;
  GameRules<S> get rules;
  AiPlayer<S>? get ai;

  Widget icon(BuildContext context);

  Widget board(BuildContext context, GameBoardView<S> view);

  /// Optional hint for the bubble at the bottom, e.g. "Kuba, guess a number".
  String? turnHint(BuildContext context, S state, String playerName) => null;

  /// Calls [use] with this module's state type, so framework code that only
  /// knows `GameModule<Object?>` can build typed sessions and widgets.
  R withType<R>(R Function<T>(GameModule<T> module) use) => use<S>(this);
}
