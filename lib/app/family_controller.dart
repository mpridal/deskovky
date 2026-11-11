import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/db/app_database.dart';
import '../core/family/family_identity.dart';
import '../core/family/family_net.dart';
import '../core/family/family_op.dart';
import '../core/family/family_store.dart';
import '../core/family/family_sync.dart';
import '../core/family/fold.dart';
import '../core/multiplayer/message_channel.dart';
import '../core/multiplayer/network_env.dart';
import '../core/settings/settings_repository.dart';
import 'stats_service.dart';

/// Why the family cannot sync right now (shown in Rodina).
enum FamilyProblem { noWifi, otherVersion }

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
  StreamSubscription<Object?>? _serverSub, _beaconSub, _changesSub;
  final _peers = <String, FamilyBeacon>{};
  final _lastSync = <String, DateTime>{};
  final _busy = <String>{};
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

  Future<SyncOutcome> _run(MessageChannel channel, {required bool initiator}) async {
    final f = _family;
    if (f == null) {
      await channel.close();
      return const SyncOutcome.failed('family');
    }
    final outcome = await syncOver(channel, store: store, family: f, initiator: initiator);
    await channel.close();
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
  void debugReport(String? reason) {
    if (reason == 'version') _problem = FamilyProblem.otherVersion;
    _notify();
  }

  /// No syncing during a game (spec 7.2); afterwards it catches up.
  void setInGame(bool inGame) {
    if (_inGame == inGame) return;
    _inGame = inGame;
    if (!inGame) _syncAll();
  }

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
    _beaconSub = _serverSub = _changesSub = null;
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
    unawaited(_stop());
    super.dispose();
  }
}
