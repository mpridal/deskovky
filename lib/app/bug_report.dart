import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A Google form: anyone can send it without an account (a GitHub issue
/// needed signing in, which put parents off). The parent writes what
/// happened; the app fills in what helps to find the bug.
@immutable
class BugReportForm {
  const BugReportForm({
    required this.url,
    required this.shortLink,
    required this.versionField,
    required this.deviceField,
    required this.osField,
    required this.languageField,
  });

  /// The form's `…/viewform` address.
  final String url;

  /// Shown when no browser opens, to type in elsewhere.
  final String shortLink;

  /// The `entry.N` names of the prefilled questions (from the form's
  /// "Get pre-filled link").
  final String versionField, deviceField, osField, languageField;
}

// TODO(milos): the real form – its address and entry ids come from its
// "Get pre-filled link".
const bugReportForm = BugReportForm(
  url: 'https://docs.google.com/forms/d/e/FORM_ID/viewform',
  shortLink: 'https://forms.gle/FORM_ID',
  versionField: 'entry.1000001',
  deviceField: 'entry.1000002',
  osField: 'entry.1000003',
  languageField: 'entry.1000004',
);

/// The bug report form with the app, system, device and language filled in.
/// Nothing is sent until the parent submits it.
Uri bugReportUri({required String version, required String? device, required String? os, required String language}) =>
    Uri.parse(bugReportForm.url).replace(
      queryParameters: {
        'usp': 'pp_url',
        bugReportForm.versionField: version,
        bugReportForm.deviceField: device ?? '?',
        bugReportForm.osField: os ?? '?',
        bugReportForm.languageField: language,
      },
    );

/// Opens [uri] in the browser; false when it could not.
typedef BrowserOpener = Future<bool> Function(Uri uri);

final browserOpenerProvider = Provider<BrowserOpener>((ref) => openInBrowser);

/// The device's model and system for the report ("Samsung SM-T220",
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
    // The model, not the device's own name: the report is public (review R-011).
    final model = await _device.invokeMethod<String>('model');
    final os = await _device.invokeMethod<String>('os');
    return (device: model, os: os);
  } on Object catch (e) {
    debugPrint('deviceInfo: $e');
    return (device: null, os: null);
  }
}
