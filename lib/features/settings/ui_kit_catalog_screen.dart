import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/avatar/avatar_spec.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/avatar/robot_avatar.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/color_swatch_picker.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/player_slot.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/segmented_control.dart';
import '../../ui_kit/components/tag_pill.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Developer catalog of all UI-kit components (debug builds only). Its texts
/// are deliberately not localized: it is a tool, never shown to players.
class UiKitCatalogScreen extends StatefulWidget {
  const UiKitCatalogScreen({super.key});

  @override
  State<UiKitCatalogScreen> createState() => _UiKitCatalogScreenState();
}

class _UiKitCatalogScreenState extends State<UiKitCatalogScreen> {
  int _segment = 4;
  int _swatch = 0;
  final _avatars = [for (var i = 0; i < 4; i++) AvatarSpec.random(Random(i))];

  Widget _section(String title, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.h2(color: AppColors.paper)),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(children: [
                RoundIconButton(icon: Icons.arrow_back, tooltip: 'Back', onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 8),
                Text('UI kit', style: AppTypography.h1(color: AppColors.paper)),
              ]),
              const SizedBox(height: 16),
              _section(
                'Avatars 28 / 40 / 64 / 160',
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    for (final size in [28.0, 40.0, 64.0, 160.0])
                      AvatarView(spec: _avatars[0], size: size, ringColor: AppColors.players[0]),
                  ],
                ),
              ),
              _section(
                'Robots',
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final color in AppColors.players) RobotAvatar(color: color, size: 40),
                  RobotAvatar(color: AppColors.players[2], size: 64),
                ]),
              ),
              _section(
                'Buttons',
                Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  PrimaryButton(label: 'Play', icon: Icons.play_arrow, onPressed: () {}),
                  const PrimaryButton(label: 'Disabled', onPressed: null),
                  RoundIconButton(icon: Icons.volume_up, tooltip: 'Sound', onPressed: () {}),
                  RoundIconButton(icon: Icons.pause, tooltip: 'Pause', onPressed: () {}),
                ]),
              ),
              _section(
                'Segmented control',
                SegmentedControl<int>(
                  segments: const [(1, '1'), (2, '2'), (3, '3'), (4, '4')],
                  selected: _segment,
                  onChanged: (v) => setState(() => _segment = v),
                ),
              ),
              _section(
                'Swatches',
                ColorSwatchPicker(
                  colors: AppColors.players,
                  selected: _swatch,
                  onSelected: (i) => setState(() => _swatch = i),
                  semanticLabels: const ['1', '2', '3', '4'],
                ),
              ),
              _section(
                'Card, tags, slots',
                PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Wrap(spacing: 6, children: [TagPill(label: 'Soon'), TagPill(label: 'Human')]),
                      const SizedBox(height: 12),
                      for (var seat = 0; seat < 4; seat++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: PlayerSlot(
                            seat: seat,
                            avatar: seat < 2
                                ? AvatarView(spec: _avatars[seat], size: 40)
                                : RobotAvatar(color: AppColors.players[seat], size: 40),
                            name: seat < 2 ? 'Player ${seat + 1}' : 'Robot ${seat + 1}',
                            tag: seat < 2 ? 'Human' : 'Robot',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _section(
                'Dialog and toast',
                Wrap(spacing: 12, runSpacing: 12, children: [
                  PrimaryButton(
                    label: 'Dialog',
                    onPressed: () => showAppConfirmDialog(
                      context,
                      title: 'Delete player?',
                      message: 'This cannot be undone.',
                      confirmLabel: 'Delete',
                      cancelLabel: 'Cancel',
                    ),
                  ),
                  PrimaryButton(label: 'Toast', onPressed: () => showAppToast(context, 'Saved')),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
