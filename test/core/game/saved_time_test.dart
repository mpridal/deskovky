import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/games/_sample/sample_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = GameConfig(
    gameId: 'sample',
    seats: [HumanSeat(1), RobotSeat()],
    difficulty: Difficulty.easy,
    robotSpeed: RobotSpeed.fast,
    options: {'range': 20},
  );

  test('a saved game keeps its playing time; old saves without it start at zero', () {
    const save = SavedGame(config: config, seed: 3, moves: [], elapsedMs: 5000);
    expect(SavedGame.fromJson(save.toJson()), save);
    final old = save.toJson()..remove('elapsedMs');
    expect(SavedGame.fromJson(old)!.elapsedMs, 0);
  });

  test('a restored session continues the time; saving stores the new total', () {
    final session = GameSession.restore(const SampleRules(), const SavedGame(config: config, seed: 3, moves: [], elapsedMs: 5000))!;
    expect(session.elapsedBefore, const Duration(seconds: 5));
    expect(session.toSave(elapsed: const Duration(seconds: 7)).elapsedMs, 7000);
    expect(GameSession.start(const SampleRules(), config, 3).elapsedBefore, Duration.zero);
  });
}
