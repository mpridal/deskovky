import 'package:flutter/widgets.dart';

const List<Locale> supportedAppLocales = [Locale('cs'), Locale('en'), Locale('es')];

/// Each language's name in itself (never translated: a person finds their
/// own language by its own name).
const _languageNames = {'cs': 'Čeština', 'en': 'English', 'es': 'Español'};

String appLanguageName(String code) => _languageNames[code] ?? code;

/// Picks the app language from the system's preferred locales (spec 1): the
/// first system language when the app has it, English otherwise.
Locale resolveAppLocale(List<Locale>? systemLocales) {
  final first = (systemLocales == null || systemLocales.isEmpty) ? null : systemLocales.first;
  return supportedAppLocales.where((l) => l.languageCode == first?.languageCode).firstOrNull ?? const Locale('en');
}
