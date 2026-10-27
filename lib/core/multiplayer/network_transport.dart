import 'dart:async';

import '../game/move.dart';
import '../game/move_transport.dart';

/// The host's transport (spec 14.3): a move is applied on the host's session
/// and sent to every device by [_apply]; [applied] carries every move of the
/// game, the other devices' ones included.
class HostTransport implements MoveTransport {
  HostTransport(this._apply);

  final bool Function(Move move) _apply;
  final _applied = StreamController<Move>.broadcast();

  @override
  Stream<Move> get applied => _applied.stream;

  @override
  Future<bool> submit(Move move) async => !_applied.isClosed && _apply(move);

  /// Called by the room after any move was applied.
  void emit(Move move) {
    if (!_applied.isClosed) _applied.add(move);
  }

  @override
  void dispose() => _applied.close();
}

/// A client's transport (spec 14.3): [submit] asks the host via [_request]
/// and is true once the host applied the move, false when it refused or did
/// not answer within [timeout].
class ClientTransport implements MoveTransport {
  ClientTransport(this._request, {this.timeout = const Duration(seconds: 5)});

  final void Function(Move move) _request;
  final Duration timeout;
  final _applied = StreamController<Move>.broadcast();
  Move? _pendingMove;
  Completer<bool>? _pending;
  Timer? _timer;

  @override
  Stream<Move> get applied => _applied.stream;

  @override
  Future<bool> submit(Move move) {
    if (_applied.isClosed || _pending != null) return Future.value(false);
    final pending = _pending = Completer<bool>();
    _pendingMove = move;
    _timer = Timer(timeout, () => _finish(false));
    _request(move);
    return pending.future;
  }

  /// The host applied [move] and so did this device.
  void confirm(Move move) {
    if (!_applied.isClosed) _applied.add(move);
    if (move == _pendingMove) _finish(true);
  }

  /// The host refused the waiting move.
  void reject() => _finish(false);

  /// This device's game was replaced by the host's; a waiting move counts
  /// as played only when it is the last one there.
  void resynced(Move? lastMove) {
    if (lastMove != null && !_applied.isClosed) _applied.add(lastMove);
    _finish(lastMove != null && lastMove == _pendingMove);
  }

  void _finish(bool applied) {
    _timer?.cancel();
    final pending = _pending;
    _pending = null;
    _pendingMove = null;
    if (pending != null && !pending.isCompleted) pending.complete(applied);
  }

  @override
  void dispose() {
    _finish(false);
    _applied.close();
  }
}
