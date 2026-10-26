import 'package:flutter/material.dart';

import '../../core/game/difficulty.dart';
import '../../core/game/game_config.dart';
import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/tokens/app_colors.dart';

/// Robot names by seat (spec 5.7.1), localized.
String robotName(AppLocalizations l10n, int seat) => switch (seat) {
  0 => l10n.robotName0,
  1 => l10n.robotName1,
  2 => l10n.robotName2,
  _ => l10n.robotName3,
};

/// How one seat looks everywhere (setup, HUD, results): a player's name and
/// avatar, or a robot in the seat colour.
@immutable
class SeatIdentity {
  const SeatIdentity({required this.seat, required this.name, required this.profile, required this.difficulty});

  final int seat;
  final String name;

  /// Null for robots.
  final PlayerProfile? profile;

  /// The robots' difficulty, null for humans.
  final Difficulty? difficulty;

  bool get isRobot => profile == null;
  Color get color => AppColors.players[seat];

  Widget avatar(double size) => isRobot
      ? RobotAvatar(color: color, size: size, semanticLabel: name)
      : AvatarView(spec: profile!.avatar, size: size, semanticLabel: name);

  static List<SeatIdentity> forConfig(GameConfig config, List<PlayerProfile> profiles, AppLocalizations l10n) => [
    for (final (seat, s) in config.seats.indexed)
      switch (s) {
        HumanSeat(:final profileId) when profiles.any((p) => p.id == profileId) => SeatIdentity(
          seat: seat,
          name: profiles.firstWhere((p) => p.id == profileId).name,
          profile: profiles.firstWhere((p) => p.id == profileId),
          difficulty: null,
        ),
        _ => SeatIdentity(seat: seat, name: robotName(l10n, seat), profile: null, difficulty: config.difficulty),
      },
  ];
}

/// One to three dots for a robot's difficulty (spec 5.7.1).
class DifficultyDots extends StatelessWidget {
  const DifficultyDots({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final filled = difficulty.index + 1;
    return ExcludeSemantics(
      child: Text(
        '${'●' * filled}${'○' * (3 - filled)}',
        style: const TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
      ),
    );
  }
}
