import 'dart:async';
import 'dart:math';

import '../../ui_kit/components/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/players/player_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../ui_kit/avatar/avatar_view.dart';
import '../../ui_kit/components/app_dialog.dart';
import '../../ui_kit/components/paper_card.dart';
import '../../ui_kit/components/round_icon_button.dart';
import '../../ui_kit/components/ui_feedback.dart';
import '../../ui_kit/surfaces/felt_background.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';

/// Asks a times-table question that children of the target age cannot yet
/// answer (spec 5.6 "Rodičovská zóna"); true when answered right. Two-digit
/// times one-digit, and three wrong answers lock it for a minute (review
/// R-013): the small times table is known from the third class.
Future<bool> showParentsGate(BuildContext context, {Random? random}) async {
  return await showDialog<bool>(context: context, builder: (_) => _Gate(random: random ?? Random())) ?? false;
}

class _Gate extends StatefulWidget {
  const _Gate({required this.random});

  final Random random;

  @override
  State<_Gate> createState() => _GateState();
}

/// Wrong answers in a row and the end of a lockout; kept while the app runs,
/// so closing and opening the gate again does not help.
var _gateMisses = 0;
DateTime? _gateLockedUntil;

class _GateState extends State<_Gate> {
  final _answer = TextEditingController();
  bool _wrong = false;
  late (int, int) _question = _next();
  Timer? _unlock;

  static const _maxMisses = 3;
  static const _lockout = Duration(minutes: 1);

  bool get _locked => _unlock != null;

  @override
  void initState() {
    super.initState();
    final until = _gateLockedUntil;
    if (until != null) {
      final left = until.difference(DateTime.now());
      if (left > Duration.zero) {
        _lockFor(left);
      } else {
        _gateLockedUntil = null;
      }
    }
  }

  /// A new 12–19 × 3–9 question, never the same as the last one.
  (int, int) _next([(int, int)? last]) {
    final q = (12 + widget.random.nextInt(8), 3 + widget.random.nextInt(7));
    return q == last ? (q.$1, 3 + (q.$2 - 2) % 7) : q;
  }

  void _lockFor(Duration time) {
    _unlock?.cancel();
    _unlock = Timer(time, () {
      _gateLockedUntil = null;
      _gateMisses = 0;
      if (mounted) setState(() => _unlock = null);
    });
  }

  @override
  void dispose() {
    _unlock?.cancel();
    _answer.dispose();
    super.dispose();
  }

  void _check() {
    if (_locked) return;
    if (int.tryParse(_answer.text.trim()) == _question.$1 * _question.$2) {
      _gateMisses = 0;
      Navigator.of(context).pop(true);
    } else {
      // A new question each time: guessing through answers stops working.
      setState(() {
        _wrong = true;
        _question = _next(_question);
        _answer.clear();
        if (++_gateMisses >= _maxMisses) {
          _gateLockedUntil = DateTime.now().add(_lockout);
          _lockFor(_lockout);
        }
      });
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
              l10n.parentsGateQuestion(_question.$1, _question.$2),
              key: const ValueKey('gateQuestion'),
              style: AppTypography.body(color: AppColors.ink),
            ),
            TextField(
              controller: _answer,
              enabled: !_locked,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (_) => _check(),
            ),
            if (_locked || _wrong) ...[
              const SizedBox(height: 4),
              Text(
                _locked ? l10n.parentsGateLocked : l10n.parentsGateWrong,
                style: AppTypography.caption(color: AppColors.players[0]),
              ),
            ],
            const SizedBox(height: 16),
            PrimaryButton(
              key: const ValueKey('gateOpen'),
              label: l10n.parentsGateOpen,
              onPressed: _locked ? null : _check,
            ),
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

  Future<void> _reset(PlayerProfile player, int balance) async {
    final l10n = AppLocalizations.of(context);
    final shop = ref.read(shopRepositoryProvider);
    final ok = await showAppConfirmDialog(
      context,
      title: l10n.parentsResetTitle,
      message: l10n.parentsResetConfirm(player.name, balance),
      confirmLabel: l10n.parentsReset,
      cancelLabel: l10n.cancel,
    );
    if (!ok) return;
    await shop.reset(player.id);
    if (mounted) setState(() => _done = l10n.parentsResetDone(player.name));
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
              // Spec "Rodinná synchronizace" 5.1: the family's devices.
              PrimaryButton(
                key: const ValueKey('familyLink'),
                label: l10n.familyTitle,
                icon: Icons.devices,
                secondary: true,
                onPressed: () => context.push('/settings/parents/family'),
              ),
              const SizedBox(height: 8),
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
                            OutlinedButton(
                              key: ValueKey('reset_${p.id}'),
                              onPressed: () => _reset(p, balances[p.id]?.balance ?? 0),
                              style: OutlinedButton.styleFrom(minimumSize: const Size(72, 48)),
                              child: Text(l10n.parentsReset, style: AppTypography.button(color: AppColors.ink)),
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
