import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/family_identity.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Vault implements FamilyKeyVault {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String? key) async => value = key;
}

Future<String?> _keyInDatabase(AppDatabase db) async =>
    (await (db.select(db.appSettings)..where((s) => s.key.equals(FamilyIdentity.keyKey))).getSingleOrNull())?.value;

/// The family key stays at home: never in the database that Android backs
/// up to the Google account (review R-030).
void main() {
  late AppDatabase db;
  late _Vault vault;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    vault = _Vault();
    FamilyIdentity.vault = vault;
  });
  tearDown(() async {
    FamilyIdentity.vault = null;
    await db.close();
  });

  test('a saved family keeps its key in the vault, not in the database', () async {
    final family = FamilyIdentity.create();
    await family.save(db);
    expect(await _keyInDatabase(db), isNull);
    expect(vault.value, family.key);
    expect(await FamilyIdentity.load(db), family);
  });

  test('a key from an older version moves out of the database on the first load', () async {
    final family = FamilyIdentity.create();
    FamilyIdentity.vault = null;
    await family.save(db);
    FamilyIdentity.vault = vault;
    expect(await FamilyIdentity.load(db), family);
    expect(vault.value, family.key);
    expect(await _keyInDatabase(db), isNull);
  });

  test('a database restored from a backup has no key: the device joins the family again by its QR code', () async {
    await FamilyIdentity.create().save(db);
    vault.value = null; // a new phone: the vault file was not in the backup
    expect(await FamilyIdentity.load(db), isNull);
  });
}
