import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game_kit/flip_card.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'memory_card_art.dart';
import 'memory_layout.dart';
import 'memory_rules.dart';
import 'memory_texts.dart';

/// Board of Pexeso (spec 13.6): a grid of cards as big as the screen allows.
/// A tap turns a card (a `Move`); a miss stays up 1.2 s (a tap anywhere
/// hurries it), found pairs fly to their finder in the HUD, and on hard alone
/// two face-down cards visibly change places. Easy alone starts with every
/// card shown for 2 s.
class MemoryBoard extends StatefulWidget {
  const MemoryBoard({super.key, required this.view});

  final GameBoardView<MemoryState> view;

  @override
  State<MemoryBoard> createState() => _MemoryBoardState();
}

/// A found pair on its way to the player who found it.
class _Flight {
  _Flight(this.cards, this.seat, this.controller);

  final List<int> cards;
  final int seat;
  final AnimationController controller;
}

class _MemoryBoardState extends State<MemoryBoard> with TickerProviderStateMixin {
  static const _rules = MemoryRules();
  static const missShown = Duration(milliseconds: 1200);
  static const previewShown = Duration(seconds: 2);

  /// The last miss, shown for [missShown] even when the next robot already
  /// turns a card, so people can remember it; a person's tap hurries it.
  Timer? _missTimer;
  List<int> _missed = const [];
  int _missSeat = 0;
  bool get _missOn => _missed.isNotEmpty;
  Timer? _previewTimer;
  bool _previewOn = false;
  late final AnimationController _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) setState(() {});
    });
  bool _swapWaiting = false;
  final _flights = <_Flight>[];
  bool _elephantsReported = false;

  MemoryState get _s => widget.view.state;

  @override
  void initState() {
    super.initState();
    final s = _s;
    if (s.preview && s.reveals.isEmpty) {
      _previewOn = true;
      _previewTimer = Timer(previewShown, _endPreview);
    }
    if (s.miss.isNotEmpty) _showMiss(s.miss, (s.current - 1 + s.seats) % s.seats);
    // A restored game: what was found before the app closed was never
    // recorded (events are kept only until the game ends), so count it now.
    if (s.reveals.isNotEmpty) {
      for (var seat = 0; seat < s.seats; seat++) {
        final pairs = s.pairsOf(seat);
        if (pairs > 0) widget.view.host.reportEvent('memory.pairs', {'seat': seat, 'count': pairs});
      }
    }
    _reportElephants();
  }

  @override
  void didUpdateWidget(MemoryBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = oldWidget.view.state;
    final after = _s;
    if (after.reveals.length > before.reveals.length) _onFlip(before, after);
    _reportElephants();
  }

  void _onFlip(MemoryState before, MemoryState after) {
    final host = widget.view.host;
    final reduce = MediaQuery.disableAnimationsOf(context);
    host.playSfx('card_flip');
    if (_previewOn) _endPreview();
    final seat = before.current;
    if (after.miss.isNotEmpty) {
      host.playSfx('memory.miss');
      _showMiss(after.miss, seat);
    }
    if (after.pairsOf(seat) > before.pairsOf(seat)) {
      host.playSfx('memory.match');
      if (!reduce) {
        final controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
        final flight = _Flight(after.reveals.sublist(after.reveals.length - 2), seat, controller);
        controller
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              setState(() => _flights.remove(flight));
              controller.dispose();
            }
          })
          ..forward();
        _flights.add(flight);
      }
    }
    if (after.swaps > before.swaps && !reduce) {
      if (_missOn) {
        _swapWaiting = true;
      } else {
        _swap.forward(from: 0);
      }
    }
  }

  void _reportElephants() {
    if (_elephantsReported) return;
    final seats = MemoryRules.elephants(_s);
    if (seats.isEmpty) return;
    _elephantsReported = true;
    for (final seat in seats) {
      widget.view.host.reportEvent('memory.elephant', {'seat': seat});
    }
  }

  void _showMiss(List<int> cards, int seat) {
    _missTimer?.cancel();
    _missed = cards;
    _missSeat = seat;
    _missTimer = Timer(missShown, () {
      if (mounted) setState(_endMiss);
    });
  }

  void _endMiss() {
    _missTimer?.cancel();
    _missed = const [];
    if (_swapWaiting) {
      _swapWaiting = false;
      _swap.forward(from: 0);
    }
  }

  void _endPreview() {
    _previewTimer?.cancel();
    if (mounted && _previewOn) setState(() => _previewOn = false);
  }

  /// A tap anywhere hurries a miss or the preview (spec 13.6).
  void _hurry() {
    if (_previewOn) _endPreview();
    if (_missOn) setState(_endMiss);
  }

  void _tap(int card) {
    if (_previewOn) {
      _endPreview();
      return;
    }
    if (_missOn) setState(_endMiss);
    final view = widget.view;
    final seat = view.mySeat;
    if (!view.canAct || seat == null) return;
    final move = MemoryRules.flip(seat, card, timeMs: view.elapsed().inMilliseconds);
    if (!_rules.isLegal(_s, move)) return;
    // Reported before the move: the last pair ends the game at once.
    for (final (id, data) in MemoryRules.eventsAfter(_s, move, _rules.apply(_s, move))) {
      view.host.reportEvent(id, data);
    }
    view.host.haptic();
    view.submit(move);
  }

  @override
  void dispose() {
    _missTimer?.cancel();
    _previewTimer?.cancel();
    _swap.dispose();
    for (final f in _flights) {
      f.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final view = widget.view;
    final text = memoryTexts;
    final header = <Widget>[
      if (s.solo)
        Text(
          '${text.of(context, 'memory.solo.turns', {'n': s.turns.first})}   ·   '
          '${text.of(context, 'memory.solo.pairs', {'found': s.pairsOf(0), 'total': s.pairs})}',
          key: const ValueKey('memory.soloInfo'),
          textAlign: TextAlign.center,
          style: AppTypography.button(color: AppColors.paper),
        ),
      if (_previewOn)
        Text(
          text.of(context, 'memory.preview'),
          textAlign: TextAlign.center,
          style: AppTypography.button(color: AppColors.gold),
        )
      else if (view.firstGame && view.canAct && s.reveals.length < 2)
        Text(
          text.of(context, 'memory.firstHint'),
          key: const ValueKey('memory.firstHint'),
          textAlign: TextAlign.center,
          style: AppTypography.button(color: AppColors.gold),
        ),
    ];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _hurry,
      child: Column(
        children: [
          for (final h in header) Padding(padding: const EdgeInsets.only(bottom: 6), child: h),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final area = constraints.biggest;
                final grid = MemoryGrid.fit(area, s.cards);
                final origin = Offset(
                  max(0, (area.width - grid.size.width) / 2),
                  max(0, (area.height - grid.size.height) / 2),
                );
                // Where the HUD shows the players: above the board, in seat order.
                final top = -origin.dy - 80 - header.length * 28;
                final spacing = min(area.width / s.seats, 110.0);
                Offset target(int seat) =>
                    Offset(area.width / 2 + (seat - (s.seats - 1) / 2) * spacing - origin.dx - grid.side / 2, top);
                Widget board = SizedBox.fromSize(
                  size: grid.size,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_swap, for (final f in _flights) f.controller]),
                    builder: (context, _) => Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var c = 0; c < s.cards; c++) _slot(c, grid),
                        for (var c = 0; c < s.cards; c++) ?_card(c, grid, target),
                      ],
                    ),
                  ),
                );
                if (grid.size.width > area.width || grid.size.height > area.height) {
                  board = SingleChildScrollView(
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: board),
                  );
                }
                return Center(child: board);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// The place of a card on the felt, visible once its pair is found.
  Widget _slot(int c, MemoryGrid grid) {
    final at = grid.cardAt(c, _s.cards);
    return Positioned(
      key: ValueKey('memory.slot$c'),
      left: at.dx,
      top: at.dy,
      width: grid.side,
      height: grid.side,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.feltDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(grid.side * 0.14),
        ),
      ),
    );
  }

  Widget? _card(int c, MemoryGrid grid, Offset Function(int seat) target) {
    final s = _s;
    final flight = _flights.where((f) => f.cards.contains(c)).firstOrNull;
    if (s.owner[c] != null && flight == null) return null;
    final home = grid.cardAt(c, s.cards);
    var at = home;
    var scale = 1.0;
    var opacity = 1.0;
    if (flight != null) {
      final t = Curves.easeInCubic.transform(((flight.controller.value - 0.45) / 0.55).clamp(0.0, 1.0));
      at = Offset.lerp(home, target(flight.seat), t)!;
      scale = 1 - 0.6 * t;
      opacity = 1 - 0.7 * t;
    } else if (_swap.isAnimating && s.swap.contains(c)) {
      // Slides from the other card's place along a little arc.
      final other = s.swap.firstWhere((o) => o != c);
      final from = grid.cardAt(other, s.cards);
      final t = Curves.easeInOut.transform(_swap.value);
      final lift = sin(t * pi) * grid.side * 0.5 * (c == s.swap.first ? 1 : -1);
      at = Offset.lerp(from, home, t)! + Offset(0, -lift);
      scale = 1 + 0.12 * sin(t * pi);
    }
    final up = flight != null || s.open.contains(c) || _missed.contains(c) || _previewOn;
    final frameSeat = flight?.seat ?? (s.open.contains(c) ? s.current : (_missed.contains(c) ? _missSeat : null));
    return Positioned(
      key: ValueKey('memory.card$c'),
      left: at.dx,
      top: at.dy,
      width: grid.side,
      height: grid.side,
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Semantics(
            button: true,
            label: memoryTexts.of(context, 'memory.card', {'n': c + 1}),
            excludeSemantics: true,
            onTap: () => _tap(c),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _tap(c),
              child: FlipCard(
                faceUp: up,
                front: MemoryCardFace(
                  set: s.set,
                  motif: s.faces[c],
                  frame: frameSeat == null ? null : AppColors.players[frameSeat % AppColors.players.length],
                ),
                back: const MemoryCardBack(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
