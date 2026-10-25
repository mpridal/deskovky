import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/avatar/avatar_spec.dart';
import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/color_swatch_picker.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

enum _Layer { face, skin, hair, eyes, mouth, background }

/// What the editor saves: the profile name (when shown) and the avatar.
@immutable
class AvatarEditResult {
  const AvatarEditResult({required this.name, required this.avatar});

  final String name;
  final AvatarSpec avatar;
}

/// Persists an edit; returns the error to show, or null on success.
typedef AvatarEditSave = Future<ProfileError?> Function(AvatarEditResult result);

/// Avatar editor (spec 5.3, mockup "Editor avatara"), optionally with the
/// profile name. With [onSave] it stays open and shows the returned error;
/// without it, it pops the edited [AvatarSpec] (or [AvatarEditResult] when
/// [showName]) on save. Back pops `null`, asking first when something
/// changed.
class AvatarEditorScreen extends StatefulWidget {
  const AvatarEditorScreen({
    super.key,
    this.initial = AvatarSpec.defaults,
    this.random,
    this.showName = false,
    this.initialName = '',
    this.onSave,
  });

  final AvatarSpec initial;

  /// Source for the "Random" button; injectable for tests.
  final Random? random;

  final bool showName;
  final String initialName;
  final AvatarEditSave? onSave;

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  late AvatarSpec _spec = widget.initial;
  late final Random _random = widget.random ?? Random();
  late final TextEditingController _name = TextEditingController(text: widget.initialName)
    ..addListener(() => setState(() {}));
  _Layer _layer = _Layer.hair;
  ProfileError? _error;
  bool _saving = false;

  bool get _dirty => _spec != widget.initial || (widget.showName && _name.text.trim() != widget.initialName.trim());

  void _update(AvatarSpec spec) => setState(() => _spec = spec);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final result = AvatarEditResult(name: _name.text, avatar: _spec);
    final navigator = Navigator.of(context);
    if (widget.onSave == null) {
      navigator.pop(widget.showName ? result : _spec);
      return;
    }
    setState(() => _saving = true);
    ProfileError? error;
    try {
      error = await widget.onSave!(result);
    } finally {
      // Never leave Save disabled, even if saving failed unexpectedly.
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    setState(() => _error = error);
    // Navigator.pop skips PopScope, so a saved edit closes without asking.
    if (error == null) navigator.pop(result);
  }

  Future<void> _confirmDiscard() async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final discard = await showAppConfirmDialog(
      context,
      title: l10n.discardTitle,
      message: l10n.discardMessage,
      confirmLabel: l10n.discardConfirm,
      cancelLabel: l10n.cancel,
    );
    if (discard && mounted) navigator.pop();
  }

  String? _errorText(AppLocalizations l10n) => switch (_error) {
    null || ProfileError.notFound => null,
    ProfileError.nameEmpty => l10n.profileErrorEmpty,
    ProfileError.nameTooLong => l10n.profileErrorTooLong,
    ProfileError.nameTaken => l10n.profileErrorTaken,
    ProfileError.limitReached => l10n.profileErrorLimit,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final wide = MediaQuery.sizeOf(context).width >= 600;

    final topBar = Padding(
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
              l10n.avatarEditorTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.h2(color: AppColors.paper),
            ),
          ),
          RoundIconButton(
            icon: Icons.casino,
            tooltip: l10n.avatarRandom,
            onPressed: () => _update(AvatarSpec.random(_random)),
          ),
        ],
      ),
    );
    final preview = Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: AppColors.paper, spreadRadius: 6),
              BoxShadow(color: Color(0x66000000), offset: Offset(0, 10), blurRadius: 24, spreadRadius: 6),
            ],
          ),
          child: AnimatedAvatarView(spec: _spec, size: 150),
        ),
      ),
    );
    final tabs = Align(
      alignment: Alignment.centerLeft,
      child: _LayerTabs(selected: _layer, onSelected: (layer) => setState(() => _layer = layer)),
    );
    // Full width on every tab, so the card does not jump when switching.
    final options = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: PaperCard(
          child: _LayerOptions(layer: _layer, spec: _spec, onChanged: _update),
        ),
      ),
    );
    final save = Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: PrimaryButton(label: l10n.avatarSave, onPressed: _saving ? null : _save),
    );
    final nameField = !widget.showName
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _name,
              maxLength: 16,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.h2(color: AppColors.ink),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.paper,
                labelText: l10n.profileName,
                suffixIcon: const Icon(Icons.edit, color: AppColors.wood),
                errorText: _errorText(l10n),
                errorStyle: AppTypography.caption(color: AppColors.paper),
                counterStyle: AppTypography.caption(color: AppColors.woodLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          );

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        body: FeltBackground(
          child: SafeArea(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 280,
                        child: SingleChildScrollView(child: Column(children: [topBar, preview, nameField])),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            // Tabs scroll with the options: a phone in landscape
                            // is only ~360 dp tall.
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(children: [const SizedBox(height: 16), tabs, options]),
                              ),
                            ),
                            save,
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      topBar,
                      Expanded(
                        child: SingleChildScrollView(child: Column(children: [preview, nameField, tabs, options])),
                      ),
                      save,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LayerTabs extends StatelessWidget {
  const _LayerTabs({required this.selected, required this.onSelected});

  final _Layer selected;
  final ValueChanged<_Layer> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      _Layer.face: l10n.avatarTabFace,
      _Layer.skin: l10n.avatarTabSkin,
      _Layer.hair: l10n.avatarTabHair,
      _Layer.eyes: l10n.avatarTabEyes,
      _Layer.mouth: l10n.avatarTabMouth,
      _Layer.background: l10n.avatarTabBackground,
    };
    // Wraps onto a second row on narrow phones so every layer stays visible.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final MapEntry(key: layer, value: label) in labels.entries)
            Semantics(
              button: true,
              selected: layer == selected,
              child: GestureDetector(
                onTap: () => onSelected(layer),
                behavior: HitTestBehavior.opaque,
                // No `alignment` here: it would stretch each pill to the
                // full row width inside the Wrap.
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: layer == selected ? AppColors.paper : const Color(0x40000000),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: AppTypography.button(color: layer == selected ? AppColors.ink : AppColors.paper)
                        .copyWith(fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LayerOptions extends StatelessWidget {
  const _LayerOptions({required this.layer, required this.spec, required this.onChanged});

  final _Layer layer;
  final AvatarSpec spec;
  final ValueChanged<AvatarSpec> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (layer) {
      case _Layer.face:
        return _VariantGrid(
          variants: [
            for (final (face, label) in [
              (FaceShape.oval, l10n.faceOval),
              (FaceShape.round, l10n.faceRound),
              (FaceShape.wide, l10n.faceWide),
              (FaceShape.square, l10n.faceSquare),
            ])
              (spec.copyWith(face: face), label, face == spec.face),
          ],
          onSelected: onChanged,
        );
      case _Layer.skin:
        return ColorSwatchPicker(
          colors: AvatarPalette.skin,
          selected: spec.skin,
          onSelected: (i) => onChanged(spec.copyWith(skin: i)),
          semanticLabels: [for (var i = 1; i <= AvatarPalette.skin.length; i++) l10n.skinTone(i)],
        );
      case _Layer.hair:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _VariantGrid(
              variants: [
                for (final (hair, label) in [
                  (HairStyle.short, l10n.hairShort),
                  (HairStyle.long, l10n.hairLong),
                  (HairStyle.curly, l10n.hairCurly),
                  (HairStyle.bun, l10n.hairBun),
                  (HairStyle.spiky, l10n.hairSpiky),
                  (HairStyle.pigtails, l10n.hairPigtails),
                  (HairStyle.bob, l10n.hairBob),
                  (HairStyle.braids, l10n.hairBraids),
                  (HairStyle.cap, l10n.hairCap),
                  (HairStyle.bald, l10n.hairBald),
                ])
                  (spec.copyWith(hair: hair), label, hair == spec.hair),
              ],
              onSelected: onChanged,
            ),
            const SizedBox(height: 12),
            Text(l10n.avatarHairColor.toUpperCase(), style: AppTypography.caption(color: AppColors.wood)),
            const SizedBox(height: 6),
            ColorSwatchPicker(
              colors: AvatarPalette.hair,
              selected: spec.hairColor,
              onSelected: (i) => onChanged(spec.copyWith(hairColor: i)),
              semanticLabels: [
                l10n.hairColorBlack,
                l10n.hairColorBrown,
                l10n.hairColorChestnut,
                l10n.hairColorBlond,
                l10n.hairColorPlatinum,
                l10n.hairColorRed,
                l10n.hairColorGrey,
                l10n.hairColorBlue,
              ],
            ),
          ],
        );
      case _Layer.eyes:
        return _VariantGrid(
          variants: [
            for (final (eyes, label) in [
              (EyeStyle.round, l10n.eyesRound),
              (EyeStyle.happy, l10n.eyesHappy),
              (EyeStyle.wink, l10n.eyesWink),
              (EyeStyle.sleepy, l10n.eyesSleepy),
              (EyeStyle.wide, l10n.eyesWide),
              (EyeStyle.lashes, l10n.eyesLashes),
            ])
              (spec.copyWith(eyes: eyes), label, eyes == spec.eyes),
          ],
          onSelected: onChanged,
        );
      case _Layer.mouth:
        return _VariantGrid(
          variants: [
            for (final (mouth, label) in [
              (MouthStyle.smile, l10n.mouthSmile),
              (MouthStyle.open, l10n.mouthOpen),
              (MouthStyle.flat, l10n.mouthFlat),
              (MouthStyle.grin, l10n.mouthGrin),
              (MouthStyle.tongue, l10n.mouthTongue),
              (MouthStyle.surprised, l10n.mouthSurprised),
            ])
              (spec.copyWith(mouth: mouth), label, mouth == spec.mouth),
          ],
          onSelected: onChanged,
        );
      case _Layer.background:
        return ColorSwatchPicker(
          colors: AvatarPalette.background,
          selected: spec.background,
          onSelected: (i) => onChanged(spec.copyWith(background: i)),
          semanticLabels: [for (var i = 1; i <= AvatarPalette.background.length; i++) l10n.backgroundColor(i)],
        );
    }
  }
}

/// Grid of variant tiles (four columns on phones, more on wide screens);
/// each tile previews the whole avatar with one variant.
class _VariantGrid extends StatelessWidget {
  const _VariantGrid({required this.variants, required this.onSelected});

  final List<(AvatarSpec spec, String label, bool selected)> variants;
  final ValueChanged<AvatarSpec> onSelected;

  static const _gap = 10.0;
  static const _maxTile = 104.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = min((constraints.maxWidth - 3 * _gap) / 4, _maxTile);
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final (i, (spec, label, selected)) in variants.indexed)
              Semantics(
                key: ValueKey('variant$i'),
                button: true,
                selected: selected,
                label: label,
                // excludeSemantics drops the detector's tap action; keep it for screen readers.
                onTap: () => onSelected(spec),
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onSelected(spec),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: tile,
                    height: tile,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.paper2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.gold : Colors.transparent, width: 4),
                    ),
                    child: AvatarView(spec: spec, size: (tile * 0.78).clamp(28, 80)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
