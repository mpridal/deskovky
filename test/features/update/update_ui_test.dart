import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/update/fake_update.dart';
import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    // Checks and downloads run on real database I/O, a step at a time.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  Future<void> start(
    WidgetTester tester, {
    FakeReleaseSource? releases,
    FakeApkInstaller? installer,
    FakeUpdateDownloader? downloader,
    Size size = const Size(412, 915),
    Locale locale = const Locale('cs'),
    double textScale = 1,
  }) async {
    await pumpApp(
      tester,
      size: size,
      db: db,
      locale: locale,
      textScale: textScale,
      releases: releases,
      installer: installer,
      downloader: downloader,
      checkUpdates: true,
    );
    await settle(tester);
  }

  testWidgets('a newer release shows a gentle card at start; "Později" hides it', (tester) async {
    await start(tester, releases: FakeReleaseSource(fakeRelease('0.1.1')));
    expect(find.text('Je tu nová verze 0.1.1'), findsOneWidget);
    expect(find.text('Nové piškvorky!'), findsOneWidget);
    await tester.tap(find.text('Později'));
    await tester.pumpAndSettle();
    expect(find.text('Je tu nová verze 0.1.1'), findsNothing);
  });

  testWidgets('no card when nothing newer is published', (tester) async {
    await start(tester, releases: FakeReleaseSource(fakeRelease('0.1.0')));
    expect(find.byKey(const ValueKey('updateCard')), findsNothing);
  });

  testWidgets('"Aktualizovat" downloads, verifies and starts the installer', (tester) async {
    final installer = FakeApkInstaller();
    final downloader = FakeUpdateDownloader();
    await start(tester, releases: FakeReleaseSource(fakeRelease('0.1.1')), installer: installer, downloader: downloader);
    await tester.tap(find.text('Aktualizovat'));
    await settle(tester);
    expect(downloader.downloads, 1);
    expect(installer.installed.single, endsWith('deskovky-0.1.1.apk'));
  });

  testWidgets('without the install permission a child-friendly explanation leads to the settings', (tester) async {
    final installer = FakeApkInstaller(allowed: false);
    await start(
      tester,
      releases: FakeReleaseSource(fakeRelease('0.1.1')),
      installer: installer,
      downloader: FakeUpdateDownloader(),
    );
    await tester.tap(find.text('Aktualizovat'));
    await settle(tester);
    expect(find.text('Ještě jedno povolení'), findsOneWidget);
    await tester.tap(find.text('Otevřít nastavení'));
    await tester.pumpAndSettle();
    expect(installer.settingsOpened, 1);
    expect(installer.installed, isEmpty);
  });

  testWidgets('a failed download says so and installs nothing', (tester) async {
    final installer = FakeApkInstaller();
    await start(
      tester,
      releases: FakeReleaseSource(fakeRelease('0.1.1')),
      installer: installer,
      downloader: FakeUpdateDownloader(fail: true),
    );
    await tester.tap(find.text('Aktualizovat'));
    await settle(tester);
    expect(find.text('Stažení se nepovedlo. Zkus to později.'), findsOneWidget);
    expect(installer.installed, isEmpty);
  });

  testWidgets('a mandatory update cannot be postponed', (tester) async {
    await start(tester, releases: FakeReleaseSource(fakeRelease('0.3.0', minSupported: '0.2.0')));
    expect(find.text('Tahle verze už je moc stará – aktualizuj prosím.'), findsOneWidget);
    expect(find.text('Později'), findsNothing);
  });

  testWidgets('settings show the version, check now and the auto-check switch', (tester) async {
    final releases = FakeReleaseSource();
    await start(tester, releases: releases);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    final checkNow = find.text('Zkontrolovat aktualizace teď');
    await tester.scrollUntilVisible(checkNow, 200);
    await tester.ensureVisible(checkNow);
    await tester.pumpAndSettle();
    expect(find.text('Verze 0.1.0'), findsOneWidget);
    await tester.tap(checkNow);
    await settle(tester);
    expect(find.text('Kontrola se nepovedla – je zařízení připojené k internetu?'), findsOneWidget);

    releases.release = fakeRelease('0.1.0');
    await tester.tap(checkNow);
    await settle(tester);
    expect(find.text('Máš nejnovější verzi.'), findsOneWidget);

    final toggle = find.byKey(const ValueKey('autoUpdate'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => SettingsRepository(db).watchAutoCheckUpdates().first), isFalse);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('the update card fits 360 dp at 130 % in $code', (tester) async {
        await start(
          tester,
          releases: FakeReleaseSource(fakeRelease('0.1.1', minSupported: '0.1.0')),
          size: const Size(360, 740),
          locale: Locale(code),
          textScale: 1.3,
        );
        expect(tester.takeException(), isNull);
        expect(find.byKey(const ValueKey('updateCard')), findsOneWidget);
      });
    }
  });
}
