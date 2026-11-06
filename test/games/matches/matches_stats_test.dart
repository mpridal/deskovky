import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/games/matches/matches_events.dart';
import 'package:deskovky/games/matches/matches_rules.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = MatchesRules();

/// Badges, stars and points of Sirky land in the framework (DoD 13.4).
void main() {
  late AppDatabase db;
  late StatsRepository repo;
  late StatsService service;
  late int tereza;
  var minute = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = StatsRepository(db, now: () => DateTime(2026, 11, 6, 10, minute++));
    service = StatsService(repo, points: PointsRepository(db, now: () => DateTime(2026, 11, 6, 10)));
    tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  GameConfig config(Difficulty difficulty) => GameConfig(
    gameId: 'matches',
    seats: [HumanSeat(tereza), const RobotSeat()],
    difficulty: difficulty,
    robotSpeed: RobotSpeed.fast,
    options: const {'start': MatchesStart.first},
  );

  /// Plays [takes] (Tereza = seat 0 first), collecting the events the board
  /// reports from every state; then records the game.
  Future<Set<String>> record(GameConfig c, List<(int, int)> takes) async {
    var s = rules.initialState(c, 1);
    final reported = <String, Map<String, Object?>>{};
    for (final (row, count) in takes) {
      s = rules.apply(s, MatchesRules.take(s.current, row, count));
      reported.addAll(MatchesEvents.of(s));
    }
    expect(rules.isOver(s), isTrue);
    final rewards = await service.recordFinished(
      config: c,
      result: rules.result(s),
      events: [for (final MapEntry(:key, :value) in reported.entries) (MatchesEvents.idOf(key), value)],
      duration: const Duration(minutes: 1),
    );
    return {for (final b in rewards.badges) b.badge.id};
  }

  // Tereza: 2-5-7, 2-3-1, 0-0-1 (every move to a losing position).
  const flawless = [(0, 1), (2, 6), (1, 2), (0, 2), (1, 3), (2, 1)];
  // Tereza wins, but 0-5-7 was not a losing position for the robot.
  const sloppy = [(0, 3), (1, 5), (2, 6), (2, 1)];
  // Tereza had 0-0-7 from the robot and still lost.
  const lost = [(0, 3), (2, 7), (1, 5)];

  test('a flawless win against the hard robot: first, master and flawless; ★★★ and points', () async {
    final badges = await record(config(Difficulty.hard), flawless);
    expect(badges, containsAll(['matches.first', 'matches.master', 'matches.flawless']));
    final match = (await repo.allMatches()).single;
    expect(match.participants.first.stars, 3);
    expect(await PointsRepository(db).balance(tereza), greaterThan(0));
  });

  test('a sloppy win against medium: only first', () async {
    final badges = await record(config(Difficulty.medium), sloppy);
    expect(badges.where((b) => b.startsWith('matches.')), {'matches.first'});
  });

  test('a loss after having a winning position: ★★, no badge, no win counted', () async {
    final badges = await record(config(Difficulty.easy), lost);
    expect(badges.where((b) => b.startsWith('matches.')), isEmpty);
    expect((await repo.allMatches()).single.participants.first.stars, 2);
    expect(await repo.counter(tereza, 'matches.win'), 0);
  });

  test('the 25th win earns Sirkař', () async {
    for (var i = 1; i <= 25; i++) {
      final badges = await record(config(Difficulty.easy), sloppy);
      expect(badges.contains('matches.collector'), i == 25, reason: 'win $i');
    }
    expect(await repo.counter(tereza, 'matches.win'), 25);
  });
}
