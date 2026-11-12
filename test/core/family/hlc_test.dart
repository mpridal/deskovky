import 'package:deskovky/core/family/hlc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ticks forward with the wall clock and counts within the same millisecond', () {
    const h = Hlc(100, 0, 'tab');
    expect(h.tick(200), const Hlc(200, 0, 'tab'));
    expect(h.tick(100), const Hlc(100, 1, 'tab'));
    // A clock that went backwards never goes backwards in the log.
    expect(h.tick(50), const Hlc(100, 1, 'tab'));
  });

  test('receiving a later remote clock moves past it', () {
    const local = Hlc(100, 3, 'tab');
    expect(local.receive(const Hlc(500, 2, 'pho'), 120), const Hlc(500, 3, 'tab'));
    expect(local.receive(const Hlc(90, 9, 'pho'), 80), const Hlc(100, 4, 'tab'));
    expect(local.receive(const Hlc(50, 0, 'pho'), 300), const Hlc(300, 0, 'tab'));
  });

  test('orders by time, then counter, then device; packs and unpacks', () {
    final clocks = [const Hlc(5, 0, 'b'), const Hlc(5, 0, 'a'), const Hlc(4, 9, 'z'), const Hlc(5, 1, 'a')]..sort();
    expect(clocks, [const Hlc(4, 9, 'z'), const Hlc(5, 0, 'a'), const Hlc(5, 0, 'b'), const Hlc(5, 1, 'a')]);
    expect(Hlc.unpack(const Hlc(1731300000000, 7, 'dev-1').pack()), const Hlc(1731300000000, 7, 'dev-1'));
    expect(Hlc.unpack('nonsense'), isNull);
  });
}
