import 'dart:io';
import 'dart:typed_data';

import 'package:deskovky/ui_kit/brand/app_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';
const _densities = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

/// Width and height from a PNG's IHDR chunk.
(int, int) _pngSize(String path) {
  final bytes = ByteData.sublistView(File(path).readAsBytesSync());
  return (bytes.getUint32(16), bytes.getUint32(20));
}

void main() {
  testWidgets('the icon: family around a table with two dice on green', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: RepaintBoundary(
          child: SizedBox.square(dimension: 192, child: CustomPaint(painter: AppIconPainter())),
        ),
      ),
    );
    await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('goldens/app_icon.png'));
  });

  test('Android has the legacy icon and the adaptive foreground at every density', () {
    for (final MapEntry(key: name, value: scale) in _densities.entries) {
      expect(_pngSize('$_res/mipmap-$name/ic_launcher.png'), ((48 * scale).round(), (48 * scale).round()), reason: name);
      expect(
        _pngSize('$_res/mipmap-$name/ic_launcher_foreground.png'),
        ((108 * scale).round(), (108 * scale).round()),
        reason: name,
      );
    }
  });

  test('the adaptive icon keeps the circle: transparent background, drawing in front', () {
    final xml = File('$_res/mipmap-anydpi-v26/ic_launcher.xml').readAsStringSync();
    expect(xml, contains('<adaptive-icon'));
    expect(xml, contains('@android:color/transparent'));
    expect(xml, contains('@mipmap/ic_launcher_foreground'));
  });
}
