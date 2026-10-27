import 'dart:async';

import 'message_channel.dart';
import 'protocol.dart';

/// Two connected in-process channels for tests (spec 14.7), with an optional
/// [latency]. Messages go through JSON, like on the network.
class LoopbackChannel implements MessageChannel {
  LoopbackChannel._(this._latency);

  final Duration _latency;
  final _in = StreamController<NetMessage>.broadcast();
  LoopbackChannel? _other;
  var _closed = false;
  Future<void> _last = Future.value();

  static (LoopbackChannel, LoopbackChannel) pair({Duration latency = Duration.zero}) {
    final a = LoopbackChannel._(latency), b = LoopbackChannel._(latency);
    a._other = b;
    b._other = a;
    return (a, b);
  }

  /// Cut the line as if Wi-Fi dropped: both sides see their stream end.
  void drop() {
    _other?._end();
    _end();
  }

  @override
  Stream<NetMessage> get incoming => _in.stream;

  @override
  void send(NetMessage message) {
    final other = _other;
    if (_closed || other == null) return;
    final text = message.encode();
    final due = DateTime.now().add(_latency);
    // Each message arrives [_latency] after it was sent; chained so they
    // always arrive in the order they were sent.
    _last = _last.then((_) {
      final wait = due.difference(DateTime.now());
      return Future<void>.delayed(wait.isNegative ? Duration.zero : wait);
    }).then((_) {
      final decoded = NetMessage.decode(text);
      if (!other._closed && decoded != null) other._in.add(decoded);
    });
  }

  void _end() {
    if (_closed) return;
    _closed = true;
    _in.close();
  }

  /// Hangs up after what was sent arrives, like a WebSocket close.
  @override
  Future<void> close() async {
    await _last;
    drop();
  }
}
