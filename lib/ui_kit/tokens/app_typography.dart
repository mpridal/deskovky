import 'package:flutter/painting.dart';

/// Text styles (spec 6.2). Fonts are bundled variable TTFs, so every style
/// sets both [TextStyle.fontWeight] and the matching `wght` font variation.
abstract final class AppTypography {
  static const String headingFamily = 'Baloo2';
  static const String bodyFamily = 'Nunito';

  static TextStyle h1({Color? color}) => _style(headingFamily, 30, FontWeight.w800, color);
  static TextStyle h2({Color? color}) => _style(headingFamily, 22, FontWeight.w600, color);
  static TextStyle body({Color? color}) => _style(bodyFamily, 16, FontWeight.w400, color);
  static TextStyle caption({Color? color}) => _style(bodyFamily, 13, FontWeight.w600, color);
  static TextStyle button({Color? color}) => _style(bodyFamily, 16, FontWeight.w800, color);

  static TextStyle _style(String family, double size, FontWeight weight, Color? color) => TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation.weight(weight.value.toDouble())],
        color: color,
      );
}
