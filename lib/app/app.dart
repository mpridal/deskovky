import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/locale_resolution.dart';
import '../l10n/app_localizations.dart';
import '../ui_kit/tokens/app_theme.dart';
import 'audio_director.dart';
import 'providers.dart';
import 'update_controller.dart';
import 'router.dart';

class DeskovkyApp extends ConsumerStatefulWidget {
  const DeskovkyApp({super.key});

  @override
  ConsumerState<DeskovkyApp> createState() => _DeskovkyAppState();
}

class _DeskovkyAppState extends ConsumerState<DeskovkyApp> {
  late final GoRouter _router = buildRouter(startGame: ref.read(startGameProvider));

  @override
  void initState() {
    super.initState();
    // Spec 4.1: the app starts at once; the update check runs afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(checkUpdatesAtStartProvider)) {
        ref.read(updateControllerProvider.notifier).checkAtStart();
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      builder: (context, child) => AudioDirector(router: _router, child: child!),
      theme: buildAppTheme(),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // A language chosen in Settings wins; null lets the system decide.
      locale: ref.watch(localeSettingProvider).value,
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
