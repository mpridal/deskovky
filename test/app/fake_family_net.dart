import 'dart:async';

import 'package:deskovky/core/family/family_net.dart';
import 'package:deskovky/core/multiplayer/loopback_channel.dart';
import 'package:deskovky/core/multiplayer/message_channel.dart';
import 'package:deskovky/core/multiplayer/network_env.dart';

/// A home Wi-Fi in memory: devices announce to each other and connect over
/// loopback lines.
class FakeLan {
  final _devices = <FakeFamilyNet>[];
  var _nextIp = 10;

  FakeFamilyNet device({bool wifi = true}) {
    final net = FakeFamilyNet._(this, wifi ? '192.168.1.${_nextIp++}' : null);
    _devices.add(net);
    return net;
  }
}

class FakeFamilyNet implements FamilyNet {
  FakeFamilyNet._(this._lan, this.ip);

  final FakeLan _lan;
  final String? ip;
  final _beacons = StreamController<FamilyBeacon>.broadcast();
  StreamController<MessageChannel>? _server;
  var connects = 0;

  @override
  Future<String?> wifiAddress() async => ip;

  @override
  Future<OpenServer> serve() async {
    final server = _server = StreamController<MessageChannel>.broadcast();
    return OpenServer(port: 50600, channels: server.stream, close: () async => server.close());
  }

  @override
  Future<MessageChannel> connect(String ip, int port) async {
    final target = _lan._devices.where((d) => d.ip == ip && d._server != null && !d._server!.isClosed).firstOrNull;
    if (target == null) throw StateError('nobody at $ip');
    connects++;
    final (mine, theirs) = LoopbackChannel.pair();
    target._server!.add(theirs);
    return mine;
  }

  @override
  Future<FamilyAnnouncement> announce(FamilyBeacon beacon) async {
    final a = _FakeAnnouncement(this)..update(beacon);
    return a;
  }

  @override
  Stream<FamilyBeacon> beacons() => _beacons.stream;

  void _hear(FamilyBeacon beacon) {
    if (!_beacons.isClosed) _beacons.add(beacon);
  }
}

/// Says it again every 50 ms, like the real one every 10 s.
class _FakeAnnouncement implements FamilyAnnouncement {
  _FakeAnnouncement(this._net) {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) => _send());
  }

  final FakeFamilyNet _net;
  late final Timer _timer;
  FamilyBeacon? _beacon;
  var _closed = false;

  @override
  void update(FamilyBeacon beacon) {
    _beacon = beacon;
    _send();
  }

  void _send() {
    final beacon = _beacon;
    if (_closed || beacon == null) return;
    for (final other in _net._lan._devices) {
      if (!identical(other, _net)) other._hear(beacon.copyWith(ip: _net.ip));
    }
  }

  @override
  void close() {
    _closed = true;
    _timer.cancel();
  }
}
