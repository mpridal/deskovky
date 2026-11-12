import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/game/game_module.dart';
import '../../core/game/move.dart';
import '../../ui_kit/components/primary_button.dart';
import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'war_card_art.dart';
import 'war_events.dart';
import 'war_rules.dart';
import 'war_texts.dart';

/// Board of Válka: every player's zone on the felt – their face-down pile
/// and the cards they have put on the table in this battle – and a strip in
/// the middle with the round, "Válka!" and "Vzít karty".
///
/// A tap on your own pile turns the top card (in a war: one face down and
/// one face up); the battle's winner takes the table with the button or a
/// tap on their pile. Sounds and badge events follow the state, so moves
/// from a robot or another device are heard and counted as well.
class WarBoard extends StatefulWidget {
  const WarBoard({super.key, required this.view});

  final GameBoardView<WarState> view;

  @override
  State<WarBoard> createState() => _WarBoardState();
}

class _WarBoardState extends State<WarBoard> {
  static const _rules = WarRules();

  final _reported = <String>{};

  WarState get _s => widget.view.state;

  @override
  void initState() {
    super.initState();
    _report(_s);
  }

  @override
  void didUpdateWidget(WarBoard old) {
    super.didUpdateWidget(old);
    final before = old.view.state, now = _s;
    if (identical(before, now)) return;
    final put = [for (var s = 0; s < now.seats; s++) now.table[s].length].fold(0, (a, b) => a + b);
    final had = [for (var s = 0; s < before.seats; s++) before.table[s].length].fold(0, (a, b) => a + b);
    if (put > had) widget.view.host.playSfx('card_flip');
    if (now.round > before.round) widget.view.host.playSfx('piece_place');
    if (now.warDepth > before.warDepth) widget.view.host.haptic();
    _report(now);
  }

  void _report(WarState s) {
    for (final MapEntry(:key, :value) in WarEvents.of(s).entries) {
      if (_reported.add(key)) widget.view.host.reportEvent(WarEvents.idOf(key), value);
    }
  }

  /// The move this device's player on turn may make now, if any.
  Move? get _myMove {
    final view = widget.view;
    final seat = view.mySeat;
    if (!view.canAct || seat == null || _s.over) return null;
    final legal = _rules.legalMoves(_s, seat);
    return legal.isEmpty ? null : legal.single;
  }

  void _play(Move move) {
    final view = widget.view;
    if (!_rules.isLegal(_s, move)) return;
    view.host.haptic();
    // Before the move: when it ends the game, the screen collects events at once.
    _report(_rules.apply(_s, move));
    view.submit(move);
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final my = _myMove;
    return LayoutBuilder(
      builder: (context, box) {
        final layout = _Layout(Size(box.maxWidth, box.maxHeight), s.seats);
        final collecting = my != null && my.type == 'collect';
        final pot = [for (var i = 0; i < s.seats; i++) s.table[i].length].fold(0, (a, b) => a + b);
        return Stack(
          children: [
            for (var seat = 0; seat < s.seats; seat++)
              Positioned.fromRect(rect: layout.zones[seat], child: _zone(context, seat, layout.cardHeight, my)),
            Positioned.fromRect(
              rect: layout.strip,
              child: Row(
                children: [
                  Expanded(child: _status(context)),
                  if (collecting || s.battleWinner != null)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: PrimaryButton(
                        key: const ValueKey('warCollect'),
                        label: warTexts.of(context, 'war.collect', {'count': pot}),
                        onPressed: collecting ? () => _play(my) : null,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _status(BuildContext context) {
    final s = _s;
    final round = s.over ? s.round : s.round + 1;
    final text = s.maxRounds >= WarLength.cap
        ? warTexts.of(context, 'war.roundOpen', {'round': round})
        : warTexts.of(context, 'war.round', {'round': round, 'total': s.maxRounds});
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        children: [
          Text(text, style: AppTypography.caption(color: AppColors.paper)),
          if (s.warDepth > 0)
            DecoratedBox(
              key: const ValueKey('warBanner'),
              decoration: BoxDecoration(color: AppColors.players[0], borderRadius: BorderRadius.circular(999)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  s.warDepth > 1 ? '${warTexts.of(context, 'war.war')} ×${s.warDepth}' : warTexts.of(context, 'war.war'),
                  style: AppTypography.button(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _zone(BuildContext context, int seat, double cardH, Move? my) {
    final s = _s;
    final view = widget.view;
    final colour = AppColors.players[seat];
    final out = s.isOut(seat);
    final mine = my != null && my.seat == seat;
    final turn = _rules.currentSeat(s) == seat;
    final cardW = cardH * warCardAspect;
    final hint = view.firstGame && mine && my.type == 'flip' && s.round == 0
        ? warTexts.of(context, 'war.firstHint')
        : null;
    final winner = s.battleWinner == seat;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.feltDark.withValues(alpha: out ? 0.3 : 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colour.withValues(alpha: turn ? 1 : 0.5), width: turn ? 3 : 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Semantics(
                key: ValueKey('warPile$seat'),
                container: true,
                button: mine,
                excludeSemantics: true,
                label: warTexts.of(context, 'war.deck', {'seat': seat + 1, 'count': s.decks[seat].length}),
                onTap: mine ? () => _play(my) : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: mine ? () => _play(my) : null,
                  child: _pile(seat, cardW, cardH, glow: mine ? colour : null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: out && s.table[seat].isEmpty
                    ? Text(warTexts.of(context, 'war.out'), style: AppTypography.caption(color: AppColors.paper2))
                    : Stack(
                        children: [
                          _tableCards(seat, cardW, cardH, winner ? colour : null),
                          if (hint != null)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  key: const ValueKey('warHint'),
                                  decoration: BoxDecoration(
                                    color: AppColors.walnut.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      hint,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption(color: AppColors.paper),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The face-down pile: a few backs stacked, and the count.
  Widget _pile(int seat, double w, double h, {Color? glow}) {
    final count = _s.decks[seat].length;
    final layers = min(count, 3);
    return SizedBox(
      width: w + 8,
      height: h + 8,
      child: Stack(
        children: [
          for (var i = 0; i < layers; i++)
            Positioned(
              left: (layers - 1 - i) * 3.0,
              top: (layers - 1 - i) * 3.0,
              width: w,
              height: h,
              child: WarCardBack(glow: i == layers - 1 ? glow : null),
            ),
          if (count == 0)
            Positioned(
              left: 0,
              top: 0,
              width: w,
              height: h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(w * 0.1),
                  border: Border.all(color: AppColors.paper2.withValues(alpha: 0.4), width: 1.5),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 26),
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.players[seat], borderRadius: BorderRadius.circular(13)),
              child: Text('$count', style: AppTypography.caption(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  /// This battle's cards of [seat], overlapping left to right; the last
  /// face-up one fully visible.
  Widget _tableCards(int seat, double w, double h, Color? glow) {
    final cards = _s.table[seat];
    final still = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, box) {
        final step = cards.length < 2 ? 0.0 : min(w * 0.45, max(0.0, (box.maxWidth - w) / (cards.length - 1)));
        return SizedBox(
          height: h,
          child: Stack(
            children: [
              for (final (i, (card, up)) in cards.indexed)
                Positioned(
                  key: ValueKey('warTable$seat,$i'),
                  left: i * step,
                  top: 0,
                  width: w,
                  height: h,
                  child: Semantics(
                    label: up ? '${warRankLabel(WarCard.rank(card))}${warSuitLabel(WarCard.suit(card))}' : warTexts.of(context, 'war.hidden'),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: still ? 1 : 0.6, end: 1),
                      duration: still ? Duration.zero : const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                      child: up
                          ? WarCardFace(card: card, glow: i == cards.length - 1 ? glow : null)
                          : const WarCardBack(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Where everything sits: one zone per seat and a strip in the middle.
/// Two players face each other (seat 1 on top, or on the right in
/// landscape); three or four share a 2 × 2 grid, seat 1 and 2 at the bottom.
class _Layout {
  _Layout(Size size, int seats) {
    const stripH = 64.0;
    final landscape = size.width > size.height * 1.1;
    if (seats == 2 && landscape) {
      final zoneH = size.height - stripH;
      zones = [Rect.fromLTWH(0, stripH, size.width / 2, zoneH), Rect.fromLTWH(size.width / 2, stripH, size.width / 2, zoneH)];
      strip = Rect.fromLTWH(0, 0, size.width, stripH);
    } else if (seats == 2) {
      final zoneH = (size.height - stripH) / 2;
      zones = [Rect.fromLTWH(0, zoneH + stripH, size.width, zoneH), Rect.fromLTWH(0, 0, size.width, zoneH)];
      strip = Rect.fromLTWH(0, zoneH, size.width, stripH);
    } else {
      final zoneH = (size.height - stripH) / 2;
      final half = size.width / 2;
      final bottom = zoneH + stripH;
      zones = [
        Rect.fromLTWH(0, bottom, half, zoneH),
        Rect.fromLTWH(half, bottom, half, zoneH),
        if (seats == 3) Rect.fromLTWH(0, 0, size.width, zoneH) else Rect.fromLTWH(0, 0, half, zoneH),
        if (seats == 4) Rect.fromLTWH(half, 0, half, zoneH),
      ];
      strip = Rect.fromLTWH(0, zoneH, size.width, stripH);
    }
    final narrowest = zones.map((z) => z.width).reduce(min);
    final lowest = zones.map((z) => z.height).reduce(min);
    // A card fits the zone's height and leaves room for the table beside it.
    cardHeight = max(40.0, min(lowest - 32, (narrowest - 48) * 0.4 / warCardAspect)).clamp(40.0, 220.0);
  }

  late final List<Rect> zones;
  late final Rect strip;
  late final double cardHeight;
}
