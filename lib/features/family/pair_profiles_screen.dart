import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/family_controller.dart';
import '../../app/family_providers.dart';
import '../../core/avatar/avatar_spec.dart';
import '../../core/family/family_state.dart';
import '../../core/family/fold.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../multiplayer/room_widgets.dart';

/// Pairing profiles of the same person from different devices (spec 5.2):
/// pairs with the same name are offered; any two can be paired by hand.
class PairProfilesScreen extends ConsumerStatefulWidget {
  const PairProfilesScreen({super.key});

  @override
  ConsumerState<PairProfilesScreen> createState() => _PairProfilesScreenState();
}

class _PairProfilesScreenState extends ConsumerState<PairProfilesScreen> {
  late final FamilyController _family = ref.read(familyControllerProvider);
  late Future<(List<(ProfileView, ProfileView)>, List<ProfileView>)> _data = _load();

  /// Whose look the joined profile keeps, per pair index (the newer by default).
  final _lookFromLater = <int, bool>{};
  String? _manualFirst, _manualSecond;
  var _busy = false;

  Future<(List<(ProfileView, ProfileView)>, List<ProfileView>)> _load() async =>
      (await _family.pairCandidates(), foldFamily(await _family.store.all()).profiles.values.toList());

  void _reload() => setState(() {
    _data = _load();
    _lookFromLater.clear();
  });

  Future<void> _merge(ProfileView into, ProfileView from, {required bool lookFromFrom}) async {
    setState(() => _busy = true);
    await _family.mergeProfiles(intoUid: into.uid, fromUid: from.uid, lookFromUid: lookFromFrom ? from.uid : into.uid);
    if (!mounted) return;
    _busy = false;
    _reload();
  }

  Widget _face(ProfileView p, {bool selected = false, VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? AppColors.gold : Colors.transparent, width: 3),
          ),
          child: AvatarView(spec: AvatarSpec.fromJson(p.avatar), size: 56, semanticLabel: p.name),
        ),
        const SizedBox(height: 4),
        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.button(color: AppColors.ink)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return RoomPage(
      title: l10n.pairTitle,
      onBack: () => context.pop(),
      body: FutureBuilder(
        future: _data,
        builder: (context, snapshot) {
          final (pairs, profiles) = snapshot.data ?? (const <(ProfileView, ProfileView)>[], const <ProfileView>[]);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (snapshot.hasData && pairs.isEmpty)
                Text(l10n.pairNone, style: AppTypography.body(color: AppColors.paper)),
              for (final (i, (a, b)) in pairs.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.pairQuestion, style: AppTypography.h2(color: AppColors.ink)),
                        const SizedBox(height: 8),
                        Text(l10n.pairLook, style: AppTypography.caption(color: AppColors.wood)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: _face(a, selected: !(_lookFromLater[i] ?? true), onTap: () => setState(() => _lookFromLater[i] = false)),
                            ),
                            const Icon(Icons.link, color: AppColors.wood),
                            Flexible(
                              child: _face(b, selected: _lookFromLater[i] ?? true, onTap: () => setState(() => _lookFromLater[i] = true)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          key: ValueKey('pairMerge$i'),
                          label: l10n.pairMerge,
                          icon: Icons.merge,
                          onPressed: _busy ? null : () => _merge(a, b, lookFromFrom: _lookFromLater[i] ?? true),
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          key: ValueKey('pairKeep$i'),
                          label: l10n.pairKeep,
                          secondary: true,
                          onPressed: _busy
                              ? null
                              : () async {
                                  await _family.declinePair(a.uid, b.uid);
                                  if (mounted) _reload();
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              if (profiles.length >= 2) ...[
                roomLabel(l10n.pairManual),
                PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (label, value, set) in [
                        (l10n.pairFirst, _manualFirst, (String? v) => _manualFirst = v),
                        (l10n.pairSecond, _manualSecond, (String? v) => _manualSecond = v),
                      ])
                        DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(label),
                          value: value,
                          items: [
                            for (final p in profiles) DropdownMenuItem(value: p.uid, child: Text(p.name, overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (v) => setState(() => set(v)),
                        ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        key: const ValueKey('pairManualMerge'),
                        label: l10n.pairMerge,
                        icon: Icons.merge,
                        onPressed: _busy || _manualFirst == null || _manualSecond == null || _manualFirst == _manualSecond
                            ? null
                            : () {
                                final into = profiles.firstWhere((p) => p.uid == _manualFirst);
                                final from = profiles.firstWhere((p) => p.uid == _manualSecond);
                                _manualFirst = _manualSecond = null;
                                _merge(into, from, lookFromFrom: false);
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
