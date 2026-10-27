import 'dart:async';
import 'dart:io';

import 'message_channel.dart';
import 'socket_channel.dart';

/// The host's WebSocket server on the home Wi-Fi (spec 14.3): every device
/// that connects arrives on [channels]. [close] shuts the port and every line.
class NetServer {
  NetServer._(this._server, this._pingInterval, this._deadAfter) {
    _sub = _server.listen(_onRequest);
  }

  /// Listens on [port] (0: any free one) of [address].
  static Future<NetServer> start({
    Object? address,
    int port = 0,
    Duration pingInterval = SocketChannel.defaultPingInterval,
    Duration deadAfter = SocketChannel.defaultDeadAfter,
  }) async {
    final server = await HttpServer.bind(address ?? InternetAddress.anyIPv4, port);
    return NetServer._(server, pingInterval, deadAfter);
  }

  final HttpServer _server;
  final Duration _pingInterval;
  final Duration _deadAfter;
  late final StreamSubscription<HttpRequest> _sub;
  final _channels = StreamController<MessageChannel>.broadcast();
  final _open = <SocketChannel>{};
  var _closed = false;

  int get port => _server.port;
  Stream<MessageChannel> get channels => _channels.stream;

  Future<void> _onRequest(HttpRequest request) async {
    if (_closed || !WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    try {
      final socket = await WebSocketTransformer.upgrade(request);
      if (_closed) {
        await socket.close();
        return;
      }
      final channel = SocketChannel(socket, pingInterval: _pingInterval, deadAfter: _deadAfter);
      _open.add(channel);
      channel.incoming.listen(null, onDone: () => _open.remove(channel));
      _channels.add(channel);
    } on Object {
      // A broken handshake: nothing to keep.
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _sub.cancel();
    for (final channel in [..._open]) {
      await channel.close();
    }
    _open.clear();
    await _server.close(force: true);
    await _channels.close();
  }
}
