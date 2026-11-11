import 'dart:async';
import '../core/multiplayer/room_info.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../core/db/app_database.dart';
import '../core/family/family_identity.dart';
import '../core/family/family_net.dart';
import '../core/family/family_op.dart';
import '../core/family/family_state.dart';
import '../core/family/family_store.dart';
import '../core/family/family_sync.dart';
import '../core/family/fold.dart';
import '../core/multiplayer/message_channel.dart';
import '../core/multiplayer/network_env.dart';
import '../core/settings/settings_repository.dart';
import 'stats_service.dart';

/// Why the family cannot sync right now (shown in Rodina).
enum FamilyProblem { noWifi, otherVersion }

/// "Táta tě zve do Pexesa" (spec 5.4): a room to join and the child it is for.
@immutable
class FamilyInvite {
  const FamilyInvite({required this.profileUid, required this.room, required this.gameId, required this.hostName});

  final String profileUid;
  final JoinTicket room;
  final String gameId;
  final String hostName;

  Map<String, Object?> toJson() => {'profile': profileUid, 'room': room.toUri().toString(), 'game': gameId, 'host': hostName};

  static FamilyInvite? fromJson(Map<String, Object?> json) {
    final profile = json['profile'], room = json['room'], game = json['game'], host = json['host'];
    if (profile is! String || room is! String || game is! String || host is! String) return null;
    final ticket = JoinTicket.parse(room);
    return ticket == null ? null : FamilyInvite(profileUid: profile, room: ticket, gameId: game, hostName: host);
  }
}

/// A family device as Rodina lists it.
@immutable
class FamilyDeviceInfo {
  const FamilyDeviceInfo({required this.deviceId, required this.name, required this.isMe, required this.removed, this.lastSync});

  final String deviceId;
  final String name;
  final bool isMe;
  final bool removed;
  final DateTime? lastSync;
}

/// Keeps this device in step with the family (spec "Rodinná synchronizace"
/// 5.3, 7.2): serves syncs, says it is here on the Wi-Fi, and syncs with
/// every family device it hears – after a change, or every [resyncAfter] –
/// except while a game is played.
class FamilyController extends ChangeNotifier {
  FamilyController({
    required this.db,
    required this.net,
    required this.stats,
    this.resyncAfter = const Duration(minutes: 1),
  });

  final AppDatabase db;
  final FamilyNet net;
  final StatsService stats;
  final Duration resyncAfter;

  FamilyStore get store => FamilyStore.of(db);

  FamilyIdentity? _family;
  String? _me;
  String? _ip;
  OpenServer? _server;
  FamilyAnnouncement? _announcement;
  StreamSubscription<Object?>? _serverSub, _beaconSub, _changesSub, _activeSub;
  final _peers = <String, FamilyBeacon>{};
  final _lastSync = <String, DateTime>{};
  final _busy = <String>{};

  /// Lines of syncs in progress; closed when this device stops.
  final _open = <MessageChannel>{};
  var _changedSince = <String>{};
  var _inGame = false;
  var _disposed = false;
  FamilyProblem? _problem;
  DateTime? _lastSyncAt;

  bool get inFamily => _family != null;
  FamilyProblem? get problem => _problem;

  /// When something new arrived last (the home screen shows a short blip).
  DateTime? get lastSyncAt => _lastSyncAt;

  /// The family QR code's content; null without a family or Wi-Fi.
  FamilyTicket? get ticket {
    final f = _family, ip = _ip, server = _server;
    if (f == null || ip == null || server == null) return null;
    return FamilyTicket(familyId: f.familyId, key: f.key, ip: ip, port: server.port);
  }

  /// Starts serving and announcing when this device is in a family.
  Future<void> start() async {
    _family ??= await FamilyIdentity.load(db);
    if (_family == null || _server != null || _disposed) return;
    _me = await store.deviceId();
    _ip = await net.wifiAddress();
    if (_ip == null) {
      _problem = FamilyProblem.noWifi;
      _notify();
      return;
    }
    if (_problem == FamilyProblem.noWifi) _problem = null;
    final server = _server = await net.serve();
    _serverSub = server.channels.listen((ch) {
      // Busy with a game: the other device tries again, this one catches up after.
      if (_inGame) {
        unawaited(ch.close());
      } else {
        unawaited(_run(ch, initiator: false));
      }
    });
    _announcement = await net.announce(await _beacon());
    _beaconSub = net.beacons().listen(_heard);
    // Invitations find the device by the child playing on it (spec 5.4).
    _activeSub = SettingsRepository(db).watchActivePlayerId().skip(1).listen((_) async {
      final beacon = await _beacon();
      if (!_disposed) _announcement?.update(beacon);
    });
    _changesSub = store.changes.listen((_) {
      _changedSince = {..._peers.keys};
      _syncAll();
    });
    _notify();
  }

  Future<FamilyBeacon> _beacon() async {
    final active = await (db.select(db.appSettings)..where((s) => s.key.equals(SettingsRepository.activePlayerKey)))
        .getSingleOrNull();
    final activeId = int.tryParse(active?.value ?? '');
    final activeRow = activeId == null ? null : await (db.select(db.players)..where((p) => p.id.equals(activeId))).getSingleOrNull();
    return FamilyBeacon(
      familyTag: FamilyBeacon.tagOf(_family!.familyId),
      deviceId: _me!,
      ip: _ip!,
      port: _server!.port,
      activeUid: activeRow?.uid,
    );
  }

  /// Another device says it is here.
  void _heard(FamilyBeacon beacon) {
    final f = _family;
    if (f == null || beacon.deviceId == _me || beacon.familyTag != FamilyBeacon.tagOf(f.familyId)) return;
    final isNew = !_peers.containsKey(beacon.deviceId);
    _peers[beacon.deviceId] = beacon;
    final last = _lastSync[beacon.deviceId];
    if (isNew || last == null || DateTime.now().difference(last) > resyncAfter) _syncWith(beacon);
  }

  /// A sync with another device is running now.
  bool get syncing => _busy.isNotEmpty || _open.isNotEmpty;

  /// Family devices seen on the Wi-Fi now (for invitations, spec 5.4).
  List<FamilyBeacon> get peers => List.unmodifiable(_peers.values);

  void _syncAll() {
    for (final peer in _peers.values) {
      _syncWith(peer);
    }
  }

  Future<void> _syncWith(FamilyBeacon peer) async {
    if (_inGame || _disposed || _busy.contains(peer.deviceId)) return;
    _busy.add(peer.deviceId);
    try {
      final channel = await net.connect(peer.ip, peer.port);
      await _run(channel, initiator: true);
    } on Object catch (e) {
      debugPrint('Family sync with ${peer.deviceId}: $e');
    } finally {
      _busy.remove(peer.deviceId);
    }
    // Something changed while this sync ran: once more.
    if (_changedSince.remove(peer.deviceId) && !_inGame) unawaited(_syncWith(peer));
  }

  final _invites = StreamController<FamilyInvite>.broadcast();

  /// Invitations to network games from family devices.
  Stream<FamilyInvite> get invites => _invites.stream;

  /// Invites the child [profileUid] into a room: to the family device where
  /// they play now, else to every family device on the Wi-Fi. False when no
  /// family device took it.
  Future<bool> invite({
    required String profileUid,
    required JoinTicket room,
    required String gameId,
    required String hostName,
  }) async {
    final f = _family;
    if (f == null || _peers.isEmpty) return false;
    final theirs = _peers.values.where((p) => p.activeUid == profileUid).toList();
    final targets = theirs.isEmpty ? _peers.values.toList() : theirs;
    final body = FamilyInvite(profileUid: profileUid, room: room, gameId: gameId, hostName: hostName).toJson();
    var delivered = false;
    for (final peer in targets) {
      try {
        final channel = await net.connect(peer.ip, peer.port);
        final outcome = await syncOver(channel, store: store, family: f, initiator: true, invite: body);
        await channel.close();
        delivered |= outcome.ok;
      } on Object catch (e) {
        debugPrint('Family invite to ${peer.deviceId}: $e');
      }
    }
    return delivered;
  }

  Future<SyncOutcome> _run(MessageChannel channel, {required bool initiator}) async {
    final f = _family;
    if (f == null) {
      await channel.close();
      return const SyncOutcome.failed('family');
    }
    _open.add(channel);
    final SyncOutcome outcome;
    try {
      outcome = await syncOver(
        channel,
        store: store,
        family: f,
        initiator: initiator,
        onInvite: (json) {
          if (FamilyInvite.fromJson(json) case final invite? when !_inGame && !_invites.isClosed) _invites.add(invite);
        },
      );
    } finally {
      _open.remove(channel);
      await channel.close();
    }
    if (_disposed) return outcome;
    if (outcome.ok) {
      _lastSync[outcome.peer!] = DateTime.now();
      if (_problem == FamilyProblem.otherVersion) _problem = null;
      if (outcome.received > 0) {
        await _afterNewData();
        _lastSyncAt = DateTime.now();
      }
    } else {
      debugReport(outcome.reason);
    }
    _notify();
    return outcome;
  }

  /// Badges whose goal was reached with data from other devices.
  Future<void> _afterNewData() async {
    for (final p in await db.select(db.players).get()) {
      await stats.checkBadges(p.id);
    }
  }

  @visibleForTesting
  void debugReceiveInvite(FamilyInvite invite) => _invites.add(invite);

  /// As if new data had just come from the family (the home screen blip).
  @visibleForTesting
  void debugNewData() {
    _lastSyncAt = DateTime.now();
    _notify();
  }

  @visibleForTesting
  void debugReport(String? reason) {
    if (reason == 'version') _problem = FamilyProblem.otherVersion;
    _notify();
  }

  /// No syncing during a game (spec 7.2); afterwards it catches up. Counted:
  /// a rematch opens the next game screen before the last one closes.
  void setInGame(bool inGame) {
    _games = inGame ? _games + 1 : (_games - 1).clamp(0, 1 << 30);
    final now = _games > 0;
    if (_inGame == now) return;
    _inGame = now;
    if (!now) _syncAll();
  }

  var _games = 0;

  /// Back in the app (or asked by hand): sync with everyone seen.
  void syncSoon() {
    if (_server == null) {
      unawaited(start());
    } else {
      _syncAll();
    }
  }

  /// Makes this device the first of a new family (Rodina → Založit).
  Future<void> createFamily({required String deviceName}) async {
    final f = FamilyIdentity.create();
    await f.save(db);
    _family = f;
    await store.append(DeviceJoined(deviceId: await store.deviceId(), name: deviceName));
    await start();
  }

  /// Joins the family of a scanned QR code: gets everything from the device
  /// showing it. A device in another family leaves that one (spec 7.2).
  Future<SyncOutcome> joinFamily(FamilyTicket ticket, {required String deviceName}) async {
    final previous = _family;
    await _stop();
    _family = ticket.identity;
    await ticket.identity.save(db);
    await store.append(DeviceJoined(deviceId: await store.deviceId(), name: deviceName));
    SyncOutcome outcome;
    try {
      outcome = await _run(await net.connect(ticket.ip, ticket.port), initiator: true);
    } on Object {
      outcome = const SyncOutcome.failed('lost');
    }
    if (!outcome.ok) {
      // Could not reach the family: stay where this device was.
      _family = previous;
      if (previous == null) {
        await (db.delete(db.appSettings)..where((s) => s.key.isIn([FamilyIdentity.idKey, FamilyIdentity.keyKey]))).go();
      } else {
        await previous.save(db);
      }
    }
    await start();
    return outcome;
  }

  /// Takes a device out of the family; the others refuse it from now on.
  Future<void> removeDevice(String deviceId) async {
    _peers.remove(deviceId);
    await store.append(DeviceRemoved(deviceId: deviceId));
  }

  static const _declinedKey = 'pairDeclined';
  static const _refundsSeenKey = 'refundsSeen';

  /// Profiles that may be the same person (same name), not yet answered on
  /// this device: (the earlier profile, the later one shown as "… 2").
  Future<List<(ProfileView, ProfileView)>> pairCandidates() async {
    final state = foldFamily(await store.all());
    final declined = await _stringSet(_declinedKey);
    return [
      for (final p in state.profiles.values)
        if (p.pairCandidate case final other? when state.profiles[other] != null && !declined.contains(_pairKey(other, p.uid)))
          (state.profiles[other]!, p),
    ];
  }

  /// "No, two people": not asked again on this device.
  Future<void> declinePair(String a, String b) async {
    await _setStringSet(_declinedKey, {...await _stringSet(_declinedKey), _pairKey(a, b)});
    _notify();
  }

  /// "Yes, the same person" (spec 5.2): everything of [fromUid] belongs to
  /// [intoUid]; its name stays, the look comes from [lookFromUid].
  Future<void> mergeProfiles({required String intoUid, required String fromUid, required String lookFromUid}) async {
    final state = foldFamily(await store.all());
    final into = state.profiles[intoUid], look = state.profiles[lookFromUid];
    if (into == null || state.profiles[fromUid] == null) return;
    await store.append(ProfilesMerged(fromUid: fromUid, intoUid: intoUid));
    await store.append(
      ProfileUpdated(
        uid: intoUid,
        name: into.name,
        avatar: (look ?? into).avatar,
        favoriteSeat: (look ?? into).favoriteSeat,
      ),
    );
    await store.rebuild();
    _notify();
  }

  /// Purchases of [playerId] taken back for lack of points that the child
  /// has not been told about yet (spec kap. 6).
  Future<List<RefundNotice>> unseenRefunds(int playerId) async {
    final row = await (db.select(db.players)..where((p) => p.id.equals(playerId))).getSingleOrNull();
    if (row?.uid == null) return const [];
    final state = foldFamily(await store.all());
    final seen = await _stringSet(_refundsSeenKey);
    return [
      for (final r in state.refunds[state.resolve(row!.uid!)] ?? const <RefundNotice>[])
        if (!seen.contains(r.itemUid)) r,
    ];
  }

  Future<void> markRefundsSeen(Iterable<RefundNotice> notices) =>
      _setStringSet(_refundsSeenKey, {for (final n in notices) n.itemUid});

  static String _pairKey(String a, String b) => ([a, b]..sort()).join('|');

  Future<Set<String>> _stringSet(String key) async {
    final row = await (db.select(db.appSettings)..where((s) => s.key.equals(key))).getSingleOrNull();
    if (row == null) return {};
    try {
      return {for (final v in jsonDecode(row.value) as List) v as String};
    } on Object {
      return {};
    }
  }

  Future<void> _setStringSet(String key, Set<String> values) async {
    final merged = key == _refundsSeenKey ? {...await _stringSet(key), ...values} : values;
    await db.into(db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: jsonEncode([...merged]..sort())));
  }

  /// Every device the family knows, this one first.
  Future<List<FamilyDeviceInfo>> familyDevices() async {
    final me = await store.deviceId();
    final state = foldFamily(await store.all());
    final synced = {for (final d in await db.select(db.familyDevices).get()) d.deviceId: d.lastSyncMs};
    final list = [
      for (final d in state.devices.values)
        FamilyDeviceInfo(
          deviceId: d.deviceId,
          name: d.name,
          isMe: d.deviceId == me,
          removed: d.removed,
          lastSync: synced[d.deviceId] == null ? null : DateTime.fromMillisecondsSinceEpoch(synced[d.deviceId]!),
        ),
    ]..sort((a, b) => a.isMe == b.isMe ? a.name.compareTo(b.name) : (a.isMe ? -1 : 1));
    return list;
  }

  Future<void> _stop() async {
    _announcement?.close();
    _announcement = null;
    await _beaconSub?.cancel();
    await _serverSub?.cancel();
    await _changesSub?.cancel();
    await _activeSub?.cancel();
    _activeSub = null;
    _beaconSub = _serverSub = _changesSub = null;
    for (final channel in [..._open]) {
      await channel.close();
    }
    await _server?.close();
    _server = null;
    _peers.clear();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_invites.close());
    unawaited(_stop());
    super.dispose();
  }
}
