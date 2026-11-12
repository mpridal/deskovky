import 'dart:convert';

import 'package:deskovky/core/family/family_op.dart';
import 'package:deskovky/core/family/family_state.dart';
import 'package:deskovky/core/family/fold.dart';
import 'package:deskovky/core/family/hlc.dart';
import 'package:deskovky/core/game/seeded_random.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds ops for a test: each device numbers its own ops; [t] is the clock.
class _Ops {
  final ops = <FamilyOp>[];
  final _seq = <String, int>{};

  FamilyOp add(String device, int t, OpBody body) {
    final seq = (_seq[device] ?? 0) + 1;
    _seq[device] = seq;
    final op = FamilyOp(origin: device, seq: seq, clock: Hlc(t, 0, device), body: body);
    ops.add(op);
    return op;
  }
}

const _avatar = <String, Object?>{'face': 'round'};

ProfileCreated _create(String uid, String name) => ProfileCreated(uid: uid, name: name, avatar: _avatar);

PointsAdded _points(String entry, String player, int amount, {String reason = 'win', String? detail}) =>
    PointsAdded(entryUid: entry, playerUid: player, amount: amount, reason: reason, detail: detail, atMs: 0);

String _json(FamilyState s) => jsonEncode(s.toJson());

void main() {
  test('points are the sum of ledger entries; the same op twice counts once', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 30));
    final gift = o.add('tab', 3, _points('e2', 'viky', 12, reason: 'gift'));
    final s = foldFamily([...o.ops, gift]);
    expect(s.balance('viky'), 42);
    expect(s.ledger['viky'], hasLength(2));
  });

  test('same result for every order of the same ops', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 100));
    o.add('tab', 5, ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'hat', price: 60, atMs: 5));
    o.add('pho', 6, ItemBought(itemUid: 'i2', playerUid: 'viky', itemId: 'glasses', price: 60, atMs: 6));
    o.add('pho', 7, _create('kuba', 'Kuba'));
    o.add('pho', 8, ProfileUpdated(uid: 'viky', name: 'Viki', avatar: _avatar));
    o.add('tab', 9, const BadgeAwarded(playerUid: 'viky', badgeId: 'first', atMs: 9));
    final expected = _json(foldFamily(o.ops));
    final random = SeededRandom(1);
    for (var i = 0; i < 100; i++) {
      final shuffled = [...o.ops];
      for (var j = shuffled.length - 1; j > 0; j--) {
        final k = random.nextInt(j + 1);
        final x = shuffled[j];
        shuffled[j] = shuffled[k];
        shuffled[k] = x;
      }
      expect(_json(foldFamily(shuffled)), expected);
    }
  });

  test('the same item bought on two devices: one item, refund "duplicate" of its price, exactly once', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 300));
    o.add('tab', 10, ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'hat', price: 100, atMs: 10));
    o.add('pho', 20, ItemBought(itemUid: 'i2', playerUid: 'viky', itemId: 'hat', price: 100, atMs: 20));
    final s = foldFamily(o.ops);
    expect(s.items['viky'], {'hat'});
    expect(s.balance('viky'), 200);
    final refunds = s.ledger['viky']!.where((e) => e.reason == 'refund').toList();
    expect(refunds, hasLength(1));
    expect(refunds.single.amount, 100);
    expect(refunds.single.detail, 'duplicate:hat');
  });

  test('overspend offline: balance 100, hat 100 at t=10, glasses 100 at t=20 → glasses refunded, balance 0', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 100));
    o.add('tab', 10, ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'hat', price: 100, atMs: 10));
    o.add('pho', 20, ItemBought(itemUid: 'i2', playerUid: 'viky', itemId: 'glasses', price: 100, atMs: 20));
    final s = foldFamily(o.ops);
    expect(s.items['viky'], {'hat'});
    expect(s.balance('viky'), 0);
    expect(s.ledger['viky']!.where((e) => e.reason == 'refund').single.detail, 'notEnough:glasses');
    expect(s.refunds['viky'], [const RefundNotice(itemUid: 'i2', itemId: 'glasses', reason: RefundReason.notEnough)]);
  });

  test('badge reward paid once when the badge is awarded on two devices', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 5, const BadgeAwarded(playerUid: 'viky', badgeId: 'collector', atMs: 5));
    o.add('tab', 5, _points('e1', 'viky', 30, reason: 'badge', detail: 'collector'));
    o.add('pho', 3, const BadgeAwarded(playerUid: 'viky', badgeId: 'collector', atMs: 3));
    o.add('pho', 3, _points('e2', 'viky', 30, reason: 'badge', detail: 'collector'));
    final s = foldFamily(o.ops);
    expect(s.badges['viky'], {'collector': 3});
    expect(s.balance('viky'), 30);
  });

  test('reset clears only the amount and items it lists; a later gift from another device stays', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 150));
    o.add('tab', 3, ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'hat', price: 50, atMs: 3));
    o.add('pho', 4, _points('e2', 'viky', 40, reason: 'gift'));
    o.add('pho', 5, ItemBought(itemUid: 'i2', playerUid: 'viky', itemId: 'cap', price: 10, atMs: 5));
    // The tablet knew 100 points and the hat when the parent reset.
    o.add('tab', 6, const PointsReset(resetUid: 'r1', playerUid: 'viky', amount: 100, itemIds: ['hat']));
    final s = foldFamily(o.ops);
    expect(s.items['viky'], {'cap'});
    expect(s.balance('viky'), 30);
  });

  test('a deleted profile never comes back, even with points or a match recorded for it later', () {
    final o = _Ops();
    o.add('tab', 1, _create('babi', 'Babička'));
    o.add('tab', 2, const ProfileDeleted(uid: 'babi'));
    o.add('pho', 5, _points('e1', 'babi', 20));
    o.add('pho', 6, ProfileUpdated(uid: 'babi', name: 'Babi', avatar: _avatar));
    o.add('pho', 7, const MatchRecorded(
      matchUid: 'm1', gameId: 'memory', playedAtMs: 7, durationMs: 1000, difficulty: null,
      participants: [MatchSeat(seat: 0, playerUid: 'babi', robot: false, place: 1, score: 3, stars: 3)],
      points: [], counters: [],
    ));
    final s = foldFamily(o.ops);
    expect(s.profiles.containsKey('babi'), isFalse);
    expect(s.ledger['babi'], isNull);
    expect(s.matches.single.participants.single.playerUid, isNull);
    expect(s.matches.single.participants.single.robot, isFalse);
  });

  test('merging B into A: sums ledger, unions items (duplicates refunded), badges with the earliest date, counters summed', () {
    final o = _Ops();
    o.add('tab', 1, _create('a', 'Viky'));
    o.add('pho', 2, _create('b', 'Viky'));
    o.add('tab', 3, _points('e1', 'a', 100));
    o.add('pho', 4, _points('e2', 'b', 80));
    o.add('tab', 5, ItemBought(itemUid: 'i1', playerUid: 'a', itemId: 'hat', price: 50, atMs: 5));
    o.add('pho', 6, ItemBought(itemUid: 'i2', playerUid: 'b', itemId: 'hat', price: 50, atMs: 6));
    o.add('pho', 7, ItemBought(itemUid: 'i3', playerUid: 'b', itemId: 'cap', price: 10, atMs: 7));
    o.add('tab', 8, const BadgeAwarded(playerUid: 'a', badgeId: 'first', atMs: 8));
    o.add('pho', 6, const BadgeAwarded(playerUid: 'b', badgeId: 'first', atMs: 6));
    o.add('tab', 9, const CountersAdded(playerUid: 'a', deltas: {'memory.pairs': 5}));
    o.add('pho', 9, const CountersAdded(playerUid: 'b', deltas: {'memory.pairs': 7}));
    o.add('pho', 10, const MatchRecorded(
      matchUid: 'm1', gameId: 'memory', playedAtMs: 10, durationMs: 1, difficulty: null,
      participants: [MatchSeat(seat: 0, playerUid: 'b', robot: false, place: 1, score: 1, stars: 3)],
      points: [], counters: [],
    ));
    o.add('tab', 20, const ProfilesMerged(fromUid: 'b', intoUid: 'a'));
    final s = foldFamily(o.ops);
    expect(s.profiles.keys, ['a']);
    expect(s.items['a'], {'hat', 'cap'});
    expect(s.balance('a'), 100 + 80 - 50 - 10);
    expect(s.badges['a'], {'first': 6});
    expect(s.counters['a'], {'memory.pairs': 12});
    expect(s.matches.single.participants.single.playerUid, 'a');
  });

  test('alias ops arriving later still land on the merged profile', () {
    final o = _Ops();
    o.add('tab', 1, _create('a', 'Viky'));
    o.add('pho', 2, _create('b', 'Viky'));
    o.add('tab', 3, const ProfilesMerged(fromUid: 'b', intoUid: 'a'));
    // The phone did not know about the merge and kept writing to b.
    o.add('pho', 9, _points('late', 'b', 25));
    final s = foldFamily(o.ops);
    expect(s.balance('a'), 25);
    expect(s.ledger['b'], isNull);
  });

  test('name and avatar: the last update wins (by clock, then device id)', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 5, ProfileUpdated(uid: 'viky', name: 'Vikinka', avatar: _avatar));
    o.add('pho', 4, ProfileUpdated(uid: 'viky', name: 'Viki', avatar: _avatar));
    o.add('aaa', 5, ProfileUpdated(uid: 'viky', name: 'Vika', avatar: _avatar));
    final s = foldFamily(o.ops);
    // Clock 5 twice: device id breaks the tie ("tab" > "aaa").
    expect(s.profiles['viky']!.name, 'Vikinka');
  });

  test('two profiles with the same name not merged: the later-created one is "Babička 2" with a pair candidate', () {
    final o = _Ops();
    o.add('tab', 1, _create('b1', 'Babička'));
    o.add('pho', 2, _create('b2', 'babička'));
    final s = foldFamily(o.ops);
    expect(s.profiles['b1']!.name, 'Babička');
    expect(s.profiles['b2']!.name, 'babička 2');
    expect(s.profiles['b2']!.pairCandidate, 'b1');
    expect(s.profiles['b1']!.pairCandidate, isNull);
  });

  test('a network match recorded by two devices merges into one match, points from both kept once each', () {
    final o = _Ops();
    o.add('tab', 1, _create('tata', 'Táta'));
    o.add('pho', 1, _create('viky', 'Viky'));
    o.add('tab', 10, const MatchRecorded(
      matchUid: '4321-7', gameId: 'memory', playedAtMs: 10, durationMs: 60000, difficulty: null,
      participants: [
        MatchSeat(seat: 0, playerUid: 'tata', robot: false, place: 1, score: 5, stars: 3),
        MatchSeat(seat: 1, playerUid: null, robot: false, place: 2, score: 3, stars: 2),
      ],
      points: [PointLine(entryUid: 'p1', playerUid: 'tata', amount: 20, reason: 'win')],
      counters: [],
    ));
    o.add('pho', 11, const MatchRecorded(
      matchUid: '4321-7', gameId: 'memory', playedAtMs: 11, durationMs: 60000, difficulty: null,
      participants: [
        MatchSeat(seat: 0, playerUid: null, robot: false, place: 1, score: 5, stars: 3),
        MatchSeat(seat: 1, playerUid: 'viky', robot: false, place: 2, score: 3, stars: 2),
      ],
      points: [PointLine(entryUid: 'p2', playerUid: 'viky', amount: 8, reason: 'second')],
      counters: [CounterLine(playerUid: 'viky', key: 'memory.pairs', delta: 3)],
    ));
    final s = foldFamily(o.ops);
    expect(s.matches, hasLength(1));
    expect([for (final p in s.matches.single.participants) p.playerUid], ['tata', 'viky']);
    expect(s.balance('tata'), 20);
    expect(s.balance('viky'), 8);
    expect(s.counters['viky'], {'memory.pairs': 3});
  });

  test('a removed device stays known as removed', () {
    final o = _Ops();
    o.add('tab', 1, const DeviceJoined(deviceId: 'pho', name: 'Telefon'));
    o.add('tab', 2, const DeviceRemoved(deviceId: 'pho'));
    final s = foldFamily(o.ops);
    expect(s.devices['pho']!.removed, isTrue);
    expect(s.devices['pho']!.name, 'Telefon');
  });

  test('ops survive JSON; an unknown op type is skipped, not a crash', () {
    final o = _Ops();
    final op = o.add('tab', 1, _create('viky', 'Viky'));
    expect(FamilyOp.fromJson(jsonDecode(jsonEncode(op.toJson()))), op);
    expect(FamilyOp.fromJson({'o': 'tab', 's': 2, 'c': Hlc(2, 0, 'tab').pack(), 'b': {'t': 'fromTheFuture'}}), isNull);
  });

  test('a rename on one device and a new hat on another both stay (review I3)', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 5, const ProfileUpdated(uid: 'viky', name: 'Vikinka'));
    o.add('pho', 6, const ProfileUpdated(uid: 'viky', avatar: {'face': 'hat'}));
    final s = foldFamily(o.ops);
    expect(s.profiles['viky']!.name, 'Vikinka');
    expect(s.profiles['viky']!.avatar, {'face': 'hat'});
  });

  test('a look-only change survives the JSON trip without a name', () {
    const body = ProfileUpdated(uid: 'viky', avatar: {'face': 'hat'});
    final op = FamilyOp(origin: 'tab', seq: 1, clock: Hlc(1, 0, 'tab'), body: body);
    final back = FamilyOp.fromJson(jsonDecode(jsonEncode(op.toJson())) as Map<String, Object?>)!.body as ProfileUpdated;
    expect(back.name, isNull);
    expect(back.avatar, {'face': 'hat'});
  });

  test('a purchase taken back for lack of points comes off the avatar too (review I5)', () {
    final o = _Ops();
    o.add('tab', 1, _create('viky', 'Viky'));
    o.add('tab', 2, _points('e1', 'viky', 100));
    o.add('tab', 3, const ItemBought(itemUid: 'i1', playerUid: 'viky', itemId: 'crown', price: 80, atMs: 3));
    o.add('pho', 4, const ItemBought(itemUid: 'i2', playerUid: 'viky', itemId: 'glasses', price: 80, atMs: 4));
    o.add('pho', 5, const ProfileUpdated(uid: 'viky', avatar: {
      'face': 'round',
      'eq': {'head': {'id': 'crown'}, 'face': {'id': 'glasses', 'v': 'red'}, 'hand': {'id': 'trophy'}},
    }));
    final s = foldFamily(o.ops);
    expect(s.refunds['viky']!.single.itemId, 'glasses');
    expect(s.profiles['viky']!.avatar['eq'], {'head': {'id': 'crown'}, 'hand': {'id': 'trophy'}});
  });
}
