import 'package:flutter/material.dart';

import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// What was picked for a seat: a profile id, or [robotChoice].
const robotChoice = -1;

/// Bottom sheet with the profiles not yet at the table (and optionally a
/// robot). Resolves to a profile id, [robotChoice], or null when dismissed.
Future<int?> showProfilePicker(
  BuildContext context, {
  required List<PlayerProfile> free,
  required bool offerRobot,
  required Color robotColor,
}) => showModalBottomSheet<int>(
  context: context,
  backgroundColor: AppColors.paper,
  showDragHandle: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    Widget tile(Widget picture, String label, int value) => Semantics(
      button: true,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(value),
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 88,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                picture,
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption(color: AppColors.ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in free) tile(AvatarView(spec: p.avatar, size: 64), p.name, p.id),
            if (offerRobot) tile(RobotAvatar(color: robotColor, size: 64), l10n.seatRobot, robotChoice),
          ],
        ),
      ),
    );
  },
);
