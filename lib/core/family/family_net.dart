import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../multiplayer/local_address.dart';
import '../multiplayer/message_channel.dart';
import '../multiplayer/net_server.dart';
import '../multiplayer/network_env.dart';
import '../multiplayer/socket_channel.dart';

/// UDP port of the family announcements (rooms use 47123).
const familyBeaconPort = 47124;

/// How often a family device says it is here.
const familyBeaconInterval = Duration(seconds: 10);

/// "A device of family [familyTag] is at [ip]:[port]" (spec 7.2). Only a
/// tag of the family id is sent – no names, no data; [activeUid] says who
/// plays on it now (for invitations, spec 5.4).
@immutable
class FamilyBeacon {
  const FamilyBeacon({
    required this.familyTag,
    required this.deviceId,
    required this.ip,
    required this.port,
    this.activeUid,
    this.busy = false,
  });

  final String familyTag;
  final String deviceId;
  final String ip;
  final int port;
  final String? activeUid;

  /// A game is being played on it now (an invitation would not show).
  final bool busy;

  /// The tag of [familyId] sent instead of the id itself.
  static String tagOf(String familyId) =>
      sha256.convert(utf8.encode('deskovky-family:$familyId')).toString().substring(0, 16);

  FamilyBeacon copyWith({String? ip, String? activeUid, bool? busy}) => FamilyBeacon(
    familyTag: familyTag,
    deviceId: deviceId,
    ip: ip ?? this.ip,
    port: port,
    activeUid: activeUid ?? this.activeUid,
    busy: busy ?? this.busy,
  );

  Map<String, Object?> toJson() => {
    'app': 'deskovky-family',
    'v': 1,
    'tag': familyTag,
    'device': deviceId,
    'ip': ip,
    'port': port,
    'active': activeUid,
    if (busy) 'busy': true,
  };

  static FamilyBeacon? fromJson(Object? json) {
    if (json is! Map<String, Object?> || json['app'] != 'deskovky-family') return null;
    final tag = json['tag'], device = json['device'], ip = json['ip'], port = json['port'], active = json['active'];
    if (tag is! String || device is! String || ip is! String || port is! int) return null;
    return FamilyBeacon(
      familyTag: tag,
      deviceId: device,
      ip: ip,
      port: port,
      activeUid: active is String ? active : null,
      busy: json['busy'] == true,
    );
  }
}

abstract interface class FamilyAnnouncement {
  void update(FamilyBeacon beacon);

  void close();
}

/// What the family sync needs from the device's network; tests use a home
/// Wi-Fi in memory.
abstract interface class FamilyNet {
  Future<String?> wifiAddress();

  Future<OpenServer> serve();

  Future<MessageChannel> connect(String ip, int port);

  Future<FamilyAnnouncement> announce(FamilyBeacon beacon);

  /// Announcements of other devices on the Wi-Fi (any family).
  Stream<FamilyBeacon> beacons();
}

/// The real Wi-Fi: WebSocket server, UDP broadcasts, Android multicast lock
/// while listening.
class DeviceFamilyNet implements FamilyNet {
  const DeviceFamilyNet();

  @override
  Future<String?> wifiAddress() => localWifiAddress();

  @override
  Future<OpenServer> serve() async {
    final server = await NetServer.start();
    return OpenServer(port: server.port, channels: server.channels, close: server.close);
  }

  @override
  Future<MessageChannel> connect(String ip, int port) => SocketChannel.connect(ip, port);

  @override
  Future<FamilyAnnouncement> announce(FamilyBeacon beacon) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
      ..broadcastEnabled = true;
    return _UdpFamilyAnnouncement(socket, beacon);
  }

  @override
  Stream<FamilyBeacon> beacons() {
    RawDatagramSocket? socket;
    const lock = MulticastLock();
    late final StreamController<FamilyBeacon> out;
    out = StreamController<FamilyBeacon>(
      onListen: () async {
        await lock.acquire();
        try {
          socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, familyBeaconPort, reuseAddress: true);
        } on SocketException catch (e) {
          debugPrint('Family beacons: $e');
          return;
        }
        socket!.listen((event) {
          if (event != RawSocketEvent.read) return;
          final d = socket?.receive();
          if (d == null || d.data.length > 1024) return;
          try {
            final beacon = FamilyBeacon.fromJson(jsonDecode(utf8.decode(d.data)));
            if (beacon != null && !out.isClosed) out.add(beacon.copyWith(ip: d.address.address));
          } on Object {
            // Not ours: ignored.
          }
        });
      },
      onCancel: () async {
        socket?.close();
        await lock.release();
        await out.close();
      },
    );
    return out.stream;
  }
}

class _UdpFamilyAnnouncement implements FamilyAnnouncement {
  _UdpFamilyAnnouncement(this._socket, this._beacon) {
    _send();
    _timer = Timer.periodic(familyBeaconInterval, (_) => _send());
  }

  final RawDatagramSocket _socket;
  FamilyBeacon _beacon;
  late final Timer _timer;
  var _closed = false;

  @override
  void update(FamilyBeacon beacon) {
    _beacon = beacon;
    _send();
  }

  void _send() {
    if (_closed) return;
    final data = utf8.encode(jsonEncode(_beacon.toJson()));
    for (final target in ['255.255.255.255', subnetBroadcast(_beacon.ip)]) {
      try {
        _socket.send(data, InternetAddress(target), familyBeaconPort);
      } on Object {
        // A network that went away; the next round tries again.
      }
    }
  }

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _timer.cancel();
    _socket.close();
  }
}
