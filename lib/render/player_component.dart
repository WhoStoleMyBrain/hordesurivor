import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/player_state.dart';

class PlayerComponent extends PositionComponent {
  PlayerComponent({required PlayerState state, required double radius})
      : _state = state,
        _radius = radius,
        _paint = Paint()..color = const Color(0xFF7BD389) {
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
  }

  final PlayerState _state;
  final double _radius;
  final Paint _paint;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _radius, _paint);
  }

  void syncWithState() {
    position.setFrom(_state.position);
  }
}
