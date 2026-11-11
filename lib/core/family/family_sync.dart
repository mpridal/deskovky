import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../multiplayer/message_channel.dart';
import '../multiplayer/protocol.dart';
import 'family_identity.dart';
import 'family_op.dart';
import 'family_store.dart';
import 'uid.dart';

/// The family sync's own version; devices with another one do not sync
/// (the parents' corner asks to update every device).
const familySyncVersion = 1;

/// Ops per message.
const _batch = 500;

@immutable
class SyncOutcome {
  const SyncOutcome.ok({required this.peer, required this.sent, required this.received}) : ok = true, reason = null;

  const SyncOutcome.failed(this.reason, {this.peer}) : ok = false, sent = 0, received = 0;

  final bool ok;

  /// Why it failed: version, family, removed, auth, lost.
  final String? reason;
  final String? peer;
  final int sent;
  final int received;

  @override
  String toString() => ok ? 'SyncOutcome(ok, $peer, sent $sent, received $received)' : 'SyncOutcome($reason)';
}

class _Refused implements Exception {
  const _Refused(this.reason);

  final String reason;
}

/// One meeting of two family devices over [channel] (spec 7.2): both prove
/// they know the family key (nothing else is sent before that), tell what
/// they have, send each other what is missing and rebuild their tables.
/// The [initiator] (the device that connected) says hello first.
Future<SyncOutcome> syncOver(
  MessageChannel channel, {
  required FamilyStore store,
  required FamilyIdentity family,
  required bool initiator,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final me = await store.deviceId();
  final inbox = StreamIterator(channel.incoming.where((m) => m is FamilyMessage).cast<FamilyMessage>());
  void send(Map<String, Object?> body) => channel.send(FamilyMessage(body));

  Future<Map<String, Object?>> next(String expected) async {
    if (!await inbox.moveNext().timeout(timeout, onTimeout: () => false)) throw const _Refused('lost');
    final body = inbox.current.body;
    if (body['t'] == 'bye') throw _Refused(body['reason'] as String? ?? 'bye');
    if (body['t'] != expected) throw const _Refused('lost');
    return body;
  }

  Never refuse(String reason) {
    send({'t': 'bye', 'reason': reason});
    throw _Refused(reason);
  }

  String? peer;
  try {
    final nonce = newUid();
    final hello = {'t': 'hello', 'v': familySyncVersion, 'family': family.familyId, 'device': me, 'nonce': nonce};
    if (initiator) send(hello);
    final theirs = await next('hello');
    if (theirs['v'] != familySyncVersion) refuse('version');
    if (theirs['family'] != family.familyId) refuse('family');
    final peerId = theirs['device'], peerNonce = theirs['nonce'];
    if (peerId is! String || peerNonce is! String) refuse('lost');
    peer = peerId;
    final removed = await store.removedDevices();
    if (removed.contains(peerId) || removed.contains(me)) refuse('removed');
    if (!initiator) send(hello);

    // Each side proves it knows the key, over both nonces and its own id.
    final (first, second) = initiator ? (nonce, peerNonce) : (peerNonce, nonce);
    String proof(String device) =>
        Hmac(sha256, family.keyBytes).convert(utf8.encode('deskovky-family|$first|$second|$device')).toString();
    send({'t': 'proof', 'hmac': proof(me)});
    final theirProof = await next('proof');
    if (theirProof['hmac'] != proof(peerId)) refuse('auth');

    send({'t': 'have', 'vector': await store.versionVector()});
    final have = await next('have');
    final vector = {
      for (final e in (have['vector'] as Map<String, Object?>? ?? const {}).entries)
        if (e.value case final int seq) e.key: seq,
    };
    final missing = await store.opsAfter(vector);
    for (var i = 0; i < missing.length; i += _batch) {
      send({
        't': 'ops',
        'ops': [for (final op in missing.skip(i).take(_batch)) op.toJson()],
      });
    }
    send({'t': 'done'});

    final received = <FamilyOp>[];
    while (true) {
      if (!await inbox.moveNext().timeout(timeout, onTimeout: () => false)) throw const _Refused('lost');
      final body = inbox.current.body;
      if (body['t'] == 'done') break;
      if (body['t'] == 'bye') throw _Refused(body['reason'] as String? ?? 'bye');
      if (body['t'] != 'ops') continue;
      for (final json in body['ops'] as List? ?? const []) {
        if (FamilyOp.fromJson(json) case final op?) received.add(op);
      }
    }
    final added = await store.insertRemote(received);
    if (added > 0) await store.rebuild();
    await store.markSynced(peerId);
    return SyncOutcome.ok(peer: peerId, sent: missing.length, received: added);
  } on _Refused catch (e) {
    return SyncOutcome.failed(e.reason, peer: peer);
  } on Object catch (e) {
    debugPrint('Family sync failed: $e');
    return SyncOutcome.failed('lost', peer: peer);
  } finally {
    await inbox.cancel();
  }
}
