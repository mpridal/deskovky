import 'package:flutter/material.dart';

import '../../ui_kit/tokens/app_colors.dart';
import '../../ui_kit/tokens/app_typography.dart';
import 'war_rules.dart';

/// Card proportions (width : height).
const warCardAspect = 0.7;

/// The rank as printed in a corner: 2–10, J, Q, K, A.
String warRankLabel(int rank) => switch (rank) {
  11 => 'J',
  12 => 'Q',
  13 => 'K',
  14 => 'A',
  _ => '$rank',
};

/// The suit for screen readers.
String warSuitLabel(int suit) => const ['♠', '♥', '♦', '♣'][suit];

/// Hearts and diamonds are red, spades and clubs ink.
Color warSuitColor(int suit) => suit == 1 || suit == 2 ? AppColors.players[0] : AppColors.ink;

/// The face of [card]: paper, the rank and suit in two corners and a big
/// suit (or the letter of a face card) in the middle.
class WarCardFace extends StatelessWidget {
  const WarCardFace({super.key, required this.card, this.glow});

  final int card;

  /// The winner's colour around a winning card.
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final rank = WarCard.rank(card), suit = WarCard.suit(card);
    final colour = warSuitColor(suit);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final corner = AppTypography.button(color: colour).copyWith(fontSize: w * 0.2, height: 1);
        final label = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(warRankLabel(rank), style: corner),
            SizedBox(height: w * 0.02),
            WarSuit(suit: suit, size: w * 0.15),
          ],
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(w * 0.1),
            border: Border.all(color: glow ?? AppColors.woodLight, width: glow == null ? 1.5 : 4),
            boxShadow: [
              BoxShadow(color: AppColors.walnut.withValues(alpha: 0.35), offset: const Offset(0, 2), blurRadius: 3),
            ],
          ),
          child: Stack(
            children: [
              Positioned(left: w * 0.07, top: w * 0.05, child: label),
              Positioned(
                right: w * 0.07,
                bottom: w * 0.05,
                child: RotatedBox(quarterTurns: 2, child: label),
              ),
              Center(
                child: rank > 10
                    ? Text(
                        warRankLabel(rank),
                        style: AppTypography.h1(color: colour).copyWith(fontSize: w * 0.5, height: 1),
                      )
                    : WarSuit(suit: suit, size: w * 0.45),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The back of a card: wood with a felt diamond.
class WarCardBack extends StatelessWidget {
  const WarCardBack({super.key, this.glow});

  /// The colour of the player whose turn it is to tap the pile.
  final Color? glow;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _BackPainter(glow), child: const SizedBox.expand());
}

class _BackPainter extends CustomPainter {
  const _BackPainter(this.glow);

  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final rect = Offset.zero & size;
    final card = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.1));
    canvas
      ..drawRRect(card.shift(Offset(0, s * 0.03)), Paint()..color = AppColors.walnut)
      ..drawRRect(
        card,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.woodLight, AppColors.wood],
          ).createShader(rect),
      );
    final inner = rect.deflate(s * 0.12);
    final diamond = Path()
      ..moveTo(inner.center.dx, inner.top)
      ..lineTo(inner.right, inner.center.dy)
      ..lineTo(inner.center.dx, inner.bottom)
      ..lineTo(inner.left, inner.center.dy)
      ..close();
    canvas
      ..drawPath(diamond, Paint()..color = AppColors.felt)
      ..drawCircle(inner.center, s * 0.1, Paint()..color = AppColors.gold)
      ..drawRRect(
        card.deflate(s * 0.05),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.025
          ..color = AppColors.walnut.withValues(alpha: 0.45),
      );
    if (glow != null) {
      canvas.drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.06
          ..color = glow!,
      );
    }
  }

  @override
  bool shouldRepaint(_BackPainter old) => old.glow != glow;
}

/// A suit drawn in code (the app fonts have no ♠ ♥ ♦ ♣).
class WarSuit extends StatelessWidget {
  const WarSuit({super.key, required this.suit, required this.size});

  final int suit;
  final double size;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: CustomPaint(painter: _SuitPainter(suit)));
}

class _SuitPainter extends CustomPainter {
  const _SuitPainter(this.suit);

  final int suit;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final paint = Paint()..color = warSuitColor(suit);
    Path heart() => Path()
      ..moveTo(w * 0.5, h * 0.95)
      ..cubicTo(w * 0.1, h * 0.65, -w * 0.05, h * 0.35, w * 0.22, h * 0.12)
      ..cubicTo(w * 0.36, h * 0.0, w * 0.48, h * 0.1, w * 0.5, h * 0.25)
      ..cubicTo(w * 0.52, h * 0.1, w * 0.64, h * 0.0, w * 0.78, h * 0.12)
      ..cubicTo(w * 1.05, h * 0.35, w * 0.9, h * 0.65, w * 0.5, h * 0.95)
      ..close();
    Path stem() => Path()
      ..moveTo(w * 0.5, h * 0.55)
      ..lineTo(w * 0.32, h * 1.0)
      ..lineTo(w * 0.68, h * 1.0)
      ..close();
    switch (suit) {
      case 1:
        canvas.drawPath(heart(), paint);
      case 2:
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.5, 0)
            ..lineTo(w * 0.88, h * 0.5)
            ..lineTo(w * 0.5, h)
            ..lineTo(w * 0.12, h * 0.5)
            ..close(),
          paint,
        );
      case 0:
        // A heart upside down, on a stem.
        canvas
          ..save()
          ..translate(0, h * 0.82)
          ..scale(1, -0.82)
          ..drawPath(heart(), paint)
          ..restore()
          ..drawPath(stem(), paint);
      default:
        final r = w * 0.2;
        canvas
          ..drawCircle(Offset(w * 0.5, h * 0.24), r, paint)
          ..drawCircle(Offset(w * 0.27, h * 0.55), r, paint)
          ..drawCircle(Offset(w * 0.73, h * 0.55), r, paint)
          ..drawCircle(Offset(w * 0.5, h * 0.5), r * 0.7, paint)
          ..drawPath(stem(), paint);
    }
  }

  @override
  bool shouldRepaint(_SuitPainter old) => old.suit != suit;
}
