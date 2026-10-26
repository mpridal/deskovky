import '../../core/game/game_config.dart';

/// Pure rules for the seats on the setup screen (spec 5.7): free seats are
/// robots, at least one human, a profile sits at most once.
abstract final class SeatEditor {
  static List<SeatConfig> defaults({required int minPlayers, required int maxPlayers, required int activeId}) {
    final count = 2.clamp(minPlayers, maxPlayers);
    return [HumanSeat(activeId), for (var i = 1; i < count; i++) const RobotSeat()];
  }

  /// New seats are robots; removing works from the end but never takes the
  /// last human – a robot goes instead.
  static List<SeatConfig> resize(List<SeatConfig> seats, int count) {
    final result = [...seats];
    while (result.length < count) {
      result.add(const RobotSeat());
    }
    while (result.length > count) {
      final last = result.length - 1;
      final humans = result.whereType<HumanSeat>().length;
      if (result[last] is RobotSeat || humans > 1) {
        result.removeAt(last);
      } else {
        result.removeAt(result.lastIndexWhere((s) => s is RobotSeat));
      }
    }
    return result;
  }

  /// Robot ⇄ human. A robot only becomes human with a free profile; the only
  /// human never becomes a robot.
  static List<SeatConfig> toggle(List<SeatConfig> seats, int index, {int? profileForHuman}) {
    final result = [...seats];
    if (result[index] is RobotSeat) {
      if (profileForHuman != null) result[index] = HumanSeat(profileForHuman);
    } else if (result.whereType<HumanSeat>().length > 1) {
      result[index] = const RobotSeat();
    }
    return result;
  }

  static List<SeatConfig> move(List<SeatConfig> seats, int from, int to) {
    final result = [...seats];
    result.insert(to, result.removeAt(from));
    return result;
  }

  /// Replaces missing or duplicated profiles by robots and makes sure somebody
  /// human plays (the active player on the first seat). Returns whether
  /// anything changed, so the screen can say so.
  static (List<SeatConfig>, bool) sanitize(List<SeatConfig> seats, {required Set<int> existing, int? activeId}) {
    final seen = <int>{};
    final result = [
      for (final seat in seats)
        if (seat is HumanSeat && existing.contains(seat.profileId) && seen.add(seat.profileId))
          seat
        else
          const RobotSeat(),
    ];
    if (result.every((s) => s is RobotSeat) && activeId != null && result.isNotEmpty) {
      result[0] = HumanSeat(activeId);
    }
    var changed = false;
    for (var i = 0; i < seats.length; i++) {
      if (seats[i] != result[i]) changed = true;
    }
    return (result, changed);
  }

  static bool isValid(List<SeatConfig> seats) {
    final humans = seats.whereType<HumanSeat>().map((s) => s.profileId).toList();
    return humans.isNotEmpty && humans.toSet().length == humans.length;
  }
}
