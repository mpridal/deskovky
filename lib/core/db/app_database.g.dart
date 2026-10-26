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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $GameSettingsLastTable gameSettingsLast = $GameSettingsLastTable(
    this,
  );
  late final $SavedSessionsTable savedSessions = $SavedSessionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    players,
    appSettings,
    gameSettingsLast,
    savedSessions,
  ];
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
          (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
          Player,
          PrefetchHooks Function()
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
                  BaseReferences<_$AppDatabase, $PlayersTable, Player>(
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
      (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
      Player,
      PrefetchHooks Function()
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
}
