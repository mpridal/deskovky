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
  test('the report form is a new GitHub issue with the app, system and device filled in', () {
    final uri = bugReportUri(version: '0.13.0', device: 'Galaxy Tab A7 Lite', os: 'Android 14 (SDK 34)', language: 'cs');
    expect(uri.host, 'github.com');
    expect(uri.path, '/mpridal/deskovky/issues/new');
    final body = uri.queryParameters['body']!;
    expect(body, contains('0.13.0'));
    expect(body, contains('Galaxy Tab A7 Lite'));
    expect(body, contains('Android 14'));
    expect(body, contains('cs'));
    expect(uri.queryParameters['labels'], 'bug');
    expect(uri.queryParameters['title'], isNotEmpty);
  });

  testWidgets('the parents corner opens the bug report form in the browser', (tester) async {
    final opened = <Uri>[];
    await _openParents(tester, opened);
    final button = find.byKey(const ValueKey('parentsReportBug'));
    await tester.scrollUntilVisible(button, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(opened.single.path, '/mpridal/deskovky/issues/new');
    expect(opened.single.queryParameters['body'], contains('Galaxy Tab A7 Lite'));
  });

  testWidgets('without a browser it says so and shows the address', (tester) async {
    final opened = <Uri>[];
    await _openParents(tester, opened, works: false);
    final button = find.byKey(const ValueKey('parentsReportBug'));
    await tester.scrollUntilVisible(button, 200, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.textContaining('github.com/mpridal/deskovky/issues'), findsOneWidget);
  });
}
