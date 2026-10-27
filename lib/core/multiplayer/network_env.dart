import 'dart:async';
import 'dart:io';

import 'local_address.dart';
import 'message_channel.dart';
import 'net_server.dart';
import 'room_announcer.dart';
import 'room_finder.dart';
import 'room_info.dart';
import 'socket_channel.dart';

/// The host's open server: its port and the devices that connect.
class OpenServer {
  const OpenServer({required this.port, required this.channels, required this.close});

  final int port;
  final Stream<MessageChannel> channels;
  final Future<void> Function() close;
}

/// A room being announced until [close].
abstract class Announcement {
  void update(RoomInfo room);

  void close();
}

/// Everything network play needs from the device (spec 14.3); tests swap in
/// a loopback one.
abstract class NetworkEnv {
  const NetworkEnv();

  /// The Wi-Fi IPv4 address, or null when not on Wi-Fi.
  Future<String?> wifiAddress();

  Future<OpenServer> serve();

  Future<Announcement> announce(RoomInfo room);

  /// The rooms on the Wi-Fi, updated while listened to.
  Stream<List<RoomInfo>> rooms();

  Future<MessageChannel> connect(String ip, int port);
}

/// The real thing: WebSocket server, UDP broadcasts, Android multicast lock.
class DeviceNetworkEnv extends NetworkEnv {
  const DeviceNetworkEnv();

  @override
  Future<String?> wifiAddress() => localWifiAddress();

  @override
  Future<OpenServer> serve() async {
    final server = await NetServer.start();
    return OpenServer(port: server.port, channels: server.channels, close: server.close);
  }

  @override
  Future<Announcement> announce(RoomInfo room) async => _UdpAnnouncement(
    await RoomAnnouncer.start(
      room,
      targets: [InternetAddress('255.255.255.255'), InternetAddress(subnetBroadcast(room.ip))],
    ),
  );

  @override
  Stream<List<RoomInfo>> rooms() {
    RoomFinder? finder;
    StreamSubscription<List<RoomInfo>>? sub;
    const lock = MulticastLock();
    late final StreamController<List<RoomInfo>> out;
    out = StreamController<List<RoomInfo>>(
      onListen: () async {
        await lock.acquire();
        try {
          finder = await RoomFinder.start();
        } on SocketException catch (e) {
          out.addError(e);
          return;
        }
        if (out.isClosed) {
          finder?.close();
          return;
        }
        out.add(finder!.current);
        sub = finder!.rooms.listen(out.add);
      },
      onCancel: () async {
        await sub?.cancel();
        finder?.close();
        await lock.release();
        await out.close();
      },
    );
    return out.stream;
  }

  @override
  Future<MessageChannel> connect(String ip, int port) => SocketChannel.connect(ip, port);
}

class _UdpAnnouncement implements Announcement {
  _UdpAnnouncement(this._announcer);

  final RoomAnnouncer _announcer;

  @override
  void update(RoomInfo room) => _announcer.update(room);

  @override
  void close() => _announcer.close();
}
