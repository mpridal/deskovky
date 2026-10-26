import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/licenses.dart';
import 'app/providers.dart';
import 'app/stats_service.dart';
import 'core/db/app_database.dart';
import 'core/shop/shop_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();
  final rewards = await StatsService.loadRewards(rootBundle);
  final shop = ShopCatalog.parse(await rootBundle.loadString(ShopCatalog.asset).catchError((Object _) => '[]'));
  runApp(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(AppDatabase.open()),
      rewardsConfigProvider.overrideWithValue(rewards),
      shopCatalogProvider.overrideWithValue(shop),
    ],
    child: const DeskovkyApp(),
  ));
}
