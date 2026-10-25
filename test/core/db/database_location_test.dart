import 'package:deskovky/core/db/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  test('database location is pinned to the app documents directory', () {
    // An APK update keeps this directory. The location must never follow a
    // library default, or an update could open an empty database.
    expect(AppDatabase.databaseDirectory, same(getApplicationDocumentsDirectory));
    expect(AppDatabase.fileName, 'deskovky');
  });
}
