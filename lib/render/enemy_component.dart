import 'dart:ui';

import 'package:flame/components.dart';

import '../game/enemy_state.dart';

class EnemyComponent extends PositionComponent {
  EnemyComponent({
    required EnemyState state,
    required double radius,
    Color color = const Color(0xFFE07064),
  })  : _state = state,
        _radius = radius,
        _paint = Paint()..color = color {
    anchor = Anchor.center;
    size = Vector2.all(radius * 2);
  }

  final EnemyState _state;
  final double _radius;
  final Paint _paint;

  @override
  void update(double dt) {
    position.setFrom(_state.position);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset.zero, _radius, _paint);
  }
}
