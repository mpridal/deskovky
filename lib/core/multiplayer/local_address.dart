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
/// lock; held only while the join screen looks for rooms. A no-op elsewhere.
class MulticastLock {
  const MulticastLock();

  static const _channel = MethodChannel('deskovky/multicast');

  Future<bool> acquire() => _call('acquire');

  Future<bool> release() => _call('release');

  Future<bool> _call(String method) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on Object catch (e) {
      debugPrint('MulticastLock.$method: $e');
      return false;
    }
  }
}
