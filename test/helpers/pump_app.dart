import 'package:deskovky/app/app.dart';
import 'package:deskovky/app/providers.dart';
import 'package:deskovky/app/update_controller.dart';
import 'package:deskovky/core/audio/audio_catalog.dart';
import 'package:deskovky/core/audio/audio_service.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/ai_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/audio/fake_audio_backend.dart';
import '../core/update/fake_update.dart';
import 'test_database.dart';

/// Pumps [DeskovkyApp] at [size] logical pixels in [locale]. Uses [db] when
/// given (e.g. to simulate a restart with the same data), otherwise a fresh
/// in-memory database. Sound goes to [audio] (a fresh fake when not given).
Future<void> pumpApp(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('cs'),
  double textScale = 1.0,
  AppDatabase? db,
  bool disableAnimations = false,
  FakeAudioBackend? audio,
  FakeReleaseSource? releases,
  FakeApkInstaller? installer,
  FakeUpdateDownloader? downloader,
  bool checkUpdates = false,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (disableAnimations) {
    // Endless animations (the HUD pulse) would keep pumpAndSettle busy forever.
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
  final database = db ?? testDatabase();
  if (db == null) addTearDown(database.close);
  await tester.pumpWidget(
    ProviderScope(
      // Robots think inline in tests: no isolates inside fake time.
      overrides: [
        databaseProvider.overrideWithValue(database),
        aiRunnerProvider.overrideWithValue(const InlineAiRunner()),
        // No network and no Android in tests: fake update pieces.
        checkUpdatesAtStartProvider.overrideWithValue(checkUpdates),
        releaseSourceProvider.overrideWithValue(releases ?? FakeReleaseSource()),
        apkInstallerProvider.overrideWithValue(installer ?? FakeApkInstaller()),
        updateDownloaderProvider.overrideWithValue(downloader ?? FakeUpdateDownloader()),
        audioServiceProvider.overrideWith((ref) {
          final service = AudioService(backend: audio ?? FakeAudioBackend(), catalog: AudioCatalog.standard);
          ref.onDispose(service.dispose);
          return service;
        }),
      ],
      child: const DeskovkyApp(),
    ),
  );
  await tester.pumpAndSettle();
}
