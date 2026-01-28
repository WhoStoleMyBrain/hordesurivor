import 'dart:ui';

import 'package:flame/components.dart';

import 'render_scale.dart';

class ShopObjectiveComponent extends PositionComponent {
  ShopObjectiveComponent({
    required Image spriteImage,
    required this.radius,
    double renderScale = RenderScale.worldScale,
  }) : _sprite = Sprite(spriteImage),
       _spriteSize = spriteImage.width.toDouble(),
       super(anchor: Anchor.center) {
    scale = Vector2.all(renderScale);
  }

  final double radius;
  final Sprite _sprite;
  final double _spriteSize;
  bool visible = true;

  final Paint _glowPaint = Paint()..color = const Color(0x66F2D38A);
  final Paint _ringPaint = Paint()
    ..color = const Color(0xFFF2D38A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  final Paint _innerPaint = Paint()..color = const Color(0x66322518);

  @override
  void render(Canvas canvas) {
    if (!visible) {
      return;
    }
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius + 8, _glowPaint);
    canvas.drawCircle(Offset.zero, radius + 2, _ringPaint);
    canvas.drawCircle(Offset.zero, radius * 0.55, _innerPaint);
    _sprite.render(
      canvas,
      position: Vector2(-_spriteSize / 2, -_spriteSize / 2),
      size: Vector2.all(_spriteSize),
    );
  }
}
