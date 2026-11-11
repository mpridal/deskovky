import 'dart:math';

import 'package:flutter/foundation.dart';

import '../db/app_database.dart';
import 'uid.dart';

/// The family this device belongs to (spec "Rodinná synchronizace" 7.1): an
/// id and a secret key. The key travels only in the family QR code, never
/// over the network; devices prove they know it (HMAC).
@immutable
class FamilyIdentity {
  const FamilyIdentity({required this.familyId, required this.key});

  static const idKey = 'familyId';
  static const keyKey = 'familyKey';

  final String familyId;

  /// 32 random bytes as 64 hex characters.
  final String key;

  static FamilyIdentity create([Random? random]) {
    final r = random ?? Random.secure();
    return FamilyIdentity(
      familyId: newUid(),
      key: [for (var i = 0; i < 32; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join(),
    );
  }

  List<int> get keyBytes => [for (var i = 0; i < key.length; i += 2) int.parse(key.substring(i, i + 2), radix: 16)];

  /// This device's family, or null when it is in none.
  static Future<FamilyIdentity?> load(AppDatabase db) async {
    final rows = {
      for (final r in await (db.select(db.appSettings)..where((s) => s.key.isIn([idKey, keyKey]))).get()) r.key: r.value,
    };
    final id = rows[idKey], key = rows[keyKey];
    return id == null || key == null ? null : FamilyIdentity(familyId: id, key: key);
  }

  Future<void> save(AppDatabase db) => db.transaction(() async {
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: idKey, value: familyId));
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: keyKey, value: key));
  });

  @override
  bool operator ==(Object other) => other is FamilyIdentity && other.familyId == familyId && other.key == key;

  @override
  int get hashCode => Object.hash(familyId, key);
}

/// What the family QR code says: the family and where to reach the device
/// showing it (`deskovky://family?id=…&key=…&ip=…&port=…`).
@immutable
class FamilyTicket {
  const FamilyTicket({required this.familyId, required this.key, required this.ip, required this.port});

  final String familyId;
  final String key;
  final String ip;
  final int port;

  FamilyIdentity get identity => FamilyIdentity(familyId: familyId, key: key);

  Uri toUri() => Uri(
    scheme: 'deskovky',
    host: 'family',
    queryParameters: {'id': familyId, 'key': key, 'ip': ip, 'port': '$port'},
  );

  /// Null for anything that is not a valid family link.
  static FamilyTicket? parse(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null || uri.scheme != 'deskovky' || uri.host != 'family') return null;
    final q = uri.queryParameters;
    final id = q['id'], key = q['key'], ip = q['ip'];
    final port = int.tryParse(q['port'] ?? '');
    if (id == null || !_hex32.hasMatch(id) || key == null || !_hex64.hasMatch(key)) return null;
    if (ip == null || !_ipv4.hasMatch(ip) || port == null || port <= 0 || port > 65535) return null;
    return FamilyTicket(familyId: id, key: key, ip: ip, port: port);
  }

  static final _hex32 = RegExp(r'^[0-9a-f]{32}$');
  static final _hex64 = RegExp(r'^[0-9a-f]{64}$');
  static final _ipv4 = RegExp(r'^((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)$');

  @override
  bool operator ==(Object other) =>
      other is FamilyTicket && other.familyId == familyId && other.key == key && other.ip == ip && other.port == port;

  @override
  int get hashCode => Object.hash(familyId, key, ip, port);
}
