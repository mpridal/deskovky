import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../core/game_kit/board_grid.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
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
  }

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
    _reportEvents(s, move);
    setState(() => _pending = null);
    view.submit(move);
  }

  /// Badge events (spec 13.5), reported with the move that decides them:
  /// a win on 15×15 (`five`, `master`), a big-board win within 9 own
  /// stones (`blitz`) and a 3×3 draw against the hard robot (`wall`) –
  /// also when the robot's last move is the only one left.
  void _reportEvents(TictactoeState s, Move move) {
    final host = widget.view.host;
    final seat = move.seat;
    final next = _rules.apply(s, move);
    if (next.winner == seat && s.bigBoard) {
      if (s.size == 15) host.reportEvent('tictactoe.win15', {'seat': seat});
      if (next.movesOf(seat) <= 9) host.reportEvent('tictactoe.blitz', {'seat': seat});
    }
    final other = 1 - seat;
    if (s.bigBoard || s.difficulty != 'hard' || !s.robots[other] || next.winner != null) return;
    var end = next;
    final left = _rules.legalMoves(next, other);
    if (left.length == 1) end = _rules.apply(next, left.single);
    if (end.full && end.winner == null) host.reportEvent('tictactoe.wall', {'seat': seat});
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
        final zooms = box.biggest.shortestSide / s.size < 48;
        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(s.bigBoard ? 4 : 12),
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
                      label: owner == 0 ? '✕' : (owner == 1 ? '◯' : '${column + 1}, ${row + 1}'),
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
