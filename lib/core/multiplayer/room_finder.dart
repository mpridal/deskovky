import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'room_announcer.dart';
import 'room_info.dart';

/// Listens for rooms announced on the Wi-Fi (spec 14.2 step 3). A room not
/// heard for [staleAfter] is gone; anything that is not a room is ignored.
class RoomFinder {
  RoomFinder._(this._socket, this._staleAfter) {
    _sub = _socket.listen(_onEvent);
    _sweep = Timer.periodic(const Duration(milliseconds: 100), (_) => _dropStale());
  }

  static const defaultStaleAfter = Duration(seconds: 6);

  static Future<RoomFinder> start({
    int port = RoomAnnouncer.defaultPort,
    InternetAddress? address,
    Duration staleAfter = defaultStaleAfter,
  }) async {
    final socket = await RawDatagramSocket.bind(address ?? InternetAddress.anyIPv4, port, reuseAddress: true);
    return RoomFinder._(socket, staleAfter);
  }

  final RawDatagramSocket _socket;
  final Duration _staleAfter;
  late final StreamSubscription<RawSocketEvent> _sub;
  late final Timer _sweep;
  final _rooms = <String, (RoomInfo, DateTime)>{};
  final _out = StreamController<List<RoomInfo>>.broadcast();

  /// Every change of the list of rooms.
  Stream<List<RoomInfo>> get rooms => _out.stream;

  List<RoomInfo> get current => [for (final (room, _) in _rooms.values) room];

  void _onEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    final datagram = _socket.receive();
    if (datagram == null || datagram.data.length > 2048) return;
    RoomInfo? room;
    try {
      room = RoomInfo.fromJson(jsonDecode(utf8.decode(datagram.data)));
    } on Object {
      return;
    }
    if (room == null) return;
    // The address the packet came from is the one that answers.
    room = room.copyWith(ip: datagram.address.address);
    final key = '${room.ip}:${room.port}';
    final before = _rooms[key]?.$1;
    _rooms[key] = (room, DateTime.now());
    if (before != room) _emit();
  }

  void _dropStale() {
    final now = DateTime.now();
    final before = _rooms.length;
    _rooms.removeWhere((_, entry) => now.difference(entry.$2) > _staleAfter);
    if (_rooms.length != before) _emit();
  }

  void _emit() {
    if (!_out.isClosed) _out.add(current);
  }

  void close() {
    _sweep.cancel();
    _sub.cancel();
    _socket.close();
    _out.close();
  }
}
