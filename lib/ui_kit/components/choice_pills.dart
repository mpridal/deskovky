import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';
import 'ui_feedback.dart';

/// Single-choice pills that wrap onto more rows instead of shrinking text –
/// for choices whose labels are too long for a [SegmentedControl]. With
/// [scrollable] they stay on one row that scrolls sideways (long lists, such
/// as one pill per game).
class ChoicePills<T> extends StatelessWidget {
  const ChoicePills({
    super.key,
    required this.choices,
    required this.selected,
    required this.onChanged,
    this.scrollable = false,
  });

  final List<(T value, String label)> choices;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final pills = [
        for (final (value, label) in choices)
          Semantics(
            button: true,
            inMutuallyExclusiveGroup: true,
            selected: value == selected,
            child: GestureDetector(
              onTap: () {
                UiFeedback.play(context, UiSound.toggle);
                onChanged(value);
              },
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
    ];
    if (!scrollable) return Wrap(spacing: 6, runSpacing: 6, children: pills);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, pill) in pills.indexed) Padding(padding: EdgeInsets.only(left: i == 0 ? 0 : 6), child: pill),
        ],
      ),
    );
  }
}
