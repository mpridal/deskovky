import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/game/ai_player.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_session.dart';
import '../../core/game/move.dart';
import '../../core/game/move_transport.dart';
import '../../core/game/seeded_random.dart';

/// Turn order (spec 5.7.1, 9): humans move through [submitHuman]; when a
/// robot is to move it waits [robotDelay], asks the AI and sends the move
/// through the same transport. Paused or disposed, robots stay still.
class TurnController<S> extends ChangeNotifier {
  TurnController({
    required this.session,
    required this.transport,
    required this.ai,
    required this.runner,
    required this.robotDelay,
    this.localSeats,
  }) {
    // Moves applied from elsewhere (another device in a network game) move
    // the game on too.
    _appliedSub = transport.applied.listen((_) {
      _notify();
      _scheduleRobot();
    });
  }

  final GameSession<S> session;
  final MoveTransport transport;
  final AiPlayer<S>? ai;
  final AiRunner runner;
  final Duration robotDelay;

  /// The seats played on this device in a network game (spec 14); null
  /// means every person sits here.
  final Set<int>? localSeats;
  late final StreamSubscription<Move> _appliedSub;

  Timer? _robotTimer;
  bool _paused = false;
  bool _disposed = false;
  bool _robotBusy = false;

  bool get isOver => session.rules.isOver(session.state);
  bool get paused => _paused;
  int? get currentSeat => session.rules.currentSeat(session.state);

  bool isRobotSeat(int seat) => session.config.seats[seat] is RobotSeat;

  /// A robot is to move (waiting for its delay or computing).
  bool get robotThinking {
    final seat = currentSeat;
    return seat != null && isRobotSeat(seat);
  }

  /// The human seat that may act now, or null.
  int? get humanSeatToAct {
    final seat = currentSeat;
    if (seat == null || isRobotSeat(seat) || _paused) return null;
    return localSeats == null || localSeats!.contains(seat) ? seat : null;
  }

  void start() => _scheduleRobot();

  Future<bool> submitHuman(Move move) async {
    if (_disposed || _paused || move.seat != humanSeatToAct) return false;
    return _send(move);
  }

  void pause() {
    _paused = true;
    _robotTimer?.cancel();
    _notify();
  }

  void resume() {
    _paused = false;
    _notify();
    _scheduleRobot();
  }

  Future<bool> _send(Move move) async {
    final applied = await transport.submit(move);
    if (applied) {
      _notify();
      _scheduleRobot();
    }
    return applied;
  }

  void _scheduleRobot() {
    _robotTimer?.cancel();
    final seat = currentSeat;
    final robotAi = ai;
    if (_disposed || _paused || seat == null || !isRobotSeat(seat) || robotAi == null) return;
    _robotTimer = Timer(robotDelay, () => _playRobot(robotAi, seat));
  }

  Future<void> _playRobot(AiPlayer<S> robotAi, int seat) async {
    if (_robotBusy) return;
    _robotBusy = true;
    try {
      final movesBefore = session.moves.length;
      Move? move;
      try {
        move = await runner.run(robotAi, session.state, seat, session.config.difficulty, session.seed + movesBefore);
      } catch (e) {
        debugPrint('TurnController: AI failed, playing a legal move instead: $e');
      }
      // The AI may finish after a pause, dispose or another move.
      if (_disposed || _paused || session.moves.length != movesBefore || currentSeat != seat) return;
      if (move != null) {
        if (await _send(move)) return;
        debugPrint('TurnController: AI answered an illegal move $move, playing a legal move instead');
        // A slower transport (phase 3) may have let the game move on meanwhile.
        if (_disposed || _paused || session.moves.length != movesBefore || currentSeat != seat) return;
      }
      // A broken AI must never leave the robot "thinking" forever: play a
      // legal move picked from the seed, so a replay picks the same one.
      final legal = session.rules.legalMoves(session.state, seat);
      if (legal.isEmpty) {
        debugPrint('TurnController: no legal move for robot seat $seat – GameRules.legalMoves breaks its contract');
        return;
      }
      await _send(legal[SeededRandom(session.seed + movesBefore).nextInt(legal.length)]);
    } finally {
      _robotBusy = false;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _robotTimer?.cancel();
    _appliedSub.cancel();
    transport.dispose();
    super.dispose();
  }
}
