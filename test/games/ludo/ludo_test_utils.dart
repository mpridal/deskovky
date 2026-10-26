import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/games/ludo/ludo_rules.dart';

const rules = LudoRules();

GameConfig ludoConfig({int players = 4, int robots = 0, Map<String, Object?> options = const {}}) => GameConfig(
  gameId: 'ludo',
  seats: [for (var s = 0; s < players; s++) s < players - robots ? HumanSeat(s + 1) : const RobotSeat()],
  difficulty: Difficulty.medium,
  robotSpeed: RobotSpeed.fast,
  options: options,
);

/// A game in a chosen position: [pieces] per seat, [current] to move.
LudoState position(
  List<List<int>> pieces, {
  int current = 0,
  Map<String, Object?> options = const {},
  List<int> finished = const [],
}) {
  final start = rules.initialState(ludoConfig(players: pieces.length, options: options), 1);
  return start.copyWith(pieces: pieces, current: current, finished: finished);
}

/// [s] after the seat to move rolled [value].
LudoState rolled(LudoState s, int value) => rules.rollWith(s, value);

Move pick(LudoState s, int piece) => Move(seat: s.current, type: 'move', data: {'piece': piece});

Move roll(LudoState s) => Move(seat: s.current, type: 'roll');

const base = LudoPos.base;
