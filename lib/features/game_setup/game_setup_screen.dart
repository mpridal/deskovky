import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/game/difficulty.dart';
import '../../core/game/game_config.dart';
import '../../core/game/game_module.dart';
import '../../core/game/game_option.dart';
import '../../core/players/player_profile.dart';
import '../../games/game_texts.dart';
import '../../games/registry.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/choice_pills.dart';
import '../../ui_kit/components/player_slot.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/segmented_control.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../game_play/seat_identity.dart';
import 'profile_picker_sheet.dart';
import 'seat_editor.dart';

/// Setup before a game (spec 5.7, mockup "Nastavení hry před startem"):
/// seats with people and robots, difficulty, speed and the game's options,
/// pre-filled from the last game.
class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key, required this.gameId, this.initialConfig});

  final String gameId;

  /// Given when coming back from results ("Změnit nastavení").
  final GameConfig? initialConfig;

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  late final GameModule<Object?>? _module = moduleById(widget.gameId);
  GameConfig? _config;
  bool _loadedFromLast = false;
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final module = _module;
    if (module == null) return;
    final profiles = await ref.read(playerRepositoryProvider).all();
    final active = await ref.read(activePlayerProvider.future);
    final remembered = widget.initialConfig ?? await ref.read(gameStoreProvider).lastConfig(module.id);
    if (!mounted || active == null) {
      setState(() {});
      return;
    }
    var config =
        remembered ??
        GameConfig(
          gameId: module.id,
          seats: SeatEditor.defaults(minPlayers: module.minPlayers, maxPlayers: module.maxPlayers, activeId: active.id),
          difficulty: Difficulty.medium,
          robotSpeed: RobotSpeed.normal,
          options: const {},
        );
    final (seats, changed) = SeatEditor.sanitize(
      SeatEditor.resize(config.seats, config.seats.length.clamp(module.minPlayers, module.maxPlayers)),
      existing: {for (final p in profiles) p.id},
      activeId: active.id,
    );
    config = config.copyWith(seats: seats, options: normalizeOptions(module.options, config.options));
    setState(() {
      _config = config;
      _loadedFromLast = remembered != null && widget.initialConfig == null;
      _filled = changed;
    });
  }

  void _update(GameConfig config) => setState(() => _config = config);

  Future<void> _tapSeat(int index, List<PlayerProfile> profiles) async {
    final config = _config!;
    final l10n = AppLocalizations.of(context);
    final seated = config.seats.whereType<HumanSeat>().map((s) => s.profileId).toSet();
    final free = profiles.where((p) => !seated.contains(p.id)).toList();
    final seat = config.seats[index];
    final canBeRobot = seat is HumanSeat && config.humans > 1;
    if (seat is RobotSeat && free.isEmpty) {
      showAppToast(context, l10n.setupNoFreeProfile);
      return;
    }
    if (seat is HumanSeat && free.isEmpty && !canBeRobot) return;
    final picked = await showProfilePicker(
      context,
      free: free,
      offerRobot: canBeRobot,
      robotColor: AppColors.players[index],
    );
    if (picked == null || !mounted) return;
    final seats = [...config.seats];
    seats[index] = picked == robotChoice ? const RobotSeat() : HumanSeat(picked);
    _update(config.copyWith(seats: seats));
  }

  Future<void> _play() async {
    final config = _config!;
    final store = ref.read(gameStoreProvider);
    await store.saveLastConfig(config);
    await store.deleteSession(config.gameId);
    if (mounted) context.pushReplacement('/play/${config.gameId}', extra: config);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final module = _module;
    final config = _config;
    final profiles = ref.watch(playersProvider).value ?? const <PlayerProfile>[];

    final title = Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.arrow_back,
            tooltip: l10n.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              module == null ? '' : gameText(l10n, module.titleKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h2(color: AppColors.paper),
            ),
          ),
        ],
      ),
    );

    Widget body;
    if (module == null) {
      body = const SizedBox.shrink();
    } else if (config == null) {
      body = ref.watch(activePlayerProvider).value == null && ref.watch(activePlayerProvider).hasValue
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.setupNeedPlayer, style: AppTypography.body(color: AppColors.paper)),
            )
          : const SizedBox.shrink();
    } else {
      body = _form(l10n, module, config, profiles);
    }

    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: Column(
            children: [
              title,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
    child: Text(text, style: AppTypography.caption(color: AppColors.woodLight)),
  );

  Widget _form(AppLocalizations l10n, GameModule<Object?> module, GameConfig config, List<PlayerProfile> profiles) {
    final identities = SeatIdentity.forConfig(config, profiles, l10n);
    final seatsTitle = config.robots == 0
        ? '${l10n.navPlayers} · ${l10n.seatsHumans(config.humans)}'
        : '${l10n.navPlayers} · ${l10n.seatsHumans(config.humans)} + ${l10n.seatsRobots(config.robots)}';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (module.minPlayers != module.maxPlayers) ...[
                _label(l10n.setupPlayers),
                SegmentedControl<int>(
                  segments: [for (var n = module.minPlayers; n <= module.maxPlayers; n++) (n, '$n')],
                  selected: config.seats.length,
                  onChanged: (n) => _update(config.copyWith(seats: SeatEditor.resize(config.seats, n))),
                ),
              ],
              _label(seatsTitle),
              for (final id in identities)
                Padding(
                  key: ValueKey('seat${id.seat}'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Semantics(
                    button: true,
                    child: GestureDetector(
                      onTap: () => _tapSeat(id.seat, profiles),
                      child: PlayerSlot(
                        seat: id.seat,
                        avatar: id.avatar(40),
                        name: id.name,
                        tag: id.isRobot ? l10n.seatRobot : l10n.seatHuman,
                        detail: id.isRobot ? DifficultyDots(difficulty: config.difficulty) : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RoundIconButton(
                              icon: Icons.arrow_upward,
                              tooltip: l10n.seatMoveUp,
                              size: 44,
                              onPressed: id.seat == 0
                                  ? null
                                  : () => _update(
                                      config.copyWith(seats: SeatEditor.move(config.seats, id.seat, id.seat - 1)),
                                    ),
                            ),
                            RoundIconButton(
                              icon: Icons.arrow_downward,
                              tooltip: l10n.seatMoveDown,
                              size: 44,
                              onPressed: id.seat == config.seats.length - 1
                                  ? null
                                  : () => _update(
                                      config.copyWith(seats: SeatEditor.move(config.seats, id.seat, id.seat + 1)),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (config.robots > 0 && module.supportsAi) ...[
                _label(l10n.setupDifficulty),
                SegmentedControl<Difficulty>(
                  segments: [for (final d in module.difficulties) (d, difficultyLabel(l10n, d))],
                  selected: config.difficulty,
                  onChanged: (d) => _update(config.copyWith(difficulty: d)),
                ),
                _label(l10n.setupSpeed),
                SegmentedControl<RobotSpeed>(
                  segments: [
                    (RobotSpeed.slow, l10n.speedSlow),
                    (RobotSpeed.normal, l10n.speedNormal),
                    (RobotSpeed.fast, l10n.speedFast),
                  ],
                  selected: config.robotSpeed,
                  onChanged: (s) => _update(config.copyWith(robotSpeed: s)),
                ),
              ],
              for (final option in module.options) ..._optionEditor(l10n, option, config),
              if (_loadedFromLast)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _filled ? '${l10n.setupLoaded} · ${l10n.setupFilled}' : l10n.setupLoaded,
                    style: AppTypography.caption(color: AppColors.woodLight),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: PrimaryButton(label: l10n.setupPlay, onPressed: SeatEditor.isValid(config.seats) ? _play : null),
        ),
      ],
    );
  }

  List<Widget> _optionEditor(AppLocalizations l10n, GameOption option, GameConfig config) {
    void set(Object value) => _update(config.copyWith(options: {...config.options, option.id: value}));
    return switch (option) {
      ChoiceOption(:final choices) => [
        _label(gameText(l10n, option.labelKey)),
        ChoicePills<Object>(
          choices: [for (final (value, label) in choices) (value, gameText(l10n, label))],
          selected: config.options[option.id] ?? option.defaultValue,
          onChanged: set,
        ),
      ],
      ToggleOption() => [
        SwitchListTile(
          value: config.options[option.id] == true,
          onChanged: set,
          title: Text(gameText(l10n, option.labelKey), style: AppTypography.body(color: AppColors.paper)),
        ),
      ],
    };
  }
}
