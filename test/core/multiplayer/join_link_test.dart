import 'package:deskovky/core/multiplayer/room_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// The QR code of a room is a `deskovky://join` link (spec 14.3); the phone
/// camera opens it as a deep link and the in-app reader reads its text.
void main() {
  group('a deskovky://join link becomes a ticket', () {
    test('the link from the room QR code', () {
      expect(
        JoinTicket.parse('deskovky://join?ip=10.0.2.2&port=1234&code=1234'),
        const JoinTicket(ip: '10.0.2.2', port: 1234, code: '1234'),
      );
    });

    test('whatever order the parameters come in, with spaces around', () {
      expect(
        JoinTicket.parse('  deskovky://join?code=0427&port=50505&ip=192.168.1.23\n'),
        const JoinTicket(ip: '192.168.1.23', port: 50505, code: '0427'),
      );
    });

    test('the scheme and the host in capitals (some cameras do that)', () {
      expect(
        JoinTicket.parse('DESKOVKY://JOIN?ip=192.168.1.23&port=50505&code=0427'),
        const JoinTicket(ip: '192.168.1.23', port: 50505, code: '0427'),
      );
    });

    test('round trip through the QR text', () {
      const ticket = JoinTicket(ip: '192.168.0.7', port: 40000, code: '0001');
      expect(JoinTicket.parse(ticket.toUri().toString()), ticket);
    });
  });

  group('anything else is ignored', () {
    for (final link in [
      '',
      'hello',
      'https://example.com/join?ip=1.2.3.4&port=1&code=1234',
      'deskovky://play?ip=1.2.3.4&port=1&code=1234',
      'otherapp://join?ip=1.2.3.4&port=1&code=1234',
      'deskovky://join',
      'deskovky://join?ip=1.2.3.4&code=1234',
      'deskovky://join?ip=1.2.3.4&port=0&code=1234',
      'deskovky://join?ip=1.2.3.4&port=70000&code=1234',
      'deskovky://join?ip=1.2.3.4&port=abc&code=1234',
      'deskovky://join?port=1&code=1234',
      'deskovky://join?ip=1.2.3.4&port=1',
      // A room code has four digits.
      'deskovky://join?ip=1.2.3.4&port=1&code=',
      'deskovky://join?ip=1.2.3.4&port=1&code=12',
      'deskovky://join?ip=1.2.3.4&port=1&code=abcd',
      'deskovky://join?ip=1.2.3.4&port=1&code=12345',
      // Rooms live on the home Wi-Fi: an IPv4 address, never a web server.
      'deskovky://join?ip=evil.example.com&port=443&code=1234',
      'deskovky://join?ip=1.2.3&port=1&code=1234',
      'deskovky://join?ip=1.2.3.400&port=1&code=1234',
      'deskovky://join?ip=::1&port=1&code=1234',
    ]) {
      test('"$link"', () => expect(JoinTicket.parse(link), isNull));
    }
  });
}
