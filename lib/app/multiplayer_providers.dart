import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/multiplayer/network_env.dart';
import '../core/multiplayer/network_rooms.dart';

/// Games that can be played each on their own device (spec 14; phase 3a:
/// Pexeso only, marked "Zkušební").
const networkGames = {'memory'};

final networkEnvProvider = Provider<NetworkEnv>((ref) => const DeviceNetworkEnv());

/// The room this device hosts or joined; closed with the app.
final networkRoomsProvider = Provider<NetworkRooms>((ref) {
  final rooms = NetworkRooms(ref.watch(networkEnvProvider));
  ref.onDispose(rooms.leave);
  return rooms;
});

/// This device's Wi-Fi address, null when not on Wi-Fi.
final wifiAddressProvider = FutureProvider.autoDispose<String?>((ref) => ref.watch(networkEnvProvider).wifiAddress());
