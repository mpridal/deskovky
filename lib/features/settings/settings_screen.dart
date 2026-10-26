import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/choice_pills.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'parents_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final chosen = ref.watch(localeSettingProvider).value?.languageCode;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.navSettings, style: AppTypography.h1(color: AppColors.paper)),
          const SizedBox(height: 24),
          Text(l10n.settingsLanguage, style: AppTypography.h2(color: AppColors.paper)),
          const SizedBox(height: 8),
          ChoicePills<String?>(
            // Language names stay in their own language, so they are not in the ARB files.
            choices: [
              (null, l10n.settingsLanguageSystem),
              ('cs', 'Čeština'),
              ('en', 'English'),
              ('es', 'Español'),
            ],
            selected: chosen,
            onChanged: (code) => ref.read(settingsRepositoryProvider).setLocale(code == null ? null : Locale(code)),
          ),
          const SizedBox(height: 24),
          const _SoundSection(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              key: const ValueKey('creditsLink'),
              label: l10n.settingsCredits,
              icon: Icons.info_outline,
              secondary: true,
              onPressed: () => context.push('/settings/credits'),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: PrimaryButton(
              key: const ValueKey('parentsLink'),
              label: l10n.settingsParents,
              icon: Icons.family_restroom,
              secondary: true,
              onPressed: () async {
                if (await showParentsGate(context) && context.mounted) await context.push('/settings/parents');
              },
            ),
          ),
          // Visual check of bundled fonts with diacritics (milestone 1).
          const SizedBox(height: 32),
          Text(l10n.fontSample, style: AppTypography.h2(color: AppColors.paper)),
          const SizedBox(height: 8),
          Text(l10n.fontSample, style: AppTypography.body(color: AppColors.paper)),
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            // Developer tool, debug builds only – not localized on purpose.
            Align(
              alignment: Alignment.centerLeft,
              child: PrimaryButton(label: 'UI kit', onPressed: () => context.push('/settings/ui-kit')),
            ),
          ],
        ],
      ),
    );
  }
}

/// Music and effects with their volumes, and vibration (spec 5.10, 7.1).
class _SoundSection extends ConsumerWidget {
  const _SoundSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.read(settingsRepositoryProvider);
    final musicOn = ref.watch(musicOnProvider).value ?? true;
    final sfxOn = ref.watch(sfxOnProvider).value ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.settingsSound, style: AppTypography.h2(color: AppColors.paper)),
        _SwitchRow(keyName: 'musicOn', label: l10n.settingsMusic, value: musicOn, onChanged: settings.setMusicOn),
        _VolumeSlider(
          keyName: 'musicVolume',
          label: l10n.settingsMusicVolume,
          value: ref.watch(musicVolumeProvider).value ?? 0.7,
          enabled: musicOn,
          onChanged: settings.setMusicVolume,
        ),
        _SwitchRow(keyName: 'sfxOn', label: l10n.settingsSfx, value: sfxOn, onChanged: settings.setSfxOn),
        _VolumeSlider(
          keyName: 'sfxVolume',
          label: l10n.settingsSfxVolume,
          value: ref.watch(sfxVolumeProvider).value ?? 0.9,
          enabled: sfxOn,
          onChanged: settings.setSfxVolume,
        ),
        _SwitchRow(
          keyName: 'vibrationOn',
          label: l10n.settingsVibration,
          value: ref.watch(vibrationOnProvider).value ?? true,
          onChanged: settings.setVibrationOn,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.keyName, required this.label, required this.value, required this.onChanged});

  final String keyName;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.body(color: AppColors.paper))),
          Switch(
            key: ValueKey(keyName),
            value: value,
            activeTrackColor: AppColors.gold,
            onChanged: (on) {
              UiFeedback.play(context, UiSound.toggle);
              onChanged(on);
            },
          ),
        ],
      ),
    );
  }
}

/// Shows the dragged value at once and stores it when the drag ends.
class _VolumeSlider extends StatefulWidget {
  const _VolumeSlider({
    required this.keyName,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String keyName;
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  State<_VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<_VolumeSlider> {
  double? _dragged;

  @override
  void didUpdateWidget(_VolumeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == _dragged) _dragged = null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.label,
      child: Slider(
        key: ValueKey(widget.keyName),
        value: _dragged ?? widget.value,
        activeColor: AppColors.gold,
        onChanged: widget.enabled ? (v) => setState(() => _dragged = v) : null,
        onChangeEnd: widget.onChanged,
      ),
    );
  }
}
