import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/multiplayer_providers.dart';
import '../../app/providers.dart';
import '../../app/stats_service.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_session.dart';
import '../../core/game/move.dart';
import '../../core/game/move_transport.dart';
import '../../core/multiplayer/client_room.dart';
import '../../core/multiplayer/host_room.dart';
import '../../core/multiplayer/network_rooms.dart';
import '../../core/players/player_profile.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../game_setup/seat_editor.dart';
import '../multiplayer/room_widgets.dart';
import 'game_orientation.dart';
import 'game_outcome.dart';
import 'player_chip.dart';
import 'rules_dialog.dart';
import 'seat_identity.dart';
import 'turn_controller.dart';

/// Opens the network game of the room this device is in (spec 14).
class NetworkStart {
  const NetworkStart();
}

/// Runs one game (spec 5.8): starts it from a [GameConfig], resumes a
/// [SavedGame] or plays the network room's game, then hands over to the
/// typed play widget.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.gameId, required this.start});

  final String gameId;

  /// A [GameConfig] (new game), a [SavedGame] (resume) or [NetworkStart].
  final Object? start;

  @override
  ConsumerState<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends ConsumerState<GameScreen> {
  late final GameModule<Object?>? _module = moduleById(widget.gameId);
  GameSession<Object?>? _session;
  List<PlayerProfile> _profiles = const [];

  /// People who already finished this game (for the first-game hint).
  Set<int> _played = const {};

  /// The network room, in a network game.
  NetworkRooms? _network;

  @visibleForTesting
  GameSession<Object?>? get debugSession => _session;

  final _play = GlobalKey();

  /// Playing time so far, without pauses (for tests).
  @visibleForTesting
  Duration get debugElapsed => (_play.currentState as _Timed?)?.elapsed ?? Duration.zero;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  var _oriented = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final module = _module;
    if (_oriented || module == null) return;
    _oriented = true;
    final lock = orientationsFor(module, MediaQuery.sizeOf(context));
    if (lock.isNotEmpty) SystemChrome.setPreferredOrientations(lock);
  }

  @override
  void dispose() {
    // Free the device again for the rest of the app.
    if (_oriented) SystemChrome.setPreferredOrientations(const []);
    super.dispose();
  }

  Future<void> _prepare() async {
    final module = _module;
    if (module == null) return;
    final store = ref.read(gameStoreProvider);
    final profiles = await ref.read(playerRepositoryProvider).all();
    final played = {
      for (final m in await ref.read(statsRepositoryProvider).allMatches())
        if (m.gameId == widget.gameId)
          for (final p in m.participants) ?p.playerId,
    };
    final ids = {for (final p in profiles) p.id};
    final start = widget.start;
    GameSession<Object?>? session;
    if (start is NetworkStart) {
      final rooms = ref.read(networkRoomsProvider);
      session = rooms.host?.session ?? rooms.client?.session;
      if (session == null) {
        if (mounted) context.go('/games');
        return;
      }
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _played = played;
        _session = session;
        _network = rooms;
      });
      return;
    }
    if (start is SavedGame) {
      final seatCount = start.config.seats.length;
      final fits = seatCount >= module.minPlayers && seatCount <= module.maxPlayers;
      final allPresent = start.config.seats.whereType<HumanSeat>().every((s) => ids.contains(s.profileId));
      session = fits && allPresent ? module.withType(<T>(m) => GameSession.restore<T>(m.rules, start)) : null;
      if (session == null) {
        await store.deleteSession(module.id);
        if (!mounted) return;
        showAppToast(context, AppLocalizations.of(context).resumeFailed);
        context.pushReplacement('/play/${module.id}/setup');
        return;
      }
    } else {
      final config = start is GameConfig ? start : await store.lastConfig(module.id);
      if (config == null) {
        if (mounted) context.pushReplacement('/play/${module.id}/setup');
        return;
      }
      final active = await ref.read(activePlayerProvider.future);
      final resized = SeatEditor.resize(config.seats, config.seats.length.clamp(module.minPlayers, module.maxPlayers));
      final (seats, changed) = SeatEditor.sanitize(resized, existing: ids, activeId: active?.id);
      // Spec 5.7: at least one person plays – otherwise go and pick players.
      if (!seats.any((s) => s is HumanSeat)) {
        if (mounted) context.pushReplacement('/play/${module.id}/setup');
        return;
      }
      if (changed && mounted) showAppToast(context, AppLocalizations.of(context).seatReplacedByRobot);
      final seed = Random().nextInt(1 << 31);
      session = module.withType(<T>(m) => GameSession<T>.start(m.rules, config.copyWith(seats: seats), seed));
    }
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _played = played;
      _session = session;
    });
  }

  @override
  Widget build(BuildContext context) {
    final module = _module;
    final session = _session;
    if (module == null || session == null) {
      return const Scaffold(body: FeltBackground(child: SizedBox.expand()));
    }
    return module.withType(
      <T>(m) => _GamePlay<T>(
        key: _play,
        module: m,
        session: session as GameSession<T>,
        profiles: _profiles,
        played: _played,
        network: _network,
      ),
    );
  }
}

class _Host implements GameHost {
  _Host({required this.vibrationOn, required this.sfx});

  final bool Function() vibrationOn;
  final void Function(String id) sfx;
  final events = <(String, Map<String, Object?>)>[];

  @override
  void haptic() {
    if (vibrationOn()) HapticFeedback.selectionClick();
  }

  @override
  void playSfx(String id) => sfx(id);

  @override
  void reportEvent(String id, [Map<String, Object?> data = const {}]) => events.add((id, data));
}

class _GamePlay<S> extends ConsumerStatefulWidget {
  const _GamePlay({
    super.key,
    required this.module,
    required this.session,
    required this.profiles,
    this.played = const {},
    this.network,
  });

  final GameModule<S> module;
  final GameSession<S> session;
  final List<PlayerProfile> profiles;
  final Set<int> played;
  final NetworkRooms? network;

  @override
  ConsumerState<_GamePlay<S>> createState() => _GamePlayState<S>();
}

abstract interface class _Timed {
  Duration get elapsed;
}

class _GamePlayState<S> extends ConsumerState<_GamePlay<S>> with WidgetsBindingObserver implements _Timed {
  late final TurnController<S> _turns;
  late final _host = _Host(
    vibrationOn: () => ref.read(vibrationOnProvider).value ?? true,
    sfx: (id) => ref.read(audioServiceProvider).playSfx(id),
  );
  int? _lastSeat;

  /// Playing time without pauses and background (spec 5.4 "délka").
  final _clock = Stopwatch();

  /// Playing time including the time before a resume (spec 13.4).
  Duration get _elapsed => _session.elapsedBefore + _clock.elapsed;

  @override
  Duration get elapsed => _elapsed;

  Timer? _finishTimer;
  bool _finished = false;
  bool _pauseOpen = false;

  /// The host's turns belong to its room; this screen only watches them.
  bool _ownsTurns = true;
  bool _deciding = false;
  bool _movedOn = false;

  GameModule<S> get _module => widget.module;
  GameSession<S> get _session => widget.session;
  HostRoom? get _hostRoom => widget.network?.host;
  ClientRoom? get _clientRoom => widget.network?.client;
  bool get _isNet => widget.network != null;

  /// This device's view of the seats: its own people are humans, the
  /// others' people are remote (spec 14.5).
  GameConfig get _config => _hostRoom?.deviceConfig ?? _clientRoom?.deviceConfig ?? _session.config;

  bool _isLocalSeat(int seat) => _config.seats[seat] is HumanSeat;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final host = _hostRoom, client = _clientRoom;
    if (host?.controller case final controller?) {
      _turns = controller as TurnController<S>;
      _ownsTurns = false;
    } else if (client?.transport case final transport? when client != null) {
      _turns = TurnController<S>(
        session: _session,
        transport: transport,
        ai: null,
        runner: ref.read(aiRunnerProvider),
        robotDelay: _session.config.robotSpeed.delay,
        localSeats: client.mySeats,
      );
    } else {
      _turns = TurnController<S>(
        session: _session,
        transport: LocalTransport<S>(_session),
        ai: _module.ai,
        runner: ref.read(aiRunnerProvider),
        robotDelay: _session.config.robotSpeed.delay,
      );
    }
    _turns.addListener(_onTurn);
    (host ?? client)?.addListener(_onRoom);
    _lastSeat = _turns.currentSeat;
    _clock.start();
    if (_ownsTurns) _turns.start();
    _checkFinished();
    if (client != null) _onRoom();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finishTimer?.cancel();
    (_hostRoom ?? _clientRoom)?.removeListener(_onRoom);
    _turns.removeListener(_onTurn);
    if (_ownsTurns) _turns.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _clock.stop();
      _save();
      // The host in the background (a phone call) pauses everyone (spec 14.4).
      _hostRoom?.pause();
    } else if (state == AppLifecycleState.resumed && !_turns.paused) {
      _clock.start();
    }
  }

  /// The room changed: a pause, a dropout, a new game or the end of the line.
  void _onRoom() {
    if (!mounted || _movedOn) return;
    final host = _hostRoom, client = _clientRoom;
    final roomSession = host?.session ?? client?.session;
    if (roomSession != null && !identical(roomSession, _session)) {
      // A rematch or a comeback: a fresh screen for the new game.
      _movedOn = true;
      context.pushReplacement('/play/${_module.id}/net');
      return;
    }
    if (client != null && client.closedReason == null) {
      if (client.paused && !_turns.paused) {
        _turns.pause();
      } else if (!client.paused && _turns.paused) {
        _turns.resume();
      }
    }
    final stopped = _turns.paused || client?.closedReason != null || (host?.ended ?? false);
    if (stopped) {
      _clock.stop();
    } else if (!_finished) {
      _clock.start();
    }
    if (host != null && host.needsDecision && !_deciding) _decide(host);
    setState(() {});
  }

  /// The wait for a dropped device ran out (spec 14.4).
  Future<void> _decide(HostRoom host) async {
    _deciding = true;
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.netDecideTitle, textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 16),
              PrimaryButton(label: l10n.netReplaceRobot, onPressed: () => Navigator.of(context).pop('robot')),
              const SizedBox(height: 8),
              for (final (id, label) in [('wait', l10n.netWaitMore), ('end', l10n.netEndGame)])
                TextButton(
                  onPressed: () => Navigator.of(context).pop(id),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: Text(label, style: AppTypography.button(color: AppColors.ink)),
                ),
            ],
          ),
        ),
      ),
    );
    _deciding = false;
    if (!mounted) return;
    switch (choice) {
      case 'robot':
        host.replaceWithRobot();
      case 'end':
        await _endNetwork();
      default:
        host.waitLonger();
    }
  }

  /// The host ends the game for everyone; a client leaves alone.
  Future<void> _endNetwork() async {
    final router = GoRouter.of(context);
    _finished = true;
    final host = _hostRoom, client = _clientRoom;
    if (host != null) {
      host.endGame();
    } else if (client != null && client.closedReason == null) {
      client.leave();
    }
    await widget.network?.leave();
    router.go('/games');
  }

  /// Back to the same room with this device's token (spec 14.4); the room
  /// screen opens the game again once the host sends it.
  Future<void> _reconnect() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    try {
      if (await widget.network?.rejoin() == null) return;
      _movedOn = true;
      router.pushReplacement('/join/lobby');
    } on Object {
      if (mounted) showAppToast(context, l10n.joinFailed);
    }
  }

  void _netPause() {
    final seat = _turns.humanSeatToAct ?? [for (var s = 0; s < _config.seats.length; s++) if (_isLocalSeat(s)) s].firstOrNull;
    final host = _hostRoom;
    if (host != null) {
      host.pause(bySeat: seat);
    } else {
      _clientRoom?.requestPause();
    }
  }

  void _netResume() {
    final host = _hostRoom;
    if (host != null) {
      host.resume();
    } else {
      _clientRoom?.requestResume();
    }
  }

  void _onTurn() {
    final seat = _turns.currentSeat;
    if (seat != null && _lastSeat != null && seat != _lastSeat && !_turns.isOver) {
      if (!_isNet) {
        _host.playSfx('turn');
      } else if (_isLocalSeat(seat)) {
        // Only the device whose turn it is rings and buzzes (spec 14.2 step 7).
        _host.playSfx('turn');
        if (ref.read(vibrationOnProvider).value ?? true) HapticFeedback.mediumImpact();
      }
    }
    _lastSeat = seat;
    setState(() {});
    _save();
    _checkFinished();
  }

  void _save() {
    // A network game lives in its room, not in this device's store.
    if (_isNet || _finished || !_module.supportsSaveResume || _turns.isOver) return;
    ref.read(gameStoreProvider).saveSession(_session.toSave(elapsed: _elapsed));
  }

  void _checkFinished() {
    if (_finished || !_turns.isOver) return;
    _finished = true;
    if (!_isNet) ref.read(gameStoreProvider).deleteSession(_module.id);
    // Each device records only its own people; the others are guests (14.5).
    final outcome = GameOutcomeView(
      config: _config,
      result: _session.rules.result(_session.state),
      seats: SeatIdentity.forConfig(_config, widget.profiles, AppLocalizations.of(context)),
      network: _isNet,
    );
    _clock.stop();
    final recording = ref
        .read(statsServiceProvider)
        .recordFinished(
          config: _config,
          result: outcome.result,
          events: List.of(_host.events),
          duration: _elapsed,
        )
        .catchError((Object e) {
          // Statistics must never keep the results away.
          debugPrint('GameScreen: cannot record the game: $e');
          return MatchRewards.none;
        });
    _finishTimer = Timer(const Duration(milliseconds: 600), () async {
      final rewards = await recording;
      if (mounted) context.pushReplacement('/play/${_module.id}/results', extra: outcome.withRewards(rewards));
    });
  }

  /// Asks before leaving; true when the player left.
  Future<bool> _confirmExit() async {
    final l10n = AppLocalizations.of(context);
    if (_isNet) {
      final host = _hostRoom != null;
      final quit = await showAppConfirmDialog(
        context,
        title: host ? l10n.netEndGame : l10n.netLeave,
        message: l10n.exitNotSaved,
        confirmLabel: host ? l10n.netEndGame : l10n.netLeave,
        cancelLabel: l10n.cancel,
      );
      if (quit && mounted) await _endNetwork();
      return quit;
    }
    final router = GoRouter.of(context);
    final store = ref.read(gameStoreProvider);
    // Robots must not play (or even finish the game) under the dialog.
    final wasPaused = _turns.paused;
    _turns.pause();
    final wasTiming = _clock.isRunning;
    _clock.stop();
    final quit = await showAppConfirmDialog(
      context,
      title: l10n.exitTitle,
      message: _module.supportsSaveResume ? l10n.exitSaved : l10n.exitNotSaved,
      confirmLabel: l10n.exitConfirm,
      cancelLabel: l10n.cancel,
    );
    if (!quit) {
      if (!wasPaused && mounted) _turns.resume();
      if (wasTiming) _clock.start();
      return false;
    }
    if (_module.supportsSaveResume && !_turns.isOver) {
      await store.saveSession(_session.toSave(elapsed: _elapsed));
    } else {
      await store.deleteSession(_module.id);
    }
    _finished = true;
    router.go('/games');
    return true;
  }

  Future<void> _openPause() async {
    if (_isNet) return _netPause();
    if (_pauseOpen) return;
    _pauseOpen = true;
    _turns.pause();
    _clock.stop();
    final l10n = AppLocalizations.of(context);
    final action = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.hudPause,
                textAlign: TextAlign.center,
                style: AppTypography.h1(color: AppColors.ink),
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: l10n.pauseResume, onPressed: () => Navigator.of(context).pop('resume')),
              const SizedBox(height: 8),
              for (final (id, label) in [
                ('restart', l10n.pauseRestart),
                ('rules', l10n.pauseRules),
                ('exit', l10n.hudExit),
              ])
                TextButton(
                  onPressed: () => Navigator.of(context).pop(id),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  child: Text(label, style: AppTypography.button(color: AppColors.ink)),
                ),
            ],
          ),
        ),
      ),
    );
    _pauseOpen = false;
    if (!mounted) return;
    switch (action) {
      case 'restart':
        await ref.read(gameStoreProvider).deleteSession(_module.id);
        _finished = true;
        if (mounted) context.pushReplacement('/play/${_module.id}', extra: _session.config);
      case 'rules':
        await _showRules();
        if (mounted) await _openPause();
      case 'exit':
        // Changed their mind: back to the pause menu, never a frozen game.
        if (!await _confirmExit() && mounted) await _openPause();
      default:
        _turns.resume();
        _clock.start();
    }
  }

  Future<void> _showRules() => showRulesDialog(context, _module);

  /// Dropped devices and their countdown (spec 14.4).
  Widget? _networkNotice(AppLocalizations l10n, List<SeatIdentity> seats) {
    final host = _hostRoom, client = _clientRoom;
    final waiting = host != null
        ? host.waitingFor
        : {
            for (final e in client?.peers?.connected.entries ?? const <MapEntry<int, bool>>[])
              if (!e.value) e.key,
          };
    if (waiting.isEmpty) return null;
    final seconds = host?.waitSeconds ?? client?.peers?.waitSeconds ?? 0;
    final time = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Container(
      width: double.infinity,
      color: const Color(0xCC8B2E24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        [for (final seat in waiting) if (seat < seats.length) l10n.netWaiting(seats[seat].name, time)].join('\n'),
        style: AppTypography.body(color: AppColors.paper),
      ),
    );
  }

  /// The shared pause, or why the line to the host ended.
  Widget? _networkOverlay(AppLocalizations l10n) {
    final host = _hostRoom, client = _clientRoom;
    final closed = client?.closedReason;
    final waitingForSomeone = (host?.waitingFor.isNotEmpty ?? false) ||
        (client?.peers?.connected.values.any((c) => !c) ?? false);
    final Widget card;
    if (closed != null && closed != 'left' && !_finished) {
      card = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(byeText(l10n, closed), textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
          const SizedBox(height: 16),
          if (closed == 'lost') ...[
            PrimaryButton(key: const ValueKey('netReconnect'), label: l10n.netReconnect, icon: Icons.wifi, onPressed: _reconnect),
            const SizedBox(height: 8),
          ],
          PrimaryButton(
            key: const ValueKey('netHome'),
            label: l10n.resultHome,
            secondary: closed == 'lost',
            onPressed: _endNetwork,
          ),
        ],
      );
    } else if (_turns.paused && !waitingForSomeone && !_finished) {
      card = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.hudPause, textAlign: TextAlign.center, style: AppTypography.h1(color: AppColors.ink)),
          const SizedBox(height: 16),
          PrimaryButton(key: const ValueKey('netResume'), label: l10n.pauseResume, onPressed: _netResume),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showRules,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(l10n.pauseRules, style: AppTypography.button(color: AppColors.ink)),
          ),
          TextButton(
            onPressed: _confirmExit,
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              host != null ? l10n.netEndGame : l10n.netLeave,
              style: AppTypography.button(color: AppColors.ink),
            ),
          ),
        ],
      );
    } else {
      return null;
    }
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x99000000),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 360),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(18)),
              child: card,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seats = SeatIdentity.forConfig(_config, widget.profiles, l10n);
    final current = _turns.currentSeat;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final musicOn = ref.watch(musicOnProvider).value ?? true;
    final sfxOn = ref.watch(sfxOnProvider).value ?? true;
    // Watched so the haptic callback reads a loaded value, not the default.
    ref.watch(vibrationOnProvider);
    final settings = ref.read(settingsRepositoryProvider);

    // Phones show compact chips scaled to fit, so all four players stay visible.
    final chips = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in seats)
          Padding(
            key: ValueKey('chip${id.seat}'),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PlayerChip(
              identity: id,
              score: _session.rules.score(_session.state, id.seat),
              active: id.seat == current,
              thinking: id.seat == current && id.isRobot,
              compact: !wide,
            ),
          ),
      ],
    );
    final strip = wide
        ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: chips)
        : FittedBox(fit: BoxFit.scaleDown, child: chips);

    final hud = Container(
      color: const Color(0x40000000),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              RoundIconButton(icon: Icons.close, tooltip: l10n.hudExit, sound: UiSound.back, onPressed: _confirmExit),
              RoundIconButton(icon: Icons.pause, tooltip: l10n.hudPause, onPressed: _openPause),
              Expanded(child: wide ? Center(child: strip) : const SizedBox()),
              RoundIconButton(
                icon: musicOn ? Icons.music_note : Icons.music_off,
                tooltip: l10n.hudMusic,
                onPressed: () => settings.setMusicOn(!musicOn),
              ),
              RoundIconButton(
                icon: sfxOn ? Icons.volume_up : Icons.volume_off,
                tooltip: l10n.hudSfx,
                onPressed: () => settings.setSfxOn(!sfxOn),
              ),
            ],
          ),
          if (!wide) Padding(padding: const EdgeInsets.only(top: 8), child: strip),
        ],
      ),
    );

    final mySeat = _turns.humanSeatToAct;
    final view = GameBoardView<S>(
      state: _session.state,
      lastMove: _session.lastMove,
      mySeat: mySeat,
      canAct: mySeat != null && !_finished,
      submit: (Move move) => _turns.submitHuman(move),
      host: _host,
      elapsed: () => _elapsed,
      firstGame: switch (mySeat == null ? null : _config.seats[mySeat]) {
        HumanSeat(:final profileId) => !widget.played.contains(profileId),
        _ => false,
      },
    );

    String? bubble;
    if (current != null) {
      final who = seats[current];
      if (who.isRobot || _turns.isRobotSeat(current)) {
        bubble = l10n.robotThinking(who.name);
      } else if (_isNet) {
        bubble = who.isRemote ? l10n.netTurnRemote(who.name) : l10n.netYourTurn(who.name);
      } else {
        bubble = _module.turnHint(context, _session.state, who.name) ?? l10n.turnOf(who.name);
      }
    }
    final notice = _isNet ? _networkNotice(l10n, seats) : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _openPause();
      },
      child: Scaffold(
        body: FeltBackground(
          child: SafeArea(
            child: Column(
              children: [
                hud,
                ?notice,
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(padding: const EdgeInsets.all(16), child: _module.board(context, view)),
                      ),
                      if (_isNet) ?_networkOverlay(l10n),
                    ],
                  ),
                ),
                if (bubble != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.paper,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4))],
                      ),
                      child: Text(
                        bubble,
                        textAlign: TextAlign.center,
                        style: AppTypography.button(color: AppColors.ink),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
