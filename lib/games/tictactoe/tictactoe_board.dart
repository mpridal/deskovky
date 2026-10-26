import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game_kit/board_grid.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'tictactoe_events.dart';
import 'tictactoe_marks.dart';
import 'tictactoe_rules.dart';
import 'tictactoe_texts.dart';

/// Board of Piškvorky (spec 13.5): squared paper on the felt. A tap places
/// the mark; with the confirm option a big-board move needs a second tap on
/// the same cell. The last stone is framed, a new one is drawn stroke by
/// stroke and the winning row is crossed out. Big boards on a phone zoom
/// and pan ([BoardGrid]) with a "centre" button.
class TictactoeBoard extends StatefulWidget {
  const TictactoeBoard({super.key, required this.view});

  final GameBoardView<TictactoeState> view;

  @override
  State<TictactoeBoard> createState() => _TictactoeBoardState();
}

class _TictactoeBoardState extends State<TictactoeBoard> with TickerProviderStateMixin {
  static const _rules = TictactoeRules();

  final _grid = BoardGridController();

  /// The new stone being drawn.
  late final _pen = AnimationController(vsync: this, duration: const Duration(milliseconds: 280), value: 1);

  /// The stroke over the winning row.
  late final _strike = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

  /// Glides a zoomed board to a move outside the view.
  late final _pan = AnimationController(vsync: this, duration: const Duration(milliseconds: 350))..addListener(_onPan);
  Matrix4Tween? _panTween;

  /// The space the grid gets (without its padding), from the last layout.
  Size _viewport = Size.zero;

  /// The cell waiting for a confirming second tap.
  int? _pending;

  TictactoeState get _state => widget.view.state;

  @override
  void initState() {
    super.initState();
    if (_state.winner != null) _strike.value = 1;
  }

  @override
  void didUpdateWidget(TictactoeBoard old) {
    super.didUpdateWidget(old);
    final before = old.view.state, now = _state;
    if (now.history.length != before.history.length || !widget.view.canAct) _pending = null;
    if (now.history.length > before.history.length) {
      widget.view.host.playSfx('tictactoe.draw');
      _animate(_pen);
    }
    if (now.winner != null && before.winner == null) {
      widget.view.host.playSfx('tictactoe.line');
      _animate(_strike);
    } else if (now.winner == null) {
      _strike.value = 0;
    }
    final last = now.lastCell;
    if (last != null && now.history.length > before.history.length) {
      // After this frame's layout, so a rotation's new size counts too.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reveal(now.line.isNotEmpty ? now.line : [last]);
      });
    }
  }

  /// Moves a zoomed board (keeping its zoom) just enough that [cells] are in
  /// view with half a cell to spare; a row too long for the view centres on
  /// its last cell.
  void _reveal(List<int> cells) {
    final s = _state, view = _viewport;
    if (!_zooms(view, s.size)) return;
    const cell = 48.0;
    final matrix = _grid.transform.value;
    final scale = matrix.getMaxScaleOnAxis();
    final shift = matrix.getTranslation();
    var target = Rect.fromLTRB(
      cells.map((i) => i % s.size).reduce(min) * cell,
      cells.map((i) => i ~/ s.size).reduce(min) * cell,
      (cells.map((i) => i % s.size).reduce(max) + 1) * cell,
      (cells.map((i) => i ~/ s.size).reduce(max) + 1) * cell,
    );
    const margin = cell / 2;
    if (target.width * scale > view.width - 2 * margin || target.height * scale > view.height - 2 * margin) {
      final i = cells.last;
      target = Rect.fromLTWH(i % s.size * cell, i ~/ s.size * cell, cell, cell);
    }
    double fit(double offset, double start, double end, double space) {
      if (scale * start + offset < margin) return margin - scale * start;
      if (scale * end + offset > space - margin) return space - margin - scale * end;
      return offset;
    }

    final dx = fit(shift.x, target.left, target.right, view.width);
    final dy = fit(shift.y, target.top, target.bottom, view.height);
    if (dx == shift.x && dy == shift.y) return;
    final goal = matrix.clone()..setTranslationRaw(dx, dy, shift.z);
    if (MediaQuery.disableAnimationsOf(context)) {
      _grid.transform.value = goal;
      return;
    }
    _panTween = Matrix4Tween(begin: matrix.clone(), end: goal);
    _pan.forward(from: 0);
  }

  void _onPan() {
    final tween = _panTween;
    if (tween != null) _grid.transform.value = tween.transform(Curves.easeInOut.transform(_pan.value));
  }

  /// Whether [BoardGrid] keeps 48 dp cells and zooms (as it decides).
  static bool _zooms(Size view, int size) => min(view.width, view.height) / size < 48;

  void _animate(AnimationController c) {
    if (MediaQuery.disableAnimationsOf(context)) {
      c.value = 1;
    } else {
      c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pen.dispose();
    _strike.dispose();
    _pan.dispose();
    _grid.dispose();
    super.dispose();
  }

  bool get _confirm => _state.confirm && _state.bigBoard;

  void _tap((int, int) at) {
    final view = widget.view;
    final seat = view.mySeat;
    final (column, row) = at;
    final s = _state;
    if (!view.canAct || seat == null || s.over) return;
    final cell = row * s.size + column;
    if (s.cells[cell] >= 0) return;
    if (_confirm && _pending != cell) {
      view.host.haptic();
      setState(() => _pending = cell);
      return;
    }
    final move = TictactoeRules.place(seat, column, row);
    if (!_rules.isLegal(s, move)) return;
    view.host.haptic();
    for (final (id, data) in tictactoeEvents(s, move)) {
      view.host.reportEvent(id, data);
    }
    setState(() => _pending = null);
    view.submit(move);
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;
    final view = widget.view;
    final hint = _pending != null
        ? tictactoeTexts.of(context, 'tictactoe.confirmHint')
        : view.firstGame && view.canAct && s.history.length < 2
        ? tictactoeTexts.of(context, s.bigBoard ? 'tictactoe.firstHint.big' : 'tictactoe.firstHint')
        : null;
    final winning = {for (final (i, c) in s.line.indexed) c: i};
    final (dc, dr) = _lineDirection(s);
    final last = s.lastCell;
    final pending = _pending;

    return LayoutBuilder(
      builder: (context, box) {
        final pad = s.bigBoard ? 4.0 : 12.0;
        _viewport = Size(box.maxWidth - 2 * pad, box.maxHeight - 2 * pad);
        final zooms = _zooms(_viewport, s.size);
        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(pad),
                child: BoardGrid(
                  key: ValueKey('tictactoeGrid${s.size}'),
                  columns: s.size,
                  rows: s.size,
                  controller: _grid,
                  highlighted: {
                    if (last != null && s.winner == null) (last % s.size, last ~/ s.size),
                    if (pending != null) (pending % s.size, pending ~/ s.size),
                  },
                  onTap: view.canAct ? _tap : null,
                  cellBuilder: (context, column, row) {
                    final i = row * s.size + column;
                    final owner = s.cells[i];
                    final strikeIndex = winning[i];
                    return Semantics(
                      key: ValueKey('cell$column,$row'),
                      container: true,
                      label: tictactoeTexts.of(context, 'tictactoe.cell', {
                        'mark': owner == 0 ? '✕' : (owner == 1 ? '◯' : tictactoeTexts.of(context, 'tictactoe.cell.empty')),
                        'column': column + 1,
                        'row': row + 1,
                      }),
                      button: owner < 0 && view.canAct,
                      excludeSemantics: true,
                      onTap: owner < 0 && view.canAct ? () => _tap((column, row)) : null,
                      child: CustomPaint(
                        painter: PaperCellPainter(right: column == s.size - 1, bottom: row == s.size - 1),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (owner >= 0)
                              i == last
                                  ? AnimatedBuilder(
                                      animation: _pen,
                                      builder: (context, _) => CustomPaint(painter: MarkPainter(seat: owner, progress: _pen.value)),
                                    )
                                  : CustomPaint(painter: MarkPainter(seat: owner)),
                            if (i == pending && view.mySeat != null)
                              CustomPaint(painter: MarkPainter(seat: view.mySeat!, opacity: 0.35)),
                            if (strikeIndex != null)
                              AnimatedBuilder(
                                animation: _strike,
                                builder: (context, _) => CustomPaint(
                                  painter: StrikePainter(
                                    index: strikeIndex,
                                    count: s.line.length,
                                    dc: dc,
                                    dr: dr,
                                    progress: _strike.value,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (hint != null)
              Positioned(
                top: 8,
                left: 16,
                right: zooms ? 72 : 16,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      key: const ValueKey('tictactoeHint'),
                      decoration: BoxDecoration(
                        color: AppColors.walnut.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text(
                          hint,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption(color: AppColors.paper),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (zooms)
              Positioned(
                top: 4,
                right: 4,
                child: RoundIconButton(
                  key: const ValueKey('tictactoeCentre'),
                  icon: Icons.center_focus_strong,
                  tooltip: tictactoeTexts.of(context, 'tictactoe.centre'),
                  onPressed: _grid.reset,
                ),
              ),
          ],
        );
      },
    );
  }

  /// Direction of the winning row, from its first two cells.
  static (int, int) _lineDirection(TictactoeState s) {
    if (s.line.length < 2) return (1, 0);
    final a = s.line[0], b = s.line[1];
    return (b % s.size - a % s.size, b ~/ s.size - a ~/ s.size);
  }
}
