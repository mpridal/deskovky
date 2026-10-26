import 'package:deskovky/core/game/game_module.dart';

/// A [GameHost] for game tests (spec 8 bod 4): records what a game asked the
/// framework to do instead of doing it.
class GameTestHost implements GameHost {
  final sfx = <String>[];
  final events = <(String, Map<String, Object?>)>[];
  var haptics = 0;

  @override
  void haptic() => haptics++;

  @override
  void playSfx(String id) => sfx.add(id);

  @override
  void reportEvent(String id, [Map<String, Object?> data = const {}]) => events.add((id, data));
}
