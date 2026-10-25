import 'package:deskovky/ui_kit/layout/window_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('WindowSizeClass.fromWidth boundaries (spec 3)', () {
    expect(WindowSizeClass.fromWidth(360), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
    expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(839.9), WindowSizeClass.medium);
    expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
    expect(WindowSizeClass.fromWidth(1280), WindowSizeClass.expanded);
  });

  test('gameGridColumns', () {
    expect(gameGridColumns(360), 2);
    expect(gameGridColumns(412), 2);
    expect(gameGridColumns(740), 3);
    expect(gameGridColumns(800), 3);
    expect(gameGridColumns(1024), 3);
    expect(gameGridColumns(1280), 4);
  });
}
