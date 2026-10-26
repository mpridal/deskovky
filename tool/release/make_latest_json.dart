// Used by .github/workflows/release.yml:
//   dart run tool/release/make_latest_json.dart <version> <apk> <out.json>
import 'dart:convert';
import 'dart:io';

import 'latest_json.dart';

void main(List<String> args) {
  if (args.length != 3) {
    stderr.writeln('usage: make_latest_json.dart <version> <apk> <out.json>');
    exit(64);
  }
  final json = buildLatestJson(
    version: args[0],
    apkBytes: File(args[1]).readAsBytesSync(),
    changelog: File('CHANGELOG.md').readAsStringSync(),
  );
  File(args[2]).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(json));
  stdout.writeln('latest.json: ${json['version']} (${json['versionCode']}) sha256 ${json['sha256']}');
}
