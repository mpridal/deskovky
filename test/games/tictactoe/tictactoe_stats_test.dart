import 'package:deskovky/app/stats_service.dart';
import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:deskovky/games/tictactoe/tictactoe_events.dart';
import 'package:deskovky/games/tictactoe/tictactoe_rules.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const rules = TictactoeRules();

/// Badges, stars and points of Piškvorky land in the framework (DoD 13.4).
void main() {
  late AppDatabase db;
  late StatsRepository repo;
  late StatsService service;
  late int tereza;
  var minute = 0;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Each game a minute later (no anti-farming, a stable order).
    repo = StatsRepository(db, now: () => DateTime(2026, 10, 26, 10, minute++));
    service = StatsService(repo, points: PointsRepository(db, now: () => DateTime(2026, 10, 26, 10)));
    tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  GameConfig config(int board, Difficulty difficulty) => GameConfig(
    gameId: 'tictactoe',
    seats: [HumanSeat(tereza), const RobotSeat()],
    difficulty: difficulty,
    robotSpeed: RobotSpeed.fast,
    options: {'board': board, 'start': 'first', 'confirm': false},
  );

  /// Plays [cells] (✕ = Tereza, ◯ = robot), collecting the events the board
  /// reports for Tereza's moves; then records the game.
  Future<Set<String>> record(GameConfig c, List<(int, int)> cells) async {
    var s = rules.initialState(c, 1);
    final events = <(String, Map<String, Object?>)>[];
    for (final (col, row) in cells) {
      final move = TictactoeRules.place(s.current, col, row);
      if (move.seat == 0) events.addAll(tictactoeEvents(s, move));
      s = rules.apply(s, move);
    }
    expect(rules.isOver(s), isTrue);
    final rewards = await service.recordFinished(
      config: c,
      result: rules.result(s),
      events: events,
      duration: const Duration(minutes: 1),
    );
    return {for (final b in rewards.badges) b.badge.id};
  }

  const quickFive = [(3, 7), (3, 8), (4, 7), (4, 8), (5, 7), (5, 8), (6, 7), (6, 8), (7, 7)];

  test('a quick win on 15×15 against the hard robot: five, blitz and master; ★★★ stored', () async {
    final badges = await record(config(15, Difficulty.hard), quickFive);
    expect(badges, containsAll(['tictactoe.five', 'tictactoe.blitz', 'tictactoe.master']));
    final match = (await repo.allMatches()).single;
    expect(match.gameId, 'tictactoe');
    expect(match.participants.first.stars, 3);
    expect(match.participants.first.place, 1);
    expect(await PointsRepository(db).balance(tereza), greaterThan(0));
  });

  test('a win on 10×10 against medium: only blitz', () async {
    final badges = await record(config(10, Difficulty.medium), quickFive);
    expect(badges.where((b) => b.startsWith('tictactoe.')), {'tictactoe.blitz'});
  });

  test('ten 3×3 draws against the hard robot earn wall, the tenth one exactly', () async {
    const draw = [(1, 1), (0, 0), (0, 2), (2, 0), (1, 0), (1, 2), (0, 1), (2, 1), (2, 2)];
    for (var i = 1; i <= 10; i++) {
      final badges = await record(config(3, Difficulty.hard), draw);
      expect(badges.contains('tictactoe.wall'), i == 10, reason: 'draw $i');
    }
    expect(await repo.counter(tereza, 'tictactoe.wall'), 10);
    // Draws against medium do not count.
    await record(config(3, Difficulty.medium), draw);
    expect(await repo.counter(tereza, 'tictactoe.wall'), 10);
  });
}
