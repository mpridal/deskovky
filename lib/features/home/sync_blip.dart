import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family_controller.dart';
import '../../app/family_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/tokens/app_colors.dart';

/// A small sync icon for 2 s after new data came from the family (spec
/// "Rodinná synchronizace" 5.3) – no message that would bother the children.
class SyncBlip extends ConsumerStatefulWidget {
  const SyncBlip({super.key});

  static const shown = Duration(seconds: 2);

  @override
  ConsumerState<SyncBlip> createState() => _SyncBlipState();
}

class _SyncBlipState extends ConsumerState<SyncBlip> {
  late final FamilyController _family = ref.read(familyControllerProvider);
  DateTime? _seen;
  Timer? _hide;
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _seen = _family.lastSyncAt;
    _family.addListener(_changed);
  }

  @override
  void dispose() {
    _family.removeListener(_changed);
    _hide?.cancel();
    super.dispose();
  }

  void _changed() {
    final at = _family.lastSyncAt;
    if (at == null || at == _seen || !mounted) return;
    _seen = at;
    setState(() => _visible = true);
    _hide?.cancel();
    _hide = Timer(SyncBlip.shown, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Padding(
      key: const ValueKey('syncBlip'),
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: AppLocalizations.of(context).familySynced,
        child: const Icon(Icons.sync, color: AppColors.gold),
      ),
    );
  }
}
