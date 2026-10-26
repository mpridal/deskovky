import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/licenses.dart';
import 'app/providers.dart';
import 'core/db/app_database.dart';

void main() {
  registerAppLicenses();
  runApp(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(AppDatabase.open())],
    child: const DeskovkyApp(),
  ));
}
