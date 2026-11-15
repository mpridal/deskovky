import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// This device's IPv4 address on the Wi-Fi (or its own hotspot), or null
/// when it is not on Wi-Fi (the screen then says "Nejsi ve Wi-Fi").
Future<String?> localWifiAddress() async {
  try {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    return pickWifiAddress([
      for (final i in interfaces)
        for (final a in i.addresses) (i.name, a.address),
    ]);
  } on Object catch (e) {
    debugPrint('localWifiAddress: $e');
    return null;
  }
}

/// Picks the Wi-Fi address from (interface name, IPv4) pairs: a private
/// address of a wlan/hotspot interface first, else any private one that is
/// not mobile data; null without one.
@visibleForTesting
String? pickWifiAddress(List<(String, String)> addresses) {
  final private = [
    for (final (name, ip) in addresses)
      if (_isPrivate(ip) && !_isMobile(name)) (name, ip),
  ];
  for (final (name, ip) in private) {
    if (_isWifi(name)) return ip;
  }
  return private.firstOrNull?.$2;
}

/// The /24 broadcast address of [ip] (home routers and phone hotspots).
String subnetBroadcast(String ip) {
  final parts = ip.split('.');
  return [...parts.take(3), '255'].join('.');
}

/// The broadcast address of [ip] in a network with a [prefix]-bit mask
/// (`/22` → `255.255.252.0`).
String broadcastAddress(String ip, int prefix) {
  final p = ip.split('.').map(int.parse).toList();
  final value = (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
  final host = prefix >= 32 ? 0 : (1 << (32 - prefix)) - 1;
  final b = (value | host) & 0xFFFFFFFF;
  return [b >> 24, (b >> 16) & 255, (b >> 8) & 255, b & 255].join('.');
}

/// The mask length of the Wi-Fi network [ip] is on, asked from Android
/// (Dart does not know it); null when it cannot tell.
class WifiPrefix {
  static const _channel = MethodChannel('deskovky/device');

  /// Stands in for Android in tests.
  @visibleForTesting
  static Future<int?> Function(String ip)? debugLookup;

  static Future<int?> of(String ip) async {
    final fake = debugLookup;
    if (fake != null) return fake(ip);
    if (!Platform.isAndroid) return null;
    try {
      return await _channel.invokeMethod<int>('prefix', ip);
    } on Object catch (e) {
      debugPrint('WifiPrefix: $e');
      return null;
    }
  }
}

/// Where rooms and family devices announce themselves: everyone on the
/// link, the /24 neighbours (home routers, hotspots) and – on a bigger
/// network such as a mesh with /22 – its real broadcast (review R-033).
Future<List<String>> broadcastTargets(String ip) async {
  final prefix = await WifiPrefix.of(ip);
  return {
    '255.255.255.255',
    subnetBroadcast(ip),
    if (prefix != null && prefix >= 8 && prefix <= 30) broadcastAddress(ip, prefix),
  }.toList();
}

bool _isWifi(String name) {
  final n = name.toLowerCase();
  return n.startsWith('wlan') || n.startsWith('ap') || n.startsWith('swlan') || n.contains('wi-fi') || n.contains('wifi');
}

bool _isMobile(String name) {
  final n = name.toLowerCase();
  return n.startsWith('rmnet') || n.startsWith('ccmni') || n.startsWith('pdp') || n.startsWith('v4-rmnet');
}

bool _isPrivate(String ip) {
  final p = ip.split('.').map(int.tryParse).toList();
  if (p.length != 4 || p.contains(null)) return false;
  final (a, b) = (p[0]!, p[1]!);
  return a == 10 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168);
}

/// Android drops Wi-Fi broadcast packets unless an app holds a multicast
/// lock; held while the join screen looks for rooms and while the family
/// listens for its devices. A no-op elsewhere.
///
/// The app has one lock for all listeners, so it is counted: it goes only
/// when the last listener releases it. (Before, closing the join screen
/// released the family's lock too and devices looked offline.)
class MulticastLock {
  const MulticastLock();

  static const _channel = MethodChannel('deskovky/multicast');

  static var _holders = 0;

  /// Stands in for Android in tests.
  @visibleForTesting
  static Future<bool> Function(String method)? debugPlatform;

  Future<bool> acquire() {
    _holders++;
    return _call('acquire');
  }

  Future<bool> release() async {
    if (_holders == 0) return false;
    _holders--;
    if (_holders > 0) return true;
    return _call('release');
  }

  Future<bool> _call(String method) async {
    final fake = debugPlatform;
    if (fake != null) return fake(method);
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on Object catch (e) {
      debugPrint('MulticastLock.$method: $e');
      return false;
    }
  }
}

/// An address in a home network (private ranges, link-local, this device):
/// rooms and families live only there, never on the internet (review R-006).
bool isLocalNetworkAddress(String ip) {
  final p = ip.split('.').map(int.tryParse).toList();
  if (p.length != 4 || p.any((x) => x == null || x < 0 || x > 255)) return false;
  final (a, b) = (p[0]!, p[1]!);
  return _isPrivate(ip) || a == 127 || (a == 169 && b == 254);
}
