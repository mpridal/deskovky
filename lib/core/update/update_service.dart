import 'dart:async';

import 'package:flutter/foundation.dart';

import '../settings/settings_repository.dart';
import 'release_info.dart';
import 'semver.dart';

/// Where the newest release comes from (GitHub API in the app, fakes in tests).
abstract class ReleaseSource {
  Future<ReleaseInfo?> latest();
}

sealed class UpdateCheck {
  const UpdateCheck();
}

/// Not checked: switched off or checked less than 6 hours ago.
class NotChecked extends UpdateCheck {
  const NotChecked();
}

class UpToDate extends UpdateCheck {
  const UpToDate();
}

/// No network, rate limit, timeout or a broken release: silently ignored.
class CheckFailed extends UpdateCheck {
  const CheckFailed(this.reason);

  final String reason;
}

class UpdateAvailable extends UpdateCheck {
  const UpdateAvailable(this.release, {required this.mandatory});

  final ReleaseInfo release;

  /// Our version is below the release's minimum supported one (spec 4.7).
  final bool mandatory;
}

/// Looks for a newer release (spec 4): never blocks, at most once in 6 hours,
/// 4 s timeout, every failure is silent.
class UpdateService {
  UpdateService({
    required this.source,
    required this.settings,
    required this.currentVersion,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const interval = Duration(hours: 6);
  static const defaultTimeout = Duration(seconds: 4);

  final ReleaseSource source;
  final SettingsRepository settings;
  final Semver currentVersion;
  final DateTime Function() _now;

  /// [force] is "Zkontrolovat aktualizace teď": ignores the switch and the
  /// 6-hour limit.
  Future<UpdateCheck> check({bool force = false, Duration timeout = defaultTimeout}) async {
    try {
      if (!force) {
        if (!await settings.watchAutoCheckUpdates().first) return const NotChecked();
        final last = await settings.lastUpdateCheck();
        if (last != null && _now().difference(last) < interval) return const NotChecked();
      }
      final release = await source.latest().timeout(timeout);
      if (release == null) return const CheckFailed('no usable release');
      if (!(release.version > currentVersion)) {
        // Only "nothing new" pauses checking for 6 hours: a known update is
        // offered again at the next start, and an offline start retries.
        await settings.setLastUpdateCheck(_now());
        return const UpToDate();
      }
      return UpdateAvailable(release, mandatory: release.minSupportedVersion > currentVersion);
    } catch (e) {
      debugPrint('UpdateService: check failed: $e');
      return CheckFailed('$e');
    }
  }
}
