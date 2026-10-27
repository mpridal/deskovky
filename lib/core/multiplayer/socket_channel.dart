import 'dart:async';
import 'dart:io';

import 'message_channel.dart';
import 'protocol.dart';

/// A [MessageChannel] over a WebSocket on the home Wi-Fi (spec 14.3). Both
/// sides send a [Ping] every [pingInterval] and answer pings themselves; a
/// line silent for [deadAfter] counts as lost and its stream ends. Pings
/// and pongs never reach [incoming].
class SocketChannel implements MessageChannel {
  SocketChannel(
    this._socket, {
    this.pingInterval = defaultPingInterval,
    this.deadAfter = defaultDeadAfter,
  }) {
    _lastHeard = DateTime.now();
    _sub = _socket.listen(_onData, onDone: _end, onError: (Object _) => _end(), cancelOnError: true);
    _heartbeat = Timer.periodic(pingInterval, (_) => _beat());
  }

  static const defaultPingInterval = Duration(seconds: 3);
  static const defaultDeadAfter = Duration(seconds: 8);

  /// Connects to a host's room; throws a [SocketException] when nobody
  /// answers within [timeout].
  static Future<SocketChannel> connect(
    String host,
    int port, {
    Duration timeout = const Duration(seconds: 5),
    Duration pingInterval = defaultPingInterval,
    Duration deadAfter = defaultDeadAfter,
  }) async {
    final socket = await WebSocket.connect('ws://$host:$port').timeout(
      timeout,
      onTimeout: () => throw SocketException('No answer from $host:$port'),
    );
    return SocketChannel(socket, pingInterval: pingInterval, deadAfter: deadAfter);
  }

  final WebSocket _socket;
  final Duration pingInterval;
  final Duration deadAfter;
  final _in = StreamController<NetMessage>.broadcast();
  late final StreamSubscription<Object?> _sub;
  late final Timer _heartbeat;
  late DateTime _lastHeard;
  var _closed = false;

  @override
  Stream<NetMessage> get incoming => _in.stream;

  @override
  void send(NetMessage message) {
    if (_closed) return;
    try {
      _socket.add(message.encode());
    } on Object {
      _end();
    }
  }

  void _onData(Object? data) {
    _lastHeard = DateTime.now();
    if (data is! String) return;
    switch (NetMessage.decode(data)) {
      case Ping(:final t):
        send(Pong(t));
      case Pong():
        break;
      case final NetMessage message:
        if (!_closed) _in.add(message);
      case null:
        break;
    }
  }

  void _beat() {
    if (DateTime.now().difference(_lastHeard) > deadAfter) {
      _end();
      return;
    }
    send(Ping(DateTime.now().millisecondsSinceEpoch));
  }

  void _end() {
    if (_closed) return;
    _closed = true;
    _heartbeat.cancel();
    _sub.cancel();
    _socket.close().ignore();
    _in.close();
  }

  @override
  Future<void> close() async => _end();
}
