import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/audio/credits.dart';

bool _registered = false;

/// Adds the bundled fonts (OFL) and sounds (CREDITS.json) to Flutter's
/// licence page next to the libraries. Safe to call more than once.
void registerAppLicenses() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    for (final (name, file) in [('Baloo 2', 'OFL-Baloo2.txt'), ('Nunito', 'OFL-Nunito.txt')]) {
      yield LicenseEntryWithLineBreaks([name], await rootBundle.loadString('assets/fonts/$file'));
    }
    for (final credit in await loadCredits(rootBundle)) {
      yield LicenseEntryWithLineBreaks([credit.title], '${credit.attribution}\n${credit.license}\n${credit.sourceUrl}');
    }
  });
}
