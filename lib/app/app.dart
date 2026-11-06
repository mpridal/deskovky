import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/locale_resolution.dart';
import '../core/multiplayer/room_info.dart';
import '../l10n/app_localizations.dart';
import '../ui_kit/tokens/app_theme.dart';
import 'audio_director.dart';
import 'multiplayer_providers.dart';
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
  StreamSubscription<String>? _links;

  @override
  void initState() {
    super.initState();
    // A room QR code read by the phone camera (deep link): while running and
    // the one that started the app.
    final links = ref.read(joinLinksProvider);
    _links = links.links.listen(_openLink);
    links.initialLink().then((link) {
      if (link != null && mounted) _openLink(link);
    });
    // Spec 4.1: the app starts at once; the update check runs afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(checkUpdatesAtStartProvider)) {
        ref.read(updateControllerProvider.notifier).checkAtStart();
      }
    });
  }

  /// Opens joining the room of a `deskovky://join` link; anything else is
  /// ignored. A newer link replaces a join screen that is already open.
  void _openLink(String link) {
    final ticket = JoinTicket.parse(link);
    if (ticket == null) return;
    if (_router.state.path == '/join') {
      _router.pushReplacement('/join', extra: ticket);
    } else {
      _router.push('/join', extra: ticket);
    }
  }

  @override
  void dispose() {
    _links?.cancel();
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
