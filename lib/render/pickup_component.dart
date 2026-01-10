import 'dart:ui';

import 'package:flame/components.dart';

import '../game/pickup_state.dart';
import 'render_scale.dart';

class PickupComponent extends PositionComponent {
  PickupComponent({
    required PickupState state,
    Image? spriteImage,
    double renderScale = RenderScale.worldScale,
  }) : _state = state,
       _spriteImage = spriteImage,
       _paint = Paint()..color = const Color(0xFFE9D8A6) {
    anchor = Anchor.center;
    scale = Vector2.all(renderScale);
    if (spriteImage != null) {
      size = Vector2(
        spriteImage.width.toDouble(),
        spriteImage.height.toDouble(),
      );
    } else {
      size = Vector2.all(10);
    }
  }

  final PickupState _state;
  final Image? _spriteImage;
  final Paint _paint;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_spriteImage != null) {
      final destRect = Rect.fromCenter(
        center: Offset.zero,
        width: size.x,
        height: size.y,
      );
      final srcRect = Rect.fromLTWH(
        0,
        0,
        _spriteImage.width.toDouble(),
        _spriteImage.height.toDouble(),
      );
      canvas.drawImageRect(_spriteImage, srcRect, destRect, _paint);
    } else {
      canvas.drawCircle(Offset.zero, size.x * 0.5, _paint);
    }
  }
}
