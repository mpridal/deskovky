import 'package:deskovky/ui_kit/tokens/app_colors.dart';
import 'package:deskovky/ui_kit/tokens/app_theme.dart';
import 'package:deskovky/ui_kit/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('match design tokens from spec 6.1', () {
      expect(AppColors.walnut, const Color(0xFF3B2A20));
      expect(AppColors.wood, const Color(0xFF8B5A3C));
      expect(AppColors.woodLight, const Color(0xFFC89B6D));
      expect(AppColors.felt, const Color(0xFF2F5D50));
      expect(AppColors.feltDark, const Color(0xFF234A3F));
      expect(AppColors.paper, const Color(0xFFF4EADB));
      expect(AppColors.paper2, const Color(0xFFE9DCC7));
      expect(AppColors.ink, const Color(0xFF2B211B));
      expect(AppColors.gold, const Color(0xFFE0A82E));
    });

    test('player colors are player1..4 in order', () {
      expect(AppColors.players, const [
        Color(0xFFD9534F),
        Color(0xFF3B7DD8),
        Color(0xFFE8B931),
        Color(0xFF4CAF6A),
      ]);
    });
  });

  group('AppTypography', () {
    void expectStyle(
      TextStyle style, {
      required String family,
      required double size,
      required FontWeight weight,
    }) {
      expect(style.fontFamily, family);
      expect(style.fontSize, size);
      expect(style.fontWeight, weight);
      expect(style.fontVariations, contains(FontVariation.weight(weight.value.toDouble())));
    }

    test('headings use Baloo 2', () {
      expectStyle(AppTypography.h1(), family: 'Baloo2', size: 30, weight: FontWeight.w800);
      expectStyle(AppTypography.h2(), family: 'Baloo2', size: 22, weight: FontWeight.w600);
    });

    test('body, caption and button use Nunito', () {
      expectStyle(AppTypography.body(), family: 'Nunito', size: 16, weight: FontWeight.w400);
      expectStyle(AppTypography.caption(), family: 'Nunito', size: 13, weight: FontWeight.w600);
      expectStyle(AppTypography.button(), family: 'Nunito', size: 16, weight: FontWeight.w800);
    });

    test('color parameter is applied', () {
      expect(AppTypography.body(color: AppColors.ink).color, AppColors.ink);
    });
  });

  group('buildAppTheme', () {
    test('felt background and Nunito body text', () {
      final theme = buildAppTheme();
      expect(theme.scaffoldBackgroundColor, AppColors.felt);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Nunito');
      expect(theme.colorScheme.primary, AppColors.gold);
    });
  });
}
