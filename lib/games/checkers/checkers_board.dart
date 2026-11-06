import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../core/game_kit/piece_token.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'checkers_events.dart';
import 'checkers_pieces.dart';
import 'checkers_rules.dart';
import 'checkers_texts.dart';

/// The last piece move being shown: the piece hops along [path] and the
/// pieces it took fly off the board towards the capturer's side.
class _Motion {
  const _Motion({
    required this.id,
    required this.seat,
    required this.piece,
    required this.path,
    required this.captured,
  });

  final int id;
  final int seat;
  final int piece;
  final List<int> path;

  /// Square and piece of everything taken, in the order of the jumps.
  final List<(int, int)> captured;
}

/// The wooden board of Dáma (spec 13.9). A tap on an own piece shows where it
/// may go; a tap on a target plays the move. A multiple capture with more
/// than one way on is played square by square. Pieces that must capture
/// pulse (option "Nápověda povinného braní"). The board only shows the state
/// and sends moves: it animates the change from the previous state (hops,
/// taken pieces flying off) and plays the sounds for everybody's moves,
/// robots' and other devices' included.
class CheckersBoard extends StatefulWidget {
  const CheckersBoard({super.key, required this.view});

  final GameBoardView<CheckersState> view;

  @override
  State<CheckersBoard> createState() => _CheckersBoardState();
}

class _CheckersBoardState extends State<CheckersBoard> with SingleTickerProviderStateMixin {
  static const _perHop = Duration(milliseconds: 260);
  static const _flight = Duration(milliseconds: 450);

  final _zoom = TransformationController();
  late final AnimationController _fly = AnimationController(vsync: this)..addStatusListener(_flown);

  /// The squares picked so far: the piece, then the landings of a capture.
  List<int> _partial = const [];

  /// Seats played on this device, to turn the board towards them.
  final _local = <int>{};
  int _bottom = 0;
  final _reported = <String>{};
  _Motion? _motion;
  var _motionId = 0;

  GameBoardView<CheckersState> get _view => widget.view;
  CheckersState get _s => _view.state;

  @override
  void initState() {
    super.initState();
    _report();
  }

  @override
  void didUpdateWidget(CheckersBoard old) {
    super.didUpdateWidget(old);
    final before = old.view.state;
    if (identical(before, _s)) {
      if (!_view.canAct) _partial = const [];
      return;
    }
    _partial = const [];
    if (_s.log.length == before.log.length + 1) {
      _animate(before, _s);
    } else {
      _motion = null;
      _fly.stop();
    }
    _report();
  }

  @override
  void dispose() {
    _fly.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _report() {
    for (final MapEntry(:key, :value) in CheckersEvents.of(_s).entries) {
      if (_reported.add(key)) _view.host.reportEvent(CheckersEvents.idOf(key), value);
    }
  }

  /// Sounds for every move; the hop and the flight unless motion is reduced.
  void _animate(CheckersState before, CheckersState after) {
    final host = _view.host;
    host.playSfx(after.lastCaptured.isNotEmpty ? 'checkers.capture' : 'piece_place');
    final path = after.lastPath!;
    if (MediaQuery.disableAnimationsOf(context)) {
      if (after.lastPromoted) host.playSfx('checkers.crown');
      _motion = null;
      return;
    }
    _motion = _Motion(
      id: ++_motionId,
      seat: before.current,
      piece: before.board[path.first],
      path: path,
      captured: [for (final i in after.lastCaptured) (i, before.board[i])],
    );
    _fly
      ..duration = _perHop * (path.length - 1) + _flight
      ..forward(from: 0);
  }

  void _flown(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) setState(() => _motion = null);
  }

  void _hopped(_Motion motion) {
    if (motion.id == _motion?.id && _s.lastPromoted) _view.host.playSfx('checkers.crown');
  }

  // ---- orientation ----

  /// The seat at the bottom: the one playing here; with two people on one
  /// device seat 0, or the seat to move when "Otáčet desku" is on.
  int _bottomSeat() {
    final mine = _view.mySeat;
    if (mine != null) _local.add(mine);
    if (_local.length == 2) return _s.rotate ? (mine ?? _bottom) : 0;
    if (_local.length == 1) return _local.single;
    return _s.robots[0] && !_s.robots[1] ? 1 : 0;
  }

  (int, int) _display(int square) {
    final n = _s.size;
    final c = square % n, r = square ~/ n;
    return _bottom == 1 ? (n - 1 - c, n - 1 - r) : (c, r);
  }

  int _square(int column, int row) {
    final n = _s.size;
    return _bottom == 1 ? (n - 1 - row) * n + (n - 1 - column) : row * n + column;
  }

  // ---- input ----

  int? get _mover {
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null || _s.over || _s.offerBy != null || seat != _s.current) return null;
    return seat;
  }

  List<CheckersStep> get _steps => _mover == null ? const [] : CheckersRules.steps(_s);

  static bool _startsWith(List<int> path, List<int> prefix) {
    if (path.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (path[i] != prefix[i]) return false;
    }
    return true;
  }

  /// Where the picked piece may land next.
  Set<int> _targets(List<CheckersStep> steps) => {
    if (_partial.isNotEmpty)
      for (final st in steps)
        if (st.path.length > _partial.length && _startsWith(st.path, _partial)) st.path[_partial.length],
  };

  /// Squares a tap may mean: the pieces that can move and the targets.
  Set<int> _actionable(List<CheckersStep> steps) => {for (final st in steps) st.from, ..._targets(steps)};

  void _tapAt(Offset local, double cell) {
    final steps = _steps;
    if (steps.isEmpty) return;
    final n = _s.size;
    final column = (local.dx ~/ cell).clamp(0, n - 1), row = (local.dy ~/ cell).clamp(0, n - 1);
    final exact = _square(column, row);
    final actionable = _actionable(steps);
    if (actionable.contains(exact)) {
      _tapSquare(exact);
      return;
    }
    // Small squares: the nearest square that means something, within reach.
    final reach = max(cell * 0.85, 32.0);
    int? best;
    var bestDistance = double.infinity;
    for (final square in actionable) {
      final (c, r) = _display(square);
      final d = (Offset((c + 0.5) * cell, (r + 0.5) * cell) - local).distance;
      if (d <= reach && d < bestDistance) {
        bestDistance = d;
        best = square;
      }
    }
    _tapSquare(best ?? exact);
  }

  void _tapSquare(int square) {
    final seat = _mover;
    if (seat == null) return;
    final steps = CheckersRules.steps(_s);
    if (_targets(steps).contains(square)) {
      final path = [..._partial, square];
      final matching = [
        for (final st in steps)
          if (_startsWith(st.path, path)) st,
      ];
      if (matching.length == 1) {
        _play(seat, matching.single);
      } else {
        _view.host.haptic();
        setState(() => _partial = path);
      }
      return;
    }
    if (steps.any((st) => st.from == square)) {
      _view.host.haptic();
      setState(() => _partial = [square]);
      return;
    }
    // Half way through a capture a stray tap changes nothing.
    if (_partial.length <= 1) setState(() => _partial = const []);
  }

  void _play(int seat, CheckersStep step) {
    final move = CheckersRules.moveOf(seat, step.path);
    for (final MapEntry(:key, :value) in CheckersEvents.ofMove(_s, move).entries) {
      if (_reported.add(key)) _view.host.reportEvent(CheckersEvents.idOf(key), value);
    }
    _view.host.haptic();
    setState(() => _partial = const []);
    _view.submit(move);
  }

  void _send(String type) {
    final seat = _view.mySeat;
    if (!_view.canAct || seat == null) return;
    final move = Move(seat: seat, type: type);
    if (!const CheckersRules().isLegal(_s, move)) return;
    _view.host.haptic();
    setState(() => _partial = const []);
    _view.submit(move);
  }

  Future<void> _offer() async {
    final t = checkersTexts;
    final yes = await showAppConfirmDialog(
      context,
      title: t.of(context, 'checkers.offer.confirm.title'),
      message: t.of(context, 'checkers.offer.confirm.message'),
      confirmLabel: t.of(context, 'checkers.offer.confirm.yes'),
      cancelLabel: t.of(context, 'checkers.offer.confirm.no'),
    );
    if (yes && mounted) _send(CheckersRules.offer);
  }

  // ---- drawing ----

  @override
  Widget build(BuildContext context) {
    _bottom = _bottomSeat();
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth > box.maxHeight * 1.15;
        const bar = 64.0;
        final side = max(
          0.0,
          wide ? min(box.maxHeight, box.maxWidth - bar - 12) : min(box.maxWidth, box.maxHeight - bar),
        );
        final frame = max(4.0, side * 0.03);
        final cell = side <= 2 * frame ? 0.0 : (side - 2 * frame) / _s.size;
        final zooms = cell > 0 && cell < 48;
        final board = SizedBox.square(dimension: side, child: cell > 0 ? _board(frame, cell, zooms) : null);
        final buttons = _buttons(zooms);
        final content = wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  board,
                  const SizedBox(width: 12),
                  SizedBox(
                    width: bar,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _spaced(buttons, vertical: true),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(child: Center(child: board)),
                  SizedBox(
                    height: bar,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _spaced(buttons, vertical: false),
                    ),
                  ),
                ],
              );
        final hint = _hint(zooms);
        final answering = _s.offerBy != null && _view.canAct && _view.mySeat == 1 - _s.offerBy!;
        return Stack(
          children: [
            Positioned.fill(child: content),
            if (hint != null)
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: IgnorePointer(child: Center(child: _bubble(hint, const ValueKey('checkersHint')))),
              ),
            if (answering) Positioned.fill(child: Center(child: _offerPanel())),
            if (_s.end case final end?)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: _bubble(
                      checkersTexts.of(context, 'checkers.end.${end.name}'),
                      const ValueKey('checkersEnd'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  static List<Widget> _spaced(List<Widget> buttons, {required bool vertical}) => [
    for (final (i, b) in buttons.indexed) ...[
      if (i > 0) SizedBox(width: vertical ? 0 : 16, height: vertical ? 16 : 0),
      b,
    ],
  ];

  List<Widget> _buttons(bool zooms) {
    final t = checkersTexts;
    final seat = _view.mySeat;
    return [
      if (seat != null && _view.canAct && CheckersRules.canUndo(_s, seat))
        RoundIconButton(
          key: const ValueKey('checkersUndo'),
          icon: Icons.undo,
          tooltip: t.of(context, 'checkers.undo', {'left': CheckersRules.maxUndos - _s.undos[seat]}),
          onPressed: () => _send(CheckersRules.undo),
        ),
      if (seat != null && _view.canAct && CheckersRules.canOffer(_s, seat))
        RoundIconButton(
          key: const ValueKey('checkersOffer'),
          icon: Icons.handshake,
          tooltip: t.of(context, 'checkers.offer'),
          onPressed: _offer,
        ),
      if (zooms)
        RoundIconButton(
          key: const ValueKey('checkersCentre'),
          icon: Icons.center_focus_strong,
          tooltip: t.of(context, 'checkers.centre'),
          onPressed: () => _zoom.value = Matrix4.identity(),
        ),
    ];
  }

  String? _hint(bool zooms) {
    final t = checkersTexts;
    if (_s.over) return null;
    if (_s.offerBy != null) return _view.canAct ? null : t.of(context, 'checkers.offer.waiting');
    if (_mover == null) return null;
    if (_partial.length > 1) return t.of(context, 'checkers.continue');
    final capture = _steps.firstOrNull?.captured.isNotEmpty ?? false;
    if (capture && _s.hint && _partial.isEmpty) return t.of(context, 'checkers.mustCapture');
    if (_view.firstGame && _s.log.length < 4 && _partial.isEmpty) {
      return t.of(context, zooms && _s.log.length >= 2 ? 'checkers.zoomHint' : 'checkers.firstHint');
    }
    return null;
  }

  Widget _bubble(String text, Key key) => DecoratedBox(
    key: key,
    decoration: BoxDecoration(
      color: AppColors.walnut.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.caption(color: AppColors.paper),
      ),
    ),
  );

  Widget _offerPanel() {
    final t = checkersTexts;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: DecoratedBox(
        key: const ValueKey('checkersOfferPanel'),
        decoration: BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.wood, width: 3),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.handshake, size: 40, color: AppColors.wood),
              const SizedBox(height: 8),
              Text(
                t.of(context, 'checkers.offer.title'),
                textAlign: TextAlign.center,
                style: AppTypography.h2(color: AppColors.ink),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                key: const ValueKey('checkersAccept'),
                label: t.of(context, 'checkers.offer.accept'),
                onPressed: () => _send(CheckersRules.accept),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                key: const ValueKey('checkersDecline'),
                label: t.of(context, 'checkers.offer.decline'),
                secondary: true,
                onPressed: () => _send(CheckersRules.decline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _board(double frame, double cell, bool zooms) {
    final s = _s;
    final n = s.size;
    final token = cell * 0.8;
    final inset = (cell - token) / 2;
    Offset topLeft(int square) {
      final (c, r) = _display(square);
      return Offset(c * cell + inset, r * cell + inset);
    }

    final steps = _steps;
    final capture = steps.firstOrNull?.captured.isNotEmpty ?? false;
    final pulsing = capture && s.hint && _partial.isEmpty ? {for (final st in steps) st.from} : const <int>{};
    final targets = _targets(steps);
    final motion = _motion;
    final last = s.lastPath;
    final t = checkersTexts;

    final children = <Widget>[
      Positioned.fill(
        child: CustomPaint(
          painter: CheckersSquaresPainter(
            size: n,
            marked: {
              if (last != null && motion == null)
                for (final i in last) _display(i),
            },
          ),
        ),
      ),
      for (final (k, square) in _partial.indexed)
        _ring(
          square,
          cell,
          k == 0 ? AppColors.gold : AppColors.gold.withValues(alpha: 0.55),
          ValueKey('picked$square'),
        ),
      for (final square in targets) _dot(square, cell),
      for (var i = 0; i < s.board.length; i++)
        if (s.board[i] != CheckersPiece.empty && !(motion != null && i == motion.path.last))
          Positioned(
            key: ValueKey('piece$i'),
            left: topLeft(i).dx,
            top: topLeft(i).dy,
            child: CheckersPieceView(
              seat: CheckersPiece.owner(s.board[i]),
              king: CheckersPiece.isKing(s.board[i]),
              size: token,
              pulse: pulsing.contains(i),
            ),
          ),
      if (motion != null) ...[
        AnimatedBuilder(
          animation: _fly,
          builder: (context, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              for (final (k, (square, piece)) in motion.captured.indexed)
                _ghost(motion, k, square, piece, cell, token, inset),
            ],
          ),
        ),
        HoppingPiece(
          key: ValueKey('hop${motion.id}'),
          path: [for (final i in motion.path) topLeft(i)],
          perStep: _perHop,
          hopHeight: cell * 0.4,
          onDone: () => _hopped(motion),
          child: CheckersPieceView(seat: motion.seat, king: CheckersPiece.isKing(motion.piece), size: token),
        ),
      ],
      // One tap target per dark square for screen readers.
      for (var i = 0; i < s.board.length; i++)
        if ((i % n + i ~/ n).isOdd)
          Positioned(
            left: _display(i).$1 * cell,
            top: _display(i).$2 * cell,
            width: cell,
            height: cell,
            child: Semantics(
              key: ValueKey('sq$i'),
              container: true,
              excludeSemantics: true,
              label: t.of(context, 'checkers.cell', {
                'piece': s.board[i] == CheckersPiece.empty
                    ? t.of(context, 'checkers.cell.empty')
                    : t.of(context, CheckersPiece.isKing(s.board[i]) ? 'checkers.cell.king' : 'checkers.cell.man', {
                        'seat': CheckersPiece.owner(s.board[i]) + 1,
                      }),
                'column': i % n + 1,
                'row': n - i ~/ n,
              }),
              button: _mover != null,
              onTap: _mover != null ? () => _tapSquare(i) : null,
              child: const SizedBox.expand(),
            ),
          ),
    ];

    Widget grid = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => _tapAt(d.localPosition, cell),
      child: SizedBox.square(
        dimension: cell * n,
        child: Stack(clipBehavior: Clip.none, children: children),
      ),
    );
    if (zooms) {
      grid = InteractiveViewer(transformationController: _zoom, minScale: 1, maxScale: 3, child: grid);
    }
    return RepaintBoundary(
      key: const ValueKey('checkersBoard'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.walnut,
          borderRadius: BorderRadius.circular(frame * 1.5),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Padding(
          padding: EdgeInsets.all(frame),
          child: ClipRect(child: grid),
        ),
      ),
    );
  }

  Widget _ring(int square, double cell, Color color, Key key) {
    final (c, r) = _display(square);
    return Positioned(
      key: key,
      left: c * cell,
      top: r * cell,
      width: cell,
      height: cell,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: max(2.0, cell * 0.07)),
            borderRadius: BorderRadius.circular(cell / 8),
          ),
        ),
      ),
    );
  }

  Widget _dot(int square, double cell) {
    final (c, r) = _display(square);
    return Positioned(
      key: ValueKey('target$square'),
      left: c * cell + cell * 0.3,
      top: r * cell + cell * 0.3,
      width: cell * 0.4,
      height: cell * 0.4,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.walnut, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// A taken piece: it stays until the hopping piece has jumped it, then
  /// flies off the board towards the capturer's side and fades.
  Widget _ghost(_Motion motion, int k, int square, int piece, double cell, double token, double inset) {
    final total = _fly.duration!.inMicroseconds;
    final start = (_perHop * (k + 1)).inMicroseconds / total;
    final end = min(1.0, start + _flight.inMicroseconds / total);
    final t = Curves.easeIn.transform(((_fly.value - start) / (end - start)).clamp(0.0, 1.0));
    final (c, r) = _display(square);
    final from = Offset(c * cell + inset, r * cell + inset);
    final away = motion.seat == _bottom ? _s.size * cell + cell : -cell * 1.5;
    final to = Offset(from.dx, away);
    final at = Offset.lerp(from, to, t)!;
    return Positioned(
      key: ValueKey('taken$square'),
      left: at.dx,
      top: at.dy,
      child: Opacity(
        opacity: 1 - t,
        child: CheckersPieceView(seat: CheckersPiece.owner(piece), king: CheckersPiece.isKing(piece), size: token),
      ),
    );
  }
}
