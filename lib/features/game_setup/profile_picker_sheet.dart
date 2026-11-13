import 'package:flutter/material.dart';

import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// What was picked for a seat: a profile id, or [robotChoice].
const robotChoice = -1;

/// A family member who plays now on another device, picked to play there.
@immutable
class AwayPick {
  const AwayPick(this.profileId);

  final int profileId;
}

/// Bottom sheet with the profiles not yet at the table (and optionally a
/// robot), then [away]: family members playing now on another device (busy
/// ones in a game shown, not pickable). Resolves to a profile id,
/// [robotChoice], an [AwayPick], or null when dismissed.
Future<Object?> showProfilePicker(
  BuildContext context, {
  required List<PlayerProfile> free,
  required bool offerRobot,
  required Color robotColor,
  List<(PlayerProfile, bool)> away = const [],
}) => showModalBottomSheet<Object>(
  context: context,
  backgroundColor: AppColors.paper,
  showDragHandle: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
  builder: (context) {
    final l10n = AppLocalizations.of(context);
    Widget tile(Widget picture, String label, Object? value, {Key? key, String? tag}) => Semantics(
      button: value != null,
      child: InkWell(
        key: key,
        onTap: value == null ? null : () => Navigator.of(context).pop(value),
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
                if (tag != null)
                  Text(
                    tag,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(color: value == null ? AppColors.wood : AppColors.felt)
                        .copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in free) tile(AvatarView(spec: p.avatar, size: 64), p.name, p.id),
                if (offerRobot) tile(RobotAvatar(color: robotColor, size: 64), l10n.seatRobot, robotChoice),
              ],
            ),
            if (away.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                child: Row(
                  children: [
                    const Icon(Icons.send_to_mobile, size: 18, color: AppColors.wood),
                    const SizedBox(width: 6),
                    Text(l10n.setupElsewhere, style: AppTypography.caption(color: AppColors.wood)),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (p, busy) in away)
                    Opacity(
                      opacity: busy ? 0.5 : 1,
                      child: tile(
                        AvatarView(spec: p.avatar, size: 64),
                        p.name,
                        busy ? null : AwayPick(p.id),
                        key: ValueKey('away_${p.id}'),
                        tag: busy ? l10n.setupBusyTag : l10n.playerActiveTag,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  },
);
