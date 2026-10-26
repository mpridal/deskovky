// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 256,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _avatarJsonMeta = const VerificationMeta(
    'avatarJson',
  );
  @override
  late final GeneratedColumn<String> avatarJson = GeneratedColumn<String>(
    'avatar_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoriteSeatMeta = const VerificationMeta(
    'favoriteSeat',
  );
  @override
  late final GeneratedColumn<int> favoriteSeat = GeneratedColumn<int>(
    'favorite_seat',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameKey,
    avatarJson,
    favoriteSeat,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('avatar_json')) {
      context.handle(
        _avatarJsonMeta,
        avatarJson.isAcceptableOrUnknown(data['avatar_json']!, _avatarJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarJsonMeta);
    }
    if (data.containsKey('favorite_seat')) {
      context.handle(
        _favoriteSeatMeta,
        favoriteSeat.isAcceptableOrUnknown(
          data['favorite_seat']!,
          _favoriteSeatMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      avatarJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_json'],
      )!,
      favoriteSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}favorite_seat'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final int id;
  final String name;
  final String nameKey;
  final String avatarJson;
  final int? favoriteSeat;
  final DateTime createdAt;
  const Player({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.avatarJson,
    this.favoriteSeat,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['avatar_json'] = Variable<String>(avatarJson);
    if (!nullToAbsent || favoriteSeat != null) {
      map['favorite_seat'] = Variable<int>(favoriteSeat);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      avatarJson: Value(avatarJson),
      favoriteSeat: favoriteSeat == null && nullToAbsent
          ? const Value.absent()
          : Value(favoriteSeat),
      createdAt: Value(createdAt),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      avatarJson: serializer.fromJson<String>(json['avatarJson']),
      favoriteSeat: serializer.fromJson<int?>(json['favoriteSeat']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'avatarJson': serializer.toJson<String>(avatarJson),
      'favoriteSeat': serializer.toJson<int?>(favoriteSeat),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Player copyWith({
    int? id,
    String? name,
    String? nameKey,
    String? avatarJson,
    Value<int?> favoriteSeat = const Value.absent(),
    DateTime? createdAt,
  }) => Player(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    avatarJson: avatarJson ?? this.avatarJson,
    favoriteSeat: favoriteSeat.present ? favoriteSeat.value : this.favoriteSeat,
    createdAt: createdAt ?? this.createdAt,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      avatarJson: data.avatarJson.present
          ? data.avatarJson.value
          : this.avatarJson,
      favoriteSeat: data.favoriteSeat.present
          ? data.favoriteSeat.value
          : this.favoriteSeat,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('avatarJson: $avatarJson, ')
          ..write('favoriteSeat: $favoriteSeat, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, nameKey, avatarJson, favoriteSeat, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.avatarJson == this.avatarJson &&
          other.favoriteSeat == this.favoriteSeat &&
          other.createdAt == this.createdAt);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String> avatarJson;
  final Value<int?> favoriteSeat;
  final Value<DateTime> createdAt;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.avatarJson = const Value.absent(),
    this.favoriteSeat = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PlayersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
    required String avatarJson,
    this.favoriteSeat = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       nameKey = Value(nameKey),
       avatarJson = Value(avatarJson),
       createdAt = Value(createdAt);
  static Insertable<Player> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? avatarJson,
    Expression<int>? favoriteSeat,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (avatarJson != null) 'avatar_json': avatarJson,
      if (favoriteSeat != null) 'favorite_seat': favoriteSeat,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PlayersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String>? avatarJson,
    Value<int?>? favoriteSeat,
    Value<DateTime>? createdAt,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      avatarJson: avatarJson ?? this.avatarJson,
      favoriteSeat: favoriteSeat ?? this.favoriteSeat,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (avatarJson.present) {
      map['avatar_json'] = Variable<String>(avatarJson.value);
    }
    if (favoriteSeat.present) {
      map['favorite_seat'] = Variable<int>(favoriteSeat.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('avatarJson: $avatarJson, ')
          ..write('favoriteSeat: $favoriteSeat, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameSettingsLastTable extends GameSettingsLast
    with TableInfo<$GameSettingsLastTable, GameSettingsLastData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSettingsLastTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, configJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_settings_last';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSettingsLastData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  GameSettingsLastData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSettingsLastData(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GameSettingsLastTable createAlias(String alias) {
    return $GameSettingsLastTable(attachedDatabase, alias);
  }
}

class GameSettingsLastData extends DataClass
    implements Insertable<GameSettingsLastData> {
  final String gameId;
  final String configJson;

  /// Strictly increasing stamp (ms); DateTime columns only keep seconds.
  final int updatedAt;
  const GameSettingsLastData({
    required this.gameId,
    required this.configJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['config_json'] = Variable<String>(configJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  GameSettingsLastCompanion toCompanion(bool nullToAbsent) {
    return GameSettingsLastCompanion(
      gameId: Value(gameId),
      configJson: Value(configJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory GameSettingsLastData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSettingsLastData(
      gameId: serializer.fromJson<String>(json['gameId']),
      configJson: serializer.fromJson<String>(json['configJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'configJson': serializer.toJson<String>(configJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  GameSettingsLastData copyWith({
    String? gameId,
    String? configJson,
    int? updatedAt,
  }) => GameSettingsLastData(
    gameId: gameId ?? this.gameId,
    configJson: configJson ?? this.configJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  GameSettingsLastData copyWithCompanion(GameSettingsLastCompanion data) {
    return GameSettingsLastData(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSettingsLastData(')
          ..write('gameId: $gameId, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, configJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSettingsLastData &&
          other.gameId == this.gameId &&
          other.configJson == this.configJson &&
          other.updatedAt == this.updatedAt);
}

class GameSettingsLastCompanion extends UpdateCompanion<GameSettingsLastData> {
  final Value<String> gameId;
  final Value<String> configJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const GameSettingsLastCompanion({
    this.gameId = const Value.absent(),
    this.configJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSettingsLastCompanion.insert({
    required String gameId,
    required String configJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       configJson = Value(configJson),
       updatedAt = Value(updatedAt);
  static Insertable<GameSettingsLastData> custom({
    Expression<String>? gameId,
    Expression<String>? configJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (configJson != null) 'config_json': configJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSettingsLastCompanion copyWith({
    Value<String>? gameId,
    Value<String>? configJson,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return GameSettingsLastCompanion(
      gameId: gameId ?? this.gameId,
      configJson: configJson ?? this.configJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSettingsLastCompanion(')
          ..write('gameId: $gameId, ')
          ..write('configJson: $configJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavedSessionsTable extends SavedSessions
    with TableInfo<$SavedSessionsTable, SavedSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saveJsonMeta = const VerificationMeta(
    'saveJson',
  );
  @override
  late final GeneratedColumn<String> saveJson = GeneratedColumn<String>(
    'save_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, saveJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('save_json')) {
      context.handle(
        _saveJsonMeta,
        saveJson.isAcceptableOrUnknown(data['save_json']!, _saveJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_saveJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  SavedSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSession(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      saveJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}save_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedSessionsTable createAlias(String alias) {
    return $SavedSessionsTable(attachedDatabase, alias);
  }
}

class SavedSession extends DataClass implements Insertable<SavedSession> {
  final String gameId;
  final String saveJson;

  /// Strictly increasing stamp (ms), see [GameSettingsLast.updatedAt].
  final int updatedAt;
  const SavedSession({
    required this.gameId,
    required this.saveJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['save_json'] = Variable<String>(saveJson);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SavedSessionsCompanion toCompanion(bool nullToAbsent) {
    return SavedSessionsCompanion(
      gameId: Value(gameId),
      saveJson: Value(saveJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSession(
      gameId: serializer.fromJson<String>(json['gameId']),
      saveJson: serializer.fromJson<String>(json['saveJson']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'saveJson': serializer.toJson<String>(saveJson),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SavedSession copyWith({String? gameId, String? saveJson, int? updatedAt}) =>
      SavedSession(
        gameId: gameId ?? this.gameId,
        saveJson: saveJson ?? this.saveJson,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SavedSession copyWithCompanion(SavedSessionsCompanion data) {
    return SavedSession(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      saveJson: data.saveJson.present ? data.saveJson.value : this.saveJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSession(')
          ..write('gameId: $gameId, ')
          ..write('saveJson: $saveJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, saveJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSession &&
          other.gameId == this.gameId &&
          other.saveJson == this.saveJson &&
          other.updatedAt == this.updatedAt);
}

class SavedSessionsCompanion extends UpdateCompanion<SavedSession> {
  final Value<String> gameId;
  final Value<String> saveJson;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const SavedSessionsCompanion({
    this.gameId = const Value.absent(),
    this.saveJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedSessionsCompanion.insert({
    required String gameId,
    required String saveJson,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : gameId = Value(gameId),
       saveJson = Value(saveJson),
       updatedAt = Value(updatedAt);
  static Insertable<SavedSession> custom({
    Expression<String>? gameId,
    Expression<String>? saveJson,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (saveJson != null) 'save_json': saveJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedSessionsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? saveJson,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavedSessionsCompanion(
      gameId: gameId ?? this.gameId,
      saveJson: saveJson ?? this.saveJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (saveJson.present) {
      map['save_json'] = Variable<String>(saveJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSessionsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('saveJson: $saveJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, MatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<int> playedAt = GeneratedColumn<int>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    playedAt,
    durationMs,
    difficulty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}played_at'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class MatchRow extends DataClass implements Insertable<MatchRow> {
  final int id;
  final String gameId;
  final int playedAt;
  final int durationMs;

  /// Robots' difficulty; null when only people played.
  final String? difficulty;
  const MatchRow({
    required this.id,
    required this.gameId,
    required this.playedAt,
    required this.durationMs,
    this.difficulty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['game_id'] = Variable<String>(gameId);
    map['played_at'] = Variable<int>(playedAt);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      playedAt: Value(playedAt),
      durationMs: Value(durationMs),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
    );
  }

  factory MatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchRow(
      id: serializer.fromJson<int>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      playedAt: serializer.fromJson<int>(json['playedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gameId': serializer.toJson<String>(gameId),
      'playedAt': serializer.toJson<int>(playedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'difficulty': serializer.toJson<String?>(difficulty),
    };
  }

  MatchRow copyWith({
    int? id,
    String? gameId,
    int? playedAt,
    int? durationMs,
    Value<String?> difficulty = const Value.absent(),
  }) => MatchRow(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    playedAt: playedAt ?? this.playedAt,
    durationMs: durationMs ?? this.durationMs,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
  );
  MatchRow copyWithCompanion(MatchesCompanion data) {
    return MatchRow(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchRow(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playedAt: $playedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, playedAt, durationMs, difficulty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchRow &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.playedAt == this.playedAt &&
          other.durationMs == this.durationMs &&
          other.difficulty == this.difficulty);
}

class MatchesCompanion extends UpdateCompanion<MatchRow> {
  final Value<int> id;
  final Value<String> gameId;
  final Value<int> playedAt;
  final Value<int> durationMs;
  final Value<String?> difficulty;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.difficulty = const Value.absent(),
  });
  MatchesCompanion.insert({
    this.id = const Value.absent(),
    required String gameId,
    required int playedAt,
    required int durationMs,
    this.difficulty = const Value.absent(),
  }) : gameId = Value(gameId),
       playedAt = Value(playedAt),
       durationMs = Value(durationMs);
  static Insertable<MatchRow> custom({
    Expression<int>? id,
    Expression<String>? gameId,
    Expression<int>? playedAt,
    Expression<int>? durationMs,
    Expression<String>? difficulty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (playedAt != null) 'played_at': playedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (difficulty != null) 'difficulty': difficulty,
    });
  }

  MatchesCompanion copyWith({
    Value<int>? id,
    Value<String>? gameId,
    Value<int>? playedAt,
    Value<int>? durationMs,
    Value<String?>? difficulty,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      playedAt: playedAt ?? this.playedAt,
      durationMs: durationMs ?? this.durationMs,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<int>(playedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('playedAt: $playedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }
}

class $MatchParticipantsTable extends MatchParticipants
    with TableInfo<$MatchParticipantsTable, MatchParticipantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<int> seat = GeneratedColumn<int>(
    'seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _robotMeta = const VerificationMeta('robot');
  @override
  late final GeneratedColumn<bool> robot = GeneratedColumn<bool>(
    'robot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("robot" IN (0, 1))',
    ),
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<int> place = GeneratedColumn<int>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    matchId,
    seat,
    playerId,
    robot,
    place,
    score,
    stars,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'match_participants';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatchParticipantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('seat')) {
      context.handle(
        _seatMeta,
        seat.isAcceptableOrUnknown(data['seat']!, _seatMeta),
      );
    } else if (isInserting) {
      context.missing(_seatMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    }
    if (data.containsKey('robot')) {
      context.handle(
        _robotMeta,
        robot.isAcceptableOrUnknown(data['robot']!, _robotMeta),
      );
    } else if (isInserting) {
      context.missing(_robotMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {matchId, seat};
  @override
  MatchParticipantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchParticipantRow(
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      )!,
      seat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seat'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      ),
      robot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}robot'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
    );
  }

  @override
  $MatchParticipantsTable createAlias(String alias) {
    return $MatchParticipantsTable(attachedDatabase, alias);
  }
}

class MatchParticipantRow extends DataClass
    implements Insertable<MatchParticipantRow> {
  final int matchId;
  final int seat;

  /// Null for robots and for players deleted since.
  final int? playerId;
  final bool robot;
  final int place;
  final int score;
  final int stars;
  const MatchParticipantRow({
    required this.matchId,
    required this.seat,
    this.playerId,
    required this.robot,
    required this.place,
    required this.score,
    required this.stars,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['match_id'] = Variable<int>(matchId);
    map['seat'] = Variable<int>(seat);
    if (!nullToAbsent || playerId != null) {
      map['player_id'] = Variable<int>(playerId);
    }
    map['robot'] = Variable<bool>(robot);
    map['place'] = Variable<int>(place);
    map['score'] = Variable<int>(score);
    map['stars'] = Variable<int>(stars);
    return map;
  }

  MatchParticipantsCompanion toCompanion(bool nullToAbsent) {
    return MatchParticipantsCompanion(
      matchId: Value(matchId),
      seat: Value(seat),
      playerId: playerId == null && nullToAbsent
          ? const Value.absent()
          : Value(playerId),
      robot: Value(robot),
      place: Value(place),
      score: Value(score),
      stars: Value(stars),
    );
  }

  factory MatchParticipantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchParticipantRow(
      matchId: serializer.fromJson<int>(json['matchId']),
      seat: serializer.fromJson<int>(json['seat']),
      playerId: serializer.fromJson<int?>(json['playerId']),
      robot: serializer.fromJson<bool>(json['robot']),
      place: serializer.fromJson<int>(json['place']),
      score: serializer.fromJson<int>(json['score']),
      stars: serializer.fromJson<int>(json['stars']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'matchId': serializer.toJson<int>(matchId),
      'seat': serializer.toJson<int>(seat),
      'playerId': serializer.toJson<int?>(playerId),
      'robot': serializer.toJson<bool>(robot),
      'place': serializer.toJson<int>(place),
      'score': serializer.toJson<int>(score),
      'stars': serializer.toJson<int>(stars),
    };
  }

  MatchParticipantRow copyWith({
    int? matchId,
    int? seat,
    Value<int?> playerId = const Value.absent(),
    bool? robot,
    int? place,
    int? score,
    int? stars,
  }) => MatchParticipantRow(
    matchId: matchId ?? this.matchId,
    seat: seat ?? this.seat,
    playerId: playerId.present ? playerId.value : this.playerId,
    robot: robot ?? this.robot,
    place: place ?? this.place,
    score: score ?? this.score,
    stars: stars ?? this.stars,
  );
  MatchParticipantRow copyWithCompanion(MatchParticipantsCompanion data) {
    return MatchParticipantRow(
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      seat: data.seat.present ? data.seat.value : this.seat,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      robot: data.robot.present ? data.robot.value : this.robot,
      place: data.place.present ? data.place.value : this.place,
      score: data.score.present ? data.score.value : this.score,
      stars: data.stars.present ? data.stars.value : this.stars,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchParticipantRow(')
          ..write('matchId: $matchId, ')
          ..write('seat: $seat, ')
          ..write('playerId: $playerId, ')
          ..write('robot: $robot, ')
          ..write('place: $place, ')
          ..write('score: $score, ')
          ..write('stars: $stars')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(matchId, seat, playerId, robot, place, score, stars);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchParticipantRow &&
          other.matchId == this.matchId &&
          other.seat == this.seat &&
          other.playerId == this.playerId &&
          other.robot == this.robot &&
          other.place == this.place &&
          other.score == this.score &&
          other.stars == this.stars);
}

class MatchParticipantsCompanion extends UpdateCompanion<MatchParticipantRow> {
  final Value<int> matchId;
  final Value<int> seat;
  final Value<int?> playerId;
  final Value<bool> robot;
  final Value<int> place;
  final Value<int> score;
  final Value<int> stars;
  final Value<int> rowid;
  const MatchParticipantsCompanion({
    this.matchId = const Value.absent(),
    this.seat = const Value.absent(),
    this.playerId = const Value.absent(),
    this.robot = const Value.absent(),
    this.place = const Value.absent(),
    this.score = const Value.absent(),
    this.stars = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchParticipantsCompanion.insert({
    required int matchId,
    required int seat,
    this.playerId = const Value.absent(),
    required bool robot,
    required int place,
    required int score,
    required int stars,
    this.rowid = const Value.absent(),
  }) : matchId = Value(matchId),
       seat = Value(seat),
       robot = Value(robot),
       place = Value(place),
       score = Value(score),
       stars = Value(stars);
  static Insertable<MatchParticipantRow> custom({
    Expression<int>? matchId,
    Expression<int>? seat,
    Expression<int>? playerId,
    Expression<bool>? robot,
    Expression<int>? place,
    Expression<int>? score,
    Expression<int>? stars,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (matchId != null) 'match_id': matchId,
      if (seat != null) 'seat': seat,
      if (playerId != null) 'player_id': playerId,
      if (robot != null) 'robot': robot,
      if (place != null) 'place': place,
      if (score != null) 'score': score,
      if (stars != null) 'stars': stars,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchParticipantsCompanion copyWith({
    Value<int>? matchId,
    Value<int>? seat,
    Value<int?>? playerId,
    Value<bool>? robot,
    Value<int>? place,
    Value<int>? score,
    Value<int>? stars,
    Value<int>? rowid,
  }) {
    return MatchParticipantsCompanion(
      matchId: matchId ?? this.matchId,
      seat: seat ?? this.seat,
      playerId: playerId ?? this.playerId,
      robot: robot ?? this.robot,
      place: place ?? this.place,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (seat.present) {
      map['seat'] = Variable<int>(seat.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (robot.present) {
      map['robot'] = Variable<bool>(robot.value);
    }
    if (place.present) {
      map['place'] = Variable<int>(place.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchParticipantsCompanion(')
          ..write('matchId: $matchId, ')
          ..write('seat: $seat, ')
          ..write('playerId: $playerId, ')
          ..write('robot: $robot, ')
          ..write('place: $place, ')
          ..write('score: $score, ')
          ..write('stars: $stars, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerCountersTable extends PlayerCounters
    with TableInfo<$PlayerCountersTable, PlayerCounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_counters';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerCounter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId, key};
  @override
  PlayerCounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerCounter(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PlayerCountersTable createAlias(String alias) {
    return $PlayerCountersTable(attachedDatabase, alias);
  }
}

class PlayerCounter extends DataClass implements Insertable<PlayerCounter> {
  final int playerId;
  final String key;
  final int value;
  const PlayerCounter({
    required this.playerId,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<int>(playerId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<int>(value);
    return map;
  }

  PlayerCountersCompanion toCompanion(bool nullToAbsent) {
    return PlayerCountersCompanion(
      playerId: Value(playerId),
      key: Value(key),
      value: Value(value),
    );
  }

  factory PlayerCounter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerCounter(
      playerId: serializer.fromJson<int>(json['playerId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<int>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<int>(playerId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<int>(value),
    };
  }

  PlayerCounter copyWith({int? playerId, String? key, int? value}) =>
      PlayerCounter(
        playerId: playerId ?? this.playerId,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  PlayerCounter copyWithCompanion(PlayerCountersCompanion data) {
    return PlayerCounter(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerCounter(')
          ..write('playerId: $playerId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerCounter &&
          other.playerId == this.playerId &&
          other.key == this.key &&
          other.value == this.value);
}

class PlayerCountersCompanion extends UpdateCompanion<PlayerCounter> {
  final Value<int> playerId;
  final Value<String> key;
  final Value<int> value;
  final Value<int> rowid;
  const PlayerCountersCompanion({
    this.playerId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerCountersCompanion.insert({
    required int playerId,
    required String key,
    required int value,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       key = Value(key),
       value = Value(value);
  static Insertable<PlayerCounter> custom({
    Expression<int>? playerId,
    Expression<String>? key,
    Expression<int>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerCountersCompanion copyWith({
    Value<int>? playerId,
    Value<String>? key,
    Value<int>? value,
    Value<int>? rowid,
  }) {
    return PlayerCountersCompanion(
      playerId: playerId ?? this.playerId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerCountersCompanion(')
          ..write('playerId: $playerId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EarnedBadgesTable extends EarnedBadges
    with TableInfo<$EarnedBadgesTable, EarnedBadge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EarnedBadgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _badgeIdMeta = const VerificationMeta(
    'badgeId',
  );
  @override
  late final GeneratedColumn<String> badgeId = GeneratedColumn<String>(
    'badge_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnedAtMeta = const VerificationMeta(
    'earnedAt',
  );
  @override
  late final GeneratedColumn<int> earnedAt = GeneratedColumn<int>(
    'earned_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [playerId, badgeId, earnedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'earned_badges';
  @override
  VerificationContext validateIntegrity(
    Insertable<EarnedBadge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('badge_id')) {
      context.handle(
        _badgeIdMeta,
        badgeId.isAcceptableOrUnknown(data['badge_id']!, _badgeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_badgeIdMeta);
    }
    if (data.containsKey('earned_at')) {
      context.handle(
        _earnedAtMeta,
        earnedAt.isAcceptableOrUnknown(data['earned_at']!, _earnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_earnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playerId, badgeId};
  @override
  EarnedBadge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EarnedBadge(
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      badgeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge_id'],
      )!,
      earnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earned_at'],
      )!,
    );
  }

  @override
  $EarnedBadgesTable createAlias(String alias) {
    return $EarnedBadgesTable(attachedDatabase, alias);
  }
}

class EarnedBadge extends DataClass implements Insertable<EarnedBadge> {
  final int playerId;
  final String badgeId;
  final int earnedAt;
  const EarnedBadge({
    required this.playerId,
    required this.badgeId,
    required this.earnedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['player_id'] = Variable<int>(playerId);
    map['badge_id'] = Variable<String>(badgeId);
    map['earned_at'] = Variable<int>(earnedAt);
    return map;
  }

  EarnedBadgesCompanion toCompanion(bool nullToAbsent) {
    return EarnedBadgesCompanion(
      playerId: Value(playerId),
      badgeId: Value(badgeId),
      earnedAt: Value(earnedAt),
    );
  }

  factory EarnedBadge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EarnedBadge(
      playerId: serializer.fromJson<int>(json['playerId']),
      badgeId: serializer.fromJson<String>(json['badgeId']),
      earnedAt: serializer.fromJson<int>(json['earnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playerId': serializer.toJson<int>(playerId),
      'badgeId': serializer.toJson<String>(badgeId),
      'earnedAt': serializer.toJson<int>(earnedAt),
    };
  }

  EarnedBadge copyWith({int? playerId, String? badgeId, int? earnedAt}) =>
      EarnedBadge(
        playerId: playerId ?? this.playerId,
        badgeId: badgeId ?? this.badgeId,
        earnedAt: earnedAt ?? this.earnedAt,
      );
  EarnedBadge copyWithCompanion(EarnedBadgesCompanion data) {
    return EarnedBadge(
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      badgeId: data.badgeId.present ? data.badgeId.value : this.badgeId,
      earnedAt: data.earnedAt.present ? data.earnedAt.value : this.earnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadge(')
          ..write('playerId: $playerId, ')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playerId, badgeId, earnedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EarnedBadge &&
          other.playerId == this.playerId &&
          other.badgeId == this.badgeId &&
          other.earnedAt == this.earnedAt);
}

class EarnedBadgesCompanion extends UpdateCompanion<EarnedBadge> {
  final Value<int> playerId;
  final Value<String> badgeId;
  final Value<int> earnedAt;
  final Value<int> rowid;
  const EarnedBadgesCompanion({
    this.playerId = const Value.absent(),
    this.badgeId = const Value.absent(),
    this.earnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EarnedBadgesCompanion.insert({
    required int playerId,
    required String badgeId,
    required int earnedAt,
    this.rowid = const Value.absent(),
  }) : playerId = Value(playerId),
       badgeId = Value(badgeId),
       earnedAt = Value(earnedAt);
  static Insertable<EarnedBadge> custom({
    Expression<int>? playerId,
    Expression<String>? badgeId,
    Expression<int>? earnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playerId != null) 'player_id': playerId,
      if (badgeId != null) 'badge_id': badgeId,
      if (earnedAt != null) 'earned_at': earnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EarnedBadgesCompanion copyWith({
    Value<int>? playerId,
    Value<String>? badgeId,
    Value<int>? earnedAt,
    Value<int>? rowid,
  }) {
    return EarnedBadgesCompanion(
      playerId: playerId ?? this.playerId,
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (badgeId.present) {
      map['badge_id'] = Variable<String>(badgeId.value);
    }
    if (earnedAt.present) {
      map['earned_at'] = Variable<int>(earnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EarnedBadgesCompanion(')
          ..write('playerId: $playerId, ')
          ..write('badgeId: $badgeId, ')
          ..write('earnedAt: $earnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PointsLedgerTable extends PointsLedger
    with TableInfo<$PointsLedgerTable, PointsEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointsLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<int> playerId = GeneratedColumn<int>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES players (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _matchIdMeta = const VerificationMeta(
    'matchId',
  );
  @override
  late final GeneratedColumn<int> matchId = GeneratedColumn<int>(
    'match_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES matches (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    playerId,
    amount,
    reason,
    detail,
    matchId,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<PointsEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    if (data.containsKey('match_id')) {
      context.handle(
        _matchIdMeta,
        matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointsEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointsEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}player_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
      matchId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}match_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $PointsLedgerTable createAlias(String alias) {
    return $PointsLedgerTable(attachedDatabase, alias);
  }
}

class PointsEntryRow extends DataClass implements Insertable<PointsEntryRow> {
  final int id;
  final int playerId;
  final int amount;

  /// `PointsReason.name`, or `purchase`.
  final String reason;
  final String? detail;
  final int? matchId;
  final int at;
  const PointsEntryRow({
    required this.id,
    required this.playerId,
    required this.amount,
    required this.reason,
    this.detail,
    this.matchId,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['player_id'] = Variable<int>(playerId);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    if (!nullToAbsent || matchId != null) {
      map['match_id'] = Variable<int>(matchId);
    }
    map['at'] = Variable<int>(at);
    return map;
  }

  PointsLedgerCompanion toCompanion(bool nullToAbsent) {
    return PointsLedgerCompanion(
      id: Value(id),
      playerId: Value(playerId),
      amount: Value(amount),
      reason: Value(reason),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
      matchId: matchId == null && nullToAbsent
          ? const Value.absent()
          : Value(matchId),
      at: Value(at),
    );
  }

  factory PointsEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointsEntryRow(
      id: serializer.fromJson<int>(json['id']),
      playerId: serializer.fromJson<int>(json['playerId']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
      detail: serializer.fromJson<String?>(json['detail']),
      matchId: serializer.fromJson<int?>(json['matchId']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playerId': serializer.toJson<int>(playerId),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
      'detail': serializer.toJson<String?>(detail),
      'matchId': serializer.toJson<int?>(matchId),
      'at': serializer.toJson<int>(at),
    };
  }

  PointsEntryRow copyWith({
    int? id,
    int? playerId,
    int? amount,
    String? reason,
    Value<String?> detail = const Value.absent(),
    Value<int?> matchId = const Value.absent(),
    int? at,
  }) => PointsEntryRow(
    id: id ?? this.id,
    playerId: playerId ?? this.playerId,
    amount: amount ?? this.amount,
    reason: reason ?? this.reason,
    detail: detail.present ? detail.value : this.detail,
    matchId: matchId.present ? matchId.value : this.matchId,
    at: at ?? this.at,
  );
  PointsEntryRow copyWithCompanion(PointsLedgerCompanion data) {
    return PointsEntryRow(
      id: data.id.present ? data.id.value : this.id,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
      detail: data.detail.present ? data.detail.value : this.detail,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointsEntryRow(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('detail: $detail, ')
          ..write('matchId: $matchId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, playerId, amount, reason, detail, matchId, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointsEntryRow &&
          other.id == this.id &&
          other.playerId == this.playerId &&
          other.amount == this.amount &&
          other.reason == this.reason &&
          other.detail == this.detail &&
          other.matchId == this.matchId &&
          other.at == this.at);
}

class PointsLedgerCompanion extends UpdateCompanion<PointsEntryRow> {
  final Value<int> id;
  final Value<int> playerId;
  final Value<int> amount;
  final Value<String> reason;
  final Value<String?> detail;
  final Value<int?> matchId;
  final Value<int> at;
  const PointsLedgerCompanion({
    this.id = const Value.absent(),
    this.playerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.detail = const Value.absent(),
    this.matchId = const Value.absent(),
    this.at = const Value.absent(),
  });
  PointsLedgerCompanion.insert({
    this.id = const Value.absent(),
    required int playerId,
    required int amount,
    required String reason,
    this.detail = const Value.absent(),
    this.matchId = const Value.absent(),
    required int at,
  }) : playerId = Value(playerId),
       amount = Value(amount),
       reason = Value(reason),
       at = Value(at);
  static Insertable<PointsEntryRow> custom({
    Expression<int>? id,
    Expression<int>? playerId,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<String>? detail,
    Expression<int>? matchId,
    Expression<int>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playerId != null) 'player_id': playerId,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (detail != null) 'detail': detail,
      if (matchId != null) 'match_id': matchId,
      if (at != null) 'at': at,
    });
  }

  PointsLedgerCompanion copyWith({
    Value<int>? id,
    Value<int>? playerId,
    Value<int>? amount,
    Value<String>? reason,
    Value<String?>? detail,
    Value<int?>? matchId,
    Value<int>? at,
  }) {
    return PointsLedgerCompanion(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      detail: detail ?? this.detail,
      matchId: matchId ?? this.matchId,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<int>(playerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<int>(matchId.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointsLedgerCompanion(')
          ..write('id: $id, ')
          ..write('playerId: $playerId, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('detail: $detail, ')
          ..write('matchId: $matchId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $GameSettingsLastTable gameSettingsLast = $GameSettingsLastTable(
    this,
  );
  late final $SavedSessionsTable savedSessions = $SavedSessionsTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $MatchParticipantsTable matchParticipants =
      $MatchParticipantsTable(this);
  late final $PlayerCountersTable playerCounters = $PlayerCountersTable(this);
  late final $EarnedBadgesTable earnedBadges = $EarnedBadgesTable(this);
  late final $PointsLedgerTable pointsLedger = $PointsLedgerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    appSettings,
    gameSettingsLast,
    savedSessions,
    matches,
    matchParticipants,
    playerCounters,
    earnedBadges,
    pointsLedger,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'matches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('match_participants', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'players',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('match_participants', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'players',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('player_counters', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'players',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('earned_badges', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'players',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('points_ledger', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'matches',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('points_ledger', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  required String name,
  required String nameKey,
  required String avatarJson,
  Value<int?> favoriteSeat,
  required DateTime createdAt,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameKey,
  Value<String> avatarJson,
  Value<int?> favoriteSeat,
  Value<DateTime> createdAt,
});

final class $$PlayersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayersTable, Player> {
  $$PlayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchParticipantsTable, List<MatchParticipantRow>>
  _matchParticipantsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.matchParticipants,
        aliasName: 'players__id__match_participants__player_id',
      );

  $$MatchParticipantsTableProcessedTableManager get matchParticipantsRefs {
    final manager = $$MatchParticipantsTableTableManager(
      $_db,
      $_db.matchParticipants,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _matchParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlayerCountersTable, List<PlayerCounter>>
  _playerCountersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playerCounters,
    aliasName: 'players__id__player_counters__player_id',
  );

  $$PlayerCountersTableProcessedTableManager get playerCountersRefs {
    final manager = $$PlayerCountersTableTableManager(
      $_db,
      $_db.playerCounters,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playerCountersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EarnedBadgesTable, List<EarnedBadge>>
  _earnedBadgesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.earnedBadges,
    aliasName: 'players__id__earned_badges__player_id',
  );

  $$EarnedBadgesTableProcessedTableManager get earnedBadgesRefs {
    final manager = $$EarnedBadgesTableTableManager(
      $_db,
      $_db.earnedBadges,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_earnedBadgesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PointsLedgerTable, List<PointsEntryRow>>
  _pointsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pointsLedger,
    aliasName: 'players__id__points_ledger__player_id',
  );

  $$PointsLedgerTableProcessedTableManager get pointsLedgerRefs {
    final manager = $$PointsLedgerTableTableManager(
      $_db,
      $_db.pointsLedger,
    ).filter((f) => f.playerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pointsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarJson => $composableBuilder(
    column: $table.avatarJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get favoriteSeat => $composableBuilder(
    column: $table.favoriteSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchParticipantsRefs(
    Expression<bool> Function($$MatchParticipantsTableFilterComposer f) f,
  ) {
    final $$MatchParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchParticipants,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.matchParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> playerCountersRefs(
    Expression<bool> Function($$PlayerCountersTableFilterComposer f) f,
  ) {
    final $$PlayerCountersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerCounters,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerCountersTableFilterComposer(
            $db: $db,
            $table: $db.playerCounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> earnedBadgesRefs(
    Expression<bool> Function($$EarnedBadgesTableFilterComposer f) f,
  ) {
    final $$EarnedBadgesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.earnedBadges,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarnedBadgesTableFilterComposer(
            $db: $db,
            $table: $db.earnedBadges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pointsLedgerRefs(
    Expression<bool> Function($$PointsLedgerTableFilterComposer f) f,
  ) {
    final $$PointsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsLedger,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.pointsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarJson => $composableBuilder(
    column: $table.avatarJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get favoriteSeat => $composableBuilder(
    column: $table.favoriteSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get avatarJson => $composableBuilder(
    column: $table.avatarJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get favoriteSeat => $composableBuilder(
    column: $table.favoriteSeat,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> matchParticipantsRefs<T extends Object>(
    Expression<T> Function($$MatchParticipantsTableAnnotationComposer a) f,
  ) {
    final $$MatchParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.matchParticipants,
          getReferencedColumn: (t) => t.playerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MatchParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.matchParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> playerCountersRefs<T extends Object>(
    Expression<T> Function($$PlayerCountersTableAnnotationComposer a) f,
  ) {
    final $$PlayerCountersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playerCounters,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayerCountersTableAnnotationComposer(
            $db: $db,
            $table: $db.playerCounters,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> earnedBadgesRefs<T extends Object>(
    Expression<T> Function($$EarnedBadgesTableAnnotationComposer a) f,
  ) {
    final $$EarnedBadgesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.earnedBadges,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EarnedBadgesTableAnnotationComposer(
            $db: $db,
            $table: $db.earnedBadges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pointsLedgerRefs<T extends Object>(
    Expression<T> Function($$PointsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PointsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsLedger,
      getReferencedColumn: (t) => t.playerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.pointsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, $$PlayersTableReferences),
          Player,
          PrefetchHooks Function({
            bool matchParticipantsRefs,
            bool playerCountersRefs,
            bool earnedBadgesRefs,
            bool pointsLedgerRefs,
          })
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> avatarJson = const Value.absent(),
                Value<int?> favoriteSeat = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                avatarJson: avatarJson,
                favoriteSeat: favoriteSeat,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameKey,
                required String avatarJson,
                Value<int?> favoriteSeat = const Value.absent(),
                required DateTime createdAt,
              }) => PlayersCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                avatarJson: avatarJson,
                favoriteSeat: favoriteSeat,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayersTable, Player>(table),
                  $$PlayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                matchParticipantsRefs = false,
                playerCountersRefs = false,
                earnedBadgesRefs = false,
                pointsLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchParticipantsRefs) db.matchParticipants,
                    if (playerCountersRefs) db.playerCounters,
                    if (earnedBadgesRefs) db.earnedBadges,
                    if (pointsLedgerRefs) db.pointsLedger,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchParticipantsRefs)
                        await $_getPrefetchedDataByColumns<
                          Player,
                          $PlayersTable,
                          MatchParticipantRow,
                          $MatchParticipantsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._matchParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).matchParticipantsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'player_id',
                          typedResults: items,
                        ),
                      if (playerCountersRefs)
                        await $_getPrefetchedDataByColumns<
                          Player,
                          $PlayersTable,
                          PlayerCounter,
                          $PlayerCountersTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._playerCountersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).playerCountersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'player_id',
                          typedResults: items,
                        ),
                      if (earnedBadgesRefs)
                        await $_getPrefetchedDataByColumns<
                          Player,
                          $PlayersTable,
                          EarnedBadge,
                          $EarnedBadgesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._earnedBadgesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).earnedBadgesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'player_id',
                          typedResults: items,
                        ),
                      if (pointsLedgerRefs)
                        await $_getPrefetchedDataByColumns<
                          Player,
                          $PlayersTable,
                          PointsEntryRow,
                          $PointsLedgerTable
                        >(
                          currentTable: table,
                          referencedTable: $$PlayersTableReferences
                              ._pointsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlayersTableReferences(
                                db,
                                table,
                                p0,
                              ).pointsLedgerRefs,
                          currentColumn: 'id',
                          referencedColumn: 'player_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, $$PlayersTableReferences),
      Player,
      PrefetchHooks Function({
        bool matchParticipantsRefs,
        bool playerCountersRefs,
        bool earnedBadgesRefs,
        bool pointsLedgerRefs,
      })
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$GameSettingsLastTableCreateCompanionBuilder =
    GameSettingsLastCompanion Function({
      required String gameId,
      required String configJson,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$GameSettingsLastTableUpdateCompanionBuilder =
    GameSettingsLastCompanion Function({
      Value<String> gameId,
      Value<String> configJson,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$GameSettingsLastTableFilterComposer
    extends Composer<_$AppDatabase, $GameSettingsLastTable> {
  $$GameSettingsLastTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSettingsLastTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSettingsLastTable> {
  $$GameSettingsLastTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSettingsLastTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSettingsLastTable> {
  $$GameSettingsLastTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GameSettingsLastTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSettingsLastTable,
          GameSettingsLastData,
          $$GameSettingsLastTableFilterComposer,
          $$GameSettingsLastTableOrderingComposer,
          $$GameSettingsLastTableAnnotationComposer,
          $$GameSettingsLastTableCreateCompanionBuilder,
          $$GameSettingsLastTableUpdateCompanionBuilder,
          (
            GameSettingsLastData,
            BaseReferences<
              _$AppDatabase,
              $GameSettingsLastTable,
              GameSettingsLastData
            >,
          ),
          GameSettingsLastData,
          PrefetchHooks Function()
        > {
  $$GameSettingsLastTableTableManager(
    _$AppDatabase db,
    $GameSettingsLastTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSettingsLastTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSettingsLastTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSettingsLastTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSettingsLastCompanion(
                gameId: gameId,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required String configJson,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GameSettingsLastCompanion.insert(
                gameId: gameId,
                configJson: configJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSettingsLastTable, GameSettingsLastData>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $GameSettingsLastTable,
                    GameSettingsLastData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSettingsLastTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSettingsLastTable,
      GameSettingsLastData,
      $$GameSettingsLastTableFilterComposer,
      $$GameSettingsLastTableOrderingComposer,
      $$GameSettingsLastTableAnnotationComposer,
      $$GameSettingsLastTableCreateCompanionBuilder,
      $$GameSettingsLastTableUpdateCompanionBuilder,
      (
        GameSettingsLastData,
        BaseReferences<
          _$AppDatabase,
          $GameSettingsLastTable,
          GameSettingsLastData
        >,
      ),
      GameSettingsLastData,
      PrefetchHooks Function()
    >;
typedef $$SavedSessionsTableCreateCompanionBuilder =
    SavedSessionsCompanion Function({
      required String gameId,
      required String saveJson,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$SavedSessionsTableUpdateCompanionBuilder =
    SavedSessionsCompanion Function({
      Value<String> gameId,
      Value<String> saveJson,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$SavedSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saveJson => $composableBuilder(
    column: $table.saveJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saveJson => $composableBuilder(
    column: $table.saveJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get saveJson =>
      $composableBuilder(column: $table.saveJson, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedSessionsTable,
          SavedSession,
          $$SavedSessionsTableFilterComposer,
          $$SavedSessionsTableOrderingComposer,
          $$SavedSessionsTableAnnotationComposer,
          $$SavedSessionsTableCreateCompanionBuilder,
          $$SavedSessionsTableUpdateCompanionBuilder,
          (
            SavedSession,
            BaseReferences<_$AppDatabase, $SavedSessionsTable, SavedSession>,
          ),
          SavedSession,
          PrefetchHooks Function()
        > {
  $$SavedSessionsTableTableManager(_$AppDatabase db, $SavedSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> saveJson = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedSessionsCompanion(
                gameId: gameId,
                saveJson: saveJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String gameId,
                required String saveJson,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavedSessionsCompanion.insert(
                gameId: gameId,
                saveJson: saveJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedSessionsTable, SavedSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SavedSessionsTable,
                    SavedSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedSessionsTable,
      SavedSession,
      $$SavedSessionsTableFilterComposer,
      $$SavedSessionsTableOrderingComposer,
      $$SavedSessionsTableAnnotationComposer,
      $$SavedSessionsTableCreateCompanionBuilder,
      $$SavedSessionsTableUpdateCompanionBuilder,
      (
        SavedSession,
        BaseReferences<_$AppDatabase, $SavedSessionsTable, SavedSession>,
      ),
      SavedSession,
      PrefetchHooks Function()
    >;
typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  required String gameId,
  required int playedAt,
  required int durationMs,
  Value<String?> difficulty,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<int> id,
  Value<String> gameId,
  Value<int> playedAt,
  Value<int> durationMs,
  Value<String?> difficulty,
});

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, MatchRow> {
  $$MatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MatchParticipantsTable, List<MatchParticipantRow>>
  _matchParticipantsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.matchParticipants,
        aliasName: 'matches__id__match_participants__match_id',
      );

  $$MatchParticipantsTableProcessedTableManager get matchParticipantsRefs {
    final manager = $$MatchParticipantsTableTableManager(
      $_db,
      $_db.matchParticipants,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _matchParticipantsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PointsLedgerTable, List<PointsEntryRow>>
  _pointsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pointsLedger,
    aliasName: 'matches__id__points_ledger__match_id',
  );

  $$PointsLedgerTableProcessedTableManager get pointsLedgerRefs {
    final manager = $$PointsLedgerTableTableManager(
      $_db,
      $_db.pointsLedger,
    ).filter((f) => f.matchId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pointsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> matchParticipantsRefs(
    Expression<bool> Function($$MatchParticipantsTableFilterComposer f) f,
  ) {
    final $$MatchParticipantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matchParticipants,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchParticipantsTableFilterComposer(
            $db: $db,
            $table: $db.matchParticipants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pointsLedgerRefs(
    Expression<bool> Function($$PointsLedgerTableFilterComposer f) f,
  ) {
    final $$PointsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsLedger,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.pointsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  Expression<T> matchParticipantsRefs<T extends Object>(
    Expression<T> Function($$MatchParticipantsTableAnnotationComposer a) f,
  ) {
    final $$MatchParticipantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.matchParticipants,
          getReferencedColumn: (t) => t.matchId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MatchParticipantsTableAnnotationComposer(
                $db: $db,
                $table: $db.matchParticipants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> pointsLedgerRefs<T extends Object>(
    Expression<T> Function($$PointsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PointsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pointsLedger,
      getReferencedColumn: (t) => t.matchId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PointsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.pointsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          MatchRow,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (MatchRow, $$MatchesTableReferences),
          MatchRow,
          PrefetchHooks Function({
            bool matchParticipantsRefs,
            bool pointsLedgerRefs,
          })
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<int> playedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                gameId: gameId,
                playedAt: playedAt,
                durationMs: durationMs,
                difficulty: difficulty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String gameId,
                required int playedAt,
                required int durationMs,
                Value<String?> difficulty = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                gameId: gameId,
                playedAt: playedAt,
                durationMs: durationMs,
                difficulty: difficulty,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchesTable, MatchRow>(table),
                  $$MatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({matchParticipantsRefs = false, pointsLedgerRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (matchParticipantsRefs) db.matchParticipants,
                    if (pointsLedgerRefs) db.pointsLedger,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchParticipantsRefs)
                        await $_getPrefetchedDataByColumns<
                          MatchRow,
                          $MatchesTable,
                          MatchParticipantRow,
                          $MatchParticipantsTable
                        >(
                          currentTable: table,
                          referencedTable: $$MatchesTableReferences
                              ._matchParticipantsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).matchParticipantsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'match_id',
                          typedResults: items,
                        ),
                      if (pointsLedgerRefs)
                        await $_getPrefetchedDataByColumns<
                          MatchRow,
                          $MatchesTable,
                          PointsEntryRow,
                          $PointsLedgerTable
                        >(
                          currentTable: table,
                          referencedTable: $$MatchesTableReferences
                              ._pointsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).pointsLedgerRefs,
                          currentColumn: 'id',
                          referencedColumn: 'match_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      MatchRow,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (MatchRow, $$MatchesTableReferences),
      MatchRow,
      PrefetchHooks Function({
        bool matchParticipantsRefs,
        bool pointsLedgerRefs,
      })
    >;
typedef $$MatchParticipantsTableCreateCompanionBuilder =
    MatchParticipantsCompanion Function({
      required int matchId,
      required int seat,
      Value<int?> playerId,
      required bool robot,
      required int place,
      required int score,
      required int stars,
      Value<int> rowid,
    });
typedef $$MatchParticipantsTableUpdateCompanionBuilder =
    MatchParticipantsCompanion Function({
      Value<int> matchId,
      Value<int> seat,
      Value<int?> playerId,
      Value<bool> robot,
      Value<int> place,
      Value<int> score,
      Value<int> stars,
      Value<int> rowid,
    });

final class $$MatchParticipantsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MatchParticipantsTable,
          MatchParticipantRow
        > {
  $$MatchParticipantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MatchesTable _matchIdTable(_$AppDatabase db) =>
      db.matches.createAlias('match_participants__match_id__matches__id');

  $$MatchesTableProcessedTableManager get matchId {
    final $_column = $_itemColumn<int>('match_id')!;

    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('match_participants__player_id__players__id');

  $$PlayersTableProcessedTableManager? get playerId {
    final $_column = $_itemColumn<int>('player_id');
    if ($_column == null) return null;
    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MatchParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get robot => $composableBuilder(
    column: $table.robot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get robot => $composableBuilder(
    column: $table.robot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableOrderingComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchParticipantsTable> {
  $$MatchParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumn<bool> get robot =>
      $composableBuilder(column: $table.robot, builder: (column) => column);

  GeneratedColumn<int> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  $$MatchesTableAnnotationComposer get matchId {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchParticipantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchParticipantsTable,
          MatchParticipantRow,
          $$MatchParticipantsTableFilterComposer,
          $$MatchParticipantsTableOrderingComposer,
          $$MatchParticipantsTableAnnotationComposer,
          $$MatchParticipantsTableCreateCompanionBuilder,
          $$MatchParticipantsTableUpdateCompanionBuilder,
          (MatchParticipantRow, $$MatchParticipantsTableReferences),
          MatchParticipantRow,
          PrefetchHooks Function({bool matchId, bool playerId})
        > {
  $$MatchParticipantsTableTableManager(
    _$AppDatabase db,
    $MatchParticipantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchParticipantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> matchId = const Value.absent(),
                Value<int> seat = const Value.absent(),
                Value<int?> playerId = const Value.absent(),
                Value<bool> robot = const Value.absent(),
                Value<int> place = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchParticipantsCompanion(
                matchId: matchId,
                seat: seat,
                playerId: playerId,
                robot: robot,
                place: place,
                score: score,
                stars: stars,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int matchId,
                required int seat,
                Value<int?> playerId = const Value.absent(),
                required bool robot,
                required int place,
                required int score,
                required int stars,
                Value<int> rowid = const Value.absent(),
              }) => MatchParticipantsCompanion.insert(
                matchId: matchId,
                seat: seat,
                playerId: playerId,
                robot: robot,
                place: place,
                score: score,
                stars: stars,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MatchParticipantsTable, MatchParticipantRow>(
                    table,
                  ),
                  $$MatchParticipantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({matchId = false, playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (matchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.matchId,
                        referencedTable: $$MatchParticipantsTableReferences
                            ._matchIdTable(db),
                        referencedColumn: $$MatchParticipantsTableReferences
                            ._matchIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$MatchParticipantsTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$MatchParticipantsTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MatchParticipantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchParticipantsTable,
      MatchParticipantRow,
      $$MatchParticipantsTableFilterComposer,
      $$MatchParticipantsTableOrderingComposer,
      $$MatchParticipantsTableAnnotationComposer,
      $$MatchParticipantsTableCreateCompanionBuilder,
      $$MatchParticipantsTableUpdateCompanionBuilder,
      (MatchParticipantRow, $$MatchParticipantsTableReferences),
      MatchParticipantRow,
      PrefetchHooks Function({bool matchId, bool playerId})
    >;
typedef $$PlayerCountersTableCreateCompanionBuilder =
    PlayerCountersCompanion Function({
      required int playerId,
      required String key,
      required int value,
      Value<int> rowid,
    });
typedef $$PlayerCountersTableUpdateCompanionBuilder =
    PlayerCountersCompanion Function({
      Value<int> playerId,
      Value<String> key,
      Value<int> value,
      Value<int> rowid,
    });

final class $$PlayerCountersTableReferences
    extends BaseReferences<_$AppDatabase, $PlayerCountersTable, PlayerCounter> {
  $$PlayerCountersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('player_counters__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayerCountersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerCountersTable> {
  $$PlayerCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerCountersTable> {
  $$PlayerCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerCountersTable> {
  $$PlayerCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayerCountersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerCountersTable,
          PlayerCounter,
          $$PlayerCountersTableFilterComposer,
          $$PlayerCountersTableOrderingComposer,
          $$PlayerCountersTableAnnotationComposer,
          $$PlayerCountersTableCreateCompanionBuilder,
          $$PlayerCountersTableUpdateCompanionBuilder,
          (PlayerCounter, $$PlayerCountersTableReferences),
          PlayerCounter,
          PrefetchHooks Function({bool playerId})
        > {
  $$PlayerCountersTableTableManager(
    _$AppDatabase db,
    $PlayerCountersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerCountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerCountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerCountersCompanion(
                playerId: playerId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int playerId,
                required String key,
                required int value,
                Value<int> rowid = const Value.absent(),
              }) => PlayerCountersCompanion.insert(
                playerId: playerId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerCountersTable, PlayerCounter>(table),
                  $$PlayerCountersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$PlayerCountersTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$PlayerCountersTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayerCountersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerCountersTable,
      PlayerCounter,
      $$PlayerCountersTableFilterComposer,
      $$PlayerCountersTableOrderingComposer,
      $$PlayerCountersTableAnnotationComposer,
      $$PlayerCountersTableCreateCompanionBuilder,
      $$PlayerCountersTableUpdateCompanionBuilder,
      (PlayerCounter, $$PlayerCountersTableReferences),
      PlayerCounter,
      PrefetchHooks Function({bool playerId})
    >;
typedef $$EarnedBadgesTableCreateCompanionBuilder =
    EarnedBadgesCompanion Function({
      required int playerId,
      required String badgeId,
      required int earnedAt,
      Value<int> rowid,
    });
typedef $$EarnedBadgesTableUpdateCompanionBuilder =
    EarnedBadgesCompanion Function({
      Value<int> playerId,
      Value<String> badgeId,
      Value<int> earnedAt,
      Value<int> rowid,
    });

final class $$EarnedBadgesTableReferences
    extends BaseReferences<_$AppDatabase, $EarnedBadgesTable, EarnedBadge> {
  $$EarnedBadgesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('earned_badges__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EarnedBadgesTableFilterComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarnedBadgesTableOrderingComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get badgeId => $composableBuilder(
    column: $table.badgeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnedAt => $composableBuilder(
    column: $table.earnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarnedBadgesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EarnedBadgesTable> {
  $$EarnedBadgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get badgeId =>
      $composableBuilder(column: $table.badgeId, builder: (column) => column);

  GeneratedColumn<int> get earnedAt =>
      $composableBuilder(column: $table.earnedAt, builder: (column) => column);

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EarnedBadgesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EarnedBadgesTable,
          EarnedBadge,
          $$EarnedBadgesTableFilterComposer,
          $$EarnedBadgesTableOrderingComposer,
          $$EarnedBadgesTableAnnotationComposer,
          $$EarnedBadgesTableCreateCompanionBuilder,
          $$EarnedBadgesTableUpdateCompanionBuilder,
          (EarnedBadge, $$EarnedBadgesTableReferences),
          EarnedBadge,
          PrefetchHooks Function({bool playerId})
        > {
  $$EarnedBadgesTableTableManager(_$AppDatabase db, $EarnedBadgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EarnedBadgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EarnedBadgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EarnedBadgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> playerId = const Value.absent(),
                Value<String> badgeId = const Value.absent(),
                Value<int> earnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EarnedBadgesCompanion(
                playerId: playerId,
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int playerId,
                required String badgeId,
                required int earnedAt,
                Value<int> rowid = const Value.absent(),
              }) => EarnedBadgesCompanion.insert(
                playerId: playerId,
                badgeId: badgeId,
                earnedAt: earnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EarnedBadgesTable, EarnedBadge>(table),
                  $$EarnedBadgesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$EarnedBadgesTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$EarnedBadgesTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EarnedBadgesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EarnedBadgesTable,
      EarnedBadge,
      $$EarnedBadgesTableFilterComposer,
      $$EarnedBadgesTableOrderingComposer,
      $$EarnedBadgesTableAnnotationComposer,
      $$EarnedBadgesTableCreateCompanionBuilder,
      $$EarnedBadgesTableUpdateCompanionBuilder,
      (EarnedBadge, $$EarnedBadgesTableReferences),
      EarnedBadge,
      PrefetchHooks Function({bool playerId})
    >;
typedef $$PointsLedgerTableCreateCompanionBuilder =
    PointsLedgerCompanion Function({
      Value<int> id,
      required int playerId,
      required int amount,
      required String reason,
      Value<String?> detail,
      Value<int?> matchId,
      required int at,
    });
typedef $$PointsLedgerTableUpdateCompanionBuilder =
    PointsLedgerCompanion Function({
      Value<int> id,
      Value<int> playerId,
      Value<int> amount,
      Value<String> reason,
      Value<String?> detail,
      Value<int?> matchId,
      Value<int> at,
    });

final class $$PointsLedgerTableReferences
    extends BaseReferences<_$AppDatabase, $PointsLedgerTable, PointsEntryRow> {
  $$PointsLedgerTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlayersTable _playerIdTable(_$AppDatabase db) =>
      db.players.createAlias('points_ledger__player_id__players__id');

  $$PlayersTableProcessedTableManager get playerId {
    final $_column = $_itemColumn<int>('player_id')!;

    final manager = $$PlayersTableTableManager(
      $_db,
      $_db.players,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MatchesTable _matchIdTable(_$AppDatabase db) =>
      db.matches.createAlias('points_ledger__match_id__matches__id');

  $$MatchesTableProcessedTableManager? get matchId {
    final $_column = $_itemColumn<int>('match_id');
    if ($_column == null) return null;
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_matchIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PointsLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $PointsLedgerTable> {
  $$PointsLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  $$PlayersTableFilterComposer get playerId {
    final $$PlayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableFilterComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableFilterComposer get matchId {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointsLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $PointsLedgerTable> {
  $$PointsLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlayersTableOrderingComposer get playerId {
    final $$PlayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableOrderingComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableOrderingComposer get matchId {
    final $$MatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableOrderingComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointsLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointsLedgerTable> {
  $$PointsLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  $$PlayersTableAnnotationComposer get playerId {
    final $$PlayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playerId,
      referencedTable: $db.players,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayersTableAnnotationComposer(
            $db: $db,
            $table: $db.players,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MatchesTableAnnotationComposer get matchId {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.matchId,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PointsLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PointsLedgerTable,
          PointsEntryRow,
          $$PointsLedgerTableFilterComposer,
          $$PointsLedgerTableOrderingComposer,
          $$PointsLedgerTableAnnotationComposer,
          $$PointsLedgerTableCreateCompanionBuilder,
          $$PointsLedgerTableUpdateCompanionBuilder,
          (PointsEntryRow, $$PointsLedgerTableReferences),
          PointsEntryRow,
          PrefetchHooks Function({bool playerId, bool matchId})
        > {
  $$PointsLedgerTableTableManager(_$AppDatabase db, $PointsLedgerTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointsLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointsLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointsLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playerId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> detail = const Value.absent(),
                Value<int?> matchId = const Value.absent(),
                Value<int> at = const Value.absent(),
              }) => PointsLedgerCompanion(
                id: id,
                playerId: playerId,
                amount: amount,
                reason: reason,
                detail: detail,
                matchId: matchId,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playerId,
                required int amount,
                required String reason,
                Value<String?> detail = const Value.absent(),
                Value<int?> matchId = const Value.absent(),
                required int at,
              }) => PointsLedgerCompanion.insert(
                id: id,
                playerId: playerId,
                amount: amount,
                reason: reason,
                detail: detail,
                matchId: matchId,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PointsLedgerTable, PointsEntryRow>(table),
                  $$PointsLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playerId = false, matchId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.playerId,
                        referencedTable: $$PointsLedgerTableReferences
                            ._playerIdTable(db),
                        referencedColumn: $$PointsLedgerTableReferences
                            ._playerIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (matchId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.matchId,
                        referencedTable: $$PointsLedgerTableReferences
                            ._matchIdTable(db),
                        referencedColumn: $$PointsLedgerTableReferences
                            ._matchIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PointsLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PointsLedgerTable,
      PointsEntryRow,
      $$PointsLedgerTableFilterComposer,
      $$PointsLedgerTableOrderingComposer,
      $$PointsLedgerTableAnnotationComposer,
      $$PointsLedgerTableCreateCompanionBuilder,
      $$PointsLedgerTableUpdateCompanionBuilder,
      (PointsEntryRow, $$PointsLedgerTableReferences),
      PointsEntryRow,
      PrefetchHooks Function({bool playerId, bool matchId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$GameSettingsLastTableTableManager get gameSettingsLast =>
      $$GameSettingsLastTableTableManager(_db, _db.gameSettingsLast);
  $$SavedSessionsTableTableManager get savedSessions =>
      $$SavedSessionsTableTableManager(_db, _db.savedSessions);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$MatchParticipantsTableTableManager get matchParticipants =>
      $$MatchParticipantsTableTableManager(_db, _db.matchParticipants);
  $$PlayerCountersTableTableManager get playerCounters =>
      $$PlayerCountersTableTableManager(_db, _db.playerCounters);
  $$EarnedBadgesTableTableManager get earnedBadges =>
      $$EarnedBadgesTableTableManager(_db, _db.earnedBadges);
  $$PointsLedgerTableTableManager get pointsLedger =>
      $$PointsLedgerTableTableManager(_db, _db.pointsLedger);
}
