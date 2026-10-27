import 'dart:async';

import '../game/ai_player.dart';
import '../game/difficulty.dart';
import '../game/game_module.dart';
import 'client_room.dart';
import 'host_room.dart';
import 'network_env.dart';
import 'protocol.dart';
import 'room_info.dart';

/// The one network room this device is in, hosting or joined; it outlives
/// the screens (room → game → results) until [leave].
class NetworkRooms {
  NetworkRooms(this.env);

  final NetworkEnv env;

  HostRoom? _host;
  ClientRoom? _client;
  OpenServer? _server;
  Announcement? _announcement;
  StreamSubscription<Object?>? _serverSub;
  RoomInfo? _info;

  HostRoom? get host => _host;
  ClientRoom? get client => _client;

  /// Where others join the hosted room (the QR code).
  JoinTicket? get ticket => _info?.ticket;

  /// Opens a room on the Wi-Fi; null when not on Wi-Fi.
  Future<HostRoom?> openHost({
    required GameModule<Object?> module,
    required List<RoomSlot> slots,
    required Difficulty difficulty,
    required RobotSpeed robotSpeed,
    required Map<String, Object?> options,
    required AiRunner runner,
    required ProfileCard hostCard,
  }) async {
    await leave();
    final ip = await env.wifiAddress();
    if (ip == null) return null;
    final server = _server = await env.serve();
    final room = _host = HostRoom(
      module: module,
      roomCode: newRoomCode(),
      slots: slots,
      difficulty: difficulty,
      robotSpeed: robotSpeed,
      options: options,
      runner: runner,
    );
    _serverSub = server.channels.listen(room.accept);
    final info = _info = RoomInfo(
      code: room.roomCode,
      gameId: module.id,
      hostName: hostCard.name,
      hostAvatar: hostCard.avatar,
      port: server.port,
      free: room.freePlaces,
      ip: ip,
    );
    final announcement = _announcement = await env.announce(info);
    room.addListener(() {
      if (room.started) {
        // Nobody else can join a running game.
        _announcement?.close();
        _announcement = null;
      } else if (_info case final current? when current.free != room.freePlaces) {
        _info = current.copyWith(free: room.freePlaces);
        announcement.update(_info!);
      }
    });
    return room;
  }

  /// Joins a host's room with this device's [profiles] (ids in [profileIds]).
  /// Throws when the host cannot be reached.
  Future<ClientRoom> join({
    required JoinTicket ticket,
    required List<ProfileCard> profiles,
    required List<int> profileIds,
    required String appVersion,
  }) async {
    await leave();
    final channel = await env.connect(ticket.ip, ticket.port);
    return _client = ClientRoom(
      channel: channel,
      hello: Hello(
        protocolVersion: protocolVersion,
        appVersion: appVersion,
        roomCode: ticket.code,
        token: null,
        profiles: profiles,
      ),
      localProfileIds: profileIds,
    );
  }

  /// Closes the room, the server and every line.
  Future<void> leave() async {
    _announcement?.close();
    _announcement = null;
    await _serverSub?.cancel();
    _serverSub = null;
    _host?.dispose();
    _host = null;
    _client?.dispose();
    _client = null;
    final server = _server;
    _server = null;
    _info = null;
    await server?.close();
  }
}
