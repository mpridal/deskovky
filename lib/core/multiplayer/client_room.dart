import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../games/registry.dart';
import '../game/game_config.dart';
import '../game/game_module.dart';
import '../game/game_session.dart';
import 'message_channel.dart';
import 'network_transport.dart';
import '../game/move.dart';
import 'protocol.dart';

/// A device that joined a host's room (spec 14). It keeps its own copy of the
/// game, applies the host's moves in order and checks every hash; a gap or a
/// mismatch asks the host for a snapshot (spec 14.7).
class ClientRoom extends ChangeNotifier {
  ClientRoom({
    required this.channel,
    required this.hello,
    required this.localProfileIds,
    this.findModule = moduleById,
  }) {
    _sub = channel.incoming.listen(_onMessage, onDone: _onGone);
    channel.send(hello);
  }

  final MessageChannel channel;
  final Hello hello;

  /// This device's profile ids, in the order of [hello]'s profiles.
  final List<int> localProfileIds;

  /// The game by id; the registry in the app, a test's own in tests.
  final GameModule<Object?>? Function(String id) findModule;
  late final StreamSubscription<NetMessage> _sub;

  String? _clientId;
  String? _token;
  String? _closedReason;
  LobbyState? _lobby;
  GameSession<Object?>? _session;
  ClientTransport? _transport;
  GameConfig? _deviceConfig;
  Set<int> _mySeats = const {};
  var _seq = 0;
  var _awaitingSnapshot = false;
  var _disposed = false;

  String? get clientId => _clientId;

  /// Lets this device come back after a dropout (spec 14.4).
  String? get token => _token;

  /// Why the host hung up ('version', 'code', 'full', 'started', 'kicked',
  /// 'lost'…), or null while connected.
  String? get closedReason => _closedReason;
  LobbyState? get lobby => _lobby;
  GameSession<Object?>? get session => _session;
  ClientTransport? get transport => _transport;
  GameConfig? get deviceConfig => _deviceConfig;
  Set<int> get mySeats => _mySeats;
  int get seq => _seq;

  void setReady(bool ready) => _send(Ready(ready));

  /// Asks the host to play [move]; true once the host applied it.
  Future<bool> submit(Move move) => _transport?.submit(move) ?? Future.value(false);

  void _onMessage(NetMessage message) {
    if (_disposed) return;
    switch (message) {
      case Welcome(:final clientId, :final token):
        _clientId = clientId;
        _token = token;
      case LobbyState():
        _lobby = message;
      case Start():
        _onStart(message);
      case MoveApplied():
        _onMoveApplied(message);
      case MoveRejected(:final seq):
        _transport?.reject();
        if (seq != _seq) _requestSnapshot();
      case StateSnapshot():
        _onSnapshot(message);
      case Ping(:final t):
        _send(Pong(t));
      case Bye(:final reason):
        _closedReason = reason;
        channel.close();
      case Kick():
        _closedReason = 'kicked';
        channel.close();
      default:
        return;
    }
    notifyListeners();
  }

  void _onStart(Start start) {
    final module = findModule(start.config.gameId);
    if (module == null) {
      _closedReason = 'unknownGame';
      channel.close();
      return;
    }
    _session = GameSession.start(module.rules, start.config, start.seed);
    _seq = 0;
    _awaitingSnapshot = false;
    _mySeats = start.yourSeats.keys.toSet();
    _deviceConfig = start.config.forDevice({
      for (final e in start.yourSeats.entries)
        if (e.value >= 0 && e.value < localProfileIds.length) e.key: localProfileIds[e.value],
    });
    _transport?.dispose();
    _transport = ClientTransport((move) => _send(MoveRequest(move: move, basedOn: _seq)));
  }

  void _onMoveApplied(MoveApplied applied) {
    final session = _session;
    if (session == null || _awaitingSnapshot || applied.seq <= _seq) return;
    if (applied.seq != _seq + 1 || !session.apply(applied.move) || session.hash != applied.stateHash) {
      _requestSnapshot();
      return;
    }
    _seq = applied.seq;
    _transport?.confirm(applied.move);
  }

  void _onSnapshot(StateSnapshot snapshot) {
    final session = _session;
    if (session == null) return;
    _awaitingSnapshot = false;
    if (!session.replaceWith(snapshot.saved)) {
      debugPrint('ClientRoom: the host\'s snapshot does not replay; asking again');
      _requestSnapshot();
      return;
    }
    _seq = snapshot.seq;
    _transport?.resynced(session.lastMove);
  }

  void _requestSnapshot() {
    if (_awaitingSnapshot) return;
    _awaitingSnapshot = true;
    _send(const SnapshotRequest());
  }

  void _send(NetMessage message) {
    if (!_disposed && _closedReason == null) channel.send(message);
  }

  void _onGone() {
    _closedReason ??= 'lost';
    _transport?.reject();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub.cancel();
    _transport?.dispose();
    channel.close();
    super.dispose();
  }
}
