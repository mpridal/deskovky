import 'package:deskovky/core/game/difficulty.dart';
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
        _m([(_t, 1)], at: DateTime(2026, 10, 25, 23, 59)), // Sunday, last week
        _m([(_k, 1)], at: DateTime(2026, 10, 26, 0, 0)), // Monday
        _m([(_b, 1)], at: DateTime(2026, 9, 30, 23, 59)), // last month
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
}
