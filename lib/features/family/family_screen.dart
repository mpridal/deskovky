import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/family_controller.dart';
import '../../app/family_providers.dart';
import '../../app/multiplayer_providers.dart';
import '../../core/family/family_identity.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/app_toast.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import '../multiplayer/qr_scanner.dart';
import '../multiplayer/room_widgets.dart';

/// Rodičovská zóna → Rodina (spec "Rodinná synchronizace" 5.1): found a
/// family or join one by its QR code; the family's QR code for a new device,
/// the family's devices and removing one.
class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  String? _message;
  var _busy = false;
  late Future<List<FamilyDeviceInfo>> _devices = ref.read(familyControllerProvider).familyDevices();

  // Kept in a field: ref must not be used in dispose.
  late final FamilyController _controller = ref.read(familyControllerProvider);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_refresh);
    _controller.syncSoon();
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _devices = _controller.familyDevices();
    });
  }

  String _deviceName(BuildContext context, AppLocalizations l10n) =>
      MediaQuery.sizeOf(context).shortestSide >= 600 ? l10n.deviceTablet : l10n.devicePhone;

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    await _controller.createFamily(deviceName: _deviceName(context, l10n));
    if (mounted) setState(() => _busy = false);
    _refresh();
  }

  Future<void> _join({required bool leaving}) async {
    final l10n = AppLocalizations.of(context);
    if (leaving &&
        !await showAppConfirmDialog(
          context,
          title: l10n.familyJoinOther,
          message: l10n.familyJoinOtherWarning,
          confirmLabel: l10n.familyJoinOtherConfirm,
          cancelLabel: l10n.cancel,
        )) {
      return;
    }
    if (!mounted) return;
    final result = await ref.read(qrScannerProvider).scan(context);
    if (!mounted) return;
    switch (result) {
      case QrScanned(:final text):
        final ticket = FamilyTicket.parse(text);
        if (ticket == null) {
          showAppToast(context, l10n.familyNotACode);
          return;
        }
        setState(() {
          _busy = true;
          _message = null;
        });
        final outcome = await _controller.joinFamily(ticket, deviceName: _deviceName(context, l10n));
        if (!mounted) return;
        setState(() {
          _busy = false;
          _message = outcome.ok ? l10n.familyJoined : l10n.familyJoinFailed;
        });
        _refresh();
      case QrCameraDenied():
        showAppToast(context, l10n.qrCameraDenied);
      case QrScanCancelled():
        break;
    }
  }

  Future<void> _remove(FamilyDeviceInfo device) async {
    final l10n = AppLocalizations.of(context);
    final yes = await showAppConfirmDialog(
      context,
      title: l10n.familyRemoveTitle(device.name),
      message: l10n.familyRemoveMessage,
      confirmLabel: l10n.familyRemove,
      cancelLabel: l10n.cancel,
    );
    if (yes) await _controller.removeDevice(device.deviceId);
    _refresh();
  }

  String _when(DateTime t) {
    final now = DateTime.now();
    final hm = '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    return t.year == now.year && t.month == now.month && t.day == now.day ? hm : '${t.day}. ${t.month}. $hm';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.watch(familyControllerProvider);
    final ticket = controller.ticket;
    Widget text(String s, {Color color = AppColors.paper}) => Text(s, style: AppTypography.body(color: color));

    return RoomPage(
      title: l10n.familyTitle,
      onBack: () => context.pop(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          text(l10n.familyIntro),
          const SizedBox(height: 16),
          if (_message case final message?) ...[
            PaperCard(child: text(message, color: AppColors.ink)),
            const SizedBox(height: 12),
          ],
          if (controller.problem case final problem?) ...[
            PaperCard(
              child: text(problem == FamilyProblem.noWifi ? l10n.noWifi : l10n.familyUpdateApps, color: AppColors.ink),
            ),
            const SizedBox(height: 12),
          ],
          if (!controller.inFamily) ...[
            PrimaryButton(
              key: const ValueKey('familyCreate'),
              label: l10n.familyCreate,
              icon: Icons.family_restroom,
              onPressed: _busy ? null : _create,
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              key: const ValueKey('familyJoin'),
              label: l10n.familyJoin,
              icon: Icons.qr_code_scanner,
              secondary: true,
              onPressed: _busy ? null : () => _join(leaving: false),
            ),
          ] else ...[
            roomLabel(l10n.familyAddDevice),
            if (ticket != null)
              PaperCard(
                child: Column(
                  children: [
                    QrImageView(data: ticket.toUri().toString(), size: 200, backgroundColor: AppColors.paper),
                    const SizedBox(height: 8),
                    text(l10n.familyQrHint, color: AppColors.ink),
                  ],
                ),
              ),
            roomLabel(l10n.familyDevices),
            FutureBuilder(
              future: _devices,
              builder: (context, snapshot) => Column(
                children: [
                  for (final d in snapshot.data ?? const <FamilyDeviceInfo>[])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PaperCard(
                        child: Row(
                          children: [
                            Icon(d.isMe ? Icons.phone_android : Icons.devices, color: AppColors.wood),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.name, style: AppTypography.button(color: AppColors.ink)),
                                  Text(
                                    d.isMe
                                        ? l10n.familyThisDevice
                                        : d.removed
                                        ? l10n.familyRemoved
                                        : d.lastSync == null
                                        ? l10n.familyNeverSynced
                                        : l10n.familyLastSync(_when(d.lastSync!)),
                                    style: AppTypography.caption(color: AppColors.wood),
                                  ),
                                ],
                              ),
                            ),
                            if (!d.isMe && !d.removed)
                              IconButton(
                                key: const ValueKey('familyRemove'),
                                tooltip: l10n.familyRemove,
                                icon: const Icon(Icons.link_off, color: AppColors.ink),
                                onPressed: () => _remove(d),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              key: const ValueKey('familyJoinOther'),
              label: l10n.familyJoinOther,
              icon: Icons.qr_code_scanner,
              secondary: true,
              onPressed: _busy ? null : () => _join(leaving: true),
            ),
          ],
        ],
      ),
    );
  }
}
