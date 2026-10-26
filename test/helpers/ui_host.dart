import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:flutter/material.dart';

/// Minimal app around a single UI-kit widget.
Widget uiHost(Widget child) => MaterialApp(
  theme: buildAppTheme(),
  home: Scaffold(body: Center(child: child)),
);
