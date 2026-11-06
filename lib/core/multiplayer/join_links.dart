import 'dart:async';

import 'package:flutter/services.dart';

/// `deskovky://join` links that Android opens with this app (the room's QR
/// code read by the phone camera). Text only – [JoinTicket.parse] decides
/// what is a room.
abstract interface class JoinLinks {
  /// The link that started the app (cold start), once; null when none.
  Future<String?> initialLink();

  /// Links that arrive while the app runs.
  Stream<String> get links;
}

/// Android: the Kotlin channel `deskovky/links` in `MainActivity`.
class DeviceJoinLinks implements JoinLinks {
  DeviceJoinLinks() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'link' && call.arguments is String) _links.add(call.arguments as String);
    });
  }

  static const _channel = MethodChannel('deskovky/links');
  final _links = StreamController<String>.broadcast();

  @override
  Future<String?> initialLink() async {
    try {
      return await _channel.invokeMethod<String>('initialLink');
    } on Object {
      // No Android (tests, other platforms): no links.
      return null;
    }
  }

  @override
  Stream<String> get links => _links.stream;
}
