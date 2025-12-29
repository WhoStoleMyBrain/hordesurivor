import 'dart:ui';

import 'package:flame/components.dart';

import '../game/projectile_state.dart';

class ProjectileComponent extends PositionComponent {
  ProjectileComponent({
    required ProjectileState state,
    Color color = const Color(0xFFFF8C3B),
  })  : _state = state,
        _paint = Paint()..color = color {
    anchor = Anchor.center;
    size = Vector2.all(state.radius * 2);
  }

  final ProjectileState _state;
  final Paint _paint;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    size.setValues(_state.radius * 2, _state.radius * 2);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _state.radius, _paint);
  }
}
