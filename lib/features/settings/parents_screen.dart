import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Asks a times-table question that children of the target age cannot yet
/// answer (spec 5.6 "Rodičovská zóna"); true when answered right.
Future<bool> showParentsGate(BuildContext context, {Random? random}) async {
  final r = random ?? Random();
  final a = 6 + r.nextInt(4), b = 6 + r.nextInt(4);
  return await showDialog<bool>(context: context, builder: (_) => _Gate(a: a, b: b)) ?? false;
}

class _Gate extends StatefulWidget {
  const _Gate({required this.a, required this.b});

  final int a;
  final int b;

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  final _answer = TextEditingController();
  bool _wrong = false;

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  void _check() {
    if (int.tryParse(_answer.text.trim()) == widget.a * widget.b) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.parentsGateTitle, style: AppTypography.h2(color: AppColors.ink)),
            const SizedBox(height: 8),
            Text(
              l10n.parentsGateQuestion(widget.a, widget.b),
              key: const ValueKey('gateQuestion'),
              style: AppTypography.body(color: AppColors.ink),
            ),
            TextField(
              controller: _answer,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _check(),
            ),
            if (_wrong) ...[
              const SizedBox(height: 4),
              Text(l10n.parentsGateWrong, style: AppTypography.caption(color: AppColors.players[0])),
            ],
            const SizedBox(height: 16),
            PrimaryButton(key: const ValueKey('gateOpen'), label: l10n.parentsGateOpen, onPressed: _check),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              child: Text(l10n.cancel, style: AppTypography.button(color: AppColors.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Rodičovská zóna": give a player points, e.g. as a reward for chores
/// (spec 5.6). Every gift is a ledger entry "dárek od rodiče".
class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  static const amounts = [10, 50, 100];

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  String? _done;

  Future<void> _gift(PlayerProfile player, int amount) async {
    final l10n = AppLocalizations.of(context);
    final points = ref.read(pointsRepositoryProvider);
    final ok = await showAppConfirmDialog(
      context,
      title: l10n.parentsGiftTitle,
      message: l10n.parentsGiftConfirm(amount, player.name),
      confirmLabel: l10n.parentsGiftAction,
      cancelLabel: l10n.cancel,
    );
    if (!ok) return;
    await points.gift(player.id, amount);
    if (mounted) setState(() => _done = l10n.parentsGiftDone(amount, player.name));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final players = ref.watch(playersProvider).value ?? const <PlayerProfile>[];
    final balances = ref.watch(pointsSummaryProvider);
    return Scaffold(
      body: FeltBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back,
                    tooltip: l10n.back,
                    sound: UiSound.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.settingsParents, style: AppTypography.h1(color: AppColors.paper))),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.parentsGiftTitle, style: AppTypography.h2(color: AppColors.paper)),
              const SizedBox(height: 8),
              if (_done != null) ...[
                Text(_done!, style: AppTypography.button(color: AppColors.gold)),
                const SizedBox(height: 8),
              ],
              for (final p in players)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            AvatarView(spec: p.avatar, size: 40),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.button(color: AppColors.ink),
                              ),
                            ),
                            Text('● ${balances[p.id]?.balance ?? 0}', style: AppTypography.button(color: AppColors.wood)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final amount in ParentsScreen.amounts)
                              OutlinedButton(
                                key: ValueKey('gift_${p.id}_$amount'),
                                onPressed: () => _gift(p, amount),
                                style: OutlinedButton.styleFrom(minimumSize: const Size(72, 48)),
                                child: Text('+$amount ●', style: AppTypography.button(color: AppColors.ink)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
