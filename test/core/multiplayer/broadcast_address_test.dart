import 'package:deskovky/core/multiplayer/local_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the broadcast address follows the network mask (review R-033)', () {
    expect(broadcastAddress('192.168.1.23', 24), '192.168.1.255');
    expect(broadcastAddress('192.168.5.23', 22), '192.168.7.255');
    expect(broadcastAddress('10.1.2.3', 16), '10.1.255.255');
    expect(broadcastAddress('172.20.10.4', 28), '172.20.10.15');
  });

  test('announcements go to everyone, the /24 neighbours and the real broadcast of a bigger network', () async {
    WifiPrefix.debugLookup = (ip) async => 22;
    addTearDown(() => WifiPrefix.debugLookup = null);
    expect(await broadcastTargets('192.168.5.23'), ['255.255.255.255', '192.168.5.255', '192.168.7.255']);
    WifiPrefix.debugLookup = (ip) async => 24;
    expect(await broadcastTargets('192.168.5.23'), ['255.255.255.255', '192.168.5.255']);
    WifiPrefix.debugLookup = (ip) async => null;
    expect(await broadcastTargets('192.168.5.23'), ['255.255.255.255', '192.168.5.255'], reason: 'mask unknown: as before');
  });
}
