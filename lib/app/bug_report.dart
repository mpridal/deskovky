import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where bugs are reported: a new issue in the public repository.
const bugReportPage = 'https://github.com/mpridal/deskovky/issues/new';

/// A new GitHub issue with what helps to find the bug filled in; the parent
/// writes what happened. Nothing is sent until they submit it on GitHub.
Uri bugReportUri({required String version, required String? device, required String? os, required String language}) =>
    Uri.parse(bugReportPage).replace(
      queryParameters: {
        'title': 'Chyba: ',
        'labels': 'bug',
        'body': [
          '**Co se stalo / What happened**',
          '',
          '',
          '**Jak to zopakovat / Steps to reproduce**',
          '1. ',
          '',
          '---',
          'Deskovky $version',
          'Systém / OS: ${os ?? '?'}',
          'Zařízení / Device: ${device ?? '?'}',
          'Jazyk / Language: $language',
        ].join('\n'),
      },
    );

/// Opens [uri] in the browser; false when it could not.
typedef BrowserOpener = Future<bool> Function(Uri uri);

final browserOpenerProvider = Provider<BrowserOpener>((ref) => openInBrowser);

/// The device's name and system for the report ("Galaxy Tab A7 Lite",
/// "Android 14 (SDK 34)"); nulls off Android.
typedef DeviceInfo = Future<({String? device, String? os})> Function();

final deviceInfoProvider = Provider<DeviceInfo>((ref) => _deviceInfo);

const _device = MethodChannel('deskovky/device');

Future<bool> openInBrowser(Uri uri) async {
  if (!Platform.isAndroid) return false;
  try {
    return await _device.invokeMethod<bool>('open', uri.toString()) ?? false;
  } on Object catch (e) {
    debugPrint('openInBrowser: $e');
    return false;
  }
}

Future<({String? device, String? os})> _deviceInfo() async {
  if (!Platform.isAndroid) return (device: null, os: null);
  try {
    final name = await _device.invokeMethod<String>('name');
    final os = await _device.invokeMethod<String>('os');
    return (device: name, os: os);
  } on Object catch (e) {
    debugPrint('deviceInfo: $e');
    return (device: null, os: null);
  }
}
