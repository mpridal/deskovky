import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/games/registry.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StatsRepository repo;
  late StatsService service;
  late int tereza;
  late int kuba;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = StatsRepository(db, now: () => DateTime(2026, 10, 21, 18));
    service = StatsService(repo);
    tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
    kuba = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  GameConfig config(List<SeatConfig> seats, {Difficulty difficulty = Difficulty.hard}) => GameConfig(
    gameId: 'sample',
    seats: seats,
    difficulty: difficulty,
    robotSpeed: RobotSpeed.fast,
    options: const {'range': 20},
  );

  test('stores the match with robots and the difficulty; the human winner earns badges', () async {
    final earned = await service.recordFinished(
      config: config([HumanSeat(tereza), const RobotSeat()]),
      result: const GameResult(places: [1, 2], scores: [3, 2], stars: [3, 1]),
      events: const [('sample.bullseye', {'seat': 0})],
      duration: const Duration(seconds: 42),
    );
    final match = (await repo.allMatches()).single;
    expect(match.difficulty, Difficulty.hard);
    expect(match.duration, const Duration(seconds: 42));
    expect(match.participants.map((p) => (p.playerId, p.robot)), [(tereza, false), (null, true)]);
    expect({for (final e in earned) (e.playerId, e.badge.id)}, {
      (tereza, 'first_win'),
      (tereza, 'hard_win'),
      (tereza, 'sample.bullseye'),
    });
  });

  test('only people play: no difficulty stored; the loser earns nothing; badges come once', () async {
    final seats = [HumanSeat(tereza), HumanSeat(kuba)];
    const result = GameResult(places: [2, 1], scores: [1, 2], stars: [1, 3]);
    final first = await service.recordFinished(
      config: config(seats),
      result: result,
      events: const [],
      duration: Duration.zero,
    );
    expect((await repo.allMatches()).single.difficulty, isNull);
    expect([for (final e in first) (e.playerId, e.badge.id)], [(kuba, 'first_win')]);
    final second = await service.recordFinished(
      config: config(seats),
      result: result,
      events: const [],
      duration: Duration.zero,
    );
    expect(second, isEmpty);
  });

  test('a seat whose profile was deleted meanwhile is stored as a deleted player, without error', () async {
    await PlayerRepository(db).delete(kuba);
    final earned = await service.recordFinished(
      config: config([HumanSeat(tereza), HumanSeat(kuba)]),
      result: const GameResult(places: [2, 1], scores: [1, 2], stars: [1, 3]),
      events: const [],
      duration: Duration.zero,
    );
    expect(earned, isEmpty);
    final p = (await repo.allMatches()).single.participants[1];
    expect(p.deletedPlayer, isTrue);
  });

  test('badges of every registered game are known to the service', () {
    expect(service.badgesFor('sample').map((b) => b.id), containsAll(['first_win', ...moduleById('sample')!.badges.map((b) => b.id)]));
  });
}
