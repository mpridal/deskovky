import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/points/points_math.dart';
import 'package:deskovky/core/points/points_repository.dart';
import 'package:deskovky/core/stats/leaderboard.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/player_stats.dart';
import 'package:flutter_test/flutter_test.dart';

const _t = 1, _k = 2, _b = 3;

MatchRecord _m(
  List<(int? player, int place)> seats, {
  String game = 'sample',
  DateTime? at,
  Difficulty? difficulty,
  int seconds = 60,
  List<int>? scores,
  List<int>? stars,
}) => MatchRecord(
  gameId: game,
  playedAt: at ?? DateTime(2026, 10, 20, 12),
  duration: Duration(seconds: seconds),
  difficulty: difficulty,
  participants: [
    for (var i = 0; i < seats.length; i++)
      MatchParticipant(
        seat: i,
        playerId: seats[i].$1,
        place: seats[i].$2,
        score: scores?[i] ?? 0,
        stars: stars?[i] ?? 0,
      ),
  ],
);

void main() {
  group('player stats', () {
    test('wins, draws, rate and streaks; a draw breaks the streak', () {
      final s = computePlayerStats(_t, [
        _m([(_t, 1), (_k, 2)]),
        _m([(_t, 1), (null, 2)]),
        _m([(_t, 1), (_k, 1)]), // draw
        _m([(_t, 1), (_k, 2)]),
        _m([(_t, 1), (_k, 2)]),
        _m([(_t, 1), (_k, 2)]),
        _m([(_t, 2), (_k, 1)]),
        _m([(_t, 1), (_k, 2)]),
      ]);
      expect(s.played, 8);
      expect(s.wins, 6);
      expect(s.draws, 1);
      expect(s.winRate, closeTo(0.75, 0.001));
      expect(s.bestStreak, 3);
      expect(s.currentStreak, 1);
    });

    test('per game: best score, fastest win, best stars; games and difficulties beaten', () {
      final s = computePlayerStats(_t, [
        _m([(_t, 1), (null, 2)], seconds: 90, scores: [5, 1], stars: [2, 0], difficulty: Difficulty.easy),
        _m([(_t, 1), (null, 2)], seconds: 40, scores: [3, 1], stars: [3, 0], difficulty: Difficulty.hard),
        _m([(_t, 2), (_k, 1)], seconds: 10, scores: [9, 10], stars: [1, 3]),
        _m([(_t, 1)], game: 'memory', seconds: 30, scores: [7], stars: [1]),
      ]);
      final sample = s.byGame['sample']!;
      expect(sample.played, 3);
      expect(sample.wins, 2);
      expect(sample.bestScore, 9);
      expect(sample.fastestWin, const Duration(seconds: 40), reason: 'a lost game is not a record time');
      expect(sample.bestStars, 3);
      expect(s.gamesPlayed, {'sample', 'memory'});
      expect(s.winsAgainst, {Difficulty.easy, Difficulty.hard});
    });

    test('a player with no games has zeros and no rate', () {
      final s = computePlayerStats(_b, [_m([(_t, 1), (_k, 2)])]);
      expect(s.played, 0);
      expect(s.winRate, 0);
      expect(s.byGame, isEmpty);
    });
  });

  group('leaderboard', () {
    final now = DateTime(2026, 10, 26, 10); // Monday

    test('ranks people by wins, then win rate; robots never appear', () {
      final rows = leaderboard([
        _m([(_t, 1), (null, 2)]),
        _m([(_t, 1), (_k, 2)]),
        _m([(_k, 1), (null, 2)]),
        _m([(null, 1), (_k, 2)]),
        _m([(_b, 1), (_k, 2)]),
      ], const LeaderboardQuery(), now: now);
      // Kuba and Babi both have one win; Babi's rate is higher.
      expect([for (final r in rows) r.playerId], [_t, _b, _k]);
      expect(rows.first.wins, 2);
      expect(rows[2].played, 4);
      expect([for (final r in rows) r.rank], [1, 2, 3]);
    });

    test('equal wins and rate share a rank', () {
      final rows = leaderboard([
        _m([(_t, 1), (_k, 2)]),
        _m([(_k, 1), (_t, 2)]),
      ], const LeaderboardQuery(), now: now);
      expect([for (final r in rows) r.rank], [1, 1]);
    });

    test('filters by game and difficulty', () {
      final matches = [
        _m([(_t, 1), (null, 2)], difficulty: Difficulty.hard),
        _m([(_k, 1), (null, 2)], difficulty: Difficulty.easy),
        _m([(_k, 1), (_t, 2)], game: 'memory'),
      ];
      final hard = leaderboard(matches, const LeaderboardQuery(difficulty: Difficulty.hard), now: now);
      expect([for (final r in hard) r.playerId], [_t]);
      final memory = leaderboard(matches, const LeaderboardQuery(gameId: 'memory'), now: now);
      expect([for (final r in memory) (r.playerId, r.wins)], [(_k, 1), (_t, 0)]);
    });

    test('week starts Monday 00:00 local, month on the 1st', () {
      final matches = [
        _m([(_t, 1), (null, 2)], at: DateTime(2026, 10, 25, 23, 59)), // Sunday, last week
        _m([(_k, 1), (null, 2)], at: DateTime(2026, 10, 26, 0, 0)), // Monday
        _m([(_b, 1), (null, 2)], at: DateTime(2026, 9, 30, 23, 59)), // last month
      ];
      expect([for (final r in leaderboard(matches, const LeaderboardQuery(period: StatsPeriod.week), now: now)) r.playerId], [_k]);
      expect(
        {for (final r in leaderboard(matches, const LeaderboardQuery(period: StatsPeriod.month), now: now)) r.playerId},
        {_t, _k},
      );
      expect(leaderboard(matches, const LeaderboardQuery(), now: now).length, 3);
    });

    test('deleted players (null id, not robot) are left out', () {
      final match = MatchRecord(
        gameId: 'sample',
        playedAt: DateTime(2026, 10, 20),
        duration: Duration.zero,
        difficulty: null,
        participants: const [
          MatchParticipant(seat: 0, playerId: null, robot: false, place: 1, score: 0, stars: 0),
          MatchParticipant(seat: 1, playerId: _t, place: 2, score: 0, stars: 0),
        ],
      );
      expect([for (final r in leaderboard([match], const LeaderboardQuery(), now: now)) r.playerId], [_t]);
    });
  });

  group('review fixes', () {
    final now = DateTime(2026, 10, 26, 10);

    test('a one-seat game: 1st place = completed = win (spec 5.6), 2nd place = failed', () {
      final s = computePlayerStats(_t, [
        for (var i = 0; i < 3; i++) _m([(_t, 1)], seconds: 50 - i),
        _m([(_t, 2)], seconds: 5),
      ]);
      expect(s.played, 4);
      expect(s.wins, 3);
      expect(s.bestStreak, 3);
      expect(s.currentStreak, 0);
      expect(s.byGame['sample']!.fastestWin, const Duration(seconds: 48), reason: 'a failed game is no record');
    });

    test('the leaderboard counts one-seat games too', () {
      final rows = leaderboard([_m([(_t, 1)]), _m([(_k, 1), (_t, 2)])], const LeaderboardQuery(), now: now);
      expect([for (final r in rows) (r.playerId, r.wins, r.played)], [(_k, 1, 1), (_t, 1, 2)]);
    });

    test('only existing players are ranked, without gaps', () {
      final rows = leaderboard(
        [_m([(_t, 1), (_k, 2)]), _m([(_t, 1), (_b, 2)]), _m([(_k, 1), (_b, 2)])],
        const LeaderboardQuery(),
        now: now,
        players: {_k, _b},
      );
      expect([for (final r in rows) (r.playerId, r.rank)], [(_k, 1), (_b, 2)]);
    });

    test('ties keep a stable order by player id', () {
      final rows = leaderboard([_m([(_k, 1), (_t, 2)]), _m([(_t, 1), (_k, 2)])], const LeaderboardQuery(), now: now);
      expect([for (final r in rows) r.playerId], [_t, _k]);
    });

    test('the next period boundary is the next Monday or the next 1st, whichever comes first', () {
      expect(nextPeriodBoundary(DateTime(2026, 10, 25, 23, 59)), DateTime(2026, 10, 26));
      expect(nextPeriodBoundary(DateTime(2026, 10, 28, 12)), DateTime(2026, 11, 1));
      expect(nextPeriodBoundary(DateTime(2026, 11, 1, 0, 0)), DateTime(2026, 11, 2));
    });
  });

  group('points (milestone 7)', () {
    final now = DateTime(2026, 10, 26, 10);
    MatchRecord withId(int id, MatchRecord m) => MatchRecord(
      id: id,
      gameId: m.gameId,
      playedAt: m.playedAt,
      duration: m.duration,
      difficulty: m.difficulty,
      participants: m.participants,
    );

    test('people are ranked by points earned in the selected games, then by wins', () {
      final matches = [withId(1, _m([(_t, 1), (_k, 2)])), withId(2, _m([(_k, 1), (_b, 2)]))];
      final points = [
        PointsEntry(playerId: _t, amount: 20, reason: PointsReason.win, at: now, matchId: 1),
        PointsEntry(playerId: _k, amount: 3, reason: PointsReason.participation, at: now, matchId: 1),
        PointsEntry(playerId: _k, amount: 35, reason: PointsReason.win, at: now, matchId: 2),
        PointsEntry(playerId: _b, amount: 4, reason: PointsReason.participation, at: now, matchId: 2),
        PointsEntry(playerId: _b, amount: 500, reason: PointsReason.gift, at: now),
        PointsEntry(playerId: _k, amount: -30, reason: PointsReason.purchase, at: now),
      ];
      final rows = leaderboard(matches, const LeaderboardQuery(), now: now, points: points);
      expect([for (final r in rows) (r.playerId, r.points)], [(_k, 38), (_t, 20), (_b, 4)]);
      final memoryOnly = leaderboard(matches, const LeaderboardQuery(gameId: 'memory'), now: now, points: points);
      expect(memoryOnly, isEmpty);
    });
  });
}
