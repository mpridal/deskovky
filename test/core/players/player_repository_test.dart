import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/players/player_profile.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _fails(ProfileError error) => throwsA(isA<ProfileException>().having((e) => e.error, 'error', error));

void main() {
  late AppDatabase db;
  late PlayerRepository repo;
  const avatar = AvatarSpec.defaults;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = PlayerRepository(db);
  });
  tearDown(() => db.close());

  test('create returns a profile with id and creation time', () async {
    final p = await repo.create(name: 'Tereza', avatar: avatar);
    expect(p.id, isPositive);
    expect(p.name, 'Tereza');
    expect(p.createdAt.isUtc, isTrue);
    expect(await repo.byId(p.id), p);
  });

  test('name is trimmed', () async {
    expect((await repo.create(name: '  Kuba  ', avatar: avatar)).name, 'Kuba');
  });

  test('empty name is rejected', () async {
    expect(() => repo.create(name: '', avatar: avatar), _fails(ProfileError.nameEmpty));
    expect(() => repo.create(name: '   ', avatar: avatar), _fails(ProfileError.nameEmpty));
  });

  test('16 characters pass, 17 are too long, emoji count as one', () async {
    await repo.create(name: 'A' * 16, avatar: avatar);
    expect(() => repo.create(name: 'B' * 17, avatar: avatar), _fails(ProfileError.nameTooLong));
    expect((await repo.create(name: 'Žofie🦄', avatar: avatar)).name, 'Žofie🦄');
    expect((await repo.create(name: '🦄' * 16, avatar: avatar)).name, '🦄' * 16);
  });

  test('names are unique regardless of case and outer spaces', () async {
    await repo.create(name: 'Tereza', avatar: avatar);
    expect(() => repo.create(name: 'tereza', avatar: avatar), _fails(ProfileError.nameTaken));
    expect(() => repo.create(name: ' TEREZA ', avatar: avatar), _fails(ProfileError.nameTaken));
    expect((await repo.create(name: 'Teréza', avatar: avatar)).name, 'Teréza');
  });

  test('update cannot take another player\'s name but may change own case', () async {
    await repo.create(name: 'Tereza', avatar: avatar);
    final kuba = await repo.create(name: 'Kuba', avatar: avatar);
    expect(() => repo.update(kuba.id, name: 'tereza'), _fails(ProfileError.nameTaken));
    expect((await repo.update(kuba.id, name: 'KUBA')).name, 'KUBA');
  });

  test('update validates the name too', () async {
    final p = await repo.create(name: 'Kuba', avatar: avatar);
    expect(() => repo.update(p.id, name: ' '), _fails(ProfileError.nameEmpty));
    expect(() => repo.update(p.id, name: 'C' * 17), _fails(ProfileError.nameTooLong));
  });

  test('at most 8 profiles', () async {
    for (var i = 1; i <= 8; i++) {
      await repo.create(name: 'Hráč $i', avatar: avatar);
    }
    expect(() => repo.create(name: 'Hráč 9', avatar: avatar), _fails(ProfileError.limitReached));
    expect(await repo.all(), hasLength(8));
  });

  test('delete and update of a missing profile report notFound', () async {
    expect(() => repo.delete(42), _fails(ProfileError.notFound));
    expect(() => repo.update(42, name: 'X'), _fails(ProfileError.notFound));
  });

  test('avatar and favorite seat round-trip', () async {
    const fancy = AvatarSpec(
      face: FaceShape.square,
      skin: 5,
      hair: HairStyle.braids,
      hairColor: 3,
      eyes: EyeStyle.wink,
      mouth: MouthStyle.grin,
      background: 6,
    );
    final p = await repo.create(name: 'Babi', avatar: fancy, favoriteSeat: 3);
    final loaded = (await repo.byId(p.id))!;
    expect(loaded.avatar, fancy);
    expect(loaded.favoriteSeat, 3);
  });

  test('a corrupted avatar in the database loads as defaults', () async {
    final p = await repo.create(name: 'Kuba', avatar: AvatarSpec.defaults.copyWith(hair: HairStyle.bob));
    await db.customStatement("UPDATE players SET avatar_json = 'not json' WHERE id = ${p.id}");
    expect((await repo.byId(p.id))!.avatar, AvatarSpec.defaults);
  });

  test('watchAll emits after create, update and delete, oldest first', () async {
    final names = <List<String>>[];
    final sub = repo.watchAll().listen((list) => names.add([for (final p in list) p.name]));
    addTearDown(sub.cancel);
    await pumpEventQueue();
    final a = await repo.create(name: 'Anna', avatar: avatar);
    await pumpEventQueue();
    await repo.create(name: 'Bára', avatar: avatar);
    await pumpEventQueue();
    await repo.update(a.id, name: 'Anička');
    await pumpEventQueue();
    await repo.delete(a.id);
    await pumpEventQueue();
    expect(names, [
      <String>[],
      ['Anna'],
      ['Anna', 'Bára'],
      ['Anička', 'Bára'],
      ['Bára'],
    ]);
  });
}
