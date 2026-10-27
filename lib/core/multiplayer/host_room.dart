import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../features/game_play/turn_controller.dart';
import '../game/ai_player.dart';
import '../game/difficulty.dart';
import '../game/game_config.dart';
import '../game/game_module.dart';
import '../game/game_session.dart';
import '../game/move.dart';
import 'message_channel.dart';
import 'network_transport.dart';
import 'protocol.dart';

/// One place in the host's room (spec 14.6).
@immutable
sealed class RoomSlot {
  const RoomSlot();
}

/// A person playing on the host's own device.
class LocalSlot extends RoomSlot {
  const LocalSlot({required this.profileId, required this.card});

  final int profileId;
  final ProfileCard card;
}

/// A free place for a person on another device.
class OpenSlot extends RoomSlot {
  const OpenSlot();
}

class RobotSlot extends RoomSlot {
  const RobotSlot();
}

/// A person on another device; [profileIndex] is their place in its [Hello].
class RemoteSlot extends RoomSlot {
  const RemoteSlot({
    required this.clientId,
    required this.profileIndex,
    required this.card,
    this.ready = false,
    this.connected = true,
  });

  final String clientId;
  final int profileIndex;
  final ProfileCard card;
  final bool ready;
  final bool connected;

  RemoteSlot copyWith({bool? ready, bool? connected}) => RemoteSlot(
    clientId: clientId,
    profileIndex: profileIndex,
    card: card,
    ready: ready ?? this.ready,
    connected: connected ?? this.connected,
  );
}

class _Conn {
  _Conn(this.channel);

  final MessageChannel channel;
  StreamSubscription<NetMessage>? sub;
  String? clientId;
}

/// The host of a network game (spec 14): keeps the room, deals places, starts
/// the game and is its only source of truth – every move is checked and
/// applied here, then sent to all devices with the state's hash.
class HostRoom extends ChangeNotifier {
  HostRoom({
    required this.module,
    required this.roomCode,
    required List<RoomSlot> slots,
    required this.difficulty,
    required this.robotSpeed,
    required this.options,
    this.runner = const IsolateAiRunner(),
    Duration? robotDelay,
    int? seed,
  }) : _slots = [...slots],
       robotDelay = robotDelay ?? robotSpeed.delay,
       seed = seed ?? Random().nextInt(1 << 31);

  /// The `clientId` of the host's own players in the shared config.
  static const hostId = 'host';

  final GameModule<Object?> module;
  final String roomCode;
  final Difficulty difficulty;
  final RobotSpeed robotSpeed;
  final Map<String, Object?> options;
  final AiRunner runner;
  final Duration robotDelay;
  final int seed;

  final List<RoomSlot> _slots;
  final _conns = <_Conn>[];
  final _tokens = <String, String>{};
  final _random = Random.secure();
  var _nextClient = 0;
  var _seq = 0;
  var _disposed = false;

  GameSession<Object?>? _session;
  TurnController<Object?>? _controller;
  HostTransport? _transport;
  GameConfig? _deviceConfig;

  /// Seat → device ('host', a clientId, or null for a robot).
  List<String?> _owners = const [];

  List<RoomSlot> get slots => List.unmodifiable(_slots);
  GameSession<Object?>? get session => _session;
  TurnController<Object?>? get controller => _controller;

  /// The shared config as this device shows it: its own people are humans.
  GameConfig? get deviceConfig => _deviceConfig;
  bool get started => _session != null;
  bool get isOver => _session != null && _session!.rules.isOver(_session!.state);
  int get seq => _seq;

  String? ownerOf(int seat) => seat >= 0 && seat < _owners.length ? _owners[seat] : null;

  bool get canStart {
    if (started) return false;
    final playing = _slots.where((s) => s is! OpenSlot).toList();
    if (playing.length < module.minPlayers || playing.length > module.maxPlayers) return false;
    return playing.whereType<RemoteSlot>().every((s) => s.ready && s.connected);
  }

  /// A new device on the line; it must say [Hello] first.
  void accept(MessageChannel channel) {
    if (_disposed) {
      channel.close();
      return;
    }
    final conn = _Conn(channel);
    _conns.add(conn);
    conn.sub = channel.incoming.listen((m) => _onMessage(conn, m), onDone: () => _onGone(conn));
  }

  void start() {
    if (!canStart) return;
    _slots.removeWhere((s) => s is OpenSlot);
    final seats = <SeatConfig>[];
    final owners = <String?>[];
    final localProfiles = <int, int>{};
    for (final (i, slot) in _slots.indexed) {
      switch (slot) {
        case LocalSlot(:final profileId, :final card):
          seats.add(RemoteSeat(clientId: hostId, name: card.name, avatar: card.avatar));
          owners.add(hostId);
          localProfiles[i] = profileId;
        case RemoteSlot(:final clientId, :final card):
          seats.add(RemoteSeat(clientId: clientId, name: card.name, avatar: card.avatar));
          owners.add(clientId);
        case RobotSlot():
          seats.add(const RobotSeat());
          owners.add(null);
        case OpenSlot():
          break;
      }
    }
    final config = GameConfig(
      gameId: module.id,
      seats: seats,
      difficulty: difficulty,
      robotSpeed: robotSpeed,
      options: options,
    );
    _owners = owners;
    _deviceConfig = config.forDevice(localProfiles);
    final session = _session = GameSession.start(module.rules, config, seed);
    final transport = _transport = HostTransport(_applyMove);
    for (final conn in _conns) {
      final id = conn.clientId;
      if (id != null) conn.channel.send(Start(config: config, seed: seed, yourSeats: _seatsOf(id)));
    }
    _controller = TurnController<Object?>(
      session: session,
      transport: transport,
      ai: module.ai,
      runner: runner,
      robotDelay: robotDelay,
      localSeats: localProfiles.keys.toSet(),
    )..start();
    notifyListeners();
  }

  /// A move by a person on this device.
  Future<bool> submitLocal(Move move) => _controller?.submitHuman(move) ?? Future.value(false);

  Map<int, int> _seatsOf(String clientId) => {
    for (final (i, slot) in _slots.indexed)
      if (slot case RemoteSlot(clientId: final id, :final profileIndex) when id == clientId) i: profileIndex,
  };

  bool _applyMove(Move move) {
    final session = _session;
    if (_disposed || session == null || !session.apply(move)) return false;
    _seq++;
    _broadcast(MoveApplied(seq: _seq, move: move, stateHash: session.hash));
    _transport?.emit(move);
    notifyListeners();
    return true;
  }

  void _onMessage(_Conn conn, NetMessage message) {
    if (_disposed) return;
    final clientId = conn.clientId;
    if (clientId == null) {
      if (message is Hello) _onHello(conn, message);
      return;
    }
    switch (message) {
      case Ready(:final ready):
        _setClient(clientId, (s) => s.copyWith(ready: ready));
      case MoveRequest():
        _onMoveRequest(conn, clientId, message);
      case SnapshotRequest():
        if (_session case final session?) conn.channel.send(StateSnapshot(seq: _seq, saved: session.toSave()));
      case Ping(:final t):
        conn.channel.send(Pong(t));
      default:
        break;
    }
  }

  void _onHello(_Conn conn, Hello hello) {
    if (hello.protocolVersion != protocolVersion) return _refuse(conn, 'version');
    if (hello.roomCode != roomCode) return _refuse(conn, 'code');
    final known = hello.token == null ? null : _tokens[hello.token];
    if (known != null) {
      // Back after a dropout (spec 14.4): the same places, the game so far.
      for (final other in _conns.where((c) => c != conn && c.clientId == known).toList()) {
        _drop(other);
      }
      conn.clientId = known;
      conn.channel.send(Welcome(clientId: known, token: hello.token!));
      _setClient(known, (s) => s.copyWith(connected: true));
      if (_session case final session?) {
        conn.channel.send(Start(config: session.config, seed: seed, yourSeats: _seatsOf(known)));
        conn.channel.send(StateSnapshot(seq: _seq, saved: session.toSave()));
      }
      return;
    }
    if (started) return _refuse(conn, 'started');
    final open = [for (final (i, s) in _slots.indexed) if (s is OpenSlot) i];
    if (hello.profiles.isEmpty || hello.profiles.length > open.length) return _refuse(conn, 'full');
    final clientId = 'c${++_nextClient}';
    final token = _newToken();
    _tokens[token] = clientId;
    conn.clientId = clientId;
    for (final (k, card) in hello.profiles.indexed) {
      _slots[open[k]] = RemoteSlot(clientId: clientId, profileIndex: k, card: card);
    }
    conn.channel.send(Welcome(clientId: clientId, token: token));
    _lobbyChanged();
  }

  void _onMoveRequest(_Conn conn, String clientId, MoveRequest request) {
    final session = _session;
    final move = request.move;
    final String? reason;
    if (session == null) {
      reason = 'notStarted';
    } else if (ownerOf(move.seat) != clientId) {
      reason = 'seat';
    } else if (request.basedOn != _seq) {
      reason = 'stale';
    } else if (_controller?.paused ?? false) {
      reason = 'paused';
    } else if (session.rules.currentSeat(session.state) != move.seat) {
      reason = 'turn';
    } else {
      reason = null;
    }
    if (reason == null && _applyMove(move)) return;
    conn.channel.send(MoveRejected(seq: _seq, reason: reason ?? 'illegal'));
  }

  void _onGone(_Conn conn) {
    _conns.remove(conn);
    final clientId = conn.clientId;
    if (_disposed || clientId == null || _conns.any((c) => c.clientId == clientId)) return;
    if (started) {
      _setClient(clientId, (s) => s.copyWith(connected: false));
    } else {
      // Left the room before the game: the places are free again.
      for (final (i, s) in _slots.indexed) {
        if (s is RemoteSlot && s.clientId == clientId) _slots[i] = const OpenSlot();
      }
      _lobbyChanged();
    }
  }

  void _setClient(String clientId, RemoteSlot Function(RemoteSlot slot) change) {
    for (final (i, s) in _slots.indexed) {
      if (s is RemoteSlot && s.clientId == clientId) _slots[i] = change(s);
    }
    _lobbyChanged();
  }

  void _lobbyChanged() {
    if (!started) _broadcast(lobbyState);
    notifyListeners();
  }

  /// The room as every device shows it.
  LobbyState get lobbyState => LobbyState(
    gameId: module.id,
    slots: [
      for (final slot in _slots)
        switch (slot) {
          LocalSlot(:final card) => LobbySlot(kind: SlotKind.host, name: card.name, avatar: card.avatar, ready: true),
          RemoteSlot(:final card, :final clientId, :final ready) => LobbySlot(
            kind: SlotKind.remote,
            name: card.name,
            avatar: card.avatar,
            clientId: clientId,
            ready: ready,
          ),
          RobotSlot() => const LobbySlot(kind: SlotKind.robot, name: '', avatar: {}, ready: true),
          OpenSlot() => const LobbySlot(kind: SlotKind.open, name: '', avatar: {}, ready: false),
        },
    ],
    options: options,
    difficulty: difficulty,
    robotSpeed: robotSpeed,
  );

  void _broadcast(NetMessage message) {
    for (final conn in _conns) {
      if (conn.clientId != null) conn.channel.send(message);
    }
  }

  void _refuse(_Conn conn, String reason) {
    conn.channel.send(Bye(reason: reason));
    _drop(conn);
  }

  void _drop(_Conn conn) {
    _conns.remove(conn);
    conn.sub?.cancel();
    conn.channel.close();
  }

  String _newToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes([for (var i = 0; i < 16; i++) chars.codeUnitAt(_random.nextInt(chars.length))]);
  }

  @override
  void dispose() {
    _disposed = true;
    for (final conn in [..._conns]) {
      _drop(conn);
    }
    _controller?.dispose();
    super.dispose();
  }
}
