import 'package:deskovky/core/multiplayer/local_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the lock stays while anyone still listens: the family keeps hearing devices after the join screen closes', () async {
    final calls = <String>[];
    MulticastLock.debugPlatform = (method) async {
      calls.add(method);
      return true;
    };
    addTearDown(() => MulticastLock.debugPlatform = null);
    const family = MulticastLock(), rooms = MulticastLock();
    await family.acquire();
    await rooms.acquire();
    await rooms.release();
    expect(calls, isNot(contains('release')), reason: 'the family still listens');
    await family.release();
    expect(calls.last, 'release');
    await family.release();
    expect(calls.where((c) => c == 'release'), hasLength(1), reason: 'an extra release changes nothing');
  });
}
