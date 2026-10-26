import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../core/game_kit/dice.dart';
import '../../core/game_kit/piece_token.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'ludo_events.dart';
import 'ludo_geometry.dart';
import 'ludo_rules.dart';
import 'ludo_texts.dart';

/// The cross of wooden fields on the felt (spec 13.8), the pieces and the
/// die. On phones the die sits under the board, on wide screens beside it.
/// The board only shows the state and sends moves; it animates the change
/// from the previous state (hops, a captured piece flying home) and plays
/// the sounds for everybody's moves, robots' included.
class LudoBoard extends StatefulWidget {
  const LudoBoard({super.key, required this.view});

  final GameBoardView<LudoState> view;

  @override
  State<LudoBoard> createState() => _LudoBoardState();
}

typedef _Piece = (int seat, int i);

class _LudoBoardState extends State<LudoBoard> {
  static const _perStep = Duration(milliseconds: 220);
  static const _rollTime = Duration(milliseconds: 500);

  /// The path (in cell units) each piece hopped last; it ends where it stands.
  final _paths = <_Piece, List<Offset>>{};
  final _flying = <_Piece>{};

  /// Sounds to play when the piece that moved has arrived.
  final _onArrival = <_Piece, List<String>>{};
  final _reported = <String>{};
  bool _rolling = false;
  Timer? _rollTimer;
  Timer? _autoTimer;
  double? _cell;

  GameBoardView<LudoState> get _view => widget.view;
  LudoState get _s => _view.state;

  @override
  void initState() {
    super.initState();
    _resetPaths();
    _report();
    _scheduleAuto();
  }

  @override
  void didUpdateWidget(LudoBoard old) {
    super.didUpdateWidget(old);
    if (identical(old.view.state, _s)) {
      if (old.view.canAct != _view.canAct) _scheduleAuto();
      return;
    }
    _animate(old.view.state, _s);
    _report();
    _scheduleAuto();
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _autoTimer?.cancel();
    super.dispose();
  }

  void _resetPaths() {
    _paths.clear();
    _flying.clear();
    for (var seat = 0; seat < _s.seats; seat++) {
      for (var i = 0; i < _s.pieces[seat].length; i++) {
        _paths[(seat, i)] = [_offset(LudoGeometry.cellOf(_s, seat, i, _s.pieces[seat][i]))];
      }
    }
  }

  static Offset _offset((int, int) cell) => Offset(cell.$1.toDouble(), cell.$2.toDouble());

  /// Works out what changed between two states and starts its animation.
  void _animate(LudoState before, LudoState after) {
    final host = _view.host;
    final animations = !MediaQuery.disableAnimationsOf(context);
    if (_view.lastMove?.type == 'roll') {
      host.playSfx('dice_roll');
      if (animations) {
        _rollTimer?.cancel();
        _rolling = true;
        _rollTimer = Timer(_rollTime, () {
          if (mounted) setState(() => _rolling = false);
        });
      }
    }
    _Piece? mover;
    var steps = 0;
    final captured = <_Piece>[];
    for (var seat = 0; seat < after.seats; seat++) {
      for (var i = 0; i < after.pieces[seat].length; i++) {
        final from = before.pieces[seat][i], to = after.pieces[seat][i];
        if (from == to) continue;
        if (to == LudoPos.base) {
          captured.add((seat, i));
        } else if (to > from) {
          mover = (seat, i);
          final walk = LudoGeometry.walk(after, seat, i, from, to);
          steps = walk.length - 1;
          _paths[mover] = [for (final c in walk) _offset(c)];
          _flying.remove(mover);
          _onArrival[mover] = [
            if (_captures(before, after, seat)) 'ludo.boing',
            if (LudoPos.inHome(to) && !LudoPos.inHome(from)) 'ludo.home',
          ];
        } else {
          _paths[(seat, i)] = [_offset(LudoGeometry.cellOf(after, seat, i, to))];
        }
      }
    }
    if (mover != null) host.playSfx('ludo.hop');
    for (final piece in captured) {
      final (seat, i) = piece;
      final from = _offset(LudoGeometry.cellOf(before, seat, i, before.pieces[seat][i]));
      // It waits on its field until the hunter lands, then flies home.
      _paths[piece] = [for (var k = 0; k <= steps; k++) from, _offset(LudoGeometry.base(after.corner(seat), i))];
      _flying.add(piece);
    }
  }

  static bool _captures(LudoState before, LudoState after, int seat) {
    for (var other = 0; other < after.seats; other++) {
      if (other != seat && after.stats[other].captured > before.stats[other].captured) return true;
    }
    return false;
  }

  void _arrived(_Piece piece) {
    final sounds = _onArrival.remove(piece);
    if (sounds == null) return;
    for (final id in sounds) {
      _view.host.playSfx(id);
    }
  }

  void _report() {
    for (final MapEntry(:key, :value) in LudoEvents.of(_s).entries) {
      if (_reported.add(key)) _view.host.reportEvent(LudoEvents.idOf(key), value);
    }
  }

  /// Spec 13.8: the only possible move plays by itself (unless switched off).
  void _scheduleAuto() {
    _autoTimer?.cancel();
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null || !_s.options.autoMove) return;
    final steps = LudoRules.currentSteps(_s);
    if (steps.length != 1) return;
    final piece = steps.single.piece;
    final state = _s;
    _autoTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted && identical(_s, state) && _view.canAct) _send(Move(seat: seat, type: 'move', data: {'piece': piece}));
    });
  }

  void _send(Move move) {
    _autoTimer?.cancel();
    _view.host.haptic();
    _view.submit(move);
  }

  void _roll() {
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null || _s.phase != LudoPhase.roll) return;
    _send(Move(seat: seat, type: 'roll'));
  }

  void _pick(int piece) {
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null) return;
    if (!LudoRules.currentSteps(_s).any((m) => m.piece == piece)) return;
    _send(Move(seat: seat, type: 'move', data: {'piece': piece}));
  }

  /// A tap anywhere picks the nearest movable piece within reach, so small
  /// fields on phones still give a target of at least 48 dp.
  void _tapAt(Offset local, double cell) {
    if (!_view.canAct) return;
    final reach = max(cell * 0.9, 28.0);
    int? best;
    var bestDistance = double.infinity;
    for (final m in LudoRules.currentSteps(_s)) {
      final c = LudoGeometry.cellOf(_s, _s.current, m.piece, m.from);
      final centre = Offset((c.$1 + 0.5) * cell, (c.$2 + 0.5) * cell);
      final d = (centre - local).distance;
      if (d <= reach && d < bestDistance) {
        bestDistance = d;
        best = m.piece;
      }
    }
    if (best != null) _pick(best);
  }

  Future<void> _stop() async {
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null) return;
    final t = ludoTexts;
    final yes = await showAppConfirmDialog(
      context,
      title: t.of(context, 'ludo.stop.title'),
      message: t.of(context, 'ludo.stop.message'),
      confirmLabel: t.of(context, 'ludo.stop.confirm'),
      cancelLabel: t.of(context, 'ludo.stop.cancel'),
    );
    if (yes && mounted && _view.canAct && _view.mySeat == seat) _send(Move(seat: seat, type: 'stop'));
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth > box.maxHeight * 1.15;
      const panelExtent = 150.0;
      final side = wide
          ? min(box.maxHeight, box.maxWidth - panelExtent - 16)
          : min(box.maxWidth, box.maxHeight - panelExtent);
      final board = SizedBox.square(dimension: max(side, 0), child: _board(max(side, 0)));
      final panel = _panel(wide);
      return wide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [board, const SizedBox(width: 16), SizedBox(width: panelExtent, child: panel)],
            )
          : Column(
              children: [
                board,
                Expanded(child: Center(child: panel)),
              ],
            );
    },
  );

  Widget _board(double side) {
    final cell = side / LudoGeometry.size;
    if (_cell != null && _cell != cell) _settlePaths();
    _cell = cell;
    final token = cell * 0.82;
    final movable = _view.canAct ? LudoRules.currentSteps(_s) : const <LudoStep>[];
    final pieces = <Widget>[];
    for (var seat = 0; seat < _s.seats; seat++) {
      for (var i = 0; i < _s.pieces[seat].length; i++) {
        final piece = (seat, i);
        final path = _paths[piece] ?? [_offset(LudoGeometry.cellOf(_s, seat, i, _s.pieces[seat][i]))];
        final canMove = seat == _s.current && movable.any((m) => m.piece == i);
        final label = ludoTexts.of(context, 'ludo.piece', {'n': i + 1});
        final flying = _flying.contains(piece);
        pieces.add(
          HoppingPiece(
            key: ValueKey('piece$seat-$i'),
            path: [for (final p in path) p * cell + Offset((cell - token) / 2, (cell - token) / 2)],
            perStep: _perStep,
            hopHeight: flying ? cell * 3 : cell * 0.45,
            onDone: () => _arrived(piece),
            child: Semantics(
              button: canMove,
              label: label,
              child: PieceToken(seat: seat, size: token, pulse: canMove),
            ),
          ),
        );
      }
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => _tapAt(d.localPosition, cell),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BoardPainter(
                seats: _s.seats,
                corner: _s.corner,
                targets: [
                  for (final m in movable) LudoGeometry.cellOf(_s, _s.current, m.piece, m.to),
                ],
              ),
            ),
          ),
          ...pieces,
        ],
      ),
    );
  }

  /// After a resize every piece stands still where it is.
  void _settlePaths() {
    for (final MapEntry(:key, :value) in _paths.entries.toList()) {
      _paths[key] = [value.last];
    }
    _flying.clear();
  }

  Widget _panel(bool wide) {
    final t = ludoTexts;
    final seat = _view.mySeat;
    final rolling = _rolling;
    final canRoll = _view.canAct && _s.phase == LudoPhase.roll;
    final who = _view.lastMove?.seat ?? _s.current;
    final hint = _view.firstGame && _view.canAct
        ? t.of(context, canRoll ? 'ludo.firstHint.roll' : 'ludo.firstHint.move')
        : null;
    final children = <Widget>[
      Container(
        key: const ValueKey('ludoDice'),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: canRoll ? AppColors.gold : AppColors.players[who % 4], width: 3),
        ),
        child: Dice(
          value: _s.dice,
          rolling: rolling,
          label: t.of(context, 'ludo.dice'),
          onTap: canRoll ? _roll : null,
          size: 64,
        ),
      ),
      if (_s.noMove && !rolling) _pill(t.of(context, 'ludo.noMove')),
      if (hint != null) _note(hint),
      if (seat != null && _view.canAct)
        TextButton(
          key: const ValueKey('ludoStop'),
          onPressed: _stop,
          style: TextButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: AppColors.paper),
          child: Text(t.of(context, 'ludo.stop'), textAlign: TextAlign.center, style: AppTypography.caption(color: AppColors.paper)),
        ),
    ];
    return SingleChildScrollView(
      child: wide
          ? Column(mainAxisSize: MainAxisSize.min, children: _spaced(children, 8))
          : Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: children,
            ),
    );
  }

  static List<Widget> _spaced(List<Widget> items, double gap) => [
    for (final (i, w) in items.indexed) ...[if (i > 0) SizedBox(height: gap), w],
  ];

  Widget _pill(String text) => DecoratedBox(
    decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(999)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(text, style: AppTypography.caption(color: AppColors.ink)),
    ),
  );

  Widget _note(String text) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 220),
    child: Text(text, textAlign: TextAlign.center, style: AppTypography.button(color: AppColors.gold)),
  );
}

/// Wooden fields on the felt: the ring, coloured start and home fields and
/// tinted corners for the seats at the table.
class _BoardPainter extends CustomPainter {
  _BoardPainter({required this.seats, required this.corner, required this.targets});

  final int seats;
  final int Function(int seat) corner;
  final List<(int, int)> targets;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / LudoGeometry.size;
    Offset centre((int, int) c) => Offset((c.$1 + 0.5) * cell, (c.$2 + 0.5) * cell);
    final colorOf = <int, Color>{for (var s = 0; s < seats; s++) corner(s): AppColors.players[s]};

    for (var k = 0; k < 4; k++) {
      final color = colorOf[k];
      final area = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          (LudoGeometry.quadrant(k).left + 0.4) * cell,
          (LudoGeometry.quadrant(k).top + 0.4) * cell,
          (LudoGeometry.quadrant(k).right - 0.4) * cell,
          (LudoGeometry.quadrant(k).bottom - 0.4) * cell,
        ),
        Radius.circular(cell * 0.6),
      );
      canvas.drawRRect(area, Paint()..color = (color ?? AppColors.paper2).withValues(alpha: color == null ? 0.12 : 0.3));
      for (var i = 0; i < 4; i++) {
        _field(canvas, centre(LudoGeometry.base(k, i)), cell, color?.withValues(alpha: 0.55) ?? AppColors.feltDark);
      }
    }
    // Spokes between the fields, like a carved track.
    final track = Paint()
      ..color = AppColors.walnut.withValues(alpha: 0.5)
      ..strokeWidth = cell * 0.12;
    final ring = LudoGeometry.ring;
    for (var i = 0; i < ring.length; i++) {
      canvas.drawLine(centre(ring[i]), centre(ring[(i + 1) % ring.length]), track);
    }
    for (final (i, c) in ring.indexed) {
      final start = i % 10 == 0 ? colorOf[i ~/ 10] : null;
      _field(canvas, centre(c), cell, start ?? AppColors.woodLight);
    }
    for (var k = 0; k < 4; k++) {
      for (var h = 0; h < 4; h++) {
        final color = colorOf[k];
        _field(
          canvas,
          centre(LudoGeometry.home(k, h)),
          cell,
          color == null ? AppColors.woodLight : Color.lerp(AppColors.woodLight, color, 0.6)!,
        );
      }
    }
    // The middle: a little wooden star.
    final mid = centre((5, 5));
    final star = Path();
    for (var k = 0; k < 8; k++) {
      final r = k.isEven ? cell * 0.42 : cell * 0.18;
      final a = -pi / 2 + k * pi / 4;
      final p = mid + Offset(cos(a) * r, sin(a) * r);
      k == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star..close(), Paint()..color = AppColors.gold);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2, cell * 0.08)
      ..color = AppColors.gold;
    for (final t in targets) {
      canvas.drawCircle(centre(t), cell * 0.47, ringPaint);
    }
  }

  void _field(Canvas canvas, Offset c, double cell, Color color) {
    final r = cell * 0.4;
    canvas
      ..drawCircle(c + Offset(0, r * 0.12), r, Paint()..color = const Color(0x55000000))
      ..drawCircle(c, r, Paint()..color = color)
      ..drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1, r * 0.12)
          ..color = AppColors.wood,
      );
  }

  @override
  bool shouldRepaint(_BoardPainter old) =>
      old.seats != seats || old.targets.length != targets.length || !_same(old.targets, targets);

  static bool _same(List<(int, int)> a, List<(int, int)> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
