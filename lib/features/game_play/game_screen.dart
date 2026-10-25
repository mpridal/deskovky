import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_session.dart';
import '../../core/game/move.dart';
import '../../core/game/move_transport.dart';
import '../../core/players/player_profile.dart';
import '../../games/game_texts.dart';
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
import 'game_outcome.dart';
import 'player_chip.dart';
import 'seat_identity.dart';
import 'turn_controller.dart';

/// Runs one game (spec 5.8): starts it from a [GameConfig] or resumes a
/// [SavedGame], then hands over to the typed play widget.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.gameId, required this.start});

  final String gameId;

  /// A [GameConfig] (new game) or a [SavedGame] (resume).
  final Object? start;

  @override
  ConsumerState<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends ConsumerState<GameScreen> {
  late final GameModule<Object?>? _module = moduleById(widget.gameId);
  GameSession<Object?>? _session;
  List<PlayerProfile> _profiles = const [];

  @visibleForTesting
  GameSession<Object?>? get debugSession => _session;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final module = _module;
    if (module == null) return;
    final store = ref.read(gameStoreProvider);
    final profiles = await ref.read(playerRepositoryProvider).all();
    final ids = {for (final p in profiles) p.id};
    final start = widget.start;
    GameSession<Object?>? session;
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
    return module.withType(<T>(m) => _GamePlay<T>(module: m, session: session as GameSession<T>, profiles: _profiles));
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
  const _GamePlay({super.key, required this.module, required this.session, required this.profiles});

  final GameModule<S> module;
  final GameSession<S> session;
  final List<PlayerProfile> profiles;

  @override
  ConsumerState<_GamePlay<S>> createState() => _GamePlayState<S>();
}

class _GamePlayState<S> extends ConsumerState<_GamePlay<S>> with WidgetsBindingObserver {
  late final TurnController<S> _turns;
  late final _host = _Host(
    vibrationOn: () => ref.read(vibrationOnProvider).value ?? true,
    sfx: (id) => ref.read(audioServiceProvider).playSfx(id),
  );
  int? _lastSeat;
  Timer? _finishTimer;
  bool _finished = false;
  bool _pauseOpen = false;

  GameModule<S> get _module => widget.module;
  GameSession<S> get _session => widget.session;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _turns = TurnController<S>(
      session: _session,
      transport: LocalTransport<S>(_session),
      ai: _module.ai,
      runner: ref.read(aiRunnerProvider),
      robotDelay: _session.config.robotSpeed.delay,
    )..addListener(_onTurn);
    _lastSeat = _turns.currentSeat;
    _turns.start();
    _checkFinished();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _finishTimer?.cancel();
    _turns
      ..removeListener(_onTurn)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) _save();
  }

  void _onTurn() {
    final seat = _turns.currentSeat;
    if (seat != null && _lastSeat != null && seat != _lastSeat && !_turns.isOver) _host.playSfx('turn');
    _lastSeat = seat;
    setState(() {});
    _save();
    _checkFinished();
  }

  void _save() {
    if (_finished || !_module.supportsSaveResume || _turns.isOver) return;
    ref.read(gameStoreProvider).saveSession(_session.toSave());
  }

  void _checkFinished() {
    if (_finished || !_turns.isOver) return;
    _finished = true;
    ref.read(gameStoreProvider).deleteSession(_module.id);
    final outcome = GameOutcomeView(
      config: _session.config,
      result: _session.rules.result(_session.state),
      seats: SeatIdentity.forConfig(_session.config, widget.profiles, AppLocalizations.of(context)),
    );
    _finishTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) context.pushReplacement('/play/${_module.id}/results', extra: outcome);
    });
  }

  Future<void> _confirmExit() async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final store = ref.read(gameStoreProvider);
    // Robots must not play (or even finish the game) under the dialog.
    final wasPaused = _turns.paused;
    _turns.pause();
    final quit = await showAppConfirmDialog(
      context,
      title: l10n.exitTitle,
      message: _module.supportsSaveResume ? l10n.exitSaved : l10n.exitNotSaved,
      confirmLabel: l10n.exitConfirm,
      cancelLabel: l10n.cancel,
    );
    if (!quit) {
      if (!wasPaused && mounted) _turns.resume();
      return;
    }
    if (_module.supportsSaveResume && !_turns.isOver) {
      await store.saveSession(_session.toSave());
    } else {
      await store.deleteSession(_module.id);
    }
    _finished = true;
    router.go('/games');
  }

  Future<void> _openPause() async {
    if (_pauseOpen) return;
    _pauseOpen = true;
    _turns.pause();
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
        await _confirmExit();
      default:
        _turns.resume();
    }
  }

  Future<void> _showRules() {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.pauseRules, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(gameText(l10n, _module.rulesKey), style: AppTypography.body(color: AppColors.ink)),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: l10n.close, onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final seats = SeatIdentity.forConfig(_session.config, widget.profiles, l10n);
    final current = _turns.currentSeat;
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final musicOn = ref.watch(musicOnProvider).value ?? true;
    final sfxOn = ref.watch(sfxOnProvider).value ?? true;
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
    );

    String? bubble;
    if (current != null) {
      final who = seats[current];
      bubble = who.isRobot
          ? l10n.robotThinking(who.name)
          : (_module.turnHint(context, _session.state, who.name) ?? l10n.turnOf(who.name));
    }

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
                Expanded(
                  child: Padding(padding: const EdgeInsets.all(16), child: _module.board(context, view)),
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
