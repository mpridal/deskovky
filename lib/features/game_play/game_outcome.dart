import 'package:flutter/foundation.dart';

import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import 'seat_identity.dart';

/// What the results screen gets when a game ends.
@immutable
class GameOutcomeView {
  const GameOutcomeView({required this.config, required this.result, required this.seats});

  final GameConfig config;
  final GameResult result;
  final List<SeatIdentity> seats;
}
