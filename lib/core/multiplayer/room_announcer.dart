import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'room_info.dart';

/// Tells the Wi-Fi about an open room (spec 14.2): its JSON on UDP every
/// [interval] to every address in [targets] (broadcasts in the app).
class RoomAnnouncer {
  RoomAnnouncer._(this._socket, this._room, this._port, this._targets, Duration interval) {
    _send();
    _timer = Timer.periodic(interval, (_) => _send());
  }

  static const defaultPort = 47123;
  static const defaultInterval = Duration(seconds: 2);

  static Future<RoomAnnouncer> start(
    RoomInfo room, {
    int port = defaultPort,
    required List<InternetAddress> targets,
    Duration interval = defaultInterval,
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      ..broadcastEnabled = true;
    return RoomAnnouncer._(socket, room, port, targets, interval);
  }

  final RawDatagramSocket _socket;
  final int _port;
  final List<InternetAddress> _targets;
  RoomInfo _room;
  late final Timer _timer;
  var _closed = false;

  RoomInfo get room => _room;

  /// E.g. fewer free places; sent right away.
  void update(RoomInfo room) {
    _room = room;
    _send();
  }

  void _send() {
    if (_closed) return;
    final data = utf8.encode(jsonEncode(_room.toJson()));
    for (final target in _targets) {
      try {
        _socket.send(data, target, _port);
      } on Object {
        // A network that went away; the next round tries again.
      }
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _timer.cancel();
    _socket.close();
  }
}
