import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Single-choice pills that wrap onto more rows instead of shrinking text –
/// for choices whose labels are too long for a [SegmentedControl].
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({super.key, required this.choices, required this.selected, required this.onChanged});

  final List<(T value, String label)> choices;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (value, label) in choices)
          Semantics(
            button: true,
            inMutuallyExclusiveGroup: true,
            selected: value == selected,
            child: GestureDetector(
              onTap: () => onChanged(value),
              behavior: HitTestBehavior.opaque,
              // No `alignment`: it would stretch the pill to the full row.
              child: Container(
                constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: value == selected ? AppColors.paper : const Color(0x40000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTypography.button(color: value == selected ? AppColors.ink : AppColors.paper)
                      .copyWith(fontSize: 14),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
