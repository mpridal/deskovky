import 'package:deskovky/core/avatar/avatar_spec.dart';
import 'package:deskovky/core/db/app_database.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/players/player_repository.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StatsRepository stats;
  late int tereza;
  late int kuba;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    stats = StatsRepository(db, now: () => DateTime(2026, 10, 21, 18));
    tereza = (await PlayerRepository(db).create(name: 'Tereza', avatar: AvatarSpec.defaults)).id;
    kuba = (await PlayerRepository(db).create(name: 'Kuba', avatar: AvatarSpec.defaults)).id;
  });
  tearDown(() => db.close());

  MatchRecord match({List<int?> players = const [null, null], List<int> places = const [1, 2]}) => MatchRecord(
    gameId: 'sample',
    playedAt: DateTime(2026, 10, 21, 17),
    duration: const Duration(seconds: 95),
    difficulty: Difficulty.hard,
    participants: [
      for (var s = 0; s < places.length; s++)
        MatchParticipant(seat: s, playerId: players[s], place: places[s], score: 10 - s, stars: 3 - s),
    ],
  );

  test('a finished match is stored with all participants, robots included', () async {
    final id = await stats.recordMatch(match(players: [tereza, null]));
    final stored = await stats.matchById(id);
    expect(stored!.gameId, 'sample');
    expect(stored.difficulty, Difficulty.hard);
    expect(stored.duration, const Duration(seconds: 95));
    expect(stored.playedAt, DateTime(2026, 10, 21, 17));
    expect(stored.participants.map((p) => p.playerId), [tereza, null]);
    expect(stored.participants.map((p) => p.place), [1, 2]);
    expect(stored.participants.map((p) => p.score), [10, 9]);
    expect(stored.participants.map((p) => p.stars), [3, 2]);
  });

  test('events reported by the game add up in counters of human players only', () async {
    await stats.recordMatch(
      match(players: [tereza, kuba]),
      events: const [('memory.pairs', {'count': 8}), ('memory.pairs', {'count': 2}), ('sample.bullseye', {})],
    );
    expect(await stats.counter(tereza, 'memory.pairs'), 10);
    expect(await stats.counter(kuba, 'sample.bullseye'), 1);
    expect(await stats.counter(tereza, 'nothing'), 0);
  });

  test('a deleted player leaves the match in place but no counters or badges', () async {
    await stats.recordMatch(match(players: [tereza, kuba]), events: const [('x', {})]);
    await stats.awardBadge(kuba, 'first_win');
    await PlayerRepository(db).delete(kuba);
    final all = await stats.allMatches();
    expect(all.single.participants[1].playerId, isNull);
    expect(all.single.participants[1].deletedPlayer, isTrue);
    expect(await stats.counter(kuba, 'x'), 0);
    expect(await stats.earnedBadges(kuba), isEmpty);
  });

  test('a badge is awarded once and remembers when', () async {
    expect(await stats.awardBadge(tereza, 'first_win'), isTrue);
    expect(await stats.awardBadge(tereza, 'first_win'), isFalse);
    final earned = await stats.earnedBadges(tereza);
    expect(earned.keys, ['first_win']);
    expect(earned['first_win'], DateTime(2026, 10, 21, 18));
  });
}
