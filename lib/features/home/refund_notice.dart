import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/family_controller.dart';
import '../../app/family_providers.dart';
import '../../app/providers.dart';
import '../../games/item_texts.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Tells the signed-in child, once, that a purchase was taken back because
/// two devices spent the same points (spec "Rodinná synchronizace" kap. 6).
class RefundNoticeHost extends ConsumerStatefulWidget {
  const RefundNoticeHost({super.key});

  @override
  ConsumerState<RefundNoticeHost> createState() => _RefundNoticeHostState();
}

class _RefundNoticeHostState extends ConsumerState<RefundNoticeHost> {
  late final FamilyController _family = ref.read(familyControllerProvider);
  var _showing = false;

  @override
  void initState() {
    super.initState();
    _family.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _family.removeListener(_check);
    super.dispose();
  }

  Future<void> _check() async {
    final active = ref.read(activePlayerProvider).value;
    if (!mounted || _showing || active == null) return;
    if (!_family.inFamily) return;
    final notices = await _family.unseenRefunds(active.id);
    if (!mounted || notices.isEmpty || _showing || ref.read(activePlayerProvider).value?.id != active.id) return;
    _showing = true;
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        key: const ValueKey('refundNotice'),
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.refundTitle, textAlign: TextAlign.center, style: AppTypography.h2(color: AppColors.ink)),
              const SizedBox(height: 12),
              for (final n in notices)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l10n.refundNotice(itemName(l10n, n.itemId)), style: AppTypography.body(color: AppColors.ink)),
                ),
              const SizedBox(height: 8),
              PrimaryButton(label: l10n.refundOk, onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
    await _family.markRefundsSeen(notices);
    _showing = false;
  }

  @override
  Widget build(BuildContext context) {
    // A new child signed in: maybe something to tell them.
    ref.listen(activePlayerProvider, (_, _) => _check());
    return const SizedBox.shrink();
  }
}
