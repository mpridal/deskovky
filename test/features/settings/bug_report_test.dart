import 'package:deskovky/app/bug_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

Future<void> _openParents(WidgetTester tester, List<Uri> opened, {bool works = true}) async {
  await pumpApp(
    tester,
    size: const Size(412, 915),
    overrides: [
      browserOpenerProvider.overrideWithValue((uri) async {
        opened.add(uri);
        return works;
      }),
      deviceInfoProvider.overrideWithValue(() async => (device: 'Galaxy Tab A7 Lite', os: 'Android 14 (SDK 34)')),
    ],
  );
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  final link = find.byKey(const ValueKey('parentsLink'));
  await tester.scrollUntilVisible(link, 200);
  await tester.ensureVisible(link);
  await tester.pumpAndSettle();
  await tester.tap(link);
  await tester.pumpAndSettle();
  final question = tester.widget<Text>(find.byKey(const ValueKey('gateQuestion'))).data!;
  final n = RegExp(r'\d+').allMatches(question).map((m) => int.parse(m[0]!)).toList();
  await tester.enterText(find.byType(TextField), '${n[0] * n[1]}');
  await tester.tap(find.byKey(const ValueKey('gateOpen')));
  await tester.pumpAndSettle();
}

void main() {
  test('the report form is a Google form (no sign-in) with the app, system and device filled in', () {
    final uri = bugReportUri(version: '0.13.0', device: 'Galaxy Tab A7 Lite', os: 'Android 14 (SDK 34)', language: 'cs');
    expect(uri.host, 'docs.google.com');
    expect(uri.path, endsWith('/viewform'));
    expect(uri.queryParameters['usp'], 'pp_url');
    final q = uri.queryParameters;
    expect(q[bugReportForm.versionField], '0.13.0');
    expect(q[bugReportForm.deviceField], 'Galaxy Tab A7 Lite');
    expect(q[bugReportForm.osField], 'Android 14 (SDK 34)');
    expect(q[bugReportForm.languageField], 'cs');
    expect(uri.toString(), isNot(contains('github')));
  });

  test('an unknown device or system is a question mark, not "null"', () {
    final q = bugReportUri(version: '0.13.0', device: null, os: null, language: 'en').queryParameters;
    expect(q[bugReportForm.deviceField], '?');
    expect(q[bugReportForm.osField], '?');
  });

  testWidgets('the parents corner opens the bug report form in the browser', (tester) async {
    final opened = <Uri>[];
    await _openParents(tester, opened);
    final button = find.byKey(const ValueKey('parentsReportBug'));
    await tester.scrollUntilVisible(button, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(opened.single.host, 'docs.google.com');
    expect(opened.single.queryParameters[bugReportForm.deviceField], 'Galaxy Tab A7 Lite');
  });

  testWidgets('without a browser it says so and shows the address', (tester) async {
    final opened = <Uri>[];
    await _openParents(tester, opened, works: false);
    final button = find.byKey(const ValueKey('parentsReportBug'));
    await tester.scrollUntilVisible(button, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text(bugReportForm.shortLink.replaceFirst('https://', '')), findsOneWidget);
  });
}
