import 'package:deskovky/games/registry.dart';

import 'contract.dart';

/// Every registered game passes the contract; unfinished ones ("Brzy") only
/// the parts that do not need a playable game (spec 12).
void main() {
  for (final module in gameModules) {
    runGameContract(module, playable: module.available);
  }
}
