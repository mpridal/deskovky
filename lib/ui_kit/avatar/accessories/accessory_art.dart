import 'dart:math';
import 'dart:ui';

import '../../../core/avatar/accessory_slot.dart';
import 'face_arts.dart';
import 'hand_arts.dart';
import 'head_arts.dart';

export '../../../core/avatar/accessory_slot.dart';

/// What an upgrade's art may use: the avatar's skin (for the hand holding
/// an item), the chosen colour variant and the animation phase.
class AccessoryContext {
  const AccessoryContext({required this.skin, this.variant, this.t = 0});

  final Color skin;
  final String? variant;

  /// 0–1, repeating; 0 when still (small sizes, reduced motion).
  final double t;
}

typedef ArtPainter = void Function(Canvas canvas, AccessoryContext ctx);

/// The drawing of one avatar upgrade in the avatar's 100×100 space
/// (spec 5.6: vector art in the avatar's style, drawn by code).
class AccessoryArt {
  const AccessoryArt(this.slot, this.painter, {this.animated = false, this.hairLine});

  final AccessorySlot slot;
  final ArtPainter painter;

  /// Moves when worn at 64 dp and larger.
  final bool animated;

  /// For hats: the hair is clipped above this y, so it does not stick out.
  final double? hairLine;

  void paint(Canvas canvas, AccessoryContext ctx) => painter(canvas, ctx);
}

/// Art for every catalog item id.
const Map<String, AccessoryArt> accessoryArts = {...headArts, ...faceArts, ...handArts};

/// Shared colours and helpers for the arts.
abstract final class Art {
  static const ink = Color(0xFF2B211B);
  static const gold = Color(0xFFE0A82E);
  static const goldDark = Color(0xFF9B6A12);
  static const goldLight = Color(0xFFFFE08A);
  static const silver = Color(0xFFC9D1D8);
  static const silverDark = Color(0xFF7C8791);
  static const red = Color(0xFFD9534F);
  static const blue = Color(0xFF3B7DD8);
  static const yellow = Color(0xFFE8B931);
  static const green = Color(0xFF4CAF6A);
  static const purple = Color(0xFF8E5BC8);
  static const white = Color(0xFFFFFFFF);

  /// A colour variant by its name in `shop_items.json`.
  static Color variant(String? name, Color fallback) => switch (name) {
    'gold' => gold,
    'silver' => silver,
    'red' => red,
    'blue' => blue,
    'yellow' => yellow,
    'green' => green,
    'brown' => const Color(0xFF6B4A2E),
    _ => fallback,
  };

  static Paint fill(Color c) => Paint()..color = c;

  static Paint stroke(Color c, double width) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// The hand at the bottom right that holds an item (spec 5.6 "Do ruky").
  static void hand(Canvas canvas, Color skin, {Offset at = const Offset(80, 88)}) {
    canvas.drawCircle(at, 6.8, fill(skin));
    canvas.drawCircle(at, 6.8, stroke(ink, 1));
  }

  /// A five-pointed star centred at [c].
  static Path star(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -pi / 2 + i * pi / 5;
      final p = c + Offset(r * cos(a), r * sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  /// Smooth 0 → 1 → 0 over one animation cycle.
  static double pulse(double t) => 0.5 - 0.5 * cos(t * 2 * pi);
}
