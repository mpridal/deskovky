import 'package:flutter/services.dart';

/// The Android side of the self-update (MainActivity, channel
/// `deskovky/update`).
abstract class ApkInstaller {
  /// versionName of the installed app, e.g. `0.1.0`.
  Future<String> appVersion();

  /// Android allows this app to install packages ("unknown apps").
  Future<bool> canInstall();

  /// Opens the system screen where the parent allows it.
  Future<void> openInstallSettings();

  /// Starts the system installer for a verified APK in `cache/updates/`.
  Future<void> install(String path);

  /// Keeps the screen from locking while the update downloads: a locked
  /// phone sends the app to the background, where mobile data often stops.
  Future<void> keepScreenOn(bool on);
}

class PlatformApkInstaller implements ApkInstaller {
  const PlatformApkInstaller();

  static const _channel = MethodChannel('deskovky/update');

  @override
  Future<String> appVersion() async => await _channel.invokeMethod<String>('version') ?? '0.0.0';

  @override
  Future<bool> canInstall() async => await _channel.invokeMethod<bool>('canInstall') ?? false;

  @override
  Future<void> openInstallSettings() => _channel.invokeMethod<void>('openInstallSettings');

  @override
  Future<void> install(String path) => _channel.invokeMethod<void>('install', {'path': path});

  @override
  Future<void> keepScreenOn(bool on) => _channel.invokeMethod<void>('keepScreenOn', {'on': on});
}
