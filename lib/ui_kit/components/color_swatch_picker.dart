import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Row of round color swatches (38 dp, 48 dp touch target); the selected one
/// has a gold outline.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelected,
    required this.semanticLabels,
  }) : assert(colors.length == semanticLabels.length);

  final List<Color> colors;
  final int selected;
  final ValueChanged<int> onSelected;
  final List<String> semanticLabels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < colors.length; i++)
          Semantics(
            key: ValueKey('swatch$i'),
            button: true,
            selected: i == selected,
            label: semanticLabels[i],
            // excludeSemantics drops the detector's tap action; keep it for screen readers.
            onTap: () => onSelected(i),
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onSelected(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.paper, width: 3),
                      boxShadow: i == selected
                          ? const [
                              BoxShadow(color: AppColors.feltDark, spreadRadius: 2),
                              BoxShadow(color: AppColors.gold, spreadRadius: 5),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
