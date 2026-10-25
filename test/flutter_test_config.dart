import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden images are generated on Windows and compared on Linux in CI;
/// antialiasing differs slightly, so up to 1 % of pixels may differ.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  if (goldenFileComparator is LocalFileComparator) {
    final base = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = _TolerantComparator(Uri.directory(base.toFilePath()).resolve('flutter_test_config.dart'));
  }
  await testMain();
}

class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const _maxDiff = 0.01;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (result.passed || result.diffPercent <= _maxDiff) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
