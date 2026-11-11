import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/family/device_marker.dart';
import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_store.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The marker file that Android backup never copies.
class _Marker implements DeviceMarker {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String id) async => value = id;
}

/// A copy of another device's data (Android backup, phone-to-phone transfer)
/// must not share that device's id (review I8).
void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async {
    FamilyStore.marker = null;
    await db.close();
  });

  test('a new device marks its id', () async {
    final marker = FamilyStore.marker = _Marker();
    final id = await FamilyStore(db).deviceId();
    expect(marker.value, id);
    expect(await FamilyStore(db).deviceId(), id);
  });

  test('data restored on another phone gets an id of its own; its old ops stay', () async {
    FamilyStore.marker = _Marker();
    final old = FamilyStore(db);
    final oldId = await old.deviceId();
    await old.append(const DeviceJoined(deviceId: 'x', name: 'Telefon'));
    // The new phone: same database from the backup, no marker file.
    FamilyStore.marker = _Marker();
    final copy = FamilyStore(db);
    final newId = await copy.deviceId();
    expect(newId, isNot(oldId));
    final op = await copy.append(const DeviceJoined(deviceId: 'y', name: 'Nový'));
    expect(op.origin, newId);
    expect(op.seq, 1);
    expect([for (final o in await copy.all()) o.origin], containsAll([oldId, newId]));
  });

  test('a device updated from before the marker keeps its id', () async {
    final id = await FamilyStore(db).deviceId();
    final marker = FamilyStore.marker = _Marker();
    expect(await FamilyStore(db).deviceId(), id);
    expect(marker.value, id);
  });
}
