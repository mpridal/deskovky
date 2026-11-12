import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import 'device_marker.dart';
import 'family_op.dart';
import 'fold.dart';
import 'hlc.dart';
import 'materializer.dart';
import 'uid.dart';

/// The family's change log on this device (spec "Rodinná synchronizace"
/// kap. 7): this device's own ops and those received from other family
/// devices. The tables the screens read are rebuilt from it ([rebuild]).
class FamilyStore {
  FamilyStore(this._db, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  /// The store of [db] shared by the repositories and the sync.
  static FamilyStore of(AppDatabase db) => _shared[db] ??= FamilyStore(db);
  static final _shared = Expando<FamilyStore>();

  /// The family uid of profile row [id] (every row has one since v6).
  static Future<String> playerUid(AppDatabase db, int id) async =>
      (await (db.select(db.players)..where((p) => p.id.equals(id))).getSingle()).uid!;

  /// Set by `main()`; tests without it never check for copied data.
  static DeviceMarker? marker;

  static const deviceIdKey = 'deviceId';
  static const markedKey = 'deviceMarked';
  static const clockKey = 'familyClock';

  final AppDatabase _db;
  final DateTime Function() _now;
  final _changes = StreamController<void>.broadcast();

  /// Fires after new ops (own or received).
  Stream<void> get changes => _changes.stream;

  /// This device's id in the family, created on first use.
  Future<String> deviceId() async {
    // Only with a marker: a future cached here would otherwise outlive the
    // zone it was made in (widget tests' fake time never finishes it).
    if (marker != null) await (_marked ??= _checkMarker());
    final existing = await _setting(deviceIdKey);
    if (existing != null) return existing;
    final id = newUid();
    await _db.into(_db.appSettings).insert(AppSettingsCompanion.insert(key: deviceIdKey, value: id), mode: InsertMode.insertOrIgnore);
    final kept = (await _setting(deviceIdKey))!;
    await _mark(kept);
    return kept;
  }

  Future<void>? _marked;

  /// Data copied from another device (backup, phone transfer) must not
  /// write in that device's name: the copy gets an id of its own; the
  /// copied ops keep theirs.
  Future<void> _checkMarker() async {
    final m = marker;
    if (m == null) return;
    final id = await _setting(deviceIdKey);
    if (id == null) return;
    final onDisk = await m.read();
    if (onDisk == id) return;
    if (onDisk == null && await _setting(markedKey) == null) {
      // First start of a version with the marker: this is the device.
      await _mark(id);
      return;
    }
    await _set(deviceIdKey, newUid());
    await _mark((await _setting(deviceIdKey))!);
  }

  Future<void> _mark(String id) async {
    final m = marker;
    if (m == null) return;
    await m.write(id);
    await _set(markedKey, '1');
  }

  /// The stamp for a new local op; never goes backwards on this device.
  Future<Hlc> nextClock() => _db.transaction(() async {
    final id = await deviceId();
    final current = Hlc.unpack(await _setting(clockKey) ?? '') ?? Hlc(0, 0, id);
    final next = Hlc(current.millis, current.counter, id).tick(_now().millisecondsSinceEpoch);
    await _set(clockKey, next.pack());
    return next;
  });

  /// Records a change made on this device.
  Future<FamilyOp> append(OpBody body) async {
    final op = await _db.transaction(() async {
      final id = await deviceId();
      final last = await _db
          .customSelect('SELECT MAX(seq) AS s FROM sync_ops WHERE origin = ?', variables: [Variable.withString(id)])
          .getSingle();
      final op = FamilyOp(origin: id, seq: (last.data['s'] as int? ?? 0) + 1, clock: await nextClock(), body: body);
      await _insert(op);
      return op;
    });
    _changes.add(null);
    return op;
  }

  /// Takes ops from another family device; returns how many were new.
  Future<int> insertRemote(Iterable<FamilyOp> ops) async {
    final added = await _db.transaction(() async {
      var added = 0;
      Hlc? latest;
      for (final op in ops) {
        final known = await (_db.select(_db.syncOps)
              ..where((o) => o.origin.equals(op.origin) & o.seq.equals(op.seq)))
            .getSingleOrNull();
        if (known != null) continue;
        await _insert(op);
        added++;
        if (latest == null || op.clock.compareTo(latest) > 0) latest = op.clock;
      }
      if (latest != null) {
        final id = await deviceId();
        final current = Hlc.unpack(await _setting(clockKey) ?? '') ?? Hlc(0, 0, id);
        await _set(clockKey, current.receive(latest, _now().millisecondsSinceEpoch).pack());
      }
      return added;
    });
    if (added > 0) _changes.add(null);
    return added;
  }

  /// For each device, the highest op number this device has from it.
  Future<Map<String, int>> versionVector() async => {
    for (final row in await _db.customSelect('SELECT origin, MAX(seq) AS s FROM sync_ops GROUP BY origin').get())
      row.data['origin'] as String: row.data['s'] as int,
  };

  /// The ops another device is missing, given its [theirs] version vector.
  Future<List<FamilyOp>> opsAfter(Map<String, int> theirs) async => [
    for (final row in await (_db.select(_db.syncOps)..orderBy([(o) => OrderingTerm.asc(o.clock)])).get())
      if (row.seq > (theirs[row.origin] ?? 0)) ?_decode(row),
  ];

  /// Devices taken out of the family; they are refused (spec 7.2).
  Future<Set<String>> removedDevices() async => {
    for (final row in await _db.customSelect("SELECT json FROM sync_ops WHERE json LIKE '%\"t\":\"deviceRemoved\"%'").get())
      if (FamilyOp.fromJson(jsonDecode(row.data['json'] as String))?.body case DeviceRemoved(:final deviceId)) deviceId,
  };

  /// Notes when this device last synced with [deviceId] (shown in Rodina).
  Future<void> markSynced(String deviceId) => _db
      .into(_db.familyDevices)
      .insertOnConflictUpdate(FamilyDevicesCompanion.insert(deviceId: deviceId, lastSyncMs: Value(_now().millisecondsSinceEpoch)));

  Future<List<FamilyOp>> all() async => [for (final row in await _db.select(_db.syncOps).get()) ?_decode(row)];

  /// Computes the family state from every op and writes it to the tables.
  /// One at a time, and the ops are read inside the transaction, so a write
  /// made meanwhile is never undone by an older picture of the log.
  Future<void> rebuild() {
    final run = _rebuilding.catchError((Object _) {}).then(
      (_) => _db.transaction(() async => materialize(_db, foldFamily(await all()))),
    );
    _rebuilding = run;
    return run;
  }

  Future<void> _rebuilding = Future.value();

  Future<void> _insert(FamilyOp op) => _db
      .into(_db.syncOps)
      .insert(
        SyncOpsCompanion.insert(origin: op.origin, seq: op.seq, clock: op.clock.pack(), json: jsonEncode(op.toJson())),
        mode: InsertMode.insertOrIgnore,
      );

  /// Writes ops made elsewhere in this device's name (the one-off import
  /// of data from before the family, with their original times).
  Future<void> insertOwn(List<FamilyOp> ops, Hlc clock) async {
    for (final op in ops) {
      await _insert(op);
    }
    await _set(clockKey, clock.pack());
  }

  static FamilyOp? _decode(SyncOpRow row) {
    try {
      return FamilyOp.fromJson(jsonDecode(row.json));
    } on FormatException {
      return null;
    }
  }

  Future<String?> _setting(String key) async =>
      (await (_db.select(_db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _set(String key, String value) =>
      _db.into(_db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));
}
