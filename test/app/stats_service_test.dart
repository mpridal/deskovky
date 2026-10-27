import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/game/game_result.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
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
    service = StatsService(repo, points: PointsRepository(db, now: () => DateTime(2026, 10, 21, 18)));
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

  test('a game ended early (endedEarly) counts nothing: no match, points, wins or badges (spec 5.6)', () async {
    final rewards = await service.recordFinished(
      config: config([HumanSeat(tereza), const RobotSeat()]),
      result: const GameResult(places: [1, 2], scores: [3, 1], stars: [0, 0], stats: {'endedEarly': true}),
      events: const [],
      duration: const Duration(minutes: 2),
    );
    expect(rewards.points, isEmpty);
    expect(rewards.badges, isEmpty);
    expect(await repo.allMatches(), isEmpty);
    expect(await PointsRepository(db).balance(tereza), 0);
  });

  test('stores the match with robots and the difficulty; the human winner earns badges', () async {
    final earned = (await service.recordFinished(
      config: config([HumanSeat(tereza), const RobotSeat()]),
      result: const GameResult(places: [1, 2], scores: [3, 2], stars: [3, 1]),
      events: const [('sample.bullseye', {'seat': 0})],
      duration: const Duration(seconds: 42),
    )).badges;
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
    final first = (await service.recordFinished(
      config: config(seats),
      result: result,
      events: const [],
      duration: Duration.zero,
    )).badges;
    expect((await repo.allMatches()).single.difficulty, isNull);
    expect([for (final e in first) (e.playerId, e.badge.id)], [(kuba, 'first_win')]);
    final second = (await service.recordFinished(
      config: config(seats),
      result: result,
      events: const [],
      duration: Duration.zero,
    )).badges;
    expect(second, isEmpty);
  });

  test('a seat whose profile was deleted meanwhile is stored as a deleted player, without error', () async {
    await PlayerRepository(db).delete(kuba);
    final earned = (await service.recordFinished(
      config: config([HumanSeat(tereza), HumanSeat(kuba)]),
      result: const GameResult(places: [2, 1], scores: [1, 2], stars: [1, 3]),
      events: const [],
      duration: Duration.zero,
    )).badges;
    expect(earned, isEmpty);
    final p = (await repo.allMatches()).single.participants[1];
    expect(p.deletedPlayer, isTrue);
  });

  test('badges of every registered game are known to the service', () {
    expect(service.badgesFor('sample').map((b) => b.id), containsAll(['first_win', ...moduleById('sample')!.badges.map((b) => b.id)]));
  });

  group('points', () {
    test('a hard win over a robot: base, stars, first game today, badges; the robot gets nothing', () async {
      final rewards = await service.recordFinished(
        config: config([HumanSeat(tereza), const RobotSeat()]),
        result: const GameResult(places: [1, 2], scores: [3, 2], stars: [2, 1]),
        events: const [],
        duration: Duration.zero,
      );
      final mine = rewards.points[tereza]!;
      expect([for (final l in mine.lines) (l.reason, l.amount)], [
        (PointsReason.win, 35),
        (PointsReason.stars, 4),
        (PointsReason.firstToday, 5),
        (PointsReason.badge, 15),
        (PointsReason.badge, 30),
      ]);
      expect(mine.total, 89);
      expect((mine.levelBefore, mine.levelAfter), (0, 1));
      expect(mine.balanceBefore, 0);
      expect(rewards.points.keys, [tereza]);
      expect(await PointsRepository(db).balance(tereza), 89);
    });

    test('the second game of the day has no first-game bonus; a better score is a new record', () async {
      final seats = [HumanSeat(tereza), HumanSeat(kuba)];
      Future<PlayerPoints> play(List<int> scores, List<int> places) async => (await service.recordFinished(
        config: config(seats),
        result: GameResult(places: places, scores: scores, stars: const [0, 0]),
        events: const [],
        duration: Duration.zero,
      )).points[kuba]!;
      await play([5, 3], [1, 2]);
      final second = await play([1, 9], [2, 1]);
      expect(second.lines.map((l) => l.reason), isNot(contains(PointsReason.firstToday)));
      expect(second.lines.map((l) => l.reason), contains(PointsReason.record));
    });

    test('a deleted player gets no points', () async {
      await PlayerRepository(db).delete(kuba);
      final rewards = await service.recordFinished(
        config: config([HumanSeat(tereza), HumanSeat(kuba)]),
        result: const GameResult(places: [2, 1], scores: [1, 2], stars: [0, 3]),
        events: const [],
        duration: Duration.zero,
      );
      expect(rewards.points.keys, [tereza]);
    });

    test('anti-farming: the 11th easy win of the day alone against robots is worth 1 point', () async {
      final easy = config([HumanSeat(tereza), const RobotSeat()], difficulty: Difficulty.easy);
      late PlayerPoints last;
      for (var i = 0; i < 11; i++) {
        last = (await service.recordFinished(
          config: easy,
          result: const GameResult(places: [1, 2], scores: [1, 0], stars: [0, 0]),
          events: const [],
          duration: Duration.zero,
        )).points[tereza]!;
      }
      expect(last.lines.first.reason, PointsReason.capped);
    });
  
    test('a one-player game uses its own difficulty and the anti-farming cap (spec 5.6, 13.7)', () async {
      final solo = config([HumanSeat(tereza)], difficulty: Difficulty.easy);
      final points = <PlayerPoints>[];
      for (var i = 0; i < 11; i++) {
        points.add((await service.recordFinished(
          config: solo,
          result: const GameResult(places: [1], scores: [1], stars: [0]),
          events: const [],
          duration: Duration.zero,
        )).points[tereza]!);
      }
      expect(points.first.lines.first, const PointsLine(PointsReason.win, 10));
      expect(points.last.lines.first.reason, PointsReason.capped);
      expect((await repo.allMatches()).first.difficulty, Difficulty.easy);
    });
  });
}
