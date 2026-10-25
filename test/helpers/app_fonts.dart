import 'dart:io';

import 'package:deskovky/ui_kit/tokens/app_typography.dart';
import 'package:flutter/services.dart';

/// Registers the bundled fonts so widget tests measure real text widths
/// instead of the FlutterTest placeholder font. Call from `setUpAll`.
Future<void> loadAppFonts() async {
  for (final (family, file) in [
    (AppTypography.headingFamily, 'assets/fonts/Baloo2-Variable.ttf'),
    (AppTypography.bodyFamily, 'assets/fonts/Nunito-Variable.ttf'),
  ]) {
    final bytes = File(file).readAsBytesSync();
    await (FontLoader(family)..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
