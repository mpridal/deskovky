import 'package:deskovky/core/game/game_config.dart';
import 'package:deskovky/features/game_setup/seat_editor.dart';
import 'package:flutter_test/flutter_test.dart';

const _r = RobotSeat();
const _h1 = HumanSeat(1);
const _h2 = HumanSeat(2);

void main() {
  group('resize', () {
    test('growing adds robots', () {
      expect(SeatEditor.resize([_h1, _r], 4), [_h1, _r, _r, _r]);
    });

    test('shrinking removes from the end', () {
      expect(SeatEditor.resize([_h1, _h2, _r, _r], 2), [_h1, _h2]);
    });

    test('never removes the last human – a robot goes instead', () {
      expect(SeatEditor.resize([_r, _r, _h1], 1), [_h1]);
      expect(SeatEditor.resize([_r, _h1, _r], 2), [_r, _h1]);
    });
  });

  group('toggle', () {
    test('robot becomes the given human', () {
      expect(SeatEditor.toggle([_h1, _r], 1, profileForHuman: 2), [_h1, _h2]);
    });

    test('robot stays a robot without a free profile', () {
      expect(SeatEditor.toggle([_h1, _r], 1), [_h1, _r]);
    });

    test('human becomes a robot, but never the only human', () {
      expect(SeatEditor.toggle([_h1, _h2], 1), [_h1, _r]);
      expect(SeatEditor.toggle([_h1, _r], 0), [_h1, _r]);
    });
  });

  test('move reorders seats', () {
    expect(SeatEditor.move([_h1, _r, _h2], 2, 0), [_h2, _h1, _r]);
    expect(SeatEditor.move([_h1, _r, _h2], 0, 1), [_r, _h1, _h2]);
  });

  group('sanitize', () {
    test('a deleted profile becomes a robot', () {
      final (seats, changed) = SeatEditor.sanitize([_h1, _h2], existing: {1}, activeId: 1);
      expect(seats, [_h1, _r]);
      expect(changed, isTrue);
    });

    test('a duplicated profile becomes a robot', () {
      final (seats, changed) = SeatEditor.sanitize([_h1, _h1], existing: {1, 2}, activeId: 1);
      expect(seats, [_h1, _r]);
      expect(changed, isTrue);
    });

    test('with nobody human left, the first seat gets the active player', () {
      final (seats, changed) = SeatEditor.sanitize([_h2, _r], existing: {1}, activeId: 1);
      expect(seats, [_h1, _r]);
      expect(changed, isTrue);
    });

    test('valid seats stay untouched', () {
      final (seats, changed) = SeatEditor.sanitize([_h1, _r, _h2], existing: {1, 2}, activeId: 1);
      expect(seats, [_h1, _r, _h2]);
      expect(changed, isFalse);
    });
  });

  test('isValid needs a human and unique profiles', () {
    expect(SeatEditor.isValid([_h1, _r]), isTrue);
    expect(SeatEditor.isValid([_r, _r]), isFalse);
    expect(SeatEditor.isValid([_h1, _h1]), isFalse);
  });

  test('defaults: active player plus robots, 2 seats within the game range', () {
    expect(SeatEditor.defaults(minPlayers: 1, maxPlayers: 4, activeId: 1), [_h1, _r]);
    expect(SeatEditor.defaults(minPlayers: 1, maxPlayers: 1, activeId: 1), [_h1]);
    expect(SeatEditor.defaults(minPlayers: 3, maxPlayers: 4, activeId: 1), [_h1, _r, _r]);
  });
}
