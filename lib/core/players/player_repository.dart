import 'dart:convert';

import 'package:characters/characters.dart';
import 'package:drift/drift.dart';

import '../avatar/avatar_spec.dart';
import '../db/app_database.dart';
import 'player_profile.dart';

/// Player profiles with the rules of spec 5.2: 1–16 characters, unique name
/// (case and outer spaces ignored), at most 8 profiles.
class PlayerRepository {
  PlayerRepository(this._db);

  final AppDatabase _db;

  static const maxProfiles = 8;
  static const maxNameLength = 16;

  Stream<List<PlayerProfile>> watchAll() => _ordered().watch().map((rows) => rows.map(_toProfile).toList());

  Future<List<PlayerProfile>> all() async => (await _ordered().get()).map(_toProfile).toList();

  Future<PlayerProfile?> byId(int id) async {
    final row = await (_db.select(_db.players)..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toProfile(row);
  }

  Future<PlayerProfile> create({required String name, required AvatarSpec avatar, int? favoriteSeat}) {
    final clean = _validName(name);
    return _db.transaction(() async {
      final count = await _db.players.count().getSingle();
      if (count >= maxProfiles) throw const ProfileException(ProfileError.limitReached);
      await _ensureNameFree(clean);
      final id = await _db.into(_db.players).insert(PlayersCompanion.insert(
            name: clean,
            nameKey: _key(clean),
            avatarJson: jsonEncode(avatar.toJson()),
            favoriteSeat: Value(favoriteSeat),
            createdAt: DateTime.now().toUtc(),
          ));
      return (await byId(id))!;
    });
  }

  Future<PlayerProfile> update(int id, {String? name, AvatarSpec? avatar, int? favoriteSeat}) {
    final clean = name == null ? null : _validName(name);
    return _db.transaction(() async {
      if (await byId(id) == null) throw const ProfileException(ProfileError.notFound);
      if (clean != null) await _ensureNameFree(clean, exceptId: id);
      await (_db.update(_db.players)..where((p) => p.id.equals(id))).write(PlayersCompanion(
        name: clean == null ? const Value.absent() : Value(clean),
        nameKey: clean == null ? const Value.absent() : Value(_key(clean)),
        avatarJson: avatar == null ? const Value.absent() : Value(jsonEncode(avatar.toJson())),
        favoriteSeat: favoriteSeat == null ? const Value.absent() : Value(favoriteSeat),
      ));
      return (await byId(id))!;
    });
  }

  Future<void> delete(int id) async {
    final deleted = await (_db.delete(_db.players)..where((p) => p.id.equals(id))).go();
    if (deleted == 0) throw const ProfileException(ProfileError.notFound);
  }

  SimpleSelectStatement<$PlayersTable, Player> _ordered() =>
      _db.select(_db.players)..orderBy([(p) => OrderingTerm.asc(p.createdAt), (p) => OrderingTerm.asc(p.id)]);

  Future<void> _ensureNameFree(String name, {int? exceptId}) async {
    final query = _db.select(_db.players)..where((p) => p.nameKey.equals(_key(name)));
    if (exceptId != null) query.where((p) => p.id.equals(exceptId).not());
    if (await query.getSingleOrNull() != null) throw const ProfileException(ProfileError.nameTaken);
  }

  static String _validName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) throw const ProfileException(ProfileError.nameEmpty);
    if (clean.characters.length > maxNameLength) throw const ProfileException(ProfileError.nameTooLong);
    return clean;
  }

  static String _key(String name) => name.trim().toLowerCase();

  static PlayerProfile _toProfile(Player row) => PlayerProfile(
        id: row.id,
        name: row.name,
        avatar: AvatarSpec.fromJson(_decode(row.avatarJson)),
        favoriteSeat: row.favoriteSeat,
        createdAt: row.createdAt.toUtc(),
      );

  static Map<String, Object?>? _decode(String json) {
    try {
      final value = jsonDecode(json);
      return value is Map<String, Object?> ? value : null;
    } on FormatException {
      return null;
    }
  }
}
