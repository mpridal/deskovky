import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/seeded_random.dart';
import '../../core/game_kit/board_grid.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'ships_art.dart';
import 'ships_events.dart';
import 'ships_rules.dart';
import 'ships_texts.dart';

/// Board of Lodě, always seen by one seat (the viewer, see [_viewer]):
/// the other seat's sea to shoot at, big, and the viewer's own fleet, small.
/// While a seat places its fleet it gets an editor instead.
///
/// Two people on one device: when the turn passes from one to the other,
/// a cover hides both seas until the next one taps "Jsem na řadě".
class ShipsBoard extends StatefulWidget {
  const ShipsBoard({super.key, required this.view});

  final GameBoardView<ShipsState> view;

  @override
  State<ShipsBoard> createState() => _ShipsBoardState();
}

class _ShipsBoardState extends State<ShipsBoard> {
  static const _rules = ShipsRules();

  final _reported = <String>{};

  /// The seat this device last played; null until one has.
  int? _seen;
  bool _covered = false;

  /// The fleet being placed, the selected ship and how often it was shuffled.
  List<Ship>? _draft;
  int? _selected;
  var _shuffles = 0;

  /// Key of the last shot's result (`ships.miss` / `.hit` / `.sunk`).
  String? _result;

  ShipsState get _s => widget.view.state;

  @override
  void initState() {
    super.initState();
    _seen = widget.view.mySeat;
    _report(_s);
  }

  @override
  void didUpdateWidget(ShipsBoard old) {
    super.didUpdateWidget(old);
    final my = widget.view.mySeat;
    if (my != null && my != _seen) {
      // Another person on this device: hide everything until they are ready.
      if (_seen != null) _covered = true;
      _seen = my;
      _draft = null;
      _selected = null;
    }
    final before = old.view.state, now = _s;
    if (identical(before, now)) return;
    for (var seat = 0; seat < 2; seat++) {
      if (now.placing || now.shots[seat].length <= before.shots[seat].length) continue;
      final cell = now.shots[seat].last;
      final other = ShipsState.other(seat);
      if (now.sunkShips(other).length > before.sunkShips(other).length) {
        _result = 'ships.sunk';
        widget.view.host.playSfx('ships.sunk');
        widget.view.host.haptic();
      } else if (now.isHit(seat, cell)) {
        _result = 'ships.hit';
        widget.view.host.playSfx('ships.hit');
        widget.view.host.haptic();
      } else {
        _result = 'ships.miss';
        widget.view.host.playSfx('ships.splash');
      }
    }
    _report(now);
  }

  void _report(ShipsState s) {
    for (final MapEntry(:key, :value) in ShipsEvents.of(s).entries) {
      if (_reported.add(key)) widget.view.host.reportEvent(ShipsEvents.idOf(key), value);
    }
  }

  /// Whose eyes the board shows: the seat played here last, else the one
  /// not on turn (a robot or another device is on turn).
  int? get _viewer {
    if (_seen != null) return _seen;
    final turn = _rules.currentSeat(_s);
    if (_s.placing || turn == null) return null;
    return ShipsState.other(turn);
  }

  bool get _canShoot {
    final view = widget.view;
    return view.canAct && view.mySeat != null && view.mySeat == _viewer && !_s.placing && !_s.over && !_covered;
  }

  void _shoot(int cell) {
    final move = ShipsRules.shoot(widget.view.mySeat!, cell);
    if (!_canShoot || !_rules.isLegal(_s, move)) return;
    widget.view.host.haptic();
    // Before the move: when it ends the game, the screen collects events at once.
    _report(_rules.apply(_s, move));
    widget.view.submit(move);
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final view = widget.view;
    if (_covered && !s.over) return _cover(context);
    final my = view.mySeat;
    if (s.placing) {
      if (my != null && view.canAct && s.ships[my] == null) return _editor(context, my);
      return _waiting(context);
    }
    final viewer = _viewer;
    if (viewer == null) return _waiting(context);
    return _battle(context, viewer);
  }

  Widget _centred(List<Widget> children) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    ),
  );

  Widget _waiting(BuildContext context) => _centred([
    const Icon(Icons.sailing, size: 56, color: AppColors.paper),
    const SizedBox(height: 12),
    Text(
      shipsTexts.of(context, 'ships.waitPlace'),
      key: const ValueKey('shipsWaiting'),
      textAlign: TextAlign.center,
      style: AppTypography.body(color: AppColors.paper),
    ),
  ]);

  Widget _cover(BuildContext context) => _centred([
    if (_result != null) ...[
      Text(shipsTexts.of(context, _result!), style: AppTypography.h2(color: AppColors.gold)),
      const SizedBox(height: 16),
    ],
    const Icon(Icons.visibility_off, size: 56, color: AppColors.paper),
    const SizedBox(height: 12),
    Text(shipsTexts.of(context, 'ships.handoff.title'), textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.paper)),
    const SizedBox(height: 8),
    Text(shipsTexts.of(context, 'ships.handoff.body'), textAlign: TextAlign.center, style: AppTypography.body(color: AppColors.paper2)),
    const SizedBox(height: 24),
    PrimaryButton(
      key: const ValueKey('shipsReady'),
      label: shipsTexts.of(context, 'ships.handoff.ready'),
      onPressed: () => setState(() {
        _covered = false;
        _result = null;
      }),
    ),
  ]);

  // --- placing ---------------------------------------------------------

  List<Ship> _draftFor(int seat) => _draft ??= ShipsRules.randomFleet(_s.size, _s.fleet, SeededRandom(seat * 1000 + _shuffles + 1));

  void _editTap(int seat, (int, int) at) {
    final s = _s;
    final ships = _draftFor(seat);
    final (x, y) = at;
    final hit = ships.indexWhere((ship) => ship.points.contains(at));
    List<Ship>? next;
    if (hit >= 0 && hit != _selected) {
      setState(() => _selected = hit);
      widget.view.host.playSfx('tap');
      return;
    }
    final selected = _selected;
    if (selected == null) return;
    final ship = ships[selected];
    final moved = hit == selected ? ship.turned() : ship.moved(x, y);
    // A turned or moved ship may stick out: slide it back onto the sea.
    final fitted = moved.horizontal
        ? moved.moved(min(moved.x, s.size - moved.length), moved.y)
        : moved.moved(moved.x, min(moved.y, s.size - moved.length));
    next = List.of(ships)..[selected] = fitted;
    if (ShipsRules.validFleet(s.size, s.fleet, next)) {
      setState(() => _draft = next);
      widget.view.host.playSfx('piece_place');
    } else {
      widget.view.host.playSfx('error');
      widget.view.host.haptic();
    }
  }

  Widget _editor(BuildContext context, int seat) {
    final s = _s;
    final ships = _draftFor(seat);
    final pieces = shipPieces(s.size, ships);
    final selected = _selected == null ? const <(int, int)>{} : ships[_selected!].points.toSet();
    final buttons = Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        PrimaryButton(
          key: const ValueKey('shipsShuffle'),
          label: shipsTexts.of(context, 'ships.shuffle'),
          secondary: true,
          onPressed: () => setState(() {
            _shuffles++;
            _draft = null;
            _selected = null;
          }),
        ),
        PrimaryButton(
          key: const ValueKey('shipsDone'),
          label: shipsTexts.of(context, 'ships.done'),
          onPressed: () {
            final move = ShipsRules.place(seat, ships);
            if (!_rules.isLegal(s, move)) return;
            widget.view.host.playSfx('piece_place');
            widget.view.submit(move);
          },
        ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final landscape = box.maxWidth > box.maxHeight * 1.1;
        final words = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(shipsTexts.of(context, 'ships.place.title'), textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.paper)),
            const SizedBox(height: 4),
            Text(shipsTexts.of(context, 'ships.place.hint'), textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.paper2)),
          ],
        );
        final grid = BoardGrid(
          key: const ValueKey('shipsEditor'),
          columns: s.size,
          rows: s.size,
          highlighted: selected,
          onTap: (at) => _editTap(seat, at),
          cellBuilder: (context, c, r) {
            final cell = r * s.size + c;
            return Semantics(
              label: shipsTexts.of(context, pieces.containsKey(cell) ? 'ships.cell.ship' : 'ships.cell', {'cell': _name(c, r)}),
              child: ShipsCell(look: ShipsLook.sea, piece: pieces[cell]),
            );
          },
        );
        return Padding(
          padding: const EdgeInsets.all(8),
          child: landscape
              ? Row(
                  children: [
                    Expanded(child: grid),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: min(320, box.maxWidth * 0.4),
                      child: SingleChildScrollView(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [words, const SizedBox(height: 16), buttons]),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    words,
                    const SizedBox(height: 8),
                    Expanded(child: grid),
                    const SizedBox(height: 8),
                    buttons,
                  ],
                ),
        );
      },
    );
  }

  // --- battle ----------------------------------------------------------

  static String _name(int column, int row) => '${String.fromCharCode(65 + column)}${row + 1}';

  Widget _battle(BuildContext context, int viewer) {
    final s = _s;
    final view = widget.view;
    final enemy = ShipsState.other(viewer);
    final size = s.size;
    final sunk = s.sunkShips(enemy).toSet();
    // The other fleet: sunk ships, and every ship once the game is over.
    final enemyShips = [
      for (var i = 0; i < s.fleet.length; i++)
        if (sunk.contains(i) || s.over) i,
    ];
    final enemyPieces = shipPieces(size, [for (final i in enemyShips) s.ships[enemy]![i]], sunk: {
      for (final (j, i) in enemyShips.indexed)
        if (sunk.contains(i)) j,
    });
    final shot = s.shots[viewer].toSet();
    final water = s.knownWater(viewer);
    ShipsLook lookAt(int cell) {
      if (water.contains(cell)) return ShipsLook.water;
      if (!shot.contains(cell)) return ShipsLook.sea;
      if (!s.isHit(viewer, cell)) return ShipsLook.miss;
      return enemyPieces[cell]?.sunk == true ? ShipsLook.sea : ShipsLook.hit;
    }

    final last = s.shots[viewer].isEmpty ? null : s.shots[viewer].last;
    final canShoot = _canShoot;
    final hint = view.firstGame && canShoot && s.shots[viewer].isEmpty ? shipsTexts.of(context, 'ships.firstHint') : null;
    final target = BoardGrid(
      key: const ValueKey('shipsTarget'),
      columns: size,
      rows: size,
      highlighted: last == null ? const {} : {(last % size, last ~/ size)},
      onTap: canShoot ? (at) => _shoot(at.$2 * size + at.$1) : null,
      cellBuilder: (context, c, r) {
        final cell = r * size + c;
        final look = lookAt(cell);
        final piece = enemyPieces[cell];
        final key = switch (look) {
          ShipsLook.miss || ShipsLook.water => 'ships.cell.miss',
          ShipsLook.hit => 'ships.cell.hit',
          ShipsLook.sea => piece == null ? 'ships.cell' : (piece.sunk ? 'ships.cell.sunk' : 'ships.cell.ship'),
        };
        return Semantics(
          button: canShoot && look == ShipsLook.sea && piece == null,
          label: shipsTexts.of(context, key, {'cell': _name(c, r)}),
          child: ShipsCell(look: look, piece: piece, shot: piece != null && shot.contains(cell)),
        );
      },
    );

    // The own fleet with the other seat's shots.
    final ownSunk = s.sunkShips(viewer).toSet();
    final ownPieces = shipPieces(size, s.ships[viewer]!, sunk: ownSunk);
    final theirShots = s.shots[enemy];
    final ownLooks = {
      for (final c in theirShots)
        if (!ownPieces.containsKey(c)) c: ShipsLook.miss,
    };
    final own = ShipsSea(
      key: const ValueKey('shipsOwn'),
      size: size,
      looks: ownLooks,
      pieces: ownPieces,
      shotShips: {
        for (final c in theirShots)
          if (ownPieces.containsKey(c)) c,
      },
      mark: theirShots.isEmpty ? null : theirShots.last,
    );

    final left = s.fleet.length - sunk.length;
    final status = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      children: [
        Text(shipsTexts.of(context, 'ships.enemySea'), style: AppTypography.caption(color: AppColors.paper)),
        Text(shipsTexts.of(context, 'ships.shipsLeft', {'count': left}), style: AppTypography.caption(color: AppColors.paper2)),
        if (_result != null)
          DecoratedBox(
            key: const ValueKey('shipsResult'),
            decoration: BoxDecoration(
              color: _result == 'ships.miss' ? ShipsColors.seaDeep : ShipsColors.fire,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Text(shipsTexts.of(context, _result!), style: AppTypography.button(color: Colors.white)),
            ),
          ),
      ],
    );
    final ownLabel = Text(shipsTexts.of(context, 'ships.ownFleet'), style: AppTypography.caption(color: AppColors.paper));
    final targetWithHint = Stack(
      children: [
        Positioned.fill(child: target),
        if (hint != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: IgnorePointer(
              child: Center(
                child: DecoratedBox(
                  key: const ValueKey('shipsHint'),
                  decoration: BoxDecoration(color: AppColors.walnut.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(999)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(hint, style: AppTypography.caption(color: AppColors.paper)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final landscape = box.maxWidth > box.maxHeight * 1.1;
        if (landscape) {
          final side = min(box.maxHeight * 0.55, box.maxWidth * 0.3);
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: Column(children: [status, const SizedBox(height: 4), Expanded(child: targetWithHint)])),
                const SizedBox(width: 16),
                SizedBox(
                  width: side,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [ownLabel, const SizedBox(height: 4), SizedBox(width: side, height: side, child: own)],
                  ),
                ),
              ],
            ),
          );
        }
        final side = min(box.maxWidth * 0.5, box.maxHeight * 0.26);
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              status,
              const SizedBox(height: 4),
              Expanded(child: targetWithHint),
              const SizedBox(height: 8),
              ownLabel,
              const SizedBox(height: 4),
              SizedBox(width: side, height: side, child: own),
            ],
          ),
        );
      },
    );
  }
}
