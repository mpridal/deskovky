import 'package:flutter/foundation.dart';

import '../../app/stats_service.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import 'seat_identity.dart';

/// What the results screen gets when a game ends.
@immutable
class GameOutcomeView {
  const GameOutcomeView({required this.config, required this.result, required this.seats, this.newBadges = const []});

  final GameConfig config;
  final GameResult result;
  final List<SeatIdentity> seats;

  /// Badges people earned with this game (spec 5.9).
  final List<EarnedBadge> newBadges;

  GameOutcomeView withBadges(List<EarnedBadge> badges) =>
      GameOutcomeView(config: config, result: result, seats: seats, newBadges: badges);
}
