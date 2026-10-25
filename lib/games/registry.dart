import '../core/game/game_module.dart';
import '_sample/sample_module.dart';

/// All games known to the app, in home-grid order (spec 8: one registry file).
/// Milestone 9 adds the skeletons of the five phase-2 games here.
const List<GameModule<Object?>> gameModules = [sampleModule];

/// How many cards the home grid shows; missing ones are "coming soon".
const homeGridSlots = 6;

GameModule<Object?>? moduleById(String id) => gameModules.where((m) => m.id == id).firstOrNull;
