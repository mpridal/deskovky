import 'package:flutter/services.dart';

import '../../core/game/game_module.dart';

/// Device orientations for a game orientation; empty = no lock.
List<DeviceOrientation> devicesFor(GameOrientation orientation) => switch (orientation) {
  GameOrientation.any => const [],
  GameOrientation.portrait => const [DeviceOrientation.portraitUp],
  GameOrientation.landscape => const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
};

/// What a game asks for on a screen of [size] (spec 13.8: Člověče is
/// portrait on phones and landscape on tablets). Phones are under 600 dp.
List<DeviceOrientation> orientationsFor(GameModule<Object?> module, Size size) =>
    devicesFor(size.shortestSide < 600 ? module.phoneOrientation : module.tabletOrientation);
