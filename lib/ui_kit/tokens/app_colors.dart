import 'package:flutter/painting.dart';

/// Design tokens "herní stůl" (spec 6.1).
abstract final class AppColors {
  static const Color walnut = Color(0xFF3B2A20);
  static const Color wood = Color(0xFF8B5A3C);
  static const Color woodLight = Color(0xFFC89B6D);
  static const Color felt = Color(0xFF2F5D50);
  static const Color feltDark = Color(0xFF234A3F);
  static const Color paper = Color(0xFFF4EADB);
  static const Color paper2 = Color(0xFFE9DCC7);
  static const Color ink = Color(0xFF2B211B);
  static const Color gold = Color(0xFFE0A82E);

  /// Player colors 1–4, identical in every game.
  static const List<Color> players = [
    Color(0xFFD9534F),
    Color(0xFF3B7DD8),
    Color(0xFFE8B931),
    Color(0xFF4CAF6A),
  ];
}
