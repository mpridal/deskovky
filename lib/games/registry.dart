import '../core/game/game_module.dart';
import '_sample/sample_module.dart';
import 'checkers/checkers_module.dart';
import 'ludo/ludo_module.dart';
import 'memory/memory_module.dart';
import 'minesweeper/minesweeper_module.dart';
import 'tictactoe/tictactoe_module.dart';

/// All games known to the app, in home-grid order (spec 8: one registry file).
/// The phase-2 games are registered from the start (milestone 9), so their
/// own sessions never touch this file; until done they say "Brzy".
const List<GameModule<Object?>> gameModules = [
  sampleModule,
  tictactoeModule,
  memoryModule,
  minesweeperModule,
  ludoModule,
  checkersModule,
];

/// How many cards the home grid shows; missing ones are "coming soon".
const homeGridSlots = 6;

GameModule<Object?>? moduleById(String id) => gameModules.where((m) => m.id == id).firstOrNull;
