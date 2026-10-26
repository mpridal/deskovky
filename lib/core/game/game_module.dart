import 'package:flutter/widgets.dart';

import '../badges/badge.dart';
import 'ai_player.dart';
import 'difficulty.dart';
import 'game_option.dart';
import 'game_rules.dart';
import 'game_texts.dart';
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
    this.elapsed = _noTime,
    this.firstGame = false,
  });

  final S state;
  final Move? lastMove;

  /// The human seat to move on this device, or null (robot's turn, game over).
  final int? mySeat;
  final bool canAct;
  final Future<bool> Function(Move move) submit;
  final GameHost host;

  /// Playing time so far without pauses and background (spec 13.4), e.g.
  /// for a move that records when a Minesweeper board was cleared.
  final Duration Function() elapsed;

  /// True on the first game of this game by the person to act (spec 13.4:
  /// a gentle hint how to play).
  final bool firstGame;
}

Duration _noTime() => Duration.zero;

/// A game registered with the framework (spec 8). The framework never looks
/// inside the game: it only uses this manifest, the rules, the AI and the board.
abstract class GameModule<S> {
  const GameModule();

  String get id;
  String get titleKey;
  String get descriptionKey;
  String get rulesKey;

  /// The game's own texts (titles, rules, options, badges), keys prefixed `<id>.`.
  GameTexts get texts => const GameTexts();
  int get minPlayers;
  int get maxPlayers;
  bool get supportsAi;
  List<Difficulty> get difficulties => Difficulty.values;

  /// True when difficulty matters without robots too (Miny: board size,
  /// Pexeso solo: preview and swaps); the setup then always offers it.
  bool get difficultyWithoutRobots => false;
  List<GameOption> get options => const [];

  /// Scales the base points of a game (spec 5.6), 0.5–2.
  double get pointsMultiplier => 1.0;

  /// The game's own badges, ids prefixed with `<id>.` (spec 5.5, 13.4).
  List<BadgeDef> get badges => const [];
  /// Orientation the game screen locks on phones and on tablets (≥ 600 dp).
  GameOrientation get phoneOrientation => GameOrientation.any;
  GameOrientation get tabletOrientation => GameOrientation.any;

  /// The game's own effects: id (`<id>.boing`) → path `games/<id>/sfx/boing.ogg`
  /// (spec 7.1, 13.4: at most three). Played via `GameHost.playSfx`.
  Map<String, String> get sfx => const {};

  /// Music id in the AudioCatalog (spec 7.2), e.g. 'ludo'.
  String get musicTrack;
  bool get supportsSaveResume;
  bool get available => true;
  GameRules<S> get rules;
  AiPlayer<S>? get ai;

  Widget icon(BuildContext context);

  Widget board(BuildContext context, GameBoardView<S> view);

  /// 2–4 illustrated rule steps drawn in code (spec 13.4), shown under the
  /// rules text in the pause menu and the setup screen.
  List<Widget> ruleSteps(BuildContext context) => const [];

  /// Optional hint for the bubble at the bottom, e.g. "Kuba, guess a number".
  String? turnHint(BuildContext context, S state, String playerName) => null;

  /// Calls [use] with this module's state type, so framework code that only
  /// knows `GameModule<Object?>` can build typed sessions and widgets.
  R withType<R>(R Function<T>(GameModule<T> module) use) => use<S>(this);
}
