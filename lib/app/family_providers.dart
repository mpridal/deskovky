import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/family/family_net.dart';
import 'family_controller.dart';
import 'providers.dart';

/// The Wi-Fi as the family sync uses it; tests swap in a home network in
/// memory.
final familyNetProvider = Provider<FamilyNet>((ref) => const DeviceFamilyNet());

/// Keeps this device in step with its family (spec "Rodinná synchronizace").
final familyControllerProvider = Provider<FamilyController>((ref) {
  final controller = FamilyController(
    db: ref.watch(databaseProvider),
    net: ref.watch(familyNetProvider),
    stats: ref.watch(statsServiceProvider),
  );
  ref.onDispose(controller.dispose);
  return controller;
});
