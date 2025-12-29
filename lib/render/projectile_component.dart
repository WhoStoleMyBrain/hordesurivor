import 'dart:ui';

import 'package:flame/components.dart';

import '../game/projectile_state.dart';

class ProjectileComponent extends PositionComponent {
  ProjectileComponent({
    required ProjectileState state,
    Color color = const Color(0xFFFF8C3B),
    Image? spriteImage,
  })  : _state = state,
        _spriteImage = spriteImage,
        _paint = Paint()..color = color {
    anchor = Anchor.center;
    if (spriteImage != null) {
      size = Vector2(
        spriteImage.width.toDouble(),
        spriteImage.height.toDouble(),
      );
    } else {
      size = Vector2.all(state.radius * 2);
    }
  }

  final ProjectileState _state;
  final Image? _spriteImage;
  final Paint _paint;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    if (_spriteImage == null) {
      size.setValues(_state.radius * 2, _state.radius * 2);
    }
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
        _spriteImage!.width.toDouble(),
        _spriteImage!.height.toDouble(),
      );
      canvas.drawImageRect(_spriteImage!, srcRect, destRect, _paint);
    } else {
      canvas.drawCircle(Offset.zero, _state.radius, _paint);
    }
  }
}
