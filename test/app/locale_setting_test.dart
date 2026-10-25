import 'dart:ui';

import 'package:deskovky/core/settings/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

void main() {
  testWidgets('stored language wins over the system language, null follows the system', (tester) async {
    final db = testDatabase();
    addTearDown(db.close);
    await tester.runAsync(() => SettingsRepository(db).setLocale(const Locale('es')));

    await pumpApp(tester, size: const Size(360, 740), locale: const Locale('cs'), db: db);
    expect(find.text('Ajustes'), findsOneWidget);

    await tester.runAsync(() => SettingsRepository(db).setLocale(null));
    await tester.pumpAndSettle();
    expect(find.text('Nastavení'), findsOneWidget);
  });
}
