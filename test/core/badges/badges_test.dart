import 'package:deskovky/core/badges/badge.dart';
import 'package:deskovky/core/badges/framework_badges.dart';
import 'package:deskovky/core/game/difficulty.dart';
import 'package:deskovky/core/stats/match_record.dart';
import 'package:deskovky/core/stats/player_stats.dart';
import 'package:deskovky/core/stats/stats_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _me = 1;

MatchRecord _m(int place, {Difficulty? difficulty, bool robot = true, String game = 'sample', int others = 1}) =>
    MatchRecord(
      gameId: game,
      playedAt: DateTime(2026, 10, 20),
      duration: const Duration(seconds: 30),
      difficulty: difficulty,
      participants: [
        MatchParticipant(seat: 0, playerId: _me, place: place, score: 0, stars: 0),
        for (var i = 0; i < others; i++)
          MatchParticipant(seat: i + 1, playerId: robot ? null : 2, place: place == 1 ? 2 : 1, score: 0, stars: 0),
      ],
    );

/// Context after [history] (oldest first; the last one is the match just played).
BadgeContext _ctx(
  List<MatchRecord> history, {
  Map<String, int> counters = const {},
  List<GameEvent> events = const [],
  Set<String> games = const {'sample'},
}) {
  final match = history.last;
  return BadgeContext(
    playerId: _me,
    stats: computePlayerStats(_me, history),
    counters: counters,
    match: match,
    me: match.participants.first,
    events: events,
    availableGames: games,
  );
}

List<String> _ids(List<BadgeDef> defs) => [for (final d in defs) d.id];

void main() {
  test('first win and five in a row', () {
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(2)]), const {})), isEmpty);
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(1)]), const {})), contains('first_win'));
    final five = [for (var i = 0; i < 5; i++) _m(1)];
    expect(_ids(evaluateBadges(frameworkBadges, _ctx(five), const {})), contains('streak5'));
    final broken = [_m(1), _m(1), _m(2), _m(1), _m(1)];
    expect(_ids(evaluateBadges(frameworkBadges, _ctx(broken), const {})), isNot(contains('streak5')));
  });

  test('already earned badges are not awarded again', () {
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(1)]), const {'first_win'})), isNot(contains('first_win')));
  });

  test('ten games played, a win against hard robots, every available game', () {
    final ten = [for (var i = 0; i < 10; i++) _m(2)];
    expect(_ids(evaluateBadges(frameworkBadges, _ctx(ten), const {})), contains('games10'));
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(1, difficulty: Difficulty.medium)]), const {})),
        isNot(contains('hard_win')));
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(1, difficulty: Difficulty.hard)]), const {})),
        contains('hard_win'));
    final both = [_m(2), _m(2, game: 'memory')];
    expect(_ids(evaluateBadges(frameworkBadges, _ctx(both, games: {'sample', 'memory'}), const {})), contains('all_games'));
    expect(_ids(evaluateBadges(frameworkBadges, _ctx([_m(2)], games: {'sample', 'memory'}), const {})),
        isNot(contains('all_games')));
  });

  test('conditions on counters and on events in this match for my seat', () {
    const pairs = BadgeDef(
      id: 'memory.collector',
      titleKey: 't',
      descriptionKey: 'd',
      icon: Icons.star,
      reward: 20,
      condition: BadgeCondition.counter('memory.pairs', 200),
    );
    const bullseye = BadgeDef(
      id: 'sample.bullseye',
      titleKey: 't',
      descriptionKey: 'd',
      icon: Icons.star,
      reward: 15,
      condition: BadgeCondition.all([BadgeCondition.won(), BadgeCondition.event('sample.bullseye')]),
    );
    expect(_ids(evaluateBadges([pairs], _ctx([_m(2)], counters: {'memory.pairs': 199}), const {})), isEmpty);
    expect(_ids(evaluateBadges([pairs], _ctx([_m(2)], counters: {'memory.pairs': 200}), const {})), [pairs.id]);
    expect(
      _ids(evaluateBadges([bullseye], _ctx([_m(1)], events: const [('sample.bullseye', {'seat': 1})]), const {})),
      isEmpty,
      reason: 'another seat hit it',
    );
    expect(
      _ids(evaluateBadges([bullseye], _ctx([_m(1)], events: const [('sample.bullseye', {'seat': 0})]), const {})),
      [bullseye.id],
    );
  });

  test('framework badge ids are unique and rewards within +15…+50 (spec 5.6)', () {
    final ids = _ids(frameworkBadges);
    expect(ids.toSet().length, ids.length);
    for (final b in frameworkBadges) {
      expect(b.reward, inInclusiveRange(15, 50), reason: b.id);
    }
  });
}
