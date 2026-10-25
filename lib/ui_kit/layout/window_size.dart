/// Window width classes from spec 3 (widths in dp).
enum WindowSizeClass {
  compact,
  medium,
  expanded;

  static WindowSizeClass fromWidth(double widthDp) {
    if (widthDp < 600) return compact;
    if (widthDp < 840) return medium;
    return expanded;
  }
}

/// Number of columns of the game grid on the home screen for a window width.
int gameGridColumns(double widthDp) => switch (WindowSizeClass.fromWidth(widthDp)) {
      WindowSizeClass.compact => 2,
      WindowSizeClass.medium => 3,
      WindowSizeClass.expanded => widthDp < 1200 ? 3 : 4,
    };
