import 'package:flutter/widgets.dart';

const List<Locale> supportedAppLocales = [Locale('cs'), Locale('en'), Locale('es')];

/// Picks the app language from the system's preferred locales (spec 1):
/// Czech and Spanish by the first system language, English otherwise.
Locale resolveAppLocale(List<Locale>? systemLocales) {
  final first = (systemLocales == null || systemLocales.isEmpty) ? null : systemLocales.first;
  return switch (first?.languageCode) {
    'cs' => const Locale('cs'),
    'es' => const Locale('es'),
    _ => const Locale('en'),
  };
}
