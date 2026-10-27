import 'protocol.dart';

/// A two-way line to one other device: a WebSocket in the app, a loopback in
/// tests (spec 14.7).
abstract class MessageChannel {
  /// Decoded messages from the other side; the stream ends when the line is
  /// closed or lost.
  Stream<NetMessage> get incoming;

  void send(NetMessage message);

  Future<void> close();
}
