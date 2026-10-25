import 'dart:async';

import 'game_session.dart';
import 'move.dart';

/// How moves reach the game. Phases 1–2 only have [LocalTransport]; phase 3
/// adds a network transport without changing any game (spec 8, 14).
abstract class MoveTransport {
  Stream<Move> get applied;

  /// True when the move was legal and applied.
  Future<bool> submit(Move move);

  void dispose();
}

/// Same-device transport: validates and applies moves on the local session.
class LocalTransport<S> implements MoveTransport {
  LocalTransport(this.session);

  final GameSession<S> session;
  final _applied = StreamController<Move>.broadcast();

  @override
  Stream<Move> get applied => _applied.stream;

  @override
  Future<bool> submit(Move move) async {
    if (_applied.isClosed || !session.apply(move)) return false;
    _applied.add(move);
    return true;
  }

  @override
  void dispose() => _applied.close();
}
