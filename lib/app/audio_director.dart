import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/audio/audio_service.dart';
import '../games/registry.dart';
import '../ui_kit/components/ui_feedback.dart';
import 'providers.dart';

/// The music for a route (spec 7.2): a game and its results play the game's
/// own track, everything else (setup included) the menu music.
String musicForLocation(String path) {
  final match = RegExp(r'^/play/([^/]+)(/results)?$').firstMatch(path);
  return (match == null ? null : moduleById(match.group(1)!)?.musicTrack) ?? 'menu';
}

/// Connects the [AudioService] to the app: settings, the current route's
/// music, the app going to the background, and ui_kit click sounds.
class AudioDirector extends ConsumerStatefulWidget {
  const AudioDirector({super.key, required this.router, required this.child});

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AudioDirector> createState() => _AudioDirectorState();
}

class _AudioDirectorState extends ConsumerState<AudioDirector> with WidgetsBindingObserver {
  bool _settingsLoaded = false;

  AudioService get _audio => ref.read(audioServiceProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.router.routerDelegate.addListener(_onRoute);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRoute);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _audio.onLifecycle(state);

  void _onRoute() {
    // No music until the settings are known: switched-off music must not
    // sound even for a moment at start.
    if (!_settingsLoaded) return;
    // The top-most route, pushed ones included.
    _audio.playMusic(musicForLocation(widget.router.state.uri.path));
  }

  @override
  Widget build(BuildContext context) {
    final musicOn = ref.watch(musicOnProvider);
    final musicVolume = ref.watch(musicVolumeProvider);
    final sfxOn = ref.watch(sfxOnProvider);
    final sfxVolume = ref.watch(sfxVolumeProvider);
    if (musicOn.hasValue && musicVolume.hasValue && sfxOn.hasValue && sfxVolume.hasValue) {
      _audio.applySettings(
        AudioSettings(
          musicOn: musicOn.requireValue,
          musicVolume: musicVolume.requireValue,
          sfxOn: sfxOn.requireValue,
          sfxVolume: sfxVolume.requireValue,
        ),
      );
      if (!_settingsLoaded) {
        _settingsLoaded = true;
        _onRoute();
      }
    }
    return UiFeedback(onSound: (sound) => _audio.playSfx(sound.name), child: widget.child);
  }
}
