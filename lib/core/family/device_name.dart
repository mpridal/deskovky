import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The name the person gave the device in its settings ("Galaxy Tab A7
/// Lite", "Kubův tablet"), else its maker and model; null off Android.
Future<String?> systemDeviceName() async {
  if (!Platform.isAndroid) return null;
  try {
    final name = await const MethodChannel('deskovky/device').invokeMethod<String>('name');
    return name == null || name.trim().isEmpty ? null : name.trim();
  } on Object catch (e) {
    debugPrint('systemDeviceName: $e');
    return null;
  }
}
