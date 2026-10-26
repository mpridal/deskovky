import 'package:flutter/foundation.dart';

import '../../app/stats_service.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_result.dart';
import 'seat_identity.dart';

/// What the results screen gets when a game ends.
@immutable
class GameOutcomeView {
  const GameOutcomeView({
    required this.config,
    required this.result,
    required this.seats,
    this.rewards = MatchRewards.none,
  });

  final GameConfig config;
  final GameResult result;
  final List<SeatIdentity> seats;

  /// Badges and points people earned with this game (spec 5.6, 5.9).
  final MatchRewards rewards;

  List<EarnedBadge> get newBadges => rewards.badges;

  GameOutcomeView withRewards(MatchRewards rewards) =>
      GameOutcomeView(config: config, result: result, seats: seats, rewards: rewards);
}
