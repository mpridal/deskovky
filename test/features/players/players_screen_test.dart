import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/avatar_editor/avatar_editor_screen.dart';
import 'package:deskovky/ui_kit/avatar/avatar_view.dart';
import 'package:deskovky/ui_kit/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _openPlayers(WidgetTester tester, AppDatabase db) async {
  await pumpApp(tester, size: const Size(360, 740), db: db);
  await tester.tap(find.text('Hráči').last);
  await tester.pumpAndSettle();
}

Future<void> _createViaEditor(WidgetTester tester, String name, {String? hair}) async {
  await tester.tap(find.text('Nový hráč'));
  await tester.pumpAndSettle();
  expect(find.byType(AvatarEditorScreen), findsOneWidget);
  await tester.enterText(find.byType(TextField), name);
  if (hair != null) {
    await tester.tap(find.text('Vlasy'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.bySemanticsLabel(hair));
    await tester.tap(find.bySemanticsLabel(hair));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Uložit'));
  await tester.pumpAndSettle();
}

Finder _row(String name) => find.ancestor(of: find.text(name), matching: find.byKey(const ValueKey('playerTile'))).first;

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('empty state invites to create the first player', (tester) async {
    await _openPlayers(tester, db);
    expect(find.text('Zatím tu nikdo není. Vytvoř prvního hráče!'), findsOneWidget);
    expect(find.text('Nový hráč'), findsOneWidget);
  });

  testWidgets('creating a player saves name and avatar and makes them active', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Tereza', hair: 'copánky');
    expect(find.byType(AvatarEditorScreen), findsNothing);
    expect(find.descendant(of: _row('Tereza'), matching: find.text('Hraje teď')), findsOneWidget);
    final saved = await tester.runAsync(() => PlayerRepository(db).all());
    expect(saved!.single.avatar.hair, HairStyle.braids);
  });

  testWidgets('tapping a row makes that player active', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Tereza');
    await _createViaEditor(tester, 'Kuba');
    await tester.tap(find.text('Kuba'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Teď hraje Kuba'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.descendant(of: _row('Kuba'), matching: find.text('Hraje teď')), findsOneWidget);
    expect(find.descendant(of: _row('Tereza'), matching: find.text('Hraje teď')), findsNothing);
  });

  testWidgets('a taken name keeps the editor open with an error', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Tereza');
    await _createViaEditor(tester, 'tereza');
    expect(find.byType(AvatarEditorScreen), findsOneWidget);
    expect(find.text('Toto jméno už má jiný hráč.'), findsOneWidget);
  });

  testWidgets('an empty name is refused', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, '   ');
    expect(find.text('Napiš jméno.'), findsOneWidget);
  });

  testWidgets('editing renames the player', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Kuba');
    await tester.tap(find.bySemanticsLabel('Upravit Kuba'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Kuba'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Jakub');
    await tester.tap(find.text('Uložit'));
    await tester.pumpAndSettle();
    expect(find.text('Jakub'), findsOneWidget);
    expect(find.text('Kuba'), findsNothing);
  });

  testWidgets('delete asks first; cancel keeps, confirm removes', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Kuba');
    await tester.tap(find.bySemanticsLabel('Smazat Kuba'));
    await tester.pumpAndSettle();
    expect(find.text('Smazat hráče Kuba?'), findsOneWidget);
    await tester.tap(find.text('Zrušit'));
    await tester.pumpAndSettle();
    expect(find.text('Kuba'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Smazat Kuba'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Smazat'));
    await tester.pumpAndSettle();
    expect(find.text('Kuba'), findsNothing);
  });

  testWidgets('with 8 players the New button is disabled and explains why', (tester) async {
    await tester.runAsync(() async {
      for (var i = 1; i <= 8; i++) {
        await PlayerRepository(db).create(name: 'Hráč $i', avatar: AvatarSpec.defaults);
      }
    });
    await _openPlayers(tester, db);
    await tester.scrollUntilVisible(find.text('Nový hráč'), 200);
    final button = tester.widget<PrimaryButton>(find.widgetWithText(PrimaryButton, 'Nový hráč'));
    expect(button.onPressed, isNull);
    expect(find.text('Na tomto zařízení může být nejvýš 8 hráčů.'), findsOneWidget);
  });

  testWidgets('players survive a restart', (tester) async {
    await _openPlayers(tester, db);
    await _createViaEditor(tester, 'Babi');
    await tester.pumpWidget(const SizedBox());
    await _openPlayers(tester, db);
    expect(find.text('Babi'), findsOneWidget);
    expect(find.byType(AvatarView), findsWidgets);
  });
}
