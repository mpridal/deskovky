import 'dart:convert';

import 'package:deskovky/ui_kit/tokens/app_typography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Baloo 2 and Nunito are bundled as app fonts', () async {
    final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
    final families = manifest.map((e) => (e as Map<String, dynamic>)['family']).toSet();
    expect(families, containsAll([AppTypography.headingFamily, AppTypography.bodyFamily]));
  });
}
