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
    this.reconnectGrace = const Duration(seconds: 30),
  }) : _slots = [...slots],
       robotDelay = robotDelay ?? robotSpeed.delay,
       _seed = seed ?? Random().nextInt(1 << 31);

  /// The `clientId` of the host's own players in the shared config.
  static const hostId = 'host';

  final GameModule<Object?> module;
  final String roomCode;
  final Difficulty difficulty;
  final RobotSpeed robotSpeed;
  final Map<String, Object?> options;
  final AiRunner runner;
  final Duration robotDelay;

  /// How long the game waits for a dropped device before the host decides
  /// (spec 14.4: 30 s).
  final Duration reconnectGrace;
  int _seed;
  int get seed => _seed;

  final List<RoomSlot> _slots;
  final _conns = <_Conn>[];
  final _tokens = <String, String>{};
  final _random = Random.secure();
  var _nextClient = 0;
  var _seq = 0;
  var _disposed = false;

  /// Paused by someone (not by a dropout).
  var _pausedByPlayer = false;

  /// Seats whose device dropped and is waited for.
  final _waiting = <int>{};
  DateTime? _waitUntil;
  Timer? _waitTimer;

  /// Devices that said goodbye: no waiting, a robot plays on.
  final _left = <String>{};

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

  bool get paused => _controller?.paused ?? false;

  /// Seats waited for after a dropout (spec 14.4).
  Set<int> get waitingFor => Set.unmodifiable(_waiting);

  /// Whole seconds left of the wait, null when nobody is waited for.
  int? get waitSeconds {
    final until = _waitUntil;
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    return left.isNegative ? 0 : (left.inMilliseconds / 1000).ceil();
  }

  /// The wait ran out: the host chooses Čekat dál / Nahradit robotem / Ukončit hru.
  bool get needsDecision => _waiting.isNotEmpty && waitSeconds == 0;

  /// Ended by the host for everyone.
  bool get ended => _ended;
  var _ended = false;

  String? ownerOf(int seat) => seat >= 0 && seat < _owners.length ? _owners[seat] : null;

  bool get canStart {
    if (started) return false;
    final playing = _slots.where((s) => s is! OpenSlot).toList();
    if (playing.length < module.minPlayers || playing.length > module.maxPlayers) return false;
    return playing.whereType<RemoteSlot>().every((s) => s.ready && s.connected);
  }

  int get freePlaces => _slots.whereType<OpenSlot>().length;

  /// Before the game: puts [slot] (open, robot or a person of this device)
  /// at [index]. A remote person's place only frees up through [kick].
  void setSlot(int index, RoomSlot slot) {
    if (started || index < 0 || index >= _slots.length || _slots[index] is RemoteSlot || slot is RemoteSlot) return;
    _slots[index] = slot;
    _lobbyChanged();
  }

  /// Removes a device and its people from the room (spec 14.3).
  void kick(String clientId) {
    for (final conn in _conns.where((c) => c.clientId == clientId).toList()) {
      conn.channel.send(const Kick());
      _drop(conn);
    }
    if (!started) {
      for (final (i, s) in _slots.indexed) {
        if (s is RemoteSlot && s.clientId == clientId) _slots[i] = const OpenSlot();
      }
    }
    _tokens.removeWhere((_, id) => id == clientId);
    _lobbyChanged();
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
    _begin(config, localProfiles.keys.toSet());
  }

  /// The same players again with a new deal (spec 14.2 step 8: Odveta).
  void rematch() {
    final session = _session;
    if (session == null || _ended) return;
    final previous = _seed;
    while (_seed == previous) {
      _seed = Random().nextInt(1 << 31);
    }
    _controller?.dispose();
    _begin(session.config, _controller?.localSeats ?? const {});
  }

  /// Starts [config] on this device and on every connected one.
  void _begin(GameConfig config, Set<int> localSeats) {
    _seq = 0;
    _pausedByPlayer = false;
    _clearWait();
    final transport = _transport = HostTransport(_applyMove);
    final (session, controller) = module.withType(<T>(m) {
      final session = GameSession<T>.start(m.rules, config, _seed);
      return (
        session as GameSession<Object?>,
        TurnController<T>(
              session: session,
              transport: transport,
              ai: m.ai,
              runner: runner,
              robotDelay: robotDelay,
              localSeats: localSeats,
            )
            as TurnController<Object?>,
      );
    });
    _session = session;
    _controller = controller;
    for (final conn in _conns) {
      final id = conn.clientId;
      if (id != null) conn.channel.send(Start(config: config, seed: _seed, yourSeats: _seatsOf(id)));
    }
    // Whoever is not here any more is played by a robot.
    for (final (seat, owner) in _owners.indexed) {
      if (owner != null && owner != hostId && !_conns.any((c) => c.clientId == owner)) {
        controller.setStandIn(seat, true);
      }
    }
    controller.start();
    notifyListeners();
  }

  /// Anyone may pause (spec 14.4); every device shows it.
  void pause({int? bySeat}) {
    final controller = _controller;
    if (controller == null || _ended) return;
    _pausedByPlayer = true;
    controller.pause();
    _broadcast(Pause(bySeat: bySeat));
    notifyListeners();
  }

  /// Ends a pause; a dropped device still waited for keeps the game paused.
  void resume() {
    final controller = _controller;
    if (controller == null || _ended) return;
    _pausedByPlayer = false;
    if (_waiting.isNotEmpty) return notifyListeners();
    controller.resume();
    _broadcast(const Resume());
    notifyListeners();
  }

  /// After the wait: give the dropped device another [reconnectGrace].
  void waitLonger() {
    if (_waiting.isEmpty) return;
    _startWait();
  }

  /// After the wait: robots play for the dropped people until they return.
  void replaceWithRobot() {
    final controller = _controller;
    if (controller == null) return;
    for (final seat in _waiting) {
      controller.setStandIn(seat, true);
    }
    _clearWait();
    _broadcastPeers();
    if (!_pausedByPlayer) {
      controller.resume();
      _broadcast(const Resume());
    }
    notifyListeners();
  }

  /// Ends the game for everyone (only the host can, spec 14.4).
  void endGame() {
    if (_ended) return;
    _ended = true;
    _clearWait();
    _controller?.pause();
    for (final conn in [..._conns]) {
      if (conn.clientId != null) conn.channel.send(const Bye(reason: 'ended'));
      _drop(conn);
    }
    notifyListeners();
  }

  void _startWait() {
    _waitUntil = DateTime.now().add(reconnectGrace);
    _waitTimer?.cancel();
    final tick = reconnectGrace < const Duration(seconds: 1) ? reconnectGrace ~/ 4 : const Duration(seconds: 1);
    _waitTimer = Timer.periodic(tick, (_) {
      _broadcastPeers();
      notifyListeners();
      if (waitSeconds == 0) _waitTimer?.cancel();
    });
    _broadcastPeers();
    notifyListeners();
  }

  void _clearWait() {
    _waiting.clear();
    _waitUntil = null;
    _waitTimer?.cancel();
    _waitTimer = null;
  }

  void _broadcastPeers() {
    _broadcast(
      PeerStatus(
        connected: {
          for (final (seat, owner) in _owners.indexed)
            if (owner != null && owner != hostId) seat: !_waiting.contains(seat),
        },
        waitSeconds: waitSeconds,
      ),
    );
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
      case Pause():
        pause(bySeat: _seatsOf(clientId).keys.firstOrNull);
      case Resume():
        resume();
      case Bye():
        // Leaving on purpose: a robot takes over without waiting.
        _left.add(clientId);
        _drop(conn);
        _onGone(conn);
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
      _left.remove(known);
      conn.channel.send(Welcome(clientId: known, token: hello.token!));
      _setClient(known, (s) => s.copyWith(connected: true));
      if (_session case final session?) {
        conn.channel.send(Start(config: session.config, seed: _seed, yourSeats: _seatsOf(known)));
        conn.channel.send(StateSnapshot(seq: _seq, saved: session.toSave()));
        // Their places are theirs again, from a robot or from the wait.
        for (final seat in _seatsOf(known).keys) {
          _waiting.remove(seat);
          _controller?.setStandIn(seat, false);
        }
        if (_waiting.isEmpty) {
          _clearWait();
          if (!_pausedByPlayer && !_ended) {
            _controller?.resume();
            _broadcast(const Resume());
          }
        }
        _broadcastPeers();
        notifyListeners();
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
      final seats = _seatsOf(clientId).keys;
      if (_ended || isOver || seats.isEmpty) return;
      if (_left.contains(clientId)) {
        for (final seat in seats) {
          _controller?.setStandIn(seat, true);
        }
        _broadcastPeers();
        return;
      }
      // A dropout (spec 14.4): everybody waits, the host decides after the grace.
      _waiting.addAll(seats);
      _controller?.pause();
      _broadcast(const Pause());
      _startWait();
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
    _waitTimer?.cancel();
    for (final conn in [..._conns]) {
      _drop(conn);
    }
    _controller?.dispose();
    super.dispose();
  }
}
