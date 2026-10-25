import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/locale_resolution.dart';
import '../l10n/app_localizations.dart';
import '../ui_kit/tokens/app_theme.dart';
import 'router.dart';

class DeskovkyApp extends StatefulWidget {
  const DeskovkyApp({super.key});

  @override
  State<DeskovkyApp> createState() => _DeskovkyAppState();
}

class _DeskovkyAppState extends State<DeskovkyApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: buildAppTheme(),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (locales, _) => resolveAppLocale(locales),
    );
  }
}
