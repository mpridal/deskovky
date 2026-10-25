import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/features/avatar_editor/avatar_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_database.dart';

Future<void> _addPlayers(WidgetTester tester, AppDatabase db, List<String> names) => tester.runAsync(() async {
      for (final name in names) {
        await PlayerRepository(db).create(name: name, avatar: AvatarSpec.defaults);
      }
    });

void main() {
  late AppDatabase db;
  setUp(() => db = testDatabase());
  tearDown(() => db.close());

  testWidgets('without players the home screen offers to create one', (tester) async {
    await pumpApp(tester, size: const Size(360, 740), db: db);
    await tester.tap(find.text('Vytvořit hráče'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarEditorScreen), findsOneWidget);
  });

  testWidgets('shows the active player and switches via the sheet, remembered after restart', (tester) async {
    await _addPlayers(tester, db, ['Tereza', 'Kuba']);
    await pumpApp(tester, size: const Size(360, 740), db: db);
    expect(find.text('Ahoj,'), findsOneWidget);
    expect(find.text('Tereza'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^Přepnout hráče')));
    await tester.pumpAndSettle();
    expect(find.text('Kuba'), findsOneWidget);
    await tester.tap(find.text('Kuba'));
    await tester.pumpAndSettle();
    expect(find.text('Kuba'), findsOneWidget);
    expect(find.text('Tereza'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, size: const Size(360, 740), db: db);
    expect(find.text('Kuba'), findsOneWidget);
  });

  testWidgets('switcher offers a new player while there is room', (tester) async {
    await _addPlayers(tester, db, ['Tereza']);
    await pumpApp(tester, size: const Size(360, 740), db: db);
    await tester.tap(find.bySemanticsLabel(RegExp('^Přepnout hráče')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nový hráč'));
    await tester.pumpAndSettle();
    expect(find.byType(AvatarEditorScreen), findsOneWidget);
  });

  testWidgets('tablet right panel lists all players', (tester) async {
    await _addPlayers(tester, db, ['Tereza', 'Kuba', 'Babi']);
    await pumpApp(tester, size: const Size(1280, 800), db: db);
    final panel = find.byKey(const Key('rightPanel'));
    for (final name in ['Tereza', 'Kuba', 'Babi']) {
      expect(find.descendant(of: panel, matching: find.text(name)), findsOneWidget, reason: name);
    }
  });

  group('long names', () {
    setUpAll(loadAppFonts);

    for (final locale in const [Locale('cs'), Locale('es')]) {
      testWidgets('a 16-character name does not break the bar ($locale, 360 dp, 130 %)', (tester) async {
        await _addPlayers(tester, db, ['Maximiliánek123']);
        await pumpApp(tester, size: const Size(360, 740), locale: locale, textScale: 1.3, db: db);
        expect(tester.takeException(), isNull);
        final hello = find.textContaining(RegExp(r'^(Ahoj|¡Hola),$'));
        final paragraph = tester.renderObject<RenderParagraph>(hello);
        expect(paragraph.getMaxIntrinsicWidth(double.infinity) <= paragraph.size.width + 0.5, isTrue);
      });
    }
  });
}
