// Fails when a `game/<id>` branch changes files outside its own game
// (spec 8 bod 6, 13.2). Used by CI; run it locally before a PR:
//
//     dart run tool/check_scope.dart game/memory            # diff against origin/main
//     dart run tool/check_scope.dart game/memory a.dart …   # these files
import 'dart:io';

import 'scope/scope.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('usage: dart run tool/check_scope.dart <branch> [changed files…]');
    exit(64);
  }
  final branch = args.first;
  var files = args.skip(1).toList();
  if (files.isEmpty) {
    final diff = await Process.run('git', ['diff', '--name-only', 'origin/main...HEAD']);
    if (diff.exitCode != 0) {
      stderr.writeln('git diff failed: ${diff.stderr}');
      exit(2);
    }
    files = (diff.stdout as String).split('\n');
  }
  final bad = outOfScope(branch, files);
  if (bad.isEmpty) {
    stdout.writeln('check_scope: $branch is within scope.');
    return;
  }
  stderr
    ..writeln('check_scope: $branch changes files outside its game (spec 13.2):')
    ..writeAll(bad.map((f) => '  $f\n'))
    ..writeln('Ask for framework changes in lib/games/<id>/FRAMEWORK_REQUESTS.md instead.');
  exit(1);
}
