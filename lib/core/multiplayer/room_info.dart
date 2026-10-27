import 'dart:math';

import 'package:flutter/foundation.dart';

import 'protocol.dart';

/// A room as its host announces it on the Wi-Fi (spec 14.2 step 3).
@immutable
class RoomInfo {
  const RoomInfo({
    required this.code,
    required this.gameId,
    required this.hostName,
    required this.hostAvatar,
    required this.port,
    required this.free,
    required this.ip,
  });

  final String code;
  final String gameId;
  final String hostName;
  final Map<String, Object?> hostAvatar;
  final int port;

  /// Places still free.
  final int free;
  final String ip;

  RoomInfo copyWith({String? ip, int? free}) => RoomInfo(
    code: code,
    gameId: gameId,
    hostName: hostName,
    hostAvatar: hostAvatar,
    port: port,
    free: free ?? this.free,
    ip: ip ?? this.ip,
  );

  Map<String, Object?> toJson() => {
    'app': 'deskovky',
    'v': protocolVersion,
    'code': code,
    'game': gameId,
    'host': hostName,
    'avatar': hostAvatar,
    'port': port,
    'free': free,
    'ip': ip,
  };

  /// Null for anything that is not a room of this protocol version.
  static RoomInfo? fromJson(Object? json) {
    if (json is! Map<String, Object?> || json['app'] != 'deskovky' || json['v'] != protocolVersion) return null;
    final code = json['code'], game = json['game'], host = json['host'], avatar = json['avatar'];
    final port = json['port'], free = json['free'], ip = json['ip'];
    if (code is! String || game is! String || host is! String || avatar is! Map<String, Object?>) return null;
    if (port is! int || free is! int || ip is! String) return null;
    return RoomInfo(code: code, gameId: game, hostName: host, hostAvatar: avatar, port: port, free: free, ip: ip);
  }

  JoinTicket get ticket => JoinTicket(ip: ip, port: port, code: code);

  @override
  bool operator ==(Object other) =>
      other is RoomInfo &&
      other.code == code &&
      other.gameId == gameId &&
      other.hostName == hostName &&
      mapEquals(other.hostAvatar, hostAvatar) &&
      other.port == port &&
      other.free == free &&
      other.ip == ip;

  @override
  int get hashCode => Object.hash(code, gameId, hostName, port, free, ip);

  @override
  String toString() => 'RoomInfo($code, $gameId, $hostName, $ip:$port, free $free)';
}

/// Where to join a room, as the room's QR code shows it (spec 14.3).
@immutable
class JoinTicket {
  const JoinTicket({required this.ip, required this.port, required this.code});

  final String ip;
  final int port;
  final String code;

  Uri toUri() => Uri(scheme: 'deskovky', host: 'join', queryParameters: {'ip': ip, 'port': '$port', 'code': code});

  static JoinTicket? parse(String text) {
    final uri = Uri.tryParse(text.trim());
    if (uri == null || uri.scheme != 'deskovky' || uri.host != 'join') return null;
    final ip = uri.queryParameters['ip'], code = uri.queryParameters['code'];
    final port = int.tryParse(uri.queryParameters['port'] ?? '');
    if (ip == null || ip.isEmpty || code == null || port == null || port <= 0 || port > 65535) return null;
    return JoinTicket(ip: ip, port: port, code: code);
  }

  @override
  bool operator ==(Object other) => other is JoinTicket && other.ip == ip && other.port == port && other.code == code;

  @override
  int get hashCode => Object.hash(ip, port, code);
}

/// A four-digit room code, e.g. '0427' (spec 14.2 step 2).
String newRoomCode([Random? random]) => (random ?? Random.secure()).nextInt(10000).toString().padLeft(4, '0');
