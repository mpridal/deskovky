import 'package:deskovky/core/game/ai_player.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_session.dart';
import 'package:deskovky/core/game/move.dart';
import 'package:deskovky/core/game/move_transport.dart';
import 'package:deskovky/features/game_play/turn_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/game/fake_game.dart';

const _delay = Duration(milliseconds: 250);

TurnController<FakeState> _controller({required List<SeatConfig> seats, int target = 100}) {
  final config = GameConfig(
    gameId: 'fake',
    seats: seats,
    difficulty: Difficulty.easy,
    robotSpeed: RobotSpeed.fast,
    options: const {},
  );
  final session = GameSession.start(FakeRules(target: target), config, 1);
  return TurnController<FakeState>(
    session: session,
    transport: LocalTransport(session),
    ai: const FakeAi(),
    runner: const InlineAiRunner(),
    robotDelay: _delay,
  );
}

const _add1 = Move(seat: 0, type: 'add', data: {'n': 1});

void main() {
  testWidgets('robots play one after another with the delay after the human', (tester) async {
    final c = _controller(seats: const [HumanSeat(1), RobotSeat(), RobotSeat(), RobotSeat()]);
    addTearDown(c.dispose);
    c.start();
    expect(await c.submitHuman(_add1), isTrue);
    expect(c.session.moves, hasLength(1));
    expect(c.robotThinking, isTrue);

    await tester.pump(const Duration(milliseconds: 200));
    expect(c.session.moves, hasLength(1), reason: 'still waiting');
    await tester.pump(const Duration(milliseconds: 60));
    expect(c.session.moves, hasLength(2));
    await tester.pump(_delay);
    await tester.pump(_delay);
    expect(c.session.moves, hasLength(4));
    expect(c.robotThinking, isFalse, reason: 'back to the human');
  });

  testWidgets('a robot on the first seat starts by itself', (tester) async {
    final c = _controller(seats: const [RobotSeat(), HumanSeat(1)]);
    addTearDown(c.dispose);
    c.start();
    await tester.pump(_delay + const Duration(milliseconds: 10));
    expect(c.session.moves.single.seat, 0);
  });

  testWidgets('humans cannot move for a robot or out of turn', (tester) async {
    final c = _controller(seats: const [HumanSeat(1), RobotSeat()]);
    c.start();
    await c.submitHuman(_add1);
    expect(await c.submitHuman(const Move(seat: 1, type: 'add', data: {'n': 1})), isFalse);
    expect(await c.submitHuman(_add1), isFalse);
    c.dispose(); // cancels the pending robot timer before the test ends
  });

  testWidgets('pause stops robots; resume continues', (tester) async {
    final c = _controller(seats: const [HumanSeat(1), RobotSeat()]);
    addTearDown(c.dispose);
    c.start();
    await c.submitHuman(_add1);
    c.pause();
    await tester.pump(const Duration(seconds: 2));
    expect(c.session.moves, hasLength(1));
    expect(await c.submitHuman(const Move(seat: 0, type: 'add', data: {'n': 2})), isFalse, reason: 'paused');
    c.resume();
    await tester.pump(_delay + const Duration(milliseconds: 10));
    expect(c.session.moves, hasLength(2));
  });

  testWidgets('dispose during the robot delay sends nothing later', (tester) async {
    final c = _controller(seats: const [HumanSeat(1), RobotSeat()]);
    c.start();
    await c.submitHuman(_add1);
    c.dispose();
    await tester.pump(const Duration(seconds: 2));
    expect(c.session.moves, hasLength(1));
  });

  testWidgets('notifies listeners on every move and stops when the game is over', (tester) async {
    final c = _controller(seats: const [HumanSeat(1), RobotSeat()], target: 3);
    addTearDown(c.dispose);
    var notified = 0;
    c.addListener(() => notified++);
    c.start();
    while (!c.isOver) {
      if (c.session.rules.currentSeat(c.session.state) == 0) {
        await c.submitHuman(const Move(seat: 0, type: 'add', data: {'n': 2}));
      }
      await tester.pump(_delay);
    }
    expect(notified, greaterThan(0));
    final moves = c.session.moves.length;
    await tester.pump(const Duration(seconds: 2));
    expect(c.session.moves.length, moves);
  });
}
