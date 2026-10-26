import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../core/game_kit/board_grid.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'minesweeper_art.dart';
import 'minesweeper_rules.dart';
import 'minesweeper_state.dart';
import 'minesweeper_texts.dart';

/// Board of Miny (spec 13.7): wooden tiles on felt, paper once uncovered.
/// Tap uncovers (or chords on a number); a long press or the ⛏/🚩 switch
/// places a flag. Boards that do not fit can be pinch-zoomed and centred.
/// Wide screens show the board turned, so it uses the space.
class MinesweeperBoard extends StatefulWidget {
  const MinesweeperBoard({super.key, required this.view});

  final GameBoardView<MinesweeperState> view;

  /// Smallest square before the board zooms: easy and medium fit a phone,
  /// hard is pinch-zoomed there (spec 13.7) but fits a tablet.
  static double minCell(MinesweeperLevel level, {bool tablet = false}) => switch (level) {
    MinesweeperLevel.easy => 34,
    MinesweeperLevel.medium => 26,
    MinesweeperLevel.hard => tablet ? 32 : 40,
  };

  @override
  State<MinesweeperBoard> createState() => _MinesweeperBoardState();
}

class _MinesweeperBoardState extends State<MinesweeperBoard> with SingleTickerProviderStateMixin {
  static const _rules = MinesweeperRules();

  final _grid = BoardGridController();
  late final _puff = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  int? _puffCell;
  bool _flagMode = false;
  Timer? _clock;

  GameBoardView<MinesweeperState> get view => widget.view;
  MinesweeperState get s => view.state;

  @override
  void initState() {
    super.initState();
    _syncClock();
  }

  @override
  void didUpdateWidget(MinesweeperBoard old) {
    super.didUpdateWidget(old);
    final before = old.view.state, now = s;
    if (!identical(before, now)) _sounds(before, now);
    _syncClock();
  }

  /// Sounds for every change, the robots' moves included.
  void _sounds(MinesweeperState before, MinesweeperState now) {
    if (now.exploded.length > before.exploded.length) {
      view.host.playSfx('minesweeper.puff');
      _puffCell = now.exploded.last;
      if (!MediaQuery.disableAnimationsOf(context)) _puff.forward(from: 0);
    } else if (now.revealedCount > before.revealedCount) {
      view.host.playSfx('minesweeper.dig');
    } else if (now.flagsCount() != before.flagsCount()) {
      view.host.playSfx('minesweeper.flag');
    }
  }

  /// The clock of one player ticks while the board is being cleared.
  void _syncClock() {
    final run = s.solo && s.started && !s.over;
    if (run && _clock == null) {
      _clock = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else if (!run) {
      _clock?.cancel();
      _clock = null;
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    _puff.dispose();
    _grid.dispose();
    super.dispose();
  }

  void _tap(int c, int r) {
    final seat = view.mySeat;
    if (!view.canAct || seat == null) return;
    final cell = s.cellOf(c, r);
    if (s.isRevealed(cell)) {
      _send(MinesweeperMove.of(seat, MinesweeperMove.chord, c, r, t: view.elapsed().inMilliseconds));
    } else if (_flagMode) {
      _mark(c, r);
    } else if (s.marks[cell] != Mark.flag) {
      _send(MinesweeperMove.of(seat, MinesweeperMove.reveal, c, r, t: view.elapsed().inMilliseconds));
    }
  }

  void _mark(int c, int r) {
    final seat = view.mySeat;
    if (!view.canAct || seat == null) return;
    final move = MinesweeperMove.of(seat, MinesweeperMove.mark, c, r);
    if (!_rules.isLegal(s, move)) return;
    view.host.haptic();
    _send(move);
  }

  void _send(Move move) {
    if (!_rules.isLegal(s, move)) return;
    _reportEvents(_rules.apply(s, move), move.seat);
    view.submit(move);
  }

  /// Badge events (spec 13.7), reported before the move ends the game.
  void _reportEvents(MinesweeperState next, int seat) {
    if (!next.over) return;
    final host = view.host;
    if (next.solo) {
      if (!next.cleared || next.exploded.isNotEmpty) return;
      host.reportEvent('minesweeper.win', {'seat': seat});
      if (next.level == MinesweeperLevel.hard) host.reportEvent('minesweeper.defuser', {'seat': seat});
      if (next.flagsPlaced == 0) host.reportEvent('minesweeper.noflag', {'seat': seat});
      final ms = next.finishMs ?? 0;
      if (next.level == MinesweeperLevel.easy && ms > 0 && ms < 20000) {
        host.reportEvent('minesweeper.blitz', {'seat': seat});
      }
      return;
    }
    final places = MinesweeperRules.placesOf(next);
    final winners = [for (var p = 0; p < places.length; p++) if (places[p] == 1) p];
    if (winners.length == 1) host.reportEvent('minesweeper.win', {'seat': winners.single});
  }

  CellLook _look(int cell) {
    if (s.exploded.contains(cell)) return CellLook.exploded;
    if (s.isRevealed(cell)) return CellLook.open;
    final mark = s.marks[cell];
    if (s.over && s.started) {
      final mine = s.mineSet.contains(cell);
      if (mark == Mark.flag) return mine ? CellLook.flag : CellLook.wrongFlag;
      if (mine) return CellLook.mine;
    }
    return switch (mark) {
      Mark.flag => CellLook.flag,
      Mark.question => CellLook.question,
      _ => CellLook.hidden,
    };
  }

  Widget _cell(int c, int r) {
    final cell = s.cellOf(c, r);
    final look = _look(cell);
    final by = look == CellLook.exploded ? s.explodedBy[s.exploded.indexOf(cell)] : s.revealedBy[cell];
    final painter = CellPainter(
      look: look,
      number: look == CellLook.open ? s.numbers[cell] : 0,
      tint: (!s.solo || look == CellLook.exploded) && by >= 0 ? AppColors.players[by % 4] : null,
    );
    final still = MediaQuery.disableAnimationsOf(context);
    Widget child = AnimatedSwitcher(
      duration: still ? Duration.zero : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      child: CustomPaint(key: ValueKey('${look.name}${painter.number}'), painter: painter, size: Size.infinite),
    );
    if (cell == _puffCell && !still) {
      child = Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          child,
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _puff,
              builder: (context, _) => _puff.isAnimating
                  ? CustomPaint(painter: _PuffPainter(_puff.value))
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      );
    }
    if (view.canAct && !s.isRevealed(cell)) {
      child = GestureDetector(onLongPress: () => _mark(c, r), child: child);
    }
    return KeyedSubtree(key: ValueKey('cell$c,$r'), child: child);
  }

  @override
  Widget build(BuildContext context) {
    final level = s.level;
    return LayoutBuilder(
      builder: (context, box) {
        // The board is tall; a wide space shows it turned (spec 13.7).
        final turned = level.columns != level.rows && box.maxWidth > box.maxHeight;
        final columns = turned ? level.rows : level.columns;
        final rows = turned ? level.columns : level.rows;
        final last = view.lastMove;
        final lastCell = !s.solo && last != null && last.type == MinesweeperMove.reveal
            ? (last.data['c']! as int, last.data['r']! as int)
            : null;
        return Column(
          children: [
            _toolbar(context, zoomed: _zoomed(box, columns, rows, context)),
            if (_hint(context) case final hint?)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  hint,
                  key: const ValueKey('minesweeperHint'),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button(color: AppColors.gold),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Opacity(
                opacity: view.canAct || s.over ? 1 : 0.85,
                child: BoardGrid(
                  key: ValueKey('grid$turned'),
                  columns: columns,
                  rows: rows,
                  minCellSize: MinesweeperBoard.minCell(level, tablet: MediaQuery.sizeOf(context).shortestSide >= 600),
                  controller: _grid,
                  highlighted: {
                    if (lastCell != null) turned ? (lastCell.$2, lastCell.$1) : lastCell,
                  },
                  onTap: view.canAct ? ((p) => turned ? _tap(p.$2, p.$1) : _tap(p.$1, p.$2)) : null,
                  cellBuilder: (context, x, y) => turned ? _cell(y, x) : _cell(x, y),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _hint(BuildContext context) {
    if (!view.firstGame || !view.canAct) return null;
    if (!s.started) return minesweeperTexts.of(context, 'minesweeper.hint.start');
    if (s.flagsPlaced == 0) {
      return minesweeperTexts.of(context, s.switchControls ? 'minesweeper.hint.flagSwitch' : 'minesweeper.hint.flagLong');
    }
    return null;
  }

  /// Roughly what BoardGrid decides: the squares do not fit, so the board
  /// zooms and needs the "centre" button.
  bool _zoomed(BoxConstraints box, int columns, int rows, BuildContext context) {
    final height = box.maxHeight - 56 - (_hint(context) == null ? 0 : 50);
    final fit = (box.maxWidth / columns) < (height / rows) ? box.maxWidth / columns : height / rows;
    return fit < MinesweeperBoard.minCell(s.level, tablet: MediaQuery.sizeOf(context).shortestSide >= 600);
  }

  Widget _toolbar(BuildContext context, {required bool zoomed}) {
    final left = s.level.mines - s.flagsCount() - (s.solo ? 0 : s.exploded.length);
    final ms = s.over && s.finishMs != null ? s.finishMs! : view.elapsed().inMilliseconds;
    final seconds = s.started ? ms ~/ 1000 : 0;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          // Counters shrink rather than overflow next to the switch.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  _Pill(
                    key: const ValueKey('minesLeft'),
                    icon: CustomPaint(painter: _MineIconPainter(), size: const Size.square(22)),
                    text: '$left',
                  ),
                  if (s.solo) ...[
                    const SizedBox(width: 8),
                    _Pill(
                      key: const ValueKey('clock'),
                      icon: CustomPaint(painter: _ClockIconPainter(), size: const Size.square(20)),
                      text: '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (s.switchControls)
            _ModeSwitch(
              flag: _flagMode,
              digLabel: minesweeperTexts.of(context, 'minesweeper.mode.dig'),
              flagLabel: minesweeperTexts.of(context, 'minesweeper.mode.flag'),
              onChanged: (flag) => setState(() => _flagMode = flag),
            ),
          if (zoomed) ...[
            const SizedBox(width: 8),
            RoundIconButton(
              key: const ValueKey('centre'),
              icon: Icons.center_focus_strong,
              tooltip: minesweeperTexts.of(context, 'minesweeper.centre'),
              onPressed: _grid.reset,
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({super.key, required this.icon, required this.text});

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(999),
      boxShadow: const [BoxShadow(color: AppColors.paper2, offset: Offset(0, 3))],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(text, style: AppTypography.button(color: AppColors.ink)),
      ],
    ),
  );
}

/// ⛏ / 🚩: what a tap does when the switch controls are chosen.
class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.flag, required this.digLabel, required this.flagLabel, required this.onChanged});

  final bool flag;
  final String digLabel;
  final String flagLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: const Color(0x40000000), borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (value, label) in [(false, digLabel), (true, flagLabel)])
          Semantics(
            key: ValueKey(value ? 'modeFlag' : 'modeDig'),
            button: true,
            selected: value == flag,
            label: label,
            excludeSemantics: true,
            onTap: () => onChanged(value),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                UiFeedback.play(context, UiSound.toggle);
                onChanged(value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 52,
                height: 42,
                decoration: BoxDecoration(
                  color: value == flag ? AppColors.paper : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: CustomPaint(painter: _ModeIconPainter(flag: value, on: value == flag)),
              ),
            ),
          ),
      ],
    ),
  );
}

class _ModeIconPainter extends CustomPainter {
  _ModeIconPainter({required this.flag, required this.on});

  final bool flag;
  final bool on;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height * 0.7;
    final rect = Rect.fromCenter(center: size.center(Offset.zero), width: s, height: s);
    if (flag) {
      paintFlag(canvas, rect, s);
      return;
    }
    // A little pickaxe.
    final ink = Paint()
      ..color = on ? AppColors.walnut : AppColors.paper
      ..strokeWidth = s * 0.11
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas
      ..drawLine(rect.bottomLeft + Offset(s * 0.2, -s * 0.15), rect.topRight + Offset(-s * 0.3, s * 0.3), ink)
      ..drawArc(rect.deflate(s * 0.08).shift(Offset(s * 0.05, -s * 0.05)), -2.6, 1.9, false, ink..color = on ? AppColors.wood : AppColors.paper2);
  }

  @override
  bool shouldRepaint(_ModeIconPainter old) => old.flag != flag || old.on != on;
}

class _ClockIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide * 0.42;
    final ink = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawCircle(c, r, ink)
      ..drawLine(c, c - Offset(0, r * 0.6), ink)
      ..drawLine(c, c + Offset(r * 0.45, 0), ink);
  }

  @override
  bool shouldRepaint(_ClockIconPainter old) => false;
}

class _MineIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => paintMine(canvas, size.center(Offset.zero), size.shortestSide * 0.3);

  @override
  bool shouldRepaint(_MineIconPainter old) => false;
}

class _PuffPainter extends CustomPainter {
  _PuffPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    paintPuff(canvas, size.center(Offset.zero), s * 1.6, t);
  }

  @override
  bool shouldRepaint(_PuffPainter old) => old.t != t;
}
