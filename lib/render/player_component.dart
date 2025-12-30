import 'package:flame/components.dart';

import 'package:flutter/material.dart';

import '../game/player_state.dart';

class PlayerComponent extends PositionComponent {
  PlayerComponent({
    required PlayerState state,
    required double radius,
    Image? spriteImage,
  })
      : _state = state,
        _radius = radius,
        _spriteImage = spriteImage,
        _paint = Paint()..color = const Color(0xFF7BD389) {
    anchor = Anchor.center;
    if (spriteImage != null) {
      size = Vector2(
        spriteImage.width.toDouble(),
        spriteImage.height.toDouble(),
      );
    } else {
      size = Vector2.all(radius * 2);
    }
  }

  final PlayerState _state;
  final double _radius;
  final Image? _spriteImage;
  final Paint _paint;

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
      canvas.drawCircle(Offset.zero, _radius, _paint);
    }
  }

  void syncWithState() {
    position.setFrom(_state.position);
  }
}
