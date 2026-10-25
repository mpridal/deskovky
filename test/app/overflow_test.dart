import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

const _sizes = [Size(360, 740), Size(412, 915), Size(800, 1280), Size(1280, 800)];
const _locales = [Locale('cs'), Locale('en'), Locale('es')];
const _scales = [1.0, 1.3];
const _tabIcons = [Icons.people_outline, Icons.emoji_events_outlined, Icons.settings_outlined, Icons.casino_outlined];

void main() {
  for (final locale in _locales) {
    for (final size in _sizes) {
      for (final scale in _scales) {
        testWidgets('no overflow: $locale ${size.width.toInt()}x${size.height.toInt()} text x$scale', (tester) async {
          await pumpApp(tester, size: size, locale: locale, textScale: scale);
          expect(tester.takeException(), isNull);
          for (final icon in _tabIcons) {
            await tester.tap(find.byIcon(icon));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: 'after tapping $icon');
          }
        });
      }
    }
  }
}
