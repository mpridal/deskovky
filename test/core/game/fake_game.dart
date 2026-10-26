import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/game/game_rules.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/seeded_random.dart';

/// Tiny test game: players take turns adding 1 or 2 to a shared counter that
/// starts at a seeded value 0–2; whoever reaches [target] or more wins.
class FakeState {
  const FakeState({required this.count, required this.current, required this.seats, this.winner});

  final int count;
  final int current;
  final int seats;
  final int? winner;
}

class FakeRules implements GameRules<FakeState> {
  const FakeRules({this.target = 10});

  final int target;

  @override
  FakeState initialState(GameConfig config, int seed) =>
      FakeState(count: SeededRandom(seed).nextInt(3), current: 0, seats: config.seats.length);

  @override
  int? currentSeat(FakeState state) => state.winner == null ? state.current : null;

  @override
  bool isLegal(FakeState state, Move move) {
    final n = move.data['n'];
    return state.winner == null && move.seat == state.current && move.type == 'add' && (n == 1 || n == 2);
  }

  @override
  FakeState apply(FakeState state, Move move) {
    final count = state.count + (move.data['n']! as int);
    return FakeState(
      count: count,
      current: (state.current + 1) % state.seats,
      seats: state.seats,
      winner: count >= target ? move.seat : null,
    );
  }

  @override
  bool isOver(FakeState state) => state.winner != null;

  @override
  GameResult result(FakeState state) => GameResult(
        places: [for (var s = 0; s < state.seats; s++) s == state.winner ? 1 : 2],
        scores: [for (var s = 0; s < state.seats; s++) s == state.winner ? 1 : 0],
        stars: [for (var s = 0; s < state.seats; s++) s == state.winner ? 3 : 1],
      );

  @override
  int score(FakeState state, int seat) => seat == state.winner ? 1 : 0;

  @override
  Map<String, Object?> stateToJson(FakeState s) =>
      {'count': s.count, 'current': s.current, 'seats': s.seats, 'winner': s.winner};

  @override
  FakeState stateFromJson(Map<String, Object?> j) => FakeState(
        count: j['count']! as int,
        current: j['current']! as int,
        seats: j['seats']! as int,
        winner: j['winner'] as int?,
      );
}

class FakeAi implements AiPlayer<FakeState> {
  const FakeAi();

  @override
  Move chooseMove(FakeState state, int seat, Difficulty difficulty, SeededRandom random) =>
      Move(seat: seat, type: 'add', data: {'n': difficulty == Difficulty.hard ? 2 : 1 + random.nextInt(2)});
}

GameConfig fakeConfig({int seats = 2}) => GameConfig(
      gameId: 'fake',
      seats: [for (var i = 0; i < seats; i++) i == 0 ? const HumanSeat(1) : const RobotSeat()],
      difficulty: Difficulty.medium,
      robotSpeed: RobotSpeed.fast,
      options: const {},
    );
