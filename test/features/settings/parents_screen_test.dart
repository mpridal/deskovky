import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/features/settings/parents_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _openGate(WidgetTester tester, AppDatabase db, {Locale locale = const Locale('cs'), double textScale = 1}) async {
  await pumpApp(tester, size: const Size(360, 740), db: db, locale: locale, textScale: textScale);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  final link = find.byKey(const ValueKey('parentsLink'));
  await tester.scrollUntilVisible(link, 200);
  await tester.ensureVisible(link);
  await tester.pumpAndSettle();
  await tester.tap(link);
  await tester.pumpAndSettle();
}

/// Reads "Kolik je 7 × 8?" from the gate and answers.
Future<void> _answer(WidgetTester tester, {bool right = true}) async {
  final question = tester.widget<Text>(find.byKey(const ValueKey('gateQuestion'))).data!;
  final n = RegExp(r'\d+').allMatches(question).map((m) => int.parse(m[0]!)).toList();
  await tester.enterText(find.byType(TextField), '${n[0] * n[1] + (right ? 0 : 1)}');
  await tester.tap(find.byKey(const ValueKey('gateOpen')));
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('a wrong answer keeps children out', (tester) async {
    await _openGate(tester, db);
    await _answer(tester, right: false);
    expect(find.text('To není správně.'), findsOneWidget);
    expect(find.byType(ParentsScreen), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty, reason: 'answer cleared');
  });

  testWidgets('a wrong answer asks a new question', (tester) async {
    await _openGate(tester, db);
    final before = tester.widget<Text>(find.byKey(const ValueKey('gateQuestion'))).data;
    await _answer(tester, right: false);
    expect(tester.widget<Text>(find.byKey(const ValueKey('gateQuestion'))).data, isNot(before));
  });

  testWidgets('a parent gives a player 50 points; it is in the ledger as a gift', (tester) async {
    final kuba = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)))!.id;
    await _openGate(tester, db);
    await _answer(tester);
    expect(find.byType(ParentsScreen), findsOneWidget);
    await tester.tap(find.byKey(ValueKey('gift_${kuba}_50')));
    await tester.pumpAndSettle();
    expect(find.text('Darovat 50 ● hráči Kuba?'), findsOneWidget);
    await tester.tap(find.text('Darovat'));
    await tester.pumpAndSettle();
    final history = await tester.runAsync(() => PointsRepository(db).history(kuba));
    expect([for (final e in history!) (e.reason, e.amount)], [(PointsReason.gift, 50)]);
    expect(find.text('Darováno: 50 ● – Kuba'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation gives nothing', (tester) async {
    final kuba = (await tester.runAsync(() => PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)))!.id;
    await _openGate(tester, db);
    await _answer(tester);
    await tester.tap(find.byKey(ValueKey('gift_${kuba}_100')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zrušit'));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(() => PointsRepository(db).balance(kuba)), 0);
  });

  group('fit', () {
    setUpAll(loadAppFonts);
    for (final code in ['cs', 'en', 'es']) {
      testWidgets('parents corner fits 360 dp at 130 % in $code', (tester) async {
        await tester.runAsync(() => PlayerRepository(db).create(name: 'Maximiliánek123', avatar: AvatarSpec.defaults));
        await _openGate(tester, db, locale: Locale(code), textScale: 1.3);
        expect(tester.takeException(), isNull);
        await _answer(tester);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
