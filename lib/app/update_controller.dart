import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/update/apk_installer.dart';
import '../core/update/github_release_source.dart';
import '../core/update/release_info.dart';
import '../core/update/semver.dart';
import '../core/update/update_downloader.dart';
import '../core/update/update_service.dart';
import 'providers.dart';

/// GitHub in the app; tests override these three with fakes.
final releaseSourceProvider = Provider<ReleaseSource>((ref) => GitHubReleaseSource());
final apkInstallerProvider = Provider<ApkInstaller>((ref) => const PlatformApkInstaller());
final updateDownloaderProvider = Provider<UpdateDownloader>((ref) => UpdateDownloader.cache(client: http.Client()));

/// Check for updates after the first frame (spec 4.1). Widget tests switch
/// it off unless they test updates: a check still running when a test ends
/// would keep its database busy.
final checkUpdatesAtStartProvider = Provider<bool>((ref) => true);

/// versionName of the running app.
final appVersionProvider = FutureProvider<String>((ref) => ref.watch(apkInstallerProvider).appVersion());

/// Result of "Zkontrolovat aktualizace teď" in Settings.
enum ManualCheck { available, upToDate, failed }

@immutable
class UpdateState {
  const UpdateState({
    this.release,
    this.mandatory = false,
    this.dismissed = false,
    this.progress,
    this.failed = false,
    this.manual,
  });

  final ReleaseInfo? release;
  final bool mandatory;
  final bool dismissed;

  /// 0–1 while downloading.
  final double? progress;
  final bool failed;
  final ManualCheck? manual;

  /// The home card is shown.
  bool get offered => release != null && (!dismissed || mandatory);

  UpdateState copyWith({
    ReleaseInfo? release,
    bool? mandatory,
    bool? dismissed,
    double? Function()? progress,
    bool? failed,
    ManualCheck? Function()? manual,
  }) => UpdateState(
    release: release ?? this.release,
    mandatory: mandatory ?? this.mandatory,
    dismissed: dismissed ?? this.dismissed,
    progress: progress == null ? this.progress : progress(),
    failed: failed ?? this.failed,
    manual: manual == null ? this.manual : manual(),
  );
}

/// The self-update flow (spec 4): check at start and on request, download,
/// verify, hand over to the installer. Never blocks the app.
class UpdateController extends Notifier<UpdateState> {
  @override
  UpdateState build() => const UpdateState();

  Future<UpdateCheck> _check({required bool force}) async {
    final installer = ref.read(apkInstallerProvider);
    final current = Semver.parse(await installer.appVersion()) ?? const Semver(0, 0, 0);
    final service = UpdateService(
      source: ref.read(releaseSourceProvider),
      settings: ref.read(settingsRepositoryProvider),
      currentVersion: current,
    );
    final result = await service.check(force: force);
    if (result case UpdateAvailable(:final release, :final mandatory)) {
      state = state.copyWith(release: release, mandatory: mandatory, dismissed: false, failed: false);
    }
    return result;
  }

  /// Quietly at app start; at most every 6 hours.
  Future<void> checkAtStart() async {
    await _check(force: false);
  }

  Future<void> checkNow() async {
    final result = await _check(force: true);
    state = state.copyWith(
      manual: () => switch (result) {
        UpdateAvailable() => ManualCheck.available,
        UpToDate() => ManualCheck.upToDate,
        _ => ManualCheck.failed,
      },
    );
  }

  void dismiss() => state = state.copyWith(dismissed: true);

  /// Downloads, verifies and installs; false if Android does not allow
  /// installing yet (the UI explains and opens the settings).
  Future<bool> update() async {
    final release = state.release;
    if (release == null || state.progress != null) return true;
    final installer = ref.read(apkInstallerProvider);
    if (!await installer.canInstall()) return false;
    state = state.copyWith(progress: () => 0, failed: false);
    try {
      final File apk = await ref
          .read(updateDownloaderProvider)
          .download(release, onProgress: (p) => state = state.copyWith(progress: () => p));
      await installer.install(apk.path);
      state = state.copyWith(progress: () => null);
    } catch (e) {
      debugPrint('UpdateController: update failed: $e');
      state = state.copyWith(progress: () => null, failed: true);
    }
    return true;
  }
}

final updateControllerProvider = NotifierProvider<UpdateController, UpdateState>(UpdateController.new);
