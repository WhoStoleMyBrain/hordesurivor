import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

import 'render_scale.dart';

class ShopPromptComponent extends PositionComponent {
  ShopPromptComponent({double renderScale = RenderScale.worldScale})
    : super(anchor: Anchor.topCenter) {
    scale = Vector2.all(renderScale);
  }

  bool visible = true;
  static const double _keySize = 14;
  static const double _labelOffset = 12;

  final Paint _keyPaint = Paint()..color = const Color(0xFF2E241A);
  final Paint _keyBorderPaint = Paint()
    ..color = const Color(0xFFF2D38A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  final TextPaint _keyTextPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF8E6C2),
      fontSize: 10,
      fontWeight: FontWeight.w700,
    ),
  );
  final TextPaint _labelPaint = TextPaint(
    style: const TextStyle(
      color: Color(0xFFF8E6C2),
      fontSize: 8,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    ),
  );

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }
    super.render(canvas);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-_keySize / 2, 0, _keySize, _keySize),
      const Radius.circular(3),
    );
    canvas.drawRRect(rect, _keyPaint);
    canvas.drawRRect(rect, _keyBorderPaint);
    _keyTextPaint.render(canvas, 'E', Vector2(-3.2, 1.4));
    _labelPaint.render(canvas, 'SHOP', Vector2(_labelOffset, 3.2));
  }
}
