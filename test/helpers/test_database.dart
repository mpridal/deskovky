import 'package:deskovky/core/db/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// In-memory database for widget tests. Streams close synchronously, so no
/// drift timer is left pending when the widget tree is disposed.
AppDatabase testDatabase() =>
    AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
