import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/licenses.dart';
import 'app/providers.dart';
import 'app/stats_service.dart';
import 'core/db/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();
  final rewards = await StatsService.loadRewards(rootBundle);
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(AppDatabase.open()),
      rewardsConfigProvider.overrideWithValue(rewards),
    ],
    child: const DeskovkyApp(),
  ));
}
