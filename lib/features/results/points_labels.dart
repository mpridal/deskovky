import '../../app/stats_service.dart';
import '../../core/points/points_math.dart';
import '../../games/badge_texts.dart';
import '../../l10n/app_localizations.dart';

/// The label of a points line or ledger entry; [detail] is the badge id or
/// the stars/streak count.
String pointsLabel(AppLocalizations l10n, PointsReason reason, {String? detail}) {
  final count = int.tryParse(detail ?? '') ?? 0;
  return switch (reason) {
    PointsReason.win => l10n.pointsWin,
    PointsReason.draw => l10n.pointsDraw,
    PointsReason.second => l10n.pointsSecond,
    PointsReason.participation => l10n.pointsParticipation,
    PointsReason.stars => l10n.pointsStars(count),
    PointsReason.streak => l10n.pointsStreak(count),
    PointsReason.firstToday => l10n.pointsFirstToday,
    PointsReason.record => l10n.pointsRecord,
    PointsReason.badge => l10n.pointsBadge(_badgeTitle(l10n, detail)),
    PointsReason.capped => l10n.pointsCapped,
    PointsReason.gift => l10n.pointsGift,
    PointsReason.purchase => l10n.pointsPurchase,
  };
}

String _badgeTitle(AppLocalizations l10n, String? id) {
  final badge = id == null ? null : badgeById(id);
  return badge == null ? (id ?? '') : badgeText(l10n, badge.titleKey);
}
