import 'dart:async';

import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/message_channel.dart';
import 'package:deskovky/core/multiplayer/network_env.dart';
import 'package:deskovky/core/multiplayer/room_info.dart';

/// Network play without a network: servers and connections are loopback
/// channels, the rooms "on the Wi-Fi" are [found].
class FakeNetworkEnv extends NetworkEnv {
  FakeNetworkEnv({this.address = '192.168.1.5', this.found = const [], this.onConnect});

  String? address;
  List<RoomInfo> found;

  /// Where [connect] delivers the host's end; the served room by default.
  void Function(MessageChannel hostSide)? onConnect;
  final _incoming = StreamController<MessageChannel>.broadcast();

  /// Sees the client's end of every [connect], e.g. to cut it.
  void Function(LoopbackChannel clientSide)? onLine;
  final announced = <RoomInfo>[];
  var announcing = false;

  /// Hands [hostSide] of a line to the served room.
  void deliver(MessageChannel hostSide) => _incoming.add(hostSide);

  /// A device joining the served room.
  MessageChannel connectToServed() {
    final (hostSide, clientSide) = LoopbackChannel.pair();
    _incoming.add(hostSide);
    return clientSide;
  }

  @override
  Future<String?> wifiAddress() async => address;

  @override
  Future<OpenServer> serve() async => OpenServer(port: 50505, channels: _incoming.stream, close: () async {});

  @override
  Future<Announcement> announce(RoomInfo room) async {
    announced.add(room);
    announcing = true;
    return _FakeAnnouncement(this);
  }

  /// True while some screen listens for rooms (on Android: holds the lock).
  var searching = false;

  @override
  Stream<List<RoomInfo>> rooms() {
    late final StreamController<List<RoomInfo>> out;
    out = StreamController<List<RoomInfo>>(
      onListen: () {
        searching = true;
        out.add(found);
      },
      onCancel: () => searching = false,
    );
    return out.stream;
  }

  @override
  Future<MessageChannel> connect(String ip, int port) async {
    final (hostSide, clientSide) = LoopbackChannel.pair();
    onLine?.call(clientSide);
    final target = onConnect;
    if (target != null) {
      target(hostSide);
    } else {
      _incoming.add(hostSide);
    }
    return clientSide;
  }
}

class _FakeAnnouncement implements Announcement {
  _FakeAnnouncement(this.env);

  final FakeNetworkEnv env;

  @override
  void update(RoomInfo room) => env.announced.add(room);

  @override
  void close() => env.announcing = false;
}
