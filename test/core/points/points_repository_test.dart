import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/points/levels.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PointsRepository points;
  late int tereza;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    points = PointsRepository(db, now: () => DateTime(2026, 10, 26, 9));
    tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  test('game lines and gifts add up; balance and total earned', () async {
    await points.addGameLines(tereza, const [PointsLine(PointsReason.win, 20), PointsLine(PointsReason.stars, 4, count: 2)]);
    await points.gift(tereza, 50);
    expect(await points.balance(tereza), 74);
    expect(await points.totalEarned(tereza), 74);
    final history = await points.history(tereza);
    expect(history.first.reason, PointsReason.gift, reason: 'newest first');
    expect(history.map((e) => e.amount), [50, 4, 20]);
    expect(history.last.at, DateTime(2026, 10, 26, 9));
  });

  test('a spend lowers the balance but never the total earned', () async {
    await points.gift(tereza, 100);
    await points.spend(tereza, 30, itemId: 'glasses');
    expect(await points.balance(tereza), 70);
    expect(await points.totalEarned(tereza), 100);
  });

  test('a gift must be positive', () async {
    expect(() => points.gift(tereza, 0), throwsArgumentError);
  });

  test('deleting the player deletes their ledger', () async {
    await points.gift(tereza, 10);
    await PlayerRepository(db).delete(tereza);
    expect(await points.history(tereza), isEmpty);
  });

  group('levels (spec 5.6)', () {
    test('level n needs 50·n·(n+1)/2 points; max 30', () {
      expect([for (final p in [0, 49, 50, 149, 150, 300, 2750, 1000000]) levelFor(p)], [0, 0, 1, 1, 2, 3, 10, 30]);
      expect(pointsForLevel(10), 2750);
    });

    test('progress towards the next level', () {
      final p = levelProgress(100);
      expect((p.level, p.current, p.needed), (1, 50, 100));
      expect(levelProgress(pointsForLevel(30) + 999).needed, 0, reason: 'max level has nothing left');
    });
  });
}
