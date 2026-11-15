import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../db/app_database.dart';
import '../multiplayer/local_address.dart';
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

  /// Where the key is kept out of Android backup (review R-030); set in
  /// `main()`. Without it (tests) the key is in the database as before.
  static FamilyKeyVault? vault;

  /// This device's family, or null when it is in none. A database restored
  /// from a backup has the family id but no key: such a device is in no
  /// family until it scans the family QR code again.
  static Future<FamilyIdentity?> load(AppDatabase db) async {
    final rows = {
      for (final r in await (db.select(db.appSettings)..where((s) => s.key.isIn([idKey, keyKey]))).get()) r.key: r.value,
    };
    final id = rows[idKey];
    if (id == null) return null;
    final v = vault;
    if (v == null) {
      final key = rows[keyKey];
      return key == null ? null : FamilyIdentity(familyId: id, key: key);
    }
    var key = await v.read();
    final old = rows[keyKey];
    if (old != null) {
      // From a version that kept it in the database: moved to the vault.
      if (key == null) {
        await v.write(old);
        key = await v.read();
      }
      if (key == old) await (db.delete(db.appSettings)..where((s) => s.key.equals(keyKey))).go();
    }
    return key == null ? null : FamilyIdentity(familyId: id, key: key);
  }

  Future<void> save(AppDatabase db) async {
    final v = vault;
    if (v != null) await v.write(key);
    await db.transaction(() async {
      await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: idKey, value: familyId));
      if (v == null) {
        await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: keyKey, value: key));
      } else {
        await (db.delete(db.appSettings)..where((s) => s.key.equals(keyKey))).go();
      }
    });
  }

  /// This device leaves its family.
  static Future<void> forget(AppDatabase db) async {
    await vault?.write(null);
    await (db.delete(db.appSettings)..where((s) => s.key.isIn([idKey, keyKey]))).go();
  }

  @override
  bool operator ==(Object other) => other is FamilyIdentity && other.familyId == familyId && other.key == key;

  @override
  int get hashCode => Object.hash(familyId, key);
}

/// The family key, kept where Android backup and phone-to-phone transfer
/// do not reach (review R-030).
abstract interface class FamilyKeyVault {
  Future<String?> read();

  /// Null removes the key.
  Future<void> write(String? key);
}

/// `files/family_key` next to the device marker, excluded from every backup
/// (`res/xml/*backup*`).
class FileFamilyKeyVault implements FamilyKeyVault {
  const FileFamilyKeyVault();

  static const fileName = 'family_key';

  Future<File> _file() async => File('${(await getApplicationSupportDirectory()).path}/$fileName');

  @override
  Future<String?> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final key = (await file.readAsString()).trim();
      return key.isEmpty ? null : key;
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> write(String? key) async {
    // An empty file is "no key": the file itself stays (nothing is deleted).
    await (await _file()).writeAsString(key ?? '', flush: true);
  }
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
    if (ip == null || !_ipv4.hasMatch(ip) || !isLocalNetworkAddress(ip) || port == null || port <= 0 || port > 65535) {
      return null;
    }
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
