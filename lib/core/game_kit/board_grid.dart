import 'dart:math';

import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';

/// Lets a board's "centre" button reset the zoom of a [BoardGrid].
class BoardGridController {
  final TransformationController transform = TransformationController();

  /// Back to the start: the board's top left corner, no zoom.
  void reset() => transform.value = Matrix4.identity();

  void dispose() => transform.dispose();
}

/// A grid board (game kit, spec 8): it fills the space it gets with square
/// cells, turns a tap into a `(column, row)` and frames highlighted cells.
/// When cells would be smaller than [minCellSize] (48 dp, spec 13.4), they
/// keep that size and the board can be pinch-zoomed and panned instead.
class BoardGrid extends StatefulWidget {
  const BoardGrid({
    super.key,
    required this.columns,
    required this.rows,
    required this.cellBuilder,
    this.onTap,
    this.highlighted = const {},
    this.minCellSize = 48,
    this.controller,
  });

  final int columns;
  final int rows;
  final Widget Function(BuildContext context, int column, int row) cellBuilder;
  final ValueChanged<(int, int)>? onTap;

  /// Cells framed in gold, e.g. the last move or legal targets.
  final Set<(int, int)> highlighted;
  final double minCellSize;
  final BoardGridController? controller;

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  BoardGridController? _own;

  BoardGridController get _controller => widget.controller ?? (_own ??= BoardGridController());

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final byWidth = box.maxWidth / widget.columns;
      final byHeight = box.maxHeight.isFinite ? box.maxHeight / widget.rows : double.infinity;
      final fit = min(byWidth, byHeight);
      if (fit >= widget.minCellSize) return Center(child: _grid(fit));
      final cell = widget.minCellSize;
      return InteractiveViewer(
        transformationController: _controller.transform,
        constrained: false,
        minScale: max(0.1, fit / cell),
        maxScale: 2.5,
        boundaryMargin: EdgeInsets.all(cell),
        child: _grid(cell),
      );
    },
  );

  Widget _grid(double cell) {
    final columns = widget.columns, rows = widget.rows;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: widget.onTap == null
          ? null
          : (details) {
              final column = (details.localPosition.dx ~/ cell).clamp(0, columns - 1);
              final row = (details.localPosition.dy ~/ cell).clamp(0, rows - 1);
              widget.onTap!((column, row));
            },
      child: SizedBox(
        width: columns * cell,
        height: rows * cell,
        child: Stack(
          children: [
            for (var row = 0; row < rows; row++)
              for (var column = 0; column < columns; column++)
                Positioned(
                  left: column * cell,
                  top: row * cell,
                  width: cell,
                  height: cell,
                  child: widget.cellBuilder(context, column, row),
                ),
            for (final (column, row) in widget.highlighted)
              Positioned(
                left: column * cell,
                top: row * cell,
                width: cell,
                height: cell,
                child: IgnorePointer(
                  child: DecoratedBox(
                    key: ValueKey('highlight$column,$row'),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gold, width: 3),
                      borderRadius: BorderRadius.circular(cell / 8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
