import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'matches_events.dart';
import 'matches_painters.dart';
import 'matches_rules.dart';
import 'matches_texts.dart';

/// A take shown on the table: which slots of which row went to whose pile.
class _Take {
  const _Take(this.row, this.slots, this.seat, {required this.last, required this.reveal});

  final int row;
  final List<int> slots;
  final int seat;

  /// The game's final take: the match lights up on its way to the loser.
  final bool last;

  /// Somebody else's take (a robot, another device): first shown as a
  /// selection, then taken.
  final bool reveal;
}

/// Board of Sirky (design §8): three rows of matches on the felt, each
/// player's pile of taken matches at the top (on the sides in landscape).
///
/// A tap selects a match (it lifts and glows in the player's colour); more
/// taps in the same row add or remove matches, a tap in another row moves
/// the selection there. Only „Vzít (n)“ makes the move. Others' takes are
/// first shown as a selection (~0.5 s), then the matches fly to the pile;
/// the gaps of the last take blink and stay faintly visible; the final
/// match lights up on its way to the loser. Without animations all at once.
///
/// Which slots of a row are empty is this board's own business – the state
/// only counts matches. Sounds and badge events follow the state, so moves
/// from a robot or another device are heard and counted as well.
class MatchesBoard extends StatefulWidget {
  const MatchesBoard({super.key, required this.view});

  final GameBoardView<MatchesState> view;

  @override
  State<MatchesBoard> createState() => _MatchesBoardState();
}

class _MatchesBoardState extends State<MatchesBoard> with TickerProviderStateMixin {
  static const _rules = MatchesRules();

  late final _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
    ..addStatusListener(_revealed);
  late final _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 450))
    ..addStatusListener(_landed);
  late final _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 900), value: 1);

  /// Which slots of each row still hold a match.
  late List<List<bool>> _present;

  /// The selection: one row and slots in it.
  int? _selectedRow;
  final _selected = <int>{};

  /// The take being shown, and whether its matches are in the air already.
  _Take? _anim;
  bool _flying = false;

  /// The last take's gaps (outlined until the next take).
  _Take? _last;

  /// My own take, sent and waiting to come back as the new state.
  (int, List<int>)? _sent;

  final _reported = <String>{};

  MatchesState get _s => widget.view.state;

  @override
  void initState() {
    super.initState();
    _present = _fill(_s);
    _report(_s);
  }

  /// The matches of [s] without a known history: centred in each row.
  static List<List<bool>> _fill(MatchesState s) => [
    for (var row = 0; row < MatchesRules.initialRows.length; row++)
      [
        for (var i = 0; i < MatchesRules.initialRows[row]; i++)
          i >= (MatchesRules.initialRows[row] - s.rows[row]) ~/ 2 &&
              i < (MatchesRules.initialRows[row] - s.rows[row]) ~/ 2 + s.rows[row],
      ],
  ];

  bool get _still => MediaQuery.disableAnimationsOf(context);

  @override
  void didUpdateWidget(MatchesBoard old) {
    super.didUpdateWidget(old);
    final before = old.view.state, now = _s;
    if (!widget.view.canAct) _clearSelection();
    if (identical(before, now) || before.history.length == now.history.length) return;
    final sent = _sent;
    _sent = null;
    _clearSelection();
    _settle();
    if (now.history.length != before.history.length + 1 || !_continues(before, now)) {
      // A new game, a restored or caught-up state: just show it.
      _present = _fill(now);
      _last = null;
      _report(now);
      return;
    }
    final (row, count) = now.history.last;
    final mine = sent != null && sent.$1 == row && sent.$2.length == count;
    final slots = mine ? sent.$2 : _rightmost(row, count);
    for (final i in slots) {
      _present[row][i] = false;
    }
    final take = _Take(row, slots, now.seatOf(now.history.length - 1), last: now.over, reveal: !mine && !now.over);
    _last = take;
    widget.view.host.playSfx('matches.take');
    if (now.over) widget.view.host.playSfx('matches.strike');
    _report(now);
    if (_still) {
      _blink.value = 1;
      return;
    }
    _anim = take;
    if (take.reveal) {
      _flying = false;
      _reveal.forward(from: 0);
    } else {
      _flying = true;
      _fly.forward(from: 0);
    }
  }

  static bool _continues(MatchesState before, MatchesState now) {
    for (var i = 0; i < before.history.length; i++) {
      if (before.history[i] != now.history[i]) return false;
    }
    return true;
  }

  /// The [count] rightmost matches still in [row] (others' takes).
  List<int> _rightmost(int row, int count) {
    final slots = <int>[];
    for (var i = _present[row].length - 1; i >= 0 && slots.length < count; i--) {
      if (_present[row][i]) slots.add(i);
    }
    return slots..sort();
  }

  /// Ends a take still on its way, so the next one starts clean.
  void _settle() {
    if (_anim == null) return;
    _reveal.stop();
    _fly.stop();
    _anim = null;
    _flying = false;
    _blink.value = 1;
  }

  void _revealed(AnimationStatus status) {
    if (status != AnimationStatus.completed || _anim == null || !mounted) return;
    setState(() => _flying = true);
    _fly.forward(from: 0);
  }

  void _landed(AnimationStatus status) {
    if (status != AnimationStatus.completed || _anim == null || !mounted) return;
    setState(() {
      _anim = null;
      _flying = false;
    });
    _blink.forward(from: 0);
  }

  void _report(MatchesState s) {
    for (final MapEntry(:key, :value) in MatchesEvents.of(s).entries) {
      if (_reported.add(key)) widget.view.host.reportEvent(MatchesEvents.idOf(key), value);
    }
  }

  void _clearSelection() {
    _selectedRow = null;
    _selected.clear();
  }

  @override
  void dispose() {
    _reveal.dispose();
    _fly.dispose();
    _blink.dispose();
    super.dispose();
  }

  bool get _canPick => widget.view.canAct && widget.view.mySeat != null && !_s.over;

  void _tapMatch(int row, int i) {
    if (!_canPick || !_present[row][i]) return;
    widget.view.host.playSfx('matches.pick');
    widget.view.host.haptic();
    setState(() {
      if (_selectedRow != row) {
        _clearSelection();
        _selectedRow = row;
        _selected.add(i);
      } else if (!_selected.remove(i)) {
        _selected.add(i);
      } else if (_selected.isEmpty) {
        _selectedRow = null;
      }
    });
  }

  void _take() {
    final view = widget.view;
    final seat = view.mySeat, row = _selectedRow;
    if (!_canPick || seat == null || row == null || _selected.isEmpty) return;
    final move = MatchesRules.take(seat, row, _selected.length);
    if (!_rules.isLegal(_s, move)) return;
    view.host.haptic();
    // Before the move: when it ends the game, the screen collects events at once.
    _report(_rules.apply(_s, move));
    _sent = (row, _selected.toList()..sort());
    setState(_clearSelection);
    view.submit(move);
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final s = _s;
    final hint = view.firstGame && view.canAct && s.history.length < 2
        ? matchesTexts.of(context, 'matches.firstHint')
        : null;
    return LayoutBuilder(
      builder: (context, box) {
        final layout = _Layout(Size(box.maxWidth, box.maxHeight));
        return Stack(
          children: [
            for (var seat = 0; seat < 2; seat++)
              Positioned.fromRect(rect: layout.pile[seat], child: _pile(context, seat)),
            for (var row = 0; row < 3; row++)
              for (var i = 0; i < MatchesRules.initialRows[row]; i++)
                Positioned.fromRect(rect: layout.slot(row, i), child: _slot(context, row, i)),
            if (_anim != null && _flying)
              for (final i in _anim!.slots) _flyingMatch(layout, _anim!, i),
            if (hint != null)
              Positioned(
                left: layout.rows.left + 8,
                right: box.maxWidth - layout.rows.right + 8,
                top: layout.rows.top,
                child: IgnorePointer(
                  child: Center(
                    child: DecoratedBox(
                      key: const ValueKey('matchesHint'),
                      decoration: BoxDecoration(
                        color: AppColors.walnut.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Text(hint, textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.paper)),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fromRect(
              rect: layout.button,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: PrimaryButton(
                    key: const ValueKey('matchesTake'),
                    label: matchesTexts.of(context, 'matches.take', {'count': _selected.length}),
                    onPressed: _canPick && _selected.isNotEmpty ? _take : null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _slot(BuildContext context, int row, int i) {
    final anim = _anim;
    final present = _present[row][i];
    final inAnim = anim != null && anim.row == row && anim.slots.contains(i);
    final selected = _selectedRow == row && _selected.contains(i);
    final duration = _still ? Duration.zero : const Duration(milliseconds: 160);

    if (present || (inAnim && !_flying)) {
      final lifted = selected || inAnim;
      final glow = selected ? AppColors.players[widget.view.mySeat ?? 0] : (inAnim ? AppColors.players[anim.seat] : null);
      return Semantics(
        key: ValueKey('match$row,$i'),
        container: true,
        button: _canPick && present,
        selected: selected,
        excludeSemantics: true,
        label: matchesTexts.of(context, selected ? 'matches.match.selected' : 'matches.match', {'row': row + 1}),
        onTap: _canPick && present ? () => _tapMatch(row, i) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _canPick && present ? () => _tapMatch(row, i) : null,
          child: AnimatedSlide(
            offset: Offset(0, lifted ? -0.1 : 0),
            duration: duration,
            curve: Curves.easeOut,
            child: CustomPaint(painter: MatchPainter(glow: glow)),
          ),
        ),
      );
    }
    final last = _last;
    if (anim == null && last != null && last.row == row && last.slots.contains(i)) {
      return AnimatedBuilder(
        key: ValueKey('gap$row,$i'),
        animation: _blink,
        builder: (context, _) =>
            CustomPaint(painter: GapPainter(0.2 + 0.6 * sin(2 * pi * _blink.value).abs())),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _flyingMatch(_Layout layout, _Take take, int i) {
    final from = layout.slot(take.row, i);
    final to = layout.pile[take.seat];
    return AnimatedBuilder(
      key: ValueKey('flying${take.row},$i'),
      animation: _fly,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_fly.value);
        final size = Size.lerp(from.size, Size(from.width * 0.6, from.height * 0.6), t)!;
        final centre = Offset.lerp(from.center, to.center, t)!;
        return Positioned.fromRect(
          rect: Rect.fromCenter(center: centre, width: size.width, height: size.height),
          child: IgnorePointer(
            child: Transform.rotate(
              angle: t * pi / 2 * (take.seat == 0 ? -1 : 1),
              child: CustomPaint(
                painter: MatchPainter(glow: AppColors.players[take.seat], burn: take.last ? _fly.value : 0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _pile(BuildContext context, int seat) {
    final s = _s;
    final anim = _anim;
    final airborne = anim != null && anim.seat == seat ? anim.slots.length : 0;
    final count = s.takenBy(seat) - airborne;
    final burnt = s.over && s.loser == seat && anim == null ? s.history.last.$2 : 0;
    final colour = AppColors.players[seat];
    return Semantics(
      key: ValueKey('pile$seat'),
      container: true,
      excludeSemantics: true,
      label: matchesTexts.of(context, 'matches.pile', {'seat': seat + 1, 'count': s.takenBy(seat)}),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.feltDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colour.withValues(alpha: 0.8), width: 2),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 36, 4),
                  child: CustomPaint(painter: HeapPainter(count: count, burnt: burnt)),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: colour, shape: BoxShape.circle),
                  child: Text('${s.takenBy(seat)}', style: AppTypography.caption(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Where everything sits for a board of [size]: piles on top (on the sides
/// in landscape), three centred rows of slots (3-5-7), the take button below
/// (bottom right in landscape). A slot is at least 48 dp wide on a 360 dp
/// phone; when seven do not fit, every row shrinks alike.
class _Layout {
  _Layout(Size size) {
    const pad = 8.0;
    final landscape = size.width > size.height * 1.1;
    if (landscape) {
      final side = (size.width * 0.2).clamp(120.0, 220.0);
      const buttonH = 72.0;
      final pileH = min(size.height * 0.35, 140.0);
      pile = [
        Rect.fromLTWH(pad, pad, side - pad, pileH),
        Rect.fromLTWH(size.width - side, pad, side - pad, pileH),
      ];
      button = Rect.fromLTWH(size.width - side, size.height - buttonH - pad, side - pad, buttonH);
      rows = Rect.fromLTRB(side + pad, pad, size.width - side - pad, size.height - pad);
    } else {
      final pileH = (size.height * 0.12).clamp(56.0, 96.0);
      const buttonH = 76.0;
      pile = [
        Rect.fromLTWH(pad, pad, size.width / 2 - pad * 1.5, pileH),
        Rect.fromLTWH(size.width / 2 + pad / 2, pad, size.width / 2 - pad * 1.5, pileH),
      ];
      button = Rect.fromLTWH(pad, size.height - buttonH - pad, size.width - 2 * pad, buttonH);
      rows = Rect.fromLTRB(pad, pad * 2 + pileH, size.width - pad, size.height - buttonH - pad * 2);
    }
    slotWidth = min(72, rows.width / 7);
    rowHeight = max(0, rows.height / 3);
    slotHeight = min(slotWidth * 3, rowHeight);
  }

  late final List<Rect> pile;
  late final Rect button;
  late final Rect rows;
  late final double slotWidth;
  late final double rowHeight;
  late final double slotHeight;

  Rect slot(int row, int i) {
    final n = MatchesRules.initialRows[row];
    final left = rows.left + (rows.width - n * slotWidth) / 2 + i * slotWidth;
    final top = rows.top + row * rowHeight + (rowHeight - slotHeight) / 2;
    return Rect.fromLTWH(left, top, slotWidth, slotHeight);
  }
}
