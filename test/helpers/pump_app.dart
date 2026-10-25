import 'package:deskovky/app/app.dart';
import 'package:deskovky/app/providers.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// Pumps [DeskovkyApp] at [size] logical pixels in [locale]. Uses [db] when
/// given (e.g. to simulate a restart with the same data), otherwise a fresh
/// in-memory database.
Future<void> pumpApp(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('cs'),
  double textScale = 1.0,
  AppDatabase? db,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final database = db ?? testDatabase();
  if (db == null) addTearDown(database.close);
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(database)],
    child: const DeskovkyApp(),
  ));
  await tester.pumpAndSettle();
}
